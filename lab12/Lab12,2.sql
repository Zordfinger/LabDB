BEGIN ISOLATION LEVEL REPEATABLE READ;

DO $$
DECLARE
    v_appointment_id bigint;
    v_appeal_id      bigint;
    v_staff_id       bigint;
    v_dept_id        bigint;
    v_visit_id       bigint;
    v_main_dx        bigint;
    v_extra_dx       bigint;
    v_now            timestamptz := now();
    v_cnt            int;
    v_total          numeric(12,2);
BEGIN
    -- 1. Выбираем запланированный приём, у отделения врача есть активные услуги
    SELECT ap.appointment_id, ap.appeal_id, a.staff_id, ds.department_id
      INTO v_appointment_id, v_appeal_id, v_staff_id, v_dept_id
    FROM appointment ap
    JOIN appeal a ON a.appeal_id = ap.appeal_id
    JOIN medical_staff s ON s.staff_id = a.staff_id
    JOIN department_speciality ds
         ON ds.department_speciality_id = s.department_speciality_id
    WHERE ap.status_id = 1
      AND EXISTS (SELECT 1 FROM medical_service ms
                  WHERE ms.department_id = ds.department_id AND ms.status_id = 1)
    ORDER BY ap.appointment_id
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Нет запланированных приёмов с доступными услугами';
    END IF;

    RAISE NOTICE 'Демо: приём %, обращение %, врач %, отделение %',
                 v_appointment_id, v_appeal_id, v_staff_id, v_dept_id;

    -- 2. Приём состоялся (только если он всё ещё «Запланирована»)
    UPDATE appointment
       SET status_id = 2
     WHERE appointment_id = v_appointment_id
       AND status_id = 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Приём % уже завершён или отменён', v_appointment_id;
    END IF;

    -- 3. Диагнозы по коду МКБ-10
    SELECT diagnosis_id INTO v_main_dx  FROM diagnosis WHERE icd10_code = 'J06.9';
    SELECT diagnosis_id INTO v_extra_dx FROM diagnosis WHERE icd10_code = 'J20.9';

    IF v_main_dx IS NULL OR v_extra_dx IS NULL THEN
        RAISE EXCEPTION 'Не найдены диагнозы J06.9 / J20.9';
    END IF;

    -- 4. Визит
    INSERT INTO visit (visited_at, visit_type_id, complaint, appeal_id)
    VALUES (v_now, 1, 'Кашель, повышенная температура', v_appeal_id)
    RETURNING visit_id INTO v_visit_id;

    -- 5. Диагнозы визита: один основной, один дополнительный
    INSERT INTO visit_diagnosis (visit_id, diagnosis_id, is_primary)
    VALUES (v_visit_id, v_main_dx,  TRUE),
           (v_visit_id, v_extra_dx, FALSE);

    -- 6. Заказ до двух активных услуг отделения врача
    INSERT INTO service_order (order_type_id, ordered_at, appeal_id, service_id)
    SELECT 3, v_now, v_appeal_id, ms.service_id
    FROM medical_service ms
    WHERE ms.department_id = v_dept_id
      AND ms.status_id = 1
    ORDER BY ms.service_id
    LIMIT 2;

    GET DIAGNOSTICS v_cnt = ROW_COUNT;
    IF v_cnt = 0 THEN
        RAISE EXCEPTION 'Не удалось заказать услуги';
    END IF;

    -- 7. Итоговая стоимость заказанных услуг (по тому же снимку, что и выбор)
    SELECT sum(ms.price) INTO v_total
    FROM service_order so
    JOIN medical_service ms ON ms.service_id = so.service_id
    WHERE so.appeal_id = v_appeal_id
      AND so.ordered_at = v_now;

    -- 8. У визита ровно один основной диагноз
    IF (SELECT count(*) FROM visit_diagnosis
        WHERE visit_id = v_visit_id AND is_primary) <> 1 THEN
        RAISE EXCEPTION 'У визита % должен быть ровно один основной диагноз', v_visit_id;
    END IF;

    RAISE NOTICE 'Приём % завершён: визит %, услуг %, итого %',
                 v_appointment_id, v_visit_id, v_cnt, v_total;
END
$$;

-- Проверка внутри незавершённой транзакции
SELECT ap.appointment_id, ap.status_id AS appointment_status
FROM appointment ap
WHERE ap.status_id = 2
ORDER BY ap.appointment_id
LIMIT 3;

SELECT v.visit_id, v.visited_at, v.complaint, v.appeal_id
FROM visit v
ORDER BY v.visit_id DESC
LIMIT 1;

SELECT vd.visit_id, d.icd10_code, d.name, vd.is_primary
FROM visit_diagnosis vd
JOIN diagnosis d ON d.diagnosis_id = vd.diagnosis_id
WHERE vd.visit_id = (SELECT max(visit_id) FROM visit);

SELECT so.service_order_id, ms.name AS service, ms.price
FROM service_order so
JOIN medical_service ms ON ms.service_id = so.service_id
ORDER BY so.service_order_id DESC
LIMIT 2;

ROLLBACK;   -- данные не сохраняются