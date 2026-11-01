-- 1. Все визиты с пациентом, врачом, типом и диагнозами.
-- Сортировка по дате визита по убыванию.
SELECT
    v.visit_id,
    v.visited_at,
    p.last_name || ' ' || p.first_name AS patient,
    ms.last_name || ' ' || ms.first_name AS medical_staff,
    vt.name AS visit_type,
    v.complaint,
    COALESCE(
        string_agg(
            d.icd10_code || ' — ' || d.name ||
            CASE WHEN vd.is_primary THEN ' (основной)' ELSE '' END,
            '; ' ORDER BY vd.is_primary DESC, d.icd10_code
        ),
        'Диагноз не указан'
    ) AS diagnoses
FROM visit v
JOIN visit_type vt ON vt.visit_type_id = v.visit_type_id
LEFT JOIN appeal a ON a.appeal_id = v.appeal_id
LEFT JOIN medical_card mc ON mc.medical_card_id = a.medical_card_id
LEFT JOIN patient p ON p.patient_id = mc.patient_id
LEFT JOIN medical_staff ms ON ms.staff_id = a.staff_id
LEFT JOIN visit_diagnosis vd ON vd.visit_id = v.visit_id
LEFT JOIN diagnosis d ON d.diagnosis_id = vd.diagnosis_id
GROUP BY
    v.visit_id, v.visited_at,
    p.last_name, p.first_name,
    ms.last_name, ms.first_name,
    vt.name, v.complaint
ORDER BY v.visited_at DESC;

-- 2. Количество визитов каждого типа.
-- Группы отсортированы по числу визитов по убыванию.
SELECT
    vt.name AS visit_type,
    COUNT(v.visit_id) AS visit_count
FROM visit_type vt
LEFT JOIN visit v ON v.visit_type_id = vt.visit_type_id
GROUP BY vt.visit_type_id, vt.name
ORDER BY visit_count DESC, vt.name;

-- 3. Записи на приём со значением статуса 1 или 2.
-- В справочнике это «Запланирована» и «Состоялась».
-- Результат отсортирован по дате приёма по убыванию.
SELECT
    ap.appointment_id,
    ap.appointment_at,
    p.last_name || ' ' || p.first_name AS patient,
    ast.status_id,
    ast.name AS appointment_status
FROM appointment ap
JOIN appointment_status ast ON ast.status_id = ap.status_id
JOIN appeal a ON a.appeal_id = ap.appeal_id
JOIN medical_card mc ON mc.medical_card_id = a.medical_card_id
JOIN patient p ON p.patient_id = mc.patient_id
WHERE ap.status_id IN (1, 2)
ORDER BY ap.appointment_at DESC;
