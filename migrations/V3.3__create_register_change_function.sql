-- =============================================
-- Название: register_change
-- Цель:  Регистрация изменения для изделия
-- Параметры:
--   p_id INTEGER – ID изделия,
--   p_change TEXT - информация об изменении
-- Возвращает: INTEGER
--   1 – изделие удалено успешно
--   0 – изделие не найдено или возникла ошибка
-- =============================================
CREATE OR REPLACE FUNCTION register_change(
    p_id INTEGER,
    p_change TEXT
) RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    oRes INTEGER := 1;
BEGIN
    BEGIN
        UPDATE item
        SET change = p_change
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
