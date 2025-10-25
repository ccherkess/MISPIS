CREATE OR REPLACE FUNCTION find_tm(p_id_el BIGINT)
    RETURNS TABLE
            (
                indent    TEXT,
                tm_id     BIGINT,
                prod_name VARCHAR(255),
                num       BIGINT,
                to_name   VARCHAR(255),
                prof_name VARCHAR(255),
                grc_name  VARCHAR(255),
                kval_name VARCHAR(255),
                level     INTEGER
            )
AS
$$
BEGIN
    RETURN QUERY
        WITH RECURSIVE
            prod_tree AS (SELECT p_id_el         as prod_id,
                                 0               as level,
                                 ARRAY [p_id_el] as path
                          FROM prod
                          WHERE id = p_id_el

                          UNION ALL

                          SELECT t_dep.prod_id,
                                 pt.level + 1,
                                 pt.path || t_dep.prod_id
                          FROM prod_tree pt
                                   INNER JOIN tm t ON t.prod_id = pt.prod_id
                                   INNER JOIN in_res ir ON t.id = ir.out_tm
                                   INNER JOIN tm t_dep ON ir.in_tm = t_dep.id
                          WHERE t_dep.prod_id != ALL (pt.path)),
            all_prods AS (SELECT DISTINCT prod_id
                          FROM prod_tree),
            all_tm_sorted AS (SELECT t.id,
                                     t.prod_id,
                                     t.num,
                                     t.to_id,
                                     t.prof_id,
                                     t.grc_id,
                                     t.kval_id,
                                     pt.level
                              FROM all_prods ap
                                       INNER JOIN tm t ON t.prod_id = ap.prod_id
                                       INNER JOIN prod_tree pt ON t.prod_id = pt.prod_id
                              ORDER BY pt.level, t.prod_id, t.num)
        SELECT REPEAT('    ', t.level) as indent,
               t.id,
               cc.name,
               t.num,
               ev_to.name,
               ev_prof.name,
               g.name,
               ev_kval.name,
               t.level
        FROM all_tm_sorted t
                 LEFT JOIN prod p ON t.prod_id = p.id
                 LEFT JOIN chem_class cc ON p.chem_class_id = cc.id
                 LEFT JOIN enum_val ev_to ON t.to_id = ev_to.id
                 LEFT JOIN enum_val ev_prof ON t.prof_id = ev_prof.id
                 LEFT JOIN grc g ON t.grc_id = g.id
                 LEFT JOIN enum_val ev_kval ON t.kval_id = ev_kval.id
        ORDER BY t.level, t.prod_id, t.num;
END;
$$ LANGUAGE plpgsql;

SELECT find_tm(1);
SELECT find_tm(2);
