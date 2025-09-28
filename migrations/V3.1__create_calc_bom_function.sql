-- =============================================
-- Название: calc_bom
-- Цель: Расчет с учетом флагов базы и модификаций
-- Параметры:
--   pIdProd INTEGER – ID изделия
--   pQuantity INTEGER – Количество изделий
-- Возвращает: TABLE
--   name VARCHAR – Название ресурса
--   quantity BIGINT – Суммарное количество
--   is_base_item BOOLEAN – Флаг базового ресурса
-- =============================================
CREATE OR REPLACE FUNCTION calc_bom(
    pIdProd INTEGER,
    pQuantity INTEGER
)
    RETURNS TABLE
            (
                name     VARCHAR(250),
                quantity BIGINT
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        WITH RECURSIVE bom_tree AS (SELECT s.use_item_id        as item_id,
                                           s.amount * pQuantity as quantity,
                                           p.name               as item_name,
                                           CASE
                                               WHEN s.flag = true THEN false
                                               WHEN NOT EXISTS (SELECT 1
                                                                FROM spec_item si2
                                                                WHERE si2.item_id = s.use_item_id
                                                                  AND si2.flag = false)
                                                   THEN true
                                               ELSE false
                                               END              as is_base
                                    FROM spec_item s
                                             JOIN item p ON s.use_item_id = p.id
                                    WHERE s.item_id = pIdProd
                                      AND s.flag = false

                                    UNION ALL

                                    SELECT s2.use_item_id          as item_id,
                                           s2.amount * bt.quantity as quantity,
                                           p.name                  as item_name,
                                           CASE
                                               WHEN s2.flag = true THEN false
                                               WHEN NOT EXISTS (SELECT 1
                                                                FROM spec_item si3
                                                                WHERE si3.item_id = s2.use_item_id
                                                                  AND si3.flag = false) THEN true
                                               ELSE false
                                               END                 as is_base
                                    FROM spec_item s2
                                             JOIN item p ON s2.use_item_id = p.id
                                             JOIN bom_tree bt ON bt.item_id = s2.item_id
                                    WHERE s2.flag = false)
        SELECT bt.item_name             as name,
               SUM(bt.quantity)::BIGINT as quantity
        FROM bom_tree bt
        WHERE bt.is_base = true
        GROUP BY bt.item_name
        ORDER BY quantity DESC;
END;
$$;
