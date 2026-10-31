BEGIN;

-- Основные данные
INSERT INTO department (department_id, name) VALUES
    (1, 'Терапевтическое'),
    (2, 'Кардиологическое'),
    (3, 'Педиатрическое');

INSERT INTO specialty (name) VALUES
    ('Терапевт'),
    ('Кардиолог'),
    ('Педиатр');

INSERT INTO job_position (name) VALUES
    ('Врач-терапевт'),
    ('Врач-кардиолог'),
    ('Врач-педиатр');

INSERT INTO service_area (coverage_territory) VALUES
    ('Центральный район'),
    ('Северный район'),
    ('Южный район');

INSERT INTO diagnosis (name, icd10_code) VALUES
    ('Острый бронхит', 'J20.9'),
    ('Гипертоническая болезнь', 'I10'),
    ('Острая респираторная инфекция', 'J06.9'),
    ('Сахарный диабет', 'E11.9');

-- Разрешённые сочетания отделений и специальностей
INSERT INTO department_speciality (department_speciality_id, department_id, specialty_id)
SELECT v.department_speciality_id, d.department_id, s.specialty_id
FROM (VALUES
    (1, 'Терапевтическое', 'Терапевт'),
    (2, 'Кардиологическое', 'Кардиолог'),
    (3, 'Педиатрическое', 'Педиатр')
) AS v(department_speciality_id, department_name, specialty_name)
JOIN department d ON d.name = v.department_name
JOIN specialty s ON s.name = v.specialty_name;

-- Пациенты. sex_id: 1 — мужской, 2 — женский
INSERT INTO patient (
    first_name, last_name, middle_name, birth_date,
    sex_id, registration_address, contact_phone, area_id
)
SELECT
    v.first_name, v.last_name, v.middle_name, v.birth_date,
    v.sex_id, v.address, v.phone, a.area_id
FROM (VALUES
    ('Анна', 'Иванова', 'Сергеевна', DATE '1990-03-12',
     2, 'Центральный район, дом 10', '+375291112233', 'Центральный район'),
    ('Иван', 'Петров', 'Алексеевич', DATE '1985-07-24',
     1, 'Северный район, дом 5', '+375292223344', 'Северный район'),
    ('Мария', 'Сидорова', 'Олеговна', DATE '2001-11-02',
     2, 'Южный район, дом 18', '+375293334455', 'Южный район'),
    ('Павел', 'Орлов', 'Дмитриевич', DATE '1978-06-15',
     1, 'Центральный район, дом 25', '+375294445566', 'Центральный район')
) AS v(first_name, last_name, middle_name, birth_date,
       sex_id, address, phone, area_name)
JOIN service_area a ON a.coverage_territory = v.area_name;

-- Сотрудники. ID должности и пары отделение–специальность
-- выбираются по их названиям.
INSERT INTO medical_staff (
    first_name, last_name, middle_name, career_start_year,
    position_id, department_speciality_id
)
SELECT
    v.first_name, v.last_name, v.middle_name, v.career_start_year,
    jp.position_id, ds.department_speciality_id
FROM (VALUES
    ('Ольга', 'Смирнова', 'Игоревна', 2012,
     'Врач-терапевт', 'Терапевтическое', 'Терапевт'),
    ('Алексей', 'Козлов', 'Петрович', 2018,
     'Врач-кардиолог', 'Кардиологическое', 'Кардиолог'),
    ('Марина', 'Волкова', 'Андреевна', 2015,
     'Врач-педиатр', 'Педиатрическое', 'Педиатр'),
    ('Иван', 'Соколов', 'Николаевич', 2020,
     'Врач-терапевт', 'Терапевтическое', 'Терапевт')
) AS v(first_name, last_name, middle_name, career_start_year,
       position_name, department_name, specialty_name)
JOIN job_position jp ON jp.name = v.position_name
JOIN department d ON d.name = v.department_name
JOIN specialty s ON s.name = v.specialty_name
JOIN department_speciality ds
    ON ds.department_id = d.department_id
   AND ds.specialty_id = s.specialty_id;

-- Медицинские карты. status_id 1 — активная, 2 — в архиве.
INSERT INTO medical_card (status_id, patient_id)
SELECT v.status_id, p.patient_id
FROM (VALUES
    ('Анна', 'Иванова', 1),
    ('Иван', 'Петров', 1),
    ('Мария', 'Сидорова', 1),
    ('Павел', 'Орлов', 2)
) AS v(first_name, last_name, status_id)
JOIN patient p
    ON p.first_name = v.first_name
   AND p.last_name = v.last_name;

-- Медицинские услуги. status_id 1 — активная.
INSERT INTO medical_service (
    name, description, price, status_id, department_id
)
SELECT v.service_name, v.description, v.price, 1, d.department_id
FROM (VALUES
    ('Профосмотр', 'Профилактический осмотр', 50.00, 'Терапевтическое'),
    ('ЭКГ', 'Электрокардиограмма', 35.00, 'Кардиологическое'),
    ('Приём педиатра', 'Осмотр ребёнка', 45.00, 'Педиатрическое'),
    ('Анализ крови', 'Общий анализ крови', 20.00, 'Терапевтическое')
) AS v(service_name, description, price, department_name)
JOIN department d ON d.name = v.department_name;

-- Обращения: каждому пациенту назначен сотрудник.
INSERT INTO appeal (staff_id, medical_card_id)
SELECT ms.staff_id, mc.medical_card_id
FROM (VALUES
    ('Смирнова', 'Иванова'),
    ('Козлов', 'Петров'),
    ('Волкова', 'Сидорова'),
    ('Соколов', 'Орлов')
) AS v(staff_last_name, patient_last_name)
JOIN medical_staff ms ON ms.last_name = v.staff_last_name
JOIN patient p ON p.last_name = v.patient_last_name
JOIN medical_card mc ON mc.patient_id = p.patient_id;

-- Приёмы. Статусы уже заполнены в справочнике.
INSERT INTO appointment (appointment_at, status_id, appeal_id)
SELECT v.appointment_at, v.status_id, a.appeal_id
FROM (VALUES
    (TIMESTAMPTZ '2026-10-27 09:00:00+03', 1, 'Иванова'),
    (TIMESTAMPTZ '2026-10-20 10:00:00+03', 2, 'Петров'),
    (TIMESTAMPTZ '2026-10-28 11:30:00+03', 1, 'Сидорова'),
    (TIMESTAMPTZ '2026-10-19 12:00:00+03', 3, 'Орлов')
) AS v(appointment_at, status_id, patient_last_name)
JOIN patient p ON p.last_name = v.patient_last_name
JOIN medical_card mc ON mc.patient_id = p.patient_id
JOIN appeal a ON a.medical_card_id = mc.medical_card_id;

-- Визиты
INSERT INTO visit (visited_at, visit_type_id, complaint, appeal_id)
SELECT v.visited_at, vt.visit_type_id, v.complaint, a.appeal_id
FROM (VALUES
    (TIMESTAMPTZ '2026-10-20 09:05:00+03',
     'Плановый приём', 'Кашель', 'Иванова'),
    (TIMESTAMPTZ '2026-10-20 10:05:00+03',
     'Неотложная помощь', 'Головная боль', 'Петров'),
    (TIMESTAMPTZ '2026-10-19 11:05:00+03',
     'Диспансеризация', 'Плановый осмотр', 'Сидорова'),
    (TIMESTAMPTZ '2026-10-18 12:05:00+03',
     'Плановый приём', 'Повышенное давление', 'Орлов')
) AS v(visited_at, visit_type_name, complaint, patient_last_name)
JOIN visit_type vt ON vt.name = v.visit_type_name
JOIN patient p ON p.last_name = v.patient_last_name
JOIN medical_card mc ON mc.patient_id = p.patient_id
JOIN appeal a ON a.medical_card_id = mc.medical_card_id;

-- Заказы услуг
INSERT INTO service_order (order_type_id, ordered_at, appeal_id, service_id)
SELECT ot.order_type_id, v.ordered_at, a.appeal_id, ms.service_id
FROM (VALUES
    ('Лекарственное', TIMESTAMPTZ '2026-10-20 09:10:00+03',
     'Иванова', 'Профосмотр'),
    ('Диагностическое', TIMESTAMPTZ '2026-10-20 10:10:00+03',
     'Петров', 'ЭКГ'),
    ('Консультативное', TIMESTAMPTZ '2026-10-19 11:10:00+03',
     'Сидорова', 'Приём педиатра'),
    ('Процедурное', TIMESTAMPTZ '2026-10-18 12:10:00+03',
     'Орлов', 'Анализ крови')
) AS v(order_type_name, ordered_at, patient_last_name, service_name)
JOIN order_type ot ON ot.name = v.order_type_name
JOIN medical_service ms ON ms.name = v.service_name
JOIN patient p ON p.last_name = v.patient_last_name
JOIN medical_card mc ON mc.patient_id = p.patient_id
JOIN appeal a ON a.medical_card_id = mc.medical_card_id;

-- Составной ключ (visit_id, diagnosis_id) позволяет добавить несколько диагнозов одному визиту.
-- У Ивановой указаны основной и дополнительный диагнозы.
INSERT INTO visit_diagnosis (visit_id, diagnosis_id, is_primary)
SELECT v.visit_id, d.diagnosis_id, x.is_primary
FROM (VALUES
    ('Иванова', 'J20.9', TRUE),
    ('Иванова', 'J06.9', FALSE),
    ('Петров', 'I10', TRUE),
    ('Сидорова', 'J06.9', TRUE),
    ('Орлов', 'E11.9', TRUE)
) AS x(patient_last_name, icd10_code, is_primary)
JOIN patient p ON p.last_name = x.patient_last_name
JOIN medical_card mc ON mc.patient_id = p.patient_id
JOIN appeal a ON a.medical_card_id = mc.medical_card_id
JOIN visit v ON v.appeal_id = a.appeal_id
JOIN diagnosis d ON d.icd10_code = x.icd10_code;

-- Перемещения медицинских карт
INSERT INTO movement_log (destination, origin, moved_at, medical_card_id)
SELECT v.destination, v.origin, v.moved_at, mc.medical_card_id
FROM (VALUES
    ('Архив', 'Регистратура', TIMESTAMPTZ '2026-10-20 09:15:00+03', 'Иванова'),
    ('Кабинет 2', 'Регистратура', TIMESTAMPTZ '2026-10-20 10:15:00+03', 'Петров'),
    ('Кабинет 3', 'Регистратура', TIMESTAMPTZ '2026-10-19 11:15:00+03', 'Сидорова'),
    ('Архив', 'Кабинет 1', TIMESTAMPTZ '2026-10-18 12:15:00+03', 'Орлов')
) AS v(destination, origin, moved_at, patient_last_name)
JOIN patient p ON p.last_name = v.patient_last_name
JOIN medical_card mc ON mc.patient_id = p.patient_id;

-- Расписание сотрудников
INSERT INTO Work_schedule (
    staff_id, Day_of_week, Start_hours, End_hours,
    FreeTime_start, FreeTime_end
)
SELECT ms.staff_id, v.day_of_week, v.start_hours, v.end_hours,
       v.free_time_start, v.free_time_end
FROM (VALUES
    ('Смирнова', 1, TIME '09:00', TIME '17:00', TIME '13:00', TIME '14:00'),
    ('Козлов', 2, TIME '08:00', TIME '16:00', TIME '12:00', TIME '13:00'),
    ('Волкова', 3, TIME '09:00', TIME '17:00', TIME '13:00', TIME '14:00'),
    ('Соколов', 4, TIME '08:00', TIME '16:00', TIME '12:00', TIME '13:00')
) AS v(last_name, day_of_week, start_hours, end_hours,
       free_time_start, free_time_end)
JOIN medical_staff ms ON ms.last_name = v.last_name;

COMMIT;