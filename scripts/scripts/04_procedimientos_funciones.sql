-- ============================================================
-- FUNCIONES Y PROCEDIMIENTOS ALMACENADOS
-- ============================================================

-- Ingresar a la PDB correcta
ALTER SESSION SET CONTAINER = XEPDB1;

-- FUNCIONES

-- 1) Edad en anios a partir de una fecha de nacimiento
CREATE OR REPLACE FUNCTION fn_patient_age(p_birth_date DATE)
RETURN NUMBER
IS
BEGIN
  IF p_birth_date IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, p_birth_date) / 12);
END;
/

-- 2) Edad en anios a partir del id del paciente
CREATE OR REPLACE FUNCTION fn_patient_age_by_id(p_id_patient NUMBER)
RETURN NUMBER
IS
  v_birth DATE;
BEGIN
  SELECT birth_date INTO v_birth
  FROM patient
  WHERE id_patient = p_id_patient;

  RETURN fn_patient_age(v_birth);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;
/

-- 3) Nombre completo del paciente
CREATE OR REPLACE FUNCTION fn_full_patient_name(p_id_patient NUMBER)
RETURN VARCHAR2
IS
  v_res VARCHAR2(200);
BEGIN
  SELECT name || ' ' || paternal_surname || ' ' || maternal_surname
  INTO v_res
  FROM patient
  WHERE id_patient = p_id_patient;

  RETURN v_res;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;
/

-- 4) Cadena jerarquica de ciudad: City, Province, Region, Country
CREATE OR REPLACE FUNCTION fn_city_chain_name(p_id_city NUMBER)
RETURN VARCHAR2
IS
  v_txt VARCHAR2(400);
BEGIN
  SELECT ci.name || ', ' || pr.name || ', ' || re.name || ', ' || co.name
  INTO v_txt
  FROM cities ci
  JOIN provinces pr ON pr.id_province = ci.id_province
  JOIN regions   re ON re.id_region   = pr.id_region
  JOIN countries co ON co.id_country  = re.id_country
  WHERE ci.id_city = p_id_city;

  RETURN v_txt;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;
/

-- 5) IMC (BMI) a partir de talla (m) y peso (kg)
CREATE OR REPLACE FUNCTION fn_bmi(p_height_m NUMBER, p_weight_kg NUMBER)
RETURN NUMBER
IS
BEGIN
  IF p_height_m IS NULL OR p_weight_kg IS NULL OR p_height_m = 0 THEN
    RETURN NULL;
  END IF;
  RETURN ROUND(p_weight_kg / (p_height_m * p_height_m), 2);
END;
/

-- 6) Siguiente numero de ticket para un dia (1..n por dia)
CREATE OR REPLACE FUNCTION fn_next_ticket_number(p_day DATE)
RETURN NUMBER
IS
  v_next NUMBER;
BEGIN
  SELECT NVL(MAX(ticket_number), 0) + 1
  INTO v_next
  FROM ticket
  WHERE TRUNC(created_at) = TRUNC(p_day);

  RETURN v_next;
END;
/

-- 7) Nombre del rol de un usuario
CREATE OR REPLACE FUNCTION fn_user_role_name(p_id_user NUMBER)
RETURN VARCHAR2
IS
  v_role VARCHAR2(50);
BEGIN
  SELECT r.name
  INTO v_role
  FROM users u
  JOIN areas a ON a.id_area = u.id_area
  JOIN roles r ON r.id_role = a.id_role
  WHERE u.id_user = p_id_user;

  RETURN v_role;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;
/


-- PROCEDIMIENTOS

-- 1) Crear ticket: asigna numero por dia e inserta ticket y ticket_area
CREATE OR REPLACE PROCEDURE pr_create_ticket(
  p_id_patient   IN  NUMBER,
  p_id_area      IN  NUMBER,
  o_id_ticket    OUT NUMBER,
  o_ticket_number OUT NUMBER
)
IS
  v_ticket_number NUMBER;
BEGIN
  v_ticket_number := fn_next_ticket_number(SYSDATE);

  INSERT INTO ticket (id_patient, ticket_number, created_at)
  VALUES (p_id_patient, v_ticket_number, CURRENT_TIMESTAMP)
  RETURNING id_ticket INTO o_id_ticket;

  INSERT INTO ticket_area (id_ticket, id_area, started_at, state)
  VALUES (o_id_ticket, p_id_area, CURRENT_TIMESTAMP, 'EN ESPERA');

  o_ticket_number := v_ticket_number;
END;
/

-- 2) Registrar consulta medica
CREATE OR REPLACE PROCEDURE pr_register_consultation(
  p_id_doctor       IN  NUMBER,
  p_id_patient      IN  NUMBER,
  p_id_area         IN  NUMBER,
  p_history_number  IN  VARCHAR2,
  p_anamnesis       IN  CLOB,
  p_eva             IN  NUMBER,
  p_physical_exam   IN  CLOB,
  p_management_plan IN  CLOB,
  p_observations    IN  CLOB,
  o_id_consultation OUT NUMBER
)
IS
BEGIN
  INSERT INTO consultation(
    id_doctor, id_patient, id_area, responsible_name, history_number,
    anamnesis, eva, physical_exam, management_plan, observations,
    created_at, updated_at
  )
  VALUES(
    p_id_doctor, p_id_patient, p_id_area, NULL, p_history_number,
    p_anamnesis, p_eva, p_physical_exam, p_management_plan, p_observations,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
  )
  RETURNING id_consultation INTO o_id_consultation;
END;
/

-- 3) Agregar signos vitales a una consulta
CREATE OR REPLACE PROCEDURE pr_add_vital_signs(
  p_id_consultation      IN  NUMBER,
  p_height               IN  NUMBER,
  p_weight               IN  NUMBER,
  p_abdominal_perimeter  IN  NUMBER,
  p_sys_bp               IN  NUMBER,
  p_dia_bp               IN  NUMBER,
  p_hr                   IN  NUMBER,
  p_spo2                 IN  NUMBER,
  p_temp                 IN  NUMBER,
  p_rr                   IN  NUMBER
)
IS
  v_id_patient NUMBER;
BEGIN
  SELECT id_patient INTO v_id_patient
  FROM consultation
  WHERE id_consultation = p_id_consultation;

  INSERT INTO vital_signs(
    id_patient, id_consultation, height, weight, abdominal_perimeter,
    systolic_blood_pressure, diastolic_blood_pressure, heart_rate,
    oxygen_saturation, temperature, respiratory_rate, registered_at
  )
  VALUES(
    v_id_patient, p_id_consultation, p_height, p_weight, p_abdominal_perimeter,
    p_sys_bp, p_dia_bp, p_hr, p_spo2, p_temp, p_rr, CURRENT_TIMESTAMP
  );
END;
/

-- 4) Agregar diagnostico a una consulta (busca enfermedad por code)
CREATE OR REPLACE PROCEDURE pr_add_diagnosis(
  p_id_consultation IN  NUMBER,
  p_disease_code    IN  VARCHAR2,
  p_type            IN  VARCHAR2,
  o_id_diagnosis    OUT NUMBER
)
IS
  v_id_disease NUMBER;
BEGIN
  SELECT id_disease INTO v_id_disease
  FROM disease
  WHERE code = p_disease_code;

  INSERT INTO diagnosis(id_consultation, id_disease, type)
  VALUES (p_id_consultation, v_id_disease, p_type)
  RETURNING id_diagnosis INTO o_id_diagnosis;
END;
/

-- 5) Agregar medicamento a un diagnostico
CREATE OR REPLACE PROCEDURE pr_add_diagnosis_medicament(
  p_id_diagnosis  IN NUMBER,
  p_id_medicament IN NUMBER,
  p_quantity      IN NUMBER,
  p_instructions  IN VARCHAR2,
  p_duration      IN VARCHAR2
)
IS
BEGIN
  INSERT INTO diagnosis_medicament(
    id_diagnosis, id_medicament, quantity, instructions, duration
  )
  VALUES(
    p_id_diagnosis, p_id_medicament, p_quantity, p_instructions, p_duration
  );
END;
/

-- 6) Crear derivacion desde una consulta a un area
CREATE OR REPLACE PROCEDURE pr_refer_consultation(
  p_id_consultation IN  NUMBER,
  p_id_area         IN  NUMBER,
  o_id_referral     OUT NUMBER
)
IS
BEGIN
  INSERT INTO referral(id_consultation, id_area)
  VALUES (p_id_consultation, p_id_area)
  RETURNING id_referral INTO o_id_referral;
END;
/

-- 7) Mover ticket a otra area (cierra area anterior y crea nueva etapa)
CREATE OR REPLACE PROCEDURE pr_move_ticket_to_area(
  p_id_ticket  IN NUMBER,
  p_to_area    IN NUMBER
)
IS
  v_prev_area NUMBER;
BEGIN
  -- cierra la etapa vigente si existe (sin conocer el area exacta)
  UPDATE ticket_area
  SET finished_at = CURRENT_TIMESTAMP,
      state = 'ATENDIDO'
  WHERE id_ticket = p_id_ticket
    AND finished_at IS NULL;

  -- abre nueva etapa en el area destino
  INSERT INTO ticket_area(id_ticket, id_area, started_at, state)
  VALUES(p_id_ticket, p_to_area, CURRENT_TIMESTAMP, 'EN ESPERA');
END;
/

-- 8) Refrescar la vista materializada de consultas por dia y area
CREATE OR REPLACE PROCEDURE pr_refresh_mv_consultation_daily_area
IS
BEGIN
  DBMS_MVIEW.REFRESH('MV_CONSULTATION_DAILY_AREA','C');
END;
/
