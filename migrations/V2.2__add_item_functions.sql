-- Название: ins_item
-- Цель: Добавление нового изделия
-- Параметры:
--   p_class_id INTEGER – ID класса, к которому относится изделие
--   p_name VARCHAR – Название изделия
--   p_amount INTEGER – Количество
--   p_price INTEGER – Цена
-- Возвращает: TABLE (oIdItem INTEGER, oRes INTEGER)
--   oIdItem – ID нового изделия (NULL, если ошибка)
--   oRes – 1 при успехе, 0 при ошибке
-- =============================================
CREATE OR REPLACE FUNCTION ins_item(
    p_class_id INTEGER,
    p_name VARCHAR,
    p_amount INTEGER,
    p_price INTEGER
)
    RETURNS TABLE
            (
                oIdItem INTEGER,
                oRes    INTEGER
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    BEGIN
        INSERT INTO item (class_id, name, amount, price)
        VALUES (p_class_id, p_name, p_amount, p_price)
        RETURNING id INTO oIdItem;

        oRes := 1; -- Успешно
    EXCEPTION
        WHEN OTHERS THEN
            oIdItem := NULL;
            oRes := 0; -- Ошибка
    END;

    RETURN NEXT;
END;
$$;

-- =============================================
-- Название: del_item
-- Цель: Удаление изделия по его ID
-- Параметры:
--   p_id INTEGER – ID изделия
-- Возвращает: INTEGER
--   1 – изделие удалено успешно
--   0 – изделие не найдено или возникла ошибка
-- =============================================
CREATE OR REPLACE FUNCTION del_item(p_id INTEGER)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    oRes INTEGER := 1;
BEGIN
    BEGIN
        DELETE FROM item WHERE id = p_id;

        oRes := 1;
        IF NOT FOUND THEN
            oRes := 0;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            oRes := 0; -- Ошибка
    END;

    RETURN oRes;
END;
$$;

-- =============================================
-- Название: upd_item
-- Цель: Редактирование данных изделия
-- Параметры:
--   p_id INTEGER – ID изделия
--   p_name VARCHAR – Новое название
--   p_amount INTEGER – Новое количество
--   p_price INTEGER – Новая цена
-- Возвращает: INTEGER
--   1 – обновление успешно
--   0 – изделие не найдено или возникла ошибка
-- =============================================
CREATE OR REPLACE FUNCTION upd_item(
    p_id INTEGER,
    p_name VARCHAR,
    p_amount INTEGER,
    p_price INTEGER
)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    oRes INTEGER := 1;
BEGIN
    BEGIN
        UPDATE item
        SET name   = p_name,
            amount = p_amount,
            price  = p_price
        WHERE id = p_id;

        IF NOT FOUND THEN
            oRes := 0; -- Изделие не найдено
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            oRes := 0; -- Ошибка
    END;

    RETURN oRes;
END;
$$;
