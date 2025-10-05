-- =============================================
-- Название: ins_spec_item
-- Цель: Добавление новой позиции в спецификацию
-- Параметры:
--   p_item_id INTEGER – ID основного изделия
--   p_use_item_id INTEGER – ID используемого компонента
--   p_amount DOUBLE PRECISION – Количество компонента
--   p_order_position INTEGER – Порядковый номер (по умолчанию 0)
-- Возвращает: TABLE (oIdSpecItem INTEGER, oRes INTEGER)
--   oIdSpecItem – ID новой позиции спецификации (NULL, если ошибка)
--   oRes – 1 при успехе, 0 при ошибке
-- =============================================
CREATE OR REPLACE FUNCTION ins_spec_item(
    p_item_id INTEGER,
    p_use_item_id INTEGER,
    p_amount DOUBLE PRECISION,
    p_order_position INTEGER DEFAULT 0
)
    RETURNS TABLE
            (
                oIdSpecItem INTEGER,
                oRes        INTEGER
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_item_exists     BOOLEAN;
    v_use_item_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM item WHERE id = p_item_id) INTO v_item_exists;
    IF NOT v_item_exists THEN
        oIdSpecItem := NULL;
        oRes := 0;
        RETURN NEXT;
        RETURN;
    END IF;

    SELECT EXISTS(SELECT 1 FROM item WHERE id = p_use_item_id) INTO v_use_item_exists;
    IF NOT v_use_item_exists THEN
        oIdSpecItem := NULL;
        oRes := 0;
        RETURN NEXT;
        RETURN;
    END IF;

    IF p_amount <= 0 THEN
        oIdSpecItem := NULL;
        oRes := 0;
        RETURN NEXT;
        RETURN;
    END IF;

    BEGIN
        INSERT INTO spec_item(order_position, amount, item_id, use_item_id)
        VALUES (p_order_position, p_amount, p_item_id, p_use_item_id)
        RETURNING id INTO oIdSpecItem;

        oRes := 1;
    EXCEPTION
        WHEN unique_violation THEN
            oIdSpecItem := NULL;
            oRes := 0;
        WHEN OTHERS THEN
            oIdSpecItem := NULL;
            oRes := 0;
    END;

    RETURN NEXT;
END;
$$;

-- =============================================
-- Название: del_spec_item
-- Цель: Удаление позиции спецификации по ID
-- Параметры:
--   p_id INTEGER – ID удаляемой позиции спецификации
-- Возвращает: INTEGER
--   1 – если успешно удалено
--   0 – если не найдено или ошибка
-- =============================================
CREATE OR REPLACE FUNCTION del_spec_item(p_id INTEGER)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    oRes INTEGER := 1;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM spec_item WHERE id = p_id) THEN
        RETURN 0;
    END IF;

    BEGIN
        DELETE FROM spec_item WHERE id = p_id;

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
-- Название: upd_spec_item
-- Цель: Обновление информации о позиции спецификации
-- Параметры:
--   p_id INTEGER – ID обновляемой позиции
--   p_order_position INTEGER – Новый порядковый номер
--   p_amount DOUBLE PRECISION – Новое количество
--   p_item_id INTEGER – Новый ID основного изделия
--   p_use_item_id INTEGER – Новый ID используемого компонента
-- Возвращает: INTEGER
--   1 – если успешно обновлено
--   0 – если не найдено или ошибка
-- =============================================
CREATE OR REPLACE FUNCTION upd_spec_item(
    p_id INTEGER,
    p_order_position INTEGER DEFAULT NULL,
    p_amount DOUBLE PRECISION DEFAULT NULL,
    p_item_id INTEGER DEFAULT NULL,
    p_use_item_id INTEGER DEFAULT NULL
)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_current_record  RECORD;
    v_item_exists     BOOLEAN;
    v_use_item_exists BOOLEAN;
BEGIN
    SELECT * INTO v_current_record FROM spec_item WHERE id = p_id;

    IF NOT FOUND THEN
        RETURN 0;
    END IF;

    IF p_item_id IS NOT NULL THEN
        SELECT EXISTS(SELECT 1 FROM item WHERE id = p_item_id) INTO v_item_exists;
        IF NOT v_item_exists THEN
            RETURN 0;
        END IF;
    END IF;

    IF p_use_item_id IS NOT NULL THEN
        SELECT EXISTS(SELECT 1 FROM item WHERE id = p_use_item_id) INTO v_use_item_exists;
        IF NOT v_use_item_exists THEN
            RETURN 0;
        END IF;
    END IF;

    IF p_amount IS NOT NULL AND p_amount <= 0 THEN
        RETURN 0;
    END IF;

    BEGIN
        UPDATE spec_item
        SET order_position = COALESCE(p_order_position, v_current_record.order_position),
            amount         = COALESCE(p_amount, v_current_record.amount),
            flag           = v_current_record.flag,
            item_id        = COALESCE(p_item_id, v_current_record.item_id),
            use_item_id    = COALESCE(p_use_item_id, v_current_record.use_item_id)
        WHERE id = p_id;

        IF NOT FOUND THEN
            RETURN 0;
        END IF;

        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END;
END;
$$;
