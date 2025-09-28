-- =============================================
-- Название: ins_unit
-- Цель: Добавление новой единицы измерения
-- Параметры:
--   p_name VARCHAR – Название единицы
--   p_abbr VARCHAR – Аббревиатура (например, кг, м)
--   p_coefficient DOUBLE PRECISION – Коэффициент преобразования (по умолчанию 1)
--   p_parent_id INTEGER – ID родительской единицы (NULL если базовая)
-- Возвращает: TABLE (oIdUnit INTEGER, oRes INTEGER)
--   oIdUnit – ID новой единицы (NULL, если ошибка)
--   oRes – 1 при успехе, 0 при ошибке
-- =============================================
CREATE OR REPLACE FUNCTION ins_unit(
    p_name VARCHAR,
    p_abbr VARCHAR,
    p_coefficient DOUBLE PRECISION DEFAULT 1,
    p_parent_id INTEGER DEFAULT NULL
)
    RETURNS TABLE
            (
                oIdUnit INTEGER,
                oRes    INTEGER
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_parent_exists BOOLEAN;
BEGIN
    IF p_parent_id IS NOT NULL THEN
        SELECT EXISTS(SELECT 1 FROM unit WHERE id = p_parent_id) INTO v_parent_exists;
        IF NOT v_parent_exists THEN
            oIdUnit := NULL;
            oRes := 0;
            RETURN NEXT;
            RETURN;
        END IF;
    END IF;

    BEGIN
        INSERT INTO unit(name, abbreviation, coefficient, parent_id)
        VALUES (p_name, p_abbr, p_coefficient, p_parent_id)
        RETURNING id INTO oIdUnit;

        oRes := 1;
    EXCEPTION
        WHEN unique_violation THEN
            oIdUnit := NULL;
            oRes := 0;
        WHEN OTHERS THEN
            oIdUnit := NULL;
            oRes := 0;
    END;

    RETURN NEXT;
END;
$$;

-- =============================================
-- Название: del_unit
-- Цель: Удаление единицы измерения по ID
-- Параметры:
--   p_id INTEGER – ID удаляемой единицы
-- Возвращает: INTEGER
--   1 – если успешно удалено
--   0 – если не найдено или ошибка
-- =============================================
CREATE OR REPLACE FUNCTION del_unit(p_id INTEGER)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    oRes INTEGER := 1;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM unit WHERE id = p_id) THEN
        RETURN 0;
    END IF;

    BEGIN
        DELETE FROM unit WHERE id = p_id;

        IF NOT FOUND THEN
            oRes := 0;
        ELSE
            oRes := 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            oRes := 0;
    END;

    RETURN oRes;
END;
$$;

-- =============================================
-- Название: upd_unit
-- Цель: Обновление информации об единице измерения
-- Параметры:
--   p_id INTEGER – ID обновляемой единицы
--   p_name VARCHAR – Новое имя
--   p_abbr VARCHAR – Новая аббревиатура
--   p_coefficient DOUBLE PRECISION – Новый коэффициент
--   p_parent_id INTEGER – Новый ID родительской единицы
-- Возвращает: INTEGER
--   1 – если успешно обновлено
--   0 – если не найдено или ошибка
-- =============================================
CREATE OR REPLACE FUNCTION upd_unit(
    p_id INTEGER,
    p_name VARCHAR,
    p_abbr VARCHAR,
    p_coefficient DOUBLE PRECISION DEFAULT NULL,
    p_parent_id INTEGER DEFAULT NULL
)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_current_record RECORD;
    v_parent_exists  BOOLEAN;
BEGIN
    SELECT * INTO v_current_record FROM unit WHERE id = p_id;

    IF NOT FOUND THEN
        RETURN 0;
    END IF;

    IF p_parent_id = p_id THEN
        RETURN 0;
    END IF;

    IF p_parent_id IS NOT NULL THEN
        SELECT EXISTS(SELECT 1 FROM unit WHERE id = p_parent_id) INTO v_parent_exists;
        IF NOT v_parent_exists THEN
            RETURN 0;
        END IF;
    END IF;

    BEGIN
        UPDATE unit
        SET name         = p_name,
            abbreviation = p_abbr,
            coefficient  = p_coefficient,
            parent_id    = p_parent_id
        WHERE id = p_id;

        IF NOT FOUND THEN
            RETURN 0;
        END IF;

        RETURN 1;
    EXCEPTION
        WHEN unique_violation THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN 0;
    END;
END;
$$;
