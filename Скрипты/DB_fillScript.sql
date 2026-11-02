BEGIN;

-- Основные таблицы: по 10 разных значений.
INSERT INTO department (department_id, name) VALUES
    (1, 'Терапевтическое'),
    (2, 'Кардиологическое'),
    (3, 'Педиатрическое'),
    (4, 'Неврологическое'),
    (5, 'Хирургическое'),
    (6, 'Офтальмологическое'),
    (7, 'ЛОР-отделение'),
    (8, 'Эндокринологическое'),
    (9, 'Дерматологическое'),
    (10, 'Гинекологическое');

INSERT INTO specialty (name) VALUES
    ('Терапевт'), ('Кардиолог'), ('Педиатр'), ('Невролог'), ('Хирург'),
    ('Офтальмолог'), ('Оториноларинголог'), ('Эндокринолог'), ('Дерматолог'), ('Гинеколог');

INSERT INTO job_position (name) VALUES
    ('Врач-терапевт'), ('Врач-кардиолог'), ('Врач-педиатр'), ('Врач-невролог'),
    ('Врач-хирург'), ('Врач-офтальмолог'), ('Врач-ЛОР'), ('Врач-эндокринолог'),
    ('Врач-дерматолог'), ('Врач-гинеколог');

INSERT INTO service_area (coverage_territory) VALUES
    ('Центральный район'), ('Северный район'), ('Южный район'), ('Восточный район'),
    ('Западный район'), ('Заводской район'), ('Лесной район'), ('Речной район'),
    ('Солнечный район'), ('Парковый район');

INSERT INTO diagnosis (name, icd10_code) VALUES
    ('Острый бронхит', 'J20.9'),
    ('Гипертоническая болезнь', 'I10'),
    ('Острая респираторная инфекция', 'J06.9'),
    ('Сахарный диабет 2 типа', 'E11.9'),
    ('Гастрит неуточнённый', 'K29.7'),
    ('Боль в пояснице', 'M54.5'),
    ('Бронхиальная астма', 'J45.9'),
    ('Нарушение липидного обмена', 'E78.5'),
    ('Инфекция мочевых путей', 'N39.0'),
    ('Близорукость', 'H52.1');

-- Разрешённые пары «отделение — специальность».
INSERT INTO department_speciality (department_speciality_id, department_id, specialty_id)
SELECT v.pair_id, d.department_id, s.specialty_id
FROM (VALUES
    (1, 'Терапевтическое', 'Терапевт'),
    (2, 'Кардиологическое', 'Кардиолог'),
    (3, 'Педиатрическое', 'Педиатр'),
    (4, 'Неврологическое', 'Невролог'),
    (5, 'Хирургическое', 'Хирург'),
    (6, 'Офтальмологическое', 'Офтальмолог'),
    (7, 'ЛОР-отделение', 'Оториноларинголог'),
    (8, 'Эндокринологическое', 'Эндокринолог'),
    (9, 'Дерматологическое', 'Дерматолог'),
    (10, 'Гинекологическое', 'Гинеколог')
) AS v(pair_id, department_name, specialty_name)
JOIN department AS d ON d.name = v.department_name
JOIN specialty AS s ON s.name = v.specialty_name;

-- Пациенты. sex_id: 1 — мужской, 2 — женский.
INSERT INTO patient (
    first_name, last_name, middle_name, birth_date,
    sex_id, registration_address, contact_phone, area_id
)
SELECT v.first_name, v.last_name, v.middle_name, v.birth_date,
       v.sex_id, v.address, v.phone, a.area_id
FROM (VALUES
    ('Анна', 'Иванова', 'Сергеевна', DATE '1990-03-12', 2, 'Центральный район, дом 10', '+375291112233', 'Центральный район'),
    ('Иван', 'Петров', 'Алексеевич', DATE '1985-07-24', 1, 'Северный район, дом 5', '+375292223344', 'Северный район'),
    ('Мария', 'Сидорова', 'Олеговна', DATE '2001-11-02', 2, 'Южный район, дом 18', '+375293334455', 'Южный район'),
    ('Павел', 'Орлов', 'Дмитриевич', DATE '1978-06-15', 1, 'Центральный район, дом 25', '+375294445566', 'Центральный район'),
    ('Елена', 'Кузнецова', 'Ивановна', DATE '1995-04-08', 2, 'Восточный район, дом 7', '+375295556677', 'Восточный район'),
    ('Дмитрий', 'Смирнов', 'Олегович', DATE '1988-09-19', 1, 'Западный район, дом 12', '+375296667788', 'Западный район'),
    ('Ольга', 'Попова', 'Андреевна', DATE '1972-01-30', 2, 'Заводской район, дом 3', '+375297778899', 'Заводской район'),
    ('Сергей', 'Васильев', 'Павлович', DATE '2003-06-11', 1, 'Лесной район, дом 21', '+375298889900', 'Лесной район'),
    ('Наталья', 'Федорова', 'Евгеньевна', DATE '1969-12-05', 2, 'Речной район, дом 16', '+375299990011', 'Речной район'),
    ('Артём', 'Михайлов', 'Романович', DATE '1999-08-22', 1, 'Солнечный район, дом 9', '+375291010101', 'Солнечный район')
) AS v(first_name, last_name, middle_name, birth_date, sex_id, address, phone, area_name)
JOIN service_area AS a ON a.coverage_territory = v.area_name;

-- Сотрудники. Должность и допустимая пара отделение–специальность выбираются по названиям.
INSERT INTO medical_staff (
    first_name, last_name, middle_name, career_start_year,
    position_id, department_speciality_id
)
SELECT v.first_name, v.last_name, v.middle_name, v.career_start_year,
       jp.position_id, ds.department_speciality_id
FROM (VALUES
    ('Ольга', 'Смирнова', 'Игоревна', 2012, 'Врач-терапевт', 'Терапевтическое', 'Терапевт'),
    ('Алексей', 'Козлов', 'Петрович', 2018, 'Врач-кардиолог', 'Кардиологическое', 'Кардиолог'),
    ('Марина', 'Волкова', 'Андреевна', 2015, 'Врач-педиатр', 'Педиатрическое', 'Педиатр'),
    ('Иван', 'Соколов', 'Николаевич', 2020, 'Врач-терапевт', 'Терапевтическое', 'Терапевт'),
    ('Екатерина', 'Морозова', 'Викторовна', 2011, 'Врач-невролог', 'Неврологическое', 'Невролог'),
    ('Денис', 'Новиков', 'Ильич', 2016, 'Врач-хирург', 'Хирургическое', 'Хирург'),
    ('Татьяна', 'Павлова', 'Олеговна', 2009, 'Врач-офтальмолог', 'Офтальмологическое', 'Офтальмолог'),
    ('Андрей', 'Семёнов', 'Борисович', 2014, 'Врач-ЛОР', 'ЛОР-отделение', 'Оториноларинголог'),
    ('Ирина', 'Голубева', 'Сергеевна', 2017, 'Врач-эндокринолог', 'Эндокринологическое', 'Эндокринолог'),
    ('Михаил', 'Виноградов', 'Алексеевич', 2013, 'Врач-дерматолог', 'Дерматологическое', 'Дерматолог')
) AS v(first_name, last_name, middle_name, career_start_year,
       position_name, department_name, specialty_name)
JOIN job_position AS jp ON jp.name = v.position_name
JOIN department AS d ON d.name = v.department_name
JOIN specialty AS s ON s.name = v.specialty_name
JOIN department_speciality AS ds
  ON ds.department_id = d.department_id AND ds.specialty_id = s.specialty_id;

-- Медицинские карты. status_id 1 — активная, 2 — в архиве.
INSERT INTO medical_card (status_id, patient_id)
SELECT v.status_id, p.patient_id
FROM (VALUES
    ('Иванова', 1), ('Петров', 1), ('Сидорова', 1), ('Орлов', 2),
    ('Кузнецова', 1), ('Смирнов', 1), ('Попова', 1), ('Васильев', 1),
    ('Федорова', 2), ('Михайлов', 1)
) AS v(patient_last_name, status_id)
JOIN patient AS p ON p.last_name = v.patient_last_name;

-- Медицинские услуги: десять разных услуг в соответствующих отделениях.
INSERT INTO medical_service (name, description, price, status_id, department_id)
SELECT v.service_name, v.description, v.price, v.status_id, d.department_id
FROM (VALUES
    ('Профосмотр', 'Профилактический осмотр', 50.00, 1, 'Терапевтическое'),
    ('ЭКГ', 'Электрокардиограмма', 35.00, 1, 'Кардиологическое'),
    ('Приём педиатра', 'Осмотр ребёнка', 45.00, 1, 'Педиатрическое'),
    ('Анализ крови', 'Общий анализ крови', 20.00, 1, 'Терапевтическое'),
    ('УЗИ', 'Ультразвуковое исследование', 60.00, 1, 'Гинекологическое'),
    ('Рентген', 'Рентгенография', 55.00, 1, 'Хирургическое'),
    ('Осмотр глаз', 'Проверка остроты зрения', 30.00, 1, 'Офтальмологическое'),
    ('Приём ЛОР-врача', 'Осмотр уха, горла и носа', 40.00, 1, 'ЛОР-отделение'),
    ('Спирометрия', 'Исследование функции дыхания', 42.00, 1, 'Терапевтическое'),
    ('Холтер', 'Суточное мониторирование ЭКГ', 75.00, 1, 'Кардиологическое')
) AS v(service_name, description, price, status_id, department_name)
JOIN department AS d ON d.name = v.department_name;

-- Обращения: каждому пациенту назначен сотрудник.
INSERT INTO appeal (staff_id, medical_card_id)
SELECT ms.staff_id, mc.medical_card_id
FROM (VALUES
    ('Смирнова', 'Иванова'), ('Козлов', 'Петров'), ('Волкова', 'Сидорова'),
    ('Соколов', 'Орлов'), ('Морозова', 'Кузнецова'), ('Новиков', 'Смирнов'),
    ('Павлова', 'Попова'), ('Семёнов', 'Васильев'), ('Голубева', 'Федорова'),
    ('Виноградов', 'Михайлов')
) AS v(staff_last_name, patient_last_name)
JOIN medical_staff AS ms ON ms.last_name = v.staff_last_name
JOIN patient AS p ON p.last_name = v.patient_last_name
JOIN medical_card AS mc ON mc.patient_id = p.patient_id;

-- Приёмы. Используются существующие статусы 1–3 из appointment_status.
INSERT INTO appointment (appointment_at, status_id, appeal_id)
SELECT v.appointment_at, v.status_id, a.appeal_id
FROM (VALUES
    (TIMESTAMPTZ '2026-10-27 09:00:00+03', 1, 'Иванова'),
    (TIMESTAMPTZ '2026-10-20 10:00:00+03', 2, 'Петров'),
    (TIMESTAMPTZ '2026-10-28 11:30:00+03', 1, 'Сидорова'),
    (TIMESTAMPTZ '2026-10-19 12:00:00+03', 3, 'Орлов'),
    (TIMESTAMPTZ '2026-10-21 09:30:00+03', 1, 'Кузнецова'),
    (TIMESTAMPTZ '2026-10-22 10:15:00+03', 2, 'Смирнов'),
    (TIMESTAMPTZ '2026-10-23 11:00:00+03', 1, 'Попова'),
    (TIMESTAMPTZ '2026-10-24 12:20:00+03', 1, 'Васильев'),
    (TIMESTAMPTZ '2026-10-25 13:00:00+03', 2, 'Федорова'),
    (TIMESTAMPTZ '2026-10-26 14:10:00+03', 1, 'Михайлов')
) AS v(appointment_at, status_id, patient_last_name)
JOIN patient AS p ON p.last_name = v.patient_last_name
JOIN medical_card AS mc ON mc.patient_id = p.patient_id
JOIN appeal AS a ON a.medical_card_id = mc.medical_card_id;

-- Визиты: десять разных жалоб и типов приёма.
INSERT INTO visit (visited_at, visit_type_id, complaint, appeal_id)
SELECT v.visited_at, vt.visit_type_id, v.complaint, a.appeal_id
FROM (VALUES
    (TIMESTAMPTZ '2026-10-20 09:05:00+03', 'Плановый приём', 'Кашель', 'Иванова'),
    (TIMESTAMPTZ '2026-10-20 10:05:00+03', 'Неотложная помощь', 'Головная боль', 'Петров'),
    (TIMESTAMPTZ '2026-10-19 11:05:00+03', 'Диспансеризация', 'Плановый осмотр', 'Сидорова'),
    (TIMESTAMPTZ '2026-10-18 12:05:00+03', 'Плановый приём', 'Повышенное давление', 'Орлов'),
    (TIMESTAMPTZ '2026-10-21 09:35:00+03', 'Вакцинация', 'Профилактическая прививка', 'Кузнецова'),
    (TIMESTAMPTZ '2026-10-22 10:20:00+03', 'Плановый приём', 'Боль в пояснице', 'Смирнов'),
    (TIMESTAMPTZ '2026-10-23 11:05:00+03', 'Неотложная помощь', 'Сыпь на коже', 'Попова'),
    (TIMESTAMPTZ '2026-10-24 12:25:00+03', 'Диспансеризация', 'Проверка зрения', 'Васильев'),
    (TIMESTAMPTZ '2026-10-25 13:05:00+03', 'Плановый приём', 'Повышенная утомляемость', 'Федорова'),
    (TIMESTAMPTZ '2026-10-26 14:15:00+03', 'Вакцинация', 'Сезонная вакцинация', 'Михайлов')
) AS v(visited_at, visit_type_name, complaint, patient_last_name)
JOIN visit_type AS vt ON vt.name = v.visit_type_name
JOIN patient AS p ON p.last_name = v.patient_last_name
JOIN medical_card AS mc ON mc.patient_id = p.patient_id
JOIN appeal AS a ON a.medical_card_id = mc.medical_card_id;

-- Заказы услуг: десять заказов, используют четыре существующих типа заказа.
INSERT INTO service_order (order_type_id, ordered_at, appeal_id, service_id)
SELECT ot.order_type_id, v.ordered_at, a.appeal_id, ms.service_id
FROM (VALUES
    ('Лекарственное', TIMESTAMPTZ '2026-10-20 09:10:00+03', 'Иванова', 'Профосмотр'),
    ('Диагностическое', TIMESTAMPTZ '2026-10-20 10:10:00+03', 'Петров', 'ЭКГ'),
    ('Консультативное', TIMESTAMPTZ '2026-10-19 11:10:00+03', 'Сидорова', 'Приём педиатра'),
    ('Процедурное', TIMESTAMPTZ '2026-10-18 12:10:00+03', 'Орлов', 'Анализ крови'),
    ('Диагностическое', TIMESTAMPTZ '2026-10-21 09:40:00+03', 'Кузнецова', 'УЗИ'),
    ('Процедурное', TIMESTAMPTZ '2026-10-22 10:25:00+03', 'Смирнов', 'Рентген'),
    ('Консультативное', TIMESTAMPTZ '2026-10-23 11:10:00+03', 'Попова', 'Осмотр глаз'),
    ('Лекарственное', TIMESTAMPTZ '2026-10-24 12:30:00+03', 'Васильев', 'Приём ЛОР-врача'),
    ('Диагностическое', TIMESTAMPTZ '2026-10-25 13:10:00+03', 'Федорова', 'Спирометрия'),
    ('Процедурное', TIMESTAMPTZ '2026-10-26 14:20:00+03', 'Михайлов', 'Холтер')
) AS v(order_type_name, ordered_at, patient_last_name, service_name)
JOIN order_type AS ot ON ot.name = v.order_type_name
JOIN medical_service AS ms ON ms.name = v.service_name
JOIN patient AS p ON p.last_name = v.patient_last_name
JOIN medical_card AS mc ON mc.patient_id = p.patient_id
JOIN appeal AS a ON a.medical_card_id = mc.medical_card_id;

-- Диагнозы визитов. Составной ключ не допускает повтор одного диагноза у визита.
-- У Ивановой и Кузнецовой по два диагноза; всего 12 связей.
INSERT INTO visit_diagnosis (visit_id, diagnosis_id, is_primary)
SELECT v.visit_id, d.diagnosis_id, x.is_primary
FROM (VALUES
    ('Иванова', 'J20.9', TRUE), ('Иванова', 'J06.9', FALSE),
    ('Петров', 'I10', TRUE), ('Сидорова', 'J06.9', TRUE),
    ('Орлов', 'E11.9', TRUE),
    ('Кузнецова', 'J06.9', TRUE), ('Кузнецова', 'J20.9', FALSE),
    ('Смирнов', 'M54.5', TRUE), ('Попова', 'K29.7', TRUE),
    ('Васильев', 'H52.1', TRUE), ('Федорова', 'E78.5', TRUE),
    ('Михайлов', 'N39.0', TRUE)
) AS x(patient_last_name, icd10_code, is_primary)
JOIN patient AS p ON p.last_name = x.patient_last_name
JOIN medical_card AS mc ON mc.patient_id = p.patient_id
JOIN appeal AS a ON a.medical_card_id = mc.medical_card_id
JOIN visit AS v ON v.appeal_id = a.appeal_id
JOIN diagnosis AS d ON d.icd10_code = x.icd10_code;

-- Перемещения медицинских карт: десять записей.
INSERT INTO movement_log (destination, origin, moved_at, medical_card_id)
SELECT v.destination, v.origin, v.moved_at, mc.medical_card_id
FROM (VALUES
    ('Кабинет 1', 'Регистратура', TIMESTAMPTZ '2026-10-20 09:15:00+03', 'Иванова'),
    ('Кабинет 2', 'Регистратура', TIMESTAMPTZ '2026-10-20 10:15:00+03', 'Петров'),
    ('Кабинет 3', 'Регистратура', TIMESTAMPTZ '2026-10-19 11:15:00+03', 'Сидорова'),
    ('Архив', 'Кабинет 1', TIMESTAMPTZ '2026-10-18 12:15:00+03', 'Орлов'),
    ('Кабинет 4', 'Регистратура', TIMESTAMPTZ '2026-10-21 09:45:00+03', 'Кузнецова'),
    ('Кабинет 5', 'Регистратура', TIMESTAMPTZ '2026-10-22 10:30:00+03', 'Смирнов'),
    ('Кабинет 6', 'Регистратура', TIMESTAMPTZ '2026-10-23 11:15:00+03', 'Попова'),
    ('Кабинет 7', 'Регистратура', TIMESTAMPTZ '2026-10-24 12:35:00+03', 'Васильев'),
    ('Кабинет 8', 'Регистратура', TIMESTAMPTZ '2026-10-25 13:15:00+03', 'Федорова'),
    ('Кабинет 9', 'Регистратура', TIMESTAMPTZ '2026-10-26 14:25:00+03', 'Михайлов')
) AS v(destination, origin, moved_at, patient_last_name)
JOIN patient AS p ON p.last_name = v.patient_last_name
JOIN medical_card AS mc ON mc.patient_id = p.patient_id;

-- Расписание: по одной записи на каждого из десяти сотрудников.
INSERT INTO work_schedule (
    staff_id, day_of_week, start_hours, end_hours, freetime_start, freetime_end
)
SELECT ms.staff_id, v.day_of_week, v.start_hours, v.end_hours,
       v.free_time_start, v.free_time_end
FROM (VALUES
    ('Смирнова', 1, TIME '09:00', TIME '17:00', TIME '13:00', TIME '14:00'),
    ('Козлов', 2, TIME '08:00', TIME '16:00', TIME '12:00', TIME '13:00'),
    ('Волкова', 3, TIME '09:00', TIME '17:00', TIME '13:00', TIME '14:00'),
    ('Соколов', 4, TIME '08:00', TIME '16:00', TIME '12:00', TIME '13:00'),
    ('Морозова', 5, TIME '09:00', TIME '17:00', TIME '13:00', TIME '14:00'),
    ('Новиков', 1, TIME '08:00', TIME '16:00', TIME '12:00', TIME '13:00'),
    ('Павлова', 2, TIME '09:00', TIME '17:00', TIME '13:00', TIME '14:00'),
    ('Семёнов', 3, TIME '08:00', TIME '16:00', TIME '12:00', TIME '13:00'),
    ('Голубева', 4, TIME '09:00', TIME '17:00', TIME '13:00', TIME '14:00'),
    ('Виноградов', 5, TIME '08:00', TIME '16:00', TIME '12:00', TIME '13:00')
) AS v(last_name, day_of_week, start_hours, end_hours, free_time_start, free_time_end)
JOIN medical_staff AS ms ON ms.last_name = v.last_name;


-- Массовое учебное наполнение. Итоговые объёмы неровные, меньше 1000.
-- Генерация рассчитана на пустые таблицы данных и запускается один раз.

-- Пациенты: 10 основных + 640 с разными датами рождения, адресами и телефонами = 650.
INSERT INTO patient (first_name,last_name,middle_name,birth_date,sex_id,registration_address,contact_phone,area_id)
SELECT CASE WHEN g.n%2=1
         THEN (ARRAY['Александр','Дмитрий','Максим','Артём','Илья','Кирилл','Михаил','Егор','Роман','Никита','Денис','Павел','Андрей','Сергей','Владимир','Тимур','Матвей','Глеб','Олег','Фёдор']::text[])[(((g.n-11)/2)%20)+1]
         ELSE (ARRAY['Анна','Мария','Елена','Ольга','Анастасия','Екатерина','Дарья','Полина','Виктория','Алина','Ксения','София','Ирина','Наталья','Татьяна','Юлия','Валерия','Вероника','Людмила','Диана']::text[])[(((g.n-11)/2)%20)+1]
       END,
       CASE WHEN g.n%2=1
         THEN (ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Васильев','Морозов','Новиков','Фёдоров']::text[])[(((g.n-11)/20)%10)+1]
         ELSE (ARRAY['Иванова','Петрова','Сидорова','Смирнова','Кузнецова','Попова','Васильева','Морозова','Новикова','Фёдорова']::text[])[(((g.n-11)/20)%10)+1]
       END,
       CASE WHEN g.n%2=1
         THEN (ARRAY['Александрович','Дмитриевич','Сергеевич','Иванович','Алексеевич','Андреевич','Михайлович','Олегович','Павлович','Романович']::text[])[((g.n%10)+1)]
         ELSE (ARRAY['Александровна','Дмитриевна','Сергеевна','Ивановна','Алексеевна','Андреевна','Михайловна','Олеговна','Павловна','Романовна']::text[])[((g.n%10)+1)]
       END,
       DATE '1950-01-01' + ((g.n*47)%20000),
       CASE WHEN g.n%2=1 THEN 1 ELSE 2 END,
       a.coverage_territory || ', дом ' || (1+((g.n*17)%120))::text,
       '+37529' || lpad(g.n::text,7,'0'), a.area_id
FROM generate_series(11,650) AS g(n)
JOIN service_area a ON a.area_id=1+((g.n-11)%10);

-- Сотрудники: 10 основных + 230 = 240.
INSERT INTO medical_staff (first_name,last_name,middle_name,career_start_year,position_id,department_speciality_id)
SELECT (ARRAY['Александр','Дмитрий','Максим','Артём','Илья','Кирилл','Михаил','Егор','Роман','Никита','Денис','Павел','Андрей','Сергей','Владимир','Тимур','Матвей','Глеб','Олег','Фёдор','Анна','Мария','Елена']::text[])[(((g.n-11)/10)%23)+1],
       (ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Васильев','Морозов','Новиков','Фёдоров']::text[])[((g.n-11)%10)+1],
       (ARRAY['Александрович','Дмитриевич','Сергеевич','Иванович','Алексеевич','Андреевич','Михайлович','Олегович','Павлович','Романович']::text[])[((g.n-11)%10)+1],
       1980+(g.n%42), 1+((g.n-11)%10), 1+((g.n-11)%10)
FROM generate_series(11,240) AS g(n);

-- Медицинские карты: всего 650, по одной на каждого пациента.
INSERT INTO medical_card (status_id,patient_id)
SELECT CASE WHEN patient_id%7=0 THEN 2 ELSE 1 END, patient_id
FROM patient WHERE patient_id BETWEEN 11 AND 650;

-- Обращения: всего 810 (10 основных + 800).
INSERT INTO appeal (staff_id,medical_card_id)
SELECT 1+((g.n*7)%240), 1+((g.n*13)%650)
FROM generate_series(11,810) AS g(n);

-- Записи на приём: всего 730.
INSERT INTO appointment (appointment_at,status_id,appeal_id)
SELECT TIMESTAMPTZ '2026-01-01 08:00:00+03'+((g.n*11)%330)*INTERVAL '1 day'+((g.n%10)+8)*INTERVAL '1 hour',
       1+(g.n%4), g.n
FROM generate_series(11,730) AS g(n);

-- Визиты: всего 680, с разными датами, типами и жалобами.
INSERT INTO visit (visited_at,visit_type_id,complaint,appeal_id)
SELECT TIMESTAMPTZ '2025-01-01 08:00:00+03'+((g.n*17)%650)*INTERVAL '1 day'+(g.n%10)*INTERVAL '1 hour',
       1+(g.n%4),
       (ARRAY['Плановый осмотр','Кашель','Боль в спине','Головная боль','Контроль лечения','Повышенное давление','Сыпь','Утомляемость','Нарушение сна','Боль в горле']::text[])[(g.n%10)+1],
       g.n
FROM generate_series(11,680) AS g(n);

-- Заказы услуг: всего 800, распределены по обращениям и 10 услугам.
INSERT INTO service_order (order_type_id,ordered_at,appeal_id,service_id)
SELECT 1+(g.n%4), TIMESTAMPTZ '2025-01-01 08:30:00+03'+(g.n%650)*INTERVAL '1 day',
       g.n, 1+((g.n*7)%10)
FROM generate_series(11,800) AS g(n);

-- Диагнозы визитов: 670 основных и 250 дополнительных плюс исходные 12 = 932 связи.
INSERT INTO visit_diagnosis (visit_id,diagnosis_id,is_primary)
SELECT g.n, 1+((g.n*11)%10), TRUE FROM generate_series(11,680) AS g(n);
INSERT INTO visit_diagnosis (visit_id,diagnosis_id,is_primary)
SELECT g.n, 1+((g.n*11+1)%10), FALSE FROM generate_series(11,260) AS g(n);

-- Перемещения карт: всего 760.
INSERT INTO movement_log (destination,origin,moved_at,medical_card_id)
SELECT (ARRAY['Кабинет 1','Кабинет 2','Кабинет 3','Процедурный кабинет','Архив']::text[])[(g.n%5)+1],
       (ARRAY['Регистратура','Кабинет 1','Кабинет 2','Кабинет 3','Архив']::text[])[((g.n+2)%5)+1],
       TIMESTAMPTZ '2025-01-01 08:00:00+03'+(g.n%650)*INTERVAL '1 day',
       1+((g.n*19)%650)
FROM generate_series(11,760) AS g(n);

-- Расписание: всего 470 смен, по две дополнительные смены каждому сотруднику 11–240.
INSERT INTO work_schedule (staff_id,day_of_week,start_hours,end_hours,freetime_start,freetime_end)
SELECT staff.staff_id, days.day_of_week,
       CASE WHEN staff.staff_id%2=0 THEN TIME '08:00' ELSE TIME '09:00' END,
       CASE WHEN staff.staff_id%2=0 THEN TIME '16:00' ELSE TIME '17:00' END,
       TIME '12:00',TIME '13:00'
FROM generate_series(11,240) AS staff(staff_id)
CROSS JOIN (VALUES (1::smallint),(3::smallint)) AS days(day_of_week);

COMMIT;




