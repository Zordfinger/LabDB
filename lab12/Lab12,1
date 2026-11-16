BEGIN ISOLATION LEVEL SERIALIZABLE;

DO $$
DECLARE
    v_staff_id  bigint;
    v_dow       smallint;
    v_start     time;
    v_card_id   bigint;
    v_at        timestamptz;
    v_local     timestamp;
    v_slot      interval := INTERVAL '30 minutes';
    v_appeal_id bigint;
BEGIN

    SELECT ws.staff_id, ws.day_of_week, ws.start_hours
      INTO v_staff_id, v_dow, v_start
    FROM work_schedule ws
    WHERE ws.day_of_week BETWEEN 1 AND 7
    ORDER BY ws.staff_id, ws.work_schedule_id
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Таблица work_schedule пуста: сначала запустите DB_fillScript.sql';
    END IF;

    SELECT medical_card_id INTO v_card_id
    FROM medical_card
    WHERE status_id = 1
    ORDER BY medical_card_id
    LIMIT 1;

    IF v_card_id IS NULL THEN
        RAISE EXCEPTION 'Нет активных медицинских карт';
    END IF;

    -- Ближайшая неделя с 23.11.2026 (пн), нужный день недели, начало смены + 1 час
    v_local := (DATE '2026-11-23' + (v_dow - 1)) + (v_start + INTERVAL '1 hour');
    v_at    := v_local AT TIME ZONE 'Europe/Minsk';

    RAISE NOTICE 'Демо: врач %, карта %, время %', v_staff_id, v_card_id, v_at;

    -- 1. Карта активна
    IF NOT EXISTS (SELECT 1 FROM medical_card
                   WHERE medical_card_id = v_card_id AND status_id = 1) THEN
        RAISE EXCEPTION 'Медицинская карта % не найдена или не активна', v_card_id;
    END IF;

    -- 2. Время в графике врача и не в перерыве
    IF NOT EXISTS (
        SELECT 1
        FROM work_schedule ws
        WHERE ws.staff_id = v_staff_id
          AND ws.day_of_week = EXTRACT(ISODOW FROM v_local)
          AND v_local::time >= ws.start_hours
          AND v_local::time + v_slot <= ws.end_hours
          AND (ws.freetime_start IS NULL
               OR v_local::time + v_slot <= ws.freetime_start
               OR v_local::time >= ws.freetime_end)
    ) THEN
        RAISE EXCEPTION 'Врач % не принимает в это время', v_staff_id;
    END IF;

    -- 3. Нет пересечений у врача и у пациента
    IF EXISTS (
        SELECT 1
        FROM appointment ap
        JOIN appeal a ON a.appeal_id = ap.appeal_id
        WHERE ap.status_id = 1
          AND (a.staff_id = v_staff_id OR a.medical_card_id = v_card_id)
          AND ap.appointment_at > v_at - v_slot
          AND ap.appointment_at < v_at + v_slot
    ) THEN
        RAISE EXCEPTION 'Время % уже занято (у врача или у пациента)', v_at;
    END IF;

    -- 4. Находим или создаём обращение
    SELECT appeal_id INTO v_appeal_id
    FROM appeal
    WHERE staff_id = v_staff_id AND medical_card_id = v_card_id
    ORDER BY appeal_id
    LIMIT 1;

    IF v_appeal_id IS NULL THEN
        INSERT INTO appeal (staff_id, medical_card_id)
        VALUES (v_staff_id, v_card_id)
        RETURNING appeal_id INTO v_appeal_id;
    END IF;

    -- 5. Создаём запись на приём
    INSERT INTO appointment (appointment_at, status_id, appeal_id)
    VALUES (v_at, 1, v_appeal_id);
END
$$;

-- Проверка (внутри ещё не завершённой транзакции): последняя созданная запись
SELECT ap.appointment_id, ap.appointment_at, ap.status_id, a.staff_id, a.medical_card_id
FROM appointment ap
JOIN appeal a ON a.appeal_id = ap.appeal_id
ORDER BY ap.appointment_id DESC
LIMIT 1;

ROLLBACK;   -- данные не сохраняются
