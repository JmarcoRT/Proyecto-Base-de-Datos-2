-- ============================================================
-- INSERCION DE DATOS 
-- ============================================================

-- Ingresar a la PDB correcta
ALTER SESSION SET CONTAINER = XEPDB1;

-- Countries
INSERT INTO countries (iso_code, name)
SELECT 'PE','Peru' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM countries WHERE iso_code='PE');

INSERT INTO countries (iso_code, name)
SELECT 'CL','Chile' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM countries WHERE iso_code='CL');

-- Roles
INSERT INTO roles (name, enabled)
SELECT 'Administrador','1' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name='Administrador');

INSERT INTO roles (name, enabled)
SELECT 'Doctor','1' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name='Doctor');

INSERT INTO roles (name, enabled)
SELECT 'Enfermeria','1' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name='Enfermeria');

INSERT INTO roles (name, enabled)
SELECT 'Recepcion','1' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name='Recepcion');

-- Route (vias)
INSERT INTO route (abreviation, name)
SELECT 'PO','Oral' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM route WHERE abreviation='PO');

INSERT INTO route (abreviation, name)
SELECT 'IM','Intramuscular' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM route WHERE abreviation='IM');

INSERT INTO route (abreviation, name)
SELECT 'IV','Intravenosa' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM route WHERE abreviation='IV');

-- Form (formas farmaceuticas)
INSERT INTO form (name)
SELECT 'Tableta' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM form WHERE name='Tableta');

INSERT INTO form (name)
SELECT 'Capsula' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM form WHERE name='Capsula');

INSERT INTO form (name)
SELECT 'Jarabe' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM form WHERE name='Jarabe');

-- Active ingredients
INSERT INTO active_ingredient (name, enabled)
SELECT 'Paracetamol','1' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM active_ingredient WHERE name='Paracetamol');

INSERT INTO active_ingredient (name, enabled)
SELECT 'Ibuprofeno','1' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM active_ingredient WHERE name='Ibuprofeno');

INSERT INTO active_ingredient (name, enabled)
SELECT 'Amoxicilina','1' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM active_ingredient WHERE name='Amoxicilina');

-- Habits
INSERT INTO habit (name)
SELECT 'Tabaquismo' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM habit WHERE name='Tabaquismo');

INSERT INTO habit (name)
SELECT 'Alcohol' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM habit WHERE name='Alcohol');

INSERT INTO habit (name)
SELECT 'Ejercicio' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM habit WHERE name='Ejercicio');

-- Familiar
INSERT INTO familiar (name)
SELECT 'Madre' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM familiar WHERE name='Madre');

INSERT INTO familiar (name)
SELECT 'Padre' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM familiar WHERE name='Padre');

INSERT INTO familiar (name)
SELECT 'Hermano' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM familiar WHERE name='Hermano');

-- Disease (ejemplos ICD)
INSERT INTO disease (code, name)
SELECT 'I10','Hipertension esencial' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM disease WHERE code='I10');

INSERT INTO disease (code, name)
SELECT 'E11','Diabetes mellitus tipo 2' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM disease WHERE code='E11');

INSERT INTO disease (code, name)
SELECT 'J00','Rinitis aguda' FROM dual
WHERE NOT EXISTS (SELECT 1 FROM disease WHERE code='J00');

-- Historias independientes
INSERT INTO pathological_history (previous_surgeries, allergies, previous_hospitalizations, accidents)
SELECT NULL, NULL, NULL, NULL FROM dual
WHERE NOT EXISTS (SELECT 1 FROM pathological_history);

INSERT INTO general_history (previous_occupations, housing_material, housing_ownership,
  number_rooms, number_inhabitants, floor_type, roof_type,
  domestic_animals, farm_animals, description_animals,
  service_electricity, service_water, service_sewage, shared_bathroom,
  previous_residences, previous_trips)
SELECT NULL,NULL,NULL, 3,4,'Cemento','Concreto','0','0',NULL, '1','1','1','0', NULL,NULL FROM dual
WHERE NOT EXISTS (SELECT 1 FROM general_history);

INSERT INTO gynecological_history (menarche_age, min_catamenial_days, max_catamenial_days,
  last_menstrual_period, gestations, parity, contraceptive_method, sexual_orientation, number_sexual_partners)
SELECT NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL FROM dual
WHERE NOT EXISTS (SELECT 1 FROM gynecological_history);

INSERT INTO patient_history (registered_at, updated_at)
SELECT CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM dual
WHERE NOT EXISTS (SELECT 1 FROM patient_history);

-- Regions (Peru)
INSERT INTO regions (id_country, ubigeo, name)
SELECT c.id_country, '15', 'Lima'
FROM countries c
WHERE c.iso_code='PE'
  AND NOT EXISTS (SELECT 1 FROM regions r WHERE r.name='Lima');

-- Provinces
INSERT INTO provinces (id_region, ubigeo, name)
SELECT r.id_region, '01', 'Lima'
FROM regions r
WHERE r.name='Lima'
  AND NOT EXISTS (SELECT 1 FROM provinces p WHERE p.name='Lima');

-- Cities
INSERT INTO cities (id_province, ubigeo, name)
SELECT p.id_province, '01', 'Lima'
FROM provinces p
WHERE p.name='Lima'
  AND NOT EXISTS (SELECT 1 FROM cities c WHERE c.name='Lima');

-- Addresses
INSERT INTO addresses (id_city, street, reference)
SELECT c.id_city, 'Av Siempre Viva 742', 'Cerca a parque'
FROM cities c
WHERE c.name='Lima'
  AND NOT EXISTS (SELECT 1 FROM addresses a WHERE a.street='Av Siempre Viva 742');

INSERT INTO addresses (id_city, street, reference)
SELECT c.id_city, 'Jr Los Olivos 123', 'Frente a colegio'
FROM cities c
WHERE c.name='Lima'
  AND NOT EXISTS (SELECT 1 FROM addresses a WHERE a.street='Jr Los Olivos 123');

-- Areas
INSERT INTO areas (id_role, name, enabled)
SELECT r.id_role, 'Consulta Externa','1'
FROM roles r
WHERE r.name='Doctor'
  AND NOT EXISTS (SELECT 1 FROM areas a WHERE a.name='Consulta Externa');

INSERT INTO areas (id_role, name, enabled)
SELECT r.id_role, 'Emergencia','1'
FROM roles r
WHERE r.name='Doctor'
  AND NOT EXISTS (SELECT 1 FROM areas a WHERE a.name='Emergencia');

-- Presentation (forma + nombre)
INSERT INTO presentation (id_form, name)
SELECT f.id_form, 'Tableta 500 mg'
FROM form f
WHERE f.name='Tableta'
  AND NOT EXISTS (SELECT 1 FROM presentation p WHERE p.name='Tableta 500 mg');

INSERT INTO presentation (id_form, name)
SELECT f.id_form, 'Jarabe 100 ml'
FROM form f
WHERE f.name='Jarabe'
  AND NOT EXISTS (SELECT 1 FROM presentation p WHERE p.name='Jarabe 100 ml');

-- Users (doctor)
INSERT INTO users (id_area, id_address, username, password, name, paternal_surname, maternal_surname,
  email, phone, enabled, created_at, updated_at)
SELECT a.id_area, ad.id_address, 'drhouse', 'hash_demo', 'Gregory', 'House', 'MD',
  'house@example.com', '999111222', '1', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM areas a
JOIN addresses ad ON ad.street='Jr Los Olivos 123'
WHERE a.name='Consulta Externa'
  AND NOT EXISTS (SELECT 1 FROM users u WHERE u.username='drhouse');

-- Patients
INSERT INTO patient (id_address, id_birth_city, name, paternal_surname, maternal_surname,
  document_type, document_number, birth_date, age, gender, phone, emergency_phone,
  registered_at, updated_at)
SELECT ad.id_address, c.id_city, 'Juan', 'Perez', 'Gomez',
  'DNI','12345678', DATE '1990-05-20', 34, 'M', '999000111','988777666',
  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM addresses ad
JOIN cities c ON c.name='Lima'
WHERE ad.street='Av Siempre Viva 742'
  AND NOT EXISTS (SELECT 1 FROM patient p WHERE p.document_number='12345678');

-- Medicament (ejemplos)
INSERT INTO medicament (id_active_ingredient, id_presentation, id_route, concentration, enabled)
SELECT ai.id_active_ingredient, pr.id_presentation, r.id_route, '500 mg', '1'
FROM active_ingredient ai
JOIN presentation pr ON pr.name='Tableta 500 mg'
JOIN route r ON r.abreviation='PO'
WHERE ai.name='Paracetamol'
  AND NOT EXISTS (
    SELECT 1 FROM medicament m
    WHERE m.id_active_ingredient = ai.id_active_ingredient
      AND m.id_presentation = pr.id_presentation
      AND m.id_route = r.id_route
      AND m.concentration = '500 mg'
  );

INSERT INTO medicament (id_active_ingredient, id_presentation, id_route, concentration, enabled)
SELECT ai.id_active_ingredient, pr.id_presentation, r.id_route, '400 mg', '1'
FROM active_ingredient ai
JOIN presentation pr ON pr.name='Tableta 500 mg'
JOIN route r ON r.abreviation='PO'
WHERE ai.name='Ibuprofeno'
  AND NOT EXISTS (
    SELECT 1 FROM medicament m
    WHERE m.id_active_ingredient = ai.id_active_ingredient
      AND m.id_presentation = pr.id_presentation
      AND m.id_route = r.id_route
      AND m.concentration = '400 mg'
  );

-- Tablas puente de farmacos
INSERT INTO active_ingredient_medicament (id_active_ingredient, id_medicament)
SELECT ai.id_active_ingredient, m.id_medicament
FROM active_ingredient ai
JOIN medicament m ON m.id_active_ingredient = ai.id_active_ingredient
WHERE ai.name IN ('Paracetamol','Ibuprofeno')
  AND NOT EXISTS (
    SELECT 1 FROM active_ingredient_medicament x
    WHERE x.id_active_ingredient = ai.id_active_ingredient
      AND x.id_medicament = m.id_medicament
  );

-- General history habit (marcamos ejercicio)
INSERT INTO general_history_habit (id_general_history, id_habit, has, frequency)
SELECT gh.id_general_history, h.id_habit, '1', '3 veces por semana'
FROM general_history gh, habit h
WHERE h.name='Ejercicio'
  AND NOT EXISTS (
    SELECT 1 FROM general_history_habit x
    WHERE x.id_general_history = gh.id_general_history AND x.id_habit = h.id_habit
  );

-- Pathological history disease (ejemplo DM2)
INSERT INTO pathological_history_disease (id_pathological_history, id_disease, duration)
SELECT ph.id_pathological_history, d.id_disease, '5 anios'
FROM pathological_history ph, disease d
WHERE d.code='E11'
  AND NOT EXISTS (
    SELECT 1 FROM pathological_history_disease x
    WHERE x.id_pathological_history = ph.id_pathological_history AND x.id_disease = d.id_disease
  );

-- RAM: alergia a ibuprofeno
INSERT INTO ram (id_pathological_history, id_active_ingredient)
SELECT ph.id_pathological_history, ai.id_active_ingredient
FROM pathological_history ph, active_ingredient ai
WHERE ai.name='Ibuprofeno'
  AND NOT EXISTS (
    SELECT 1 FROM ram x
    WHERE x.id_pathological_history = ph.id_pathological_history AND x.id_active_ingredient = ai.id_active_ingredient
  );

-- Familiar history (padre vivo)
INSERT INTO familiar_history (id_patient_history, id_familiar, state, observations)
SELECT phis.id_patient_history, f.id_familiar, 'Vivo', 'Hipertension'
FROM patient_history phis, familiar f
WHERE f.name='Padre'
  AND NOT EXISTS (
    SELECT 1 FROM familiar_history x
    WHERE x.id_patient_history = phis.id_patient_history AND x.id_familiar = f.id_familiar
  );

-- Ticket para el paciente
INSERT INTO ticket (id_patient, ticket_number, created_at)
SELECT p.id_patient, 1, CURRENT_TIMESTAMP
FROM patient p
WHERE p.document_number='12345678'
  AND NOT EXISTS (SELECT 1 FROM ticket t WHERE t.ticket_number=1);

-- Flujo del ticket por areas
INSERT INTO ticket_area (id_ticket, id_area, started_at, state)
SELECT t.id_ticket, a.id_area, CURRENT_TIMESTAMP, 'EN ESPERA'
FROM ticket t
JOIN areas a ON a.name='Consulta Externa'
WHERE t.ticket_number=1
  AND NOT EXISTS (
    SELECT 1 FROM ticket_area ta WHERE ta.id_ticket=t.id_ticket AND ta.id_area=a.id_area
  );

-- Consultation del paciente con el doctor
INSERT INTO consultation (id_doctor, id_patient, id_area, responsible_name, history_number,
  anamnesis, eva, physical_exam, management_plan, observations, created_at, updated_at)
SELECT u.id_user, p.id_patient, a.id_area,
  'Dr Responsable', 'HIST-0001',
  'Dolor de cabeza', 5, 'Examen fisico normal', 'Paracetamol y reposo', NULL,
  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM users u
JOIN patient p ON p.document_number='12345678'
JOIN areas a ON a.name='Consulta Externa'
WHERE u.username='drhouse'
  AND NOT EXISTS (
    SELECT 1 FROM consultation c WHERE c.history_number='HIST-0001'
  );

-- Vital signs en esa consulta
INSERT INTO vital_signs (id_patient, id_consultation, height, weight, systolic_blood_pressure,
  diastolic_blood_pressure, heart_rate, oxygen_saturation, temperature, respiratory_rate, registered_at)
SELECT p.id_patient, c.id_consultation, 1.75, 78.5, 120, 80, 76, 98, 36.8, 16, CURRENT_TIMESTAMP
FROM patient p
JOIN consultation c ON c.history_number='HIST-0001'
WHERE p.document_number='12345678'
  AND NOT EXISTS (
    SELECT 1 FROM vital_signs v WHERE v.id_consultation = c.id_consultation
  );

-- Diagnostico principal
INSERT INTO diagnosis (id_consultation, id_disease, type)
SELECT c.id_consultation, d.id_disease, 'PRESUNTIVO'
FROM consultation c
JOIN disease d ON d.code='J00'
WHERE c.history_number='HIST-0001'
  AND NOT EXISTS (
    SELECT 1 FROM diagnosis dx WHERE dx.id_consultation=c.id_consultation AND dx.id_disease=d.id_disease
  );

-- Medicamento indicado para ese diagnostico
INSERT INTO diagnosis_medicament (id_diagnosis, id_medicament, quantity, instructions, duration)
SELECT dx.id_diagnosis, m.id_medicament, 10, '1 tableta cada 8 horas', '3 dias'
FROM diagnosis dx
JOIN disease d ON d.code='J00'
JOIN medicament m ON m.concentration='500 mg'
JOIN active_ingredient ai ON ai.id_active_ingredient = m.id_active_ingredient AND ai.name='Paracetamol'
WHERE dx.id_disease = d.id_disease
  AND NOT EXISTS (
    SELECT 1 FROM diagnosis_medicament dm WHERE dm.id_diagnosis=dx.id_diagnosis AND dm.id_medicament=m.id_medicament
  );

-- Derivacion a otra area (por ejemplo Emergencia)
INSERT INTO referral (id_consultation, id_area)
SELECT c.id_consultation, a.id_area
FROM consultation c
JOIN areas a ON a.name='Emergencia'
WHERE c.history_number='HIST-0001'
  AND NOT EXISTS (
    SELECT 1 FROM referral r WHERE r.id_consultation=c.id_consultation AND r.id_area=a.id_area
  );

-- Diagnostico asociado a la derivacion
INSERT INTO referral_diagnosis (id_referral, id_disease, type, observations)
SELECT r.id_referral, d.id_disease, 'PRESUNTIVO', 'Evaluacion en Emergencia'
FROM referral r
JOIN consultation c ON c.id_consultation = r.id_consultation AND c.history_number='HIST-0001'
JOIN disease d ON d.code='I10'
WHERE NOT EXISTS (
  SELECT 1 FROM referral_diagnosis rd WHERE rd.id_referral=r.id_referral AND rd.id_disease=d.id_disease
);
