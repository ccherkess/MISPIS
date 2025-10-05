-- =============================================
-- Название: create_modification
-- Цель: Создание нового элемента на основе существующего с копированием спецификации
-- Параметры:
--   p_name VARCHAR – Название нового элемента
--   p_parent_id INTEGER – ID родительского элемента
-- Возвращает: TABLE (oNewItemId INTEGER, oRes INTEGER)
--   oNewItemId – ID нового элемента (NULL, если ошибка)
--   oRes – 1 при успехе, 0 при ошибке
-- =============================================
CREATE OR REPLACE FUNCTION create_modification(
    p_parent_id INTEGER,
    p_name VARCHAR
)
    RETURNS TABLE
            (
                oNewItemId INTEGER,
                oRes       INTEGER
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_parent_item        RECORD;
    v_spec_record        RECORD;
    v_new_item_id        INTEGER;
    v_new_order_position INTEGER;
    v_copy_count         INTEGER := 0;
BEGIN
    oNewItemId := NULL;
    oRes := 0;

    SELECT * INTO v_parent_item FROM item WHERE id = p_parent_id;
    IF NOT FOUND THEN
        RETURN NEXT;
        RETURN;
    END IF;

    IF EXISTS (SELECT 1 FROM item WHERE name = p_name) THEN
        RETURN NEXT;
        RETURN;
    END IF;

    BEGIN
        -- Создаем новый элемент
        INSERT INTO item (name, class_id, parent_id)
        VALUES (p_name,
                v_parent_item.class_id,
                p_parent_id)
        RETURNING id INTO v_new_item_id;

        FOR v_spec_record IN
            SELECT order_position, amount, flag, use_item_id
            FROM spec_item
            WHERE item_id = p_parent_id
            LOOP
                BEGIN
                    INSERT INTO spec_item (order_position, amount, flag, item_id, use_item_id)
                    VALUES (v_spec_record.order_position,
                            v_spec_record.amount,
                            v_spec_record.flag,
                            v_new_item_id,
                            v_spec_record.use_item_id);
                    v_copy_count := v_copy_count + 1;
                EXCEPTION
                    WHEN unique_violation THEN
                        SELECT COALESCE(MAX(order_position), 0) + 1
                        INTO v_new_order_position
                        FROM spec_item
                        WHERE item_id = v_new_item_id;

                        INSERT INTO spec_item (order_position, amount, flag, item_id, use_item_id)
                        VALUES (v_new_order_position,
                                v_spec_record.amount,
                                v_spec_record.flag,
                                v_new_item_id,
                                v_spec_record.use_item_id);
                        v_copy_count := v_copy_count + 1;
                    WHEN OTHERS THEN
                        CONTINUE;
                END;
            END LOOP;

        oNewItemId := v_new_item_id;
        oRes := 1;

    EXCEPTION
        WHEN OTHERS THEN
            oNewItemId := NULL;
            oRes := 0;
    END;

    RETURN NEXT;
END;
$$;
