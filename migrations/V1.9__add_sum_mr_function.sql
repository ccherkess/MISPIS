CREATE OR REPLACE FUNCTION SUM_MR(p_id_el BIGINT, p_q DOUBLE PRECISION)
    RETURNS TABLE
            (
                o_prod_id   BIGINT,
                o_prod_name VARCHAR(255),
                o_total_q   DOUBLE PRECISION
            )
AS
$$
BEGIN
    RETURN QUERY
        WITH RECURSIVE material_tree AS (SELECT t.id              as tm_id,
                                                t.prod_id,
                                                cc.name           as prod_name,
                                                p_q               as required_qty,
                                                0                 as level,
                                                ARRAY [t.prod_id] as path
                                         FROM tm t
                                                  INNER JOIN prod p ON t.prod_id = p.id
                                                  INNER JOIN chem_class cc ON p.chem_class_id = cc.id
                                         WHERE t.prod_id = p_id_el

                                         UNION ALL

                                         SELECT t_dep.id                          as tm_id,
                                                t_dep.prod_id,
                                                cc_dep.name                       as prod_name,
                                                mt.required_qty * ir.q / ir.for_q as required_qty,
                                                mt.level + 1,
                                                mt.path || t_dep.prod_id
                                         FROM material_tree mt
                                                  INNER JOIN tm t ON mt.tm_id = t.id
                                                  INNER JOIN in_res ir ON t.id = ir.out_tm
                                                  INNER JOIN tm t_dep ON ir.in_tm = t_dep.id
                                                  INNER JOIN prod p_dep ON t_dep.prod_id = p_dep.id
                                                  INNER JOIN chem_class cc_dep ON p_dep.chem_class_id = cc_dep.id
                                         WHERE t_dep.prod_id != ALL (mt.path))
        SELECT prod_id,
               prod_name,
               SUM(required_qty) as total_qty
        FROM material_tree
        GROUP BY prod_id, prod_name
        ORDER BY prod_id;
END;
$$ LANGUAGE plpgsql;

SELECT SUM_MR(1, 10);
SELECT SUM_MR(2, 50)
