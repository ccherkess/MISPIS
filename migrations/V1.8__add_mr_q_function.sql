CREATE OR REPLACE FUNCTION mr_q(p_id_tm BIGINT, p_q DOUBLE PRECISION)
    RETURNS TABLE
            (
                o_prod_id   BIGINT,
                o_prod_name VARCHAR(255),
                o_q         DOUBLE PRECISION,
                o_res       INTEGER
            )
AS
$$
DECLARE
    v_prod_id   BIGINT;
    v_yes_tm    INTEGER;
    v_yes_res   INTEGER;
    v_in_tm     BIGINT;
    v_q         BIGINT;
    v_for_q     BIGINT;
    v_v_q       DOUBLE PRECISION;
    v_prod_name VARCHAR(255);
BEGIN
    SELECT prod_id
    INTO v_prod_id
    FROM tm
    WHERE id = p_id_tm;

    IF v_prod_id IS NOT NULL THEN
        v_yes_tm := 1;

        SELECT COUNT(*)
        INTO v_yes_res
        FROM in_res
        WHERE out_tm = p_id_tm;

        IF v_yes_tm > 0 THEN
            o_res := 1;

            IF v_yes_res > 0 THEN
                FOR v_in_tm, v_q, v_for_q IN
                    SELECT ir.in_tm, ir.q, ir.for_q
                    FROM in_res ir
                    WHERE ir.out_tm = p_id_tm
                    LOOP
                        SELECT t.prod_id, cc.name
                        INTO v_prod_id, v_prod_name
                        FROM tm t
                                 INNER JOIN prod p ON t.prod_id = p.id
                                 INNER JOIN chem_class cc ON p.chem_class_id = cc.id
                        WHERE t.id = v_in_tm;

                        IF v_prod_id IS NOT NULL THEN
                            v_v_q := v_q * p_q / v_for_q;
                            o_q := v_v_q;
                            o_prod_id := v_prod_id;
                            o_prod_name := v_prod_name;
                            RETURN NEXT;
                        END IF;
                    END LOOP;
            ELSE
                o_prod_id := 0;
                o_prod_name := '';
                o_q := 0;
                RETURN NEXT;
            END IF;
        END IF;
    ELSE
        -- TM не найдена
        o_prod_id := 0;
        o_prod_name := '';
        o_q := 0;
        o_res := 0;
        RETURN NEXT;
    END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT MR_Q(1, 10);
SELECT MR_Q(6, 5)
