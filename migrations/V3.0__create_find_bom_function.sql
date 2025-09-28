-- =============================================
-- Название: find_bom
-- Цель: Упрощенная версия с порядком обхода в глубину
-- Параметры:
--   pIdProd INTEGER – ID изделия
-- Возвращает: TABLE
--   item_id INTEGER – ID элемента
--   item_name VARCHAR – Название элемента
--   use_item_id INTEGER – ID компонента
--   use_item_name VARCHAR – Название компонента
--   amount DOUBLE PRECISION – Количество
--   full_path TEXT – Полный путь
-- =============================================
CREATE OR REPLACE FUNCTION find_bom(pIdProd INTEGER)
    RETURNS TABLE
            (
                tab       TEXT,
                item_id   INTEGER,
                item_name VARCHAR,
                amount    DOUBLE PRECISION,
                unit_name VARCHAR(255)
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        WITH RECURSIVE bom_tree AS (SELECT ''::TEXT                                  as tab,
                                           i.id                                      as item_id,
                                           i.name                                    as item_name,
                                           NULL::DOUBLE PRECISION                    as amount,
                                           ARRAY [ROW_NUMBER() OVER (ORDER BY i.id)] as path_order,
                                           ''::VARCHAR(255)                          as unit_name
                                    FROM item i
                                    WHERE i.id = pIdProd

                                    UNION ALL

                                    SELECT bt.tab || '-----' as tab,
                                           i.id              as item_id,
                                           i.name            as item_name,
                                           si.amount         as amount,
                                           bt.path_order ||
                                           (ROW_NUMBER() OVER (PARTITION BY si.item_id ORDER BY si.order_position)),
                                           u.name            as unit_name
                                    FROM bom_tree bt
                                             JOIN spec_item si ON bt.item_id = si.item_id
                                             JOIN item i ON si.use_item_id = i.id
                                             JOIN class c ON c.id = i.class_id
                                             JOIN unit u ON u.id = c.unit_id)
        SELECT bt.tab,
               bt.item_id,
               bt.item_name,
               bt.amount,
               bt.unit_name
        FROM bom_tree bt
        ORDER BY bt.path_order;
END;
$$;