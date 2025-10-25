CREATE OR REPLACE FUNCTION TR_TO(p_id_el BIGINT, p_q DOUBLE PRECISION)
    RETURNS TABLE
            (
                o_to_name    VARCHAR(255),
                o_total_time DOUBLE PRECISION
            )
AS
$$
BEGIN
    RETURN QUERY
        WITH RECURSIVE labor_tree AS (
            -- Базовый случай: все TM основного изделия
            SELECT t.id              as tm_id,
                   t.prod_id,
                   ev.name           as to_name,
                   ev.real_val       as time_per_unit,
                   p_q               as quantity,
                   p_q * ev.real_val as total_time,
                   0                 as level,
                   ARRAY [t.prod_id] as path
            FROM tm t
                     INNER JOIN enum_val ev ON t.to_id = ev.id
            WHERE t.prod_id = p_id_el

            UNION ALL

            -- Рекурсивно находим все зависимости через in_res
            SELECT t_dep.id                                          as tm_id,
                   t_dep.prod_id,
                   ev_dep.name                                       as to_name,
                   ev_dep.real_val                                   as time_per_unit,
                   lt.quantity * ir.q / ir.for_q                     as quantity,
                   (lt.quantity * ir.q / ir.for_q) * ev_dep.real_val as total_time,
                   lt.level + 1,
                   lt.path || t_dep.prod_id
            FROM labor_tree lt
                     INNER JOIN tm t ON lt.tm_id = t.id
                     INNER JOIN in_res ir ON t.id = ir.out_tm
                     INNER JOIN tm t_dep ON ir.in_tm = t_dep.id
                     INNER JOIN enum_val ev_dep ON t_dep.to_id = ev_dep.id
            WHERE t_dep.prod_id != ALL (lt.path))
        SELECT to_name,
               SUM(total_time) as total_time
        FROM labor_tree
        WHERE time_per_unit IS NOT NULL
        GROUP BY to_name
        ORDER BY to_name;
END;
$$ LANGUAGE plpgsql;

SELECT TR_TO(1, 10);
SELECT TR_TO(2, 50)
