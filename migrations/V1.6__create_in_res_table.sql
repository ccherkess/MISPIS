CREATE TABLE IF NOT EXISTS in_res
(
    out_tm BIGINT REFERENCES tm (id) ON DELETE CASCADE,
    in_tm  BIGINT REFERENCES tm (id) ON DELETE CASCADE,
    q      BIGINT NOT NULL,
    for_q  BIGINT NOT NULL
);

ALTER TABLE in_res
    ADD CONSTRAINT in_res_unique_pair UNIQUE (out_tm, in_tm);

-- Вставка
CREATE OR REPLACE FUNCTION insert_in_res(
    p_out_tm BIGINT,
    p_in_tm BIGINT,
    p_q BIGINT,
    p_for_q BIGINT
) RETURNS INTEGER AS
$$
BEGIN
    INSERT INTO in_res (out_tm, in_tm, q, for_q)
    VALUES (p_out_tm, p_in_tm, p_q, p_for_q);
    RETURN 1;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при вставке: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Изменение
CREATE OR REPLACE FUNCTION update_in_res(
    p_out_tm BIGINT,
    p_in_tm BIGINT,
    p_q BIGINT,
    p_for_q BIGINT
) RETURNS INTEGER AS
$$
BEGIN
    UPDATE in_res
    SET q     = p_q,
        for_q = p_for_q
    WHERE out_tm = p_out_tm
      AND in_tm = p_in_tm;

    IF FOUND THEN
        RETURN 1;
    ELSE
        RAISE NOTICE 'Элемент не найден';
        RETURN 0;
    END IF;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при обновлении: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Удаление
CREATE OR REPLACE FUNCTION delete_in_res(p_out_tm BIGINT, p_in_tm BIGINT) RETURNS INTEGER AS
$$
BEGIN
    DELETE FROM in_res WHERE out_tm = p_out_tm AND in_tm = p_in_tm;

    IF FOUND THEN
        RETURN 1;
    ELSE
        RAISE NOTICE 'Элемент не найден';
        RETURN 0;
    END IF;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при удалении: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

/*Для деревянного стола*/
SELECT insert_in_res(5, 1, 4, 1);
SELECT insert_in_res(5, 3, 1, 1);

/*Для металлического стола*/
SELECT insert_in_res(10, 6, 4, 1);
SELECT insert_in_res(10, 8, 1, 1);

/*Для деревенных ножек и столешниц*/
SELECT insert_in_res(1, 11, 1, 1);
SELECT insert_in_res(3, 11, 6, 1);

/*Для металлических ножек и столешниц*/
SELECT insert_in_res(6, 12, 1, 1);
SELECT insert_in_res(8, 12, 8, 1);

SELECT *
from in_res;
