CREATE TABLE IF NOT EXISTS tm
(
    id      BIGSERIAL PRIMARY KEY,
    prod_id BIGINT REFERENCES prod (id) ON DELETE CASCADE,
    num     BIGINT NOT NULL,
    to_id   BIGINT REFERENCES enum_val (id) ON DELETE CASCADE,
    prof_id BIGINT REFERENCES enum_val (id) ON DELETE CASCADE,
    grc_id  BIGINT REFERENCES grc (id) ON DELETE CASCADE,
    kval_id BIGINT REFERENCES enum_val (id) ON DELETE CASCADE
);

-- Вставка
CREATE OR REPLACE FUNCTION insert_tm(
    p_prod_id BIGINT,
    p_num BIGINT,
    p_to_id BIGINT,
    p_prof_id BIGINT,
    p_grc_id BIGINT,
    p_kval_id BIGINT
) RETURNS INTEGER AS
$$
BEGIN
    IF NOT check_enum_val_class(p_to_id, 15) THEN
        RAISE NOTICE 'to_id должен наследоваться от Технологическая операция';
        RETURN 0;
    END IF;

    IF NOT check_enum_val_class(p_prof_id, 12) THEN
        RAISE NOTICE 'prof_id должен наследоваться от Профессия';
        RETURN 0;
    END IF;

    IF NOT check_enum_val_class(p_kval_id, 13) THEN
        RAISE NOTICE 'kval_id должен наследоваться от Классификация';
        RETURN 0;
    END IF;

    INSERT INTO tm (prod_id, num, to_id, prof_id, grc_id, kval_id)
    VALUES (p_prod_id, p_num, p_to_id, p_prof_id, p_grc_id, p_kval_id);
    RETURN 1;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при вставке: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Изменение
CREATE OR REPLACE FUNCTION update_tm(
    p_id BIGINT,
    p_prod_id BIGINT,
    p_num BIGINT,
    p_to_id BIGINT,
    p_prof_id BIGINT,
    p_grc_id BIGINT,
    p_kval_id BIGINT
) RETURNS INTEGER AS
$$
BEGIN
    IF NOT check_enum_val_class(p_to_id, 15) THEN
        RAISE NOTICE 'to_id должен наследоваться от Технологическая операция';
        RETURN 0;
    END IF;

    IF NOT check_enum_val_class(p_prof_id, 12) THEN
        RAISE NOTICE 'prof_id должен наследоваться от Профессия';
        RETURN 0;
    END IF;

    IF NOT check_enum_val_class(p_kval_id, 13) THEN
        RAISE NOTICE 'kval_id должен наследоваться от Классификация';
        RETURN 0;
    END IF;

    UPDATE tm
    SET prod_id = p_prod_id,
        num     = p_num,
        to_id   = p_to_id,
        prof_id = p_prof_id,
        grc_id  = p_grc_id,
        kval_id = p_kval_id
    WHERE id = p_id;

    IF FOUND THEN
        RETURN 1;
    ELSE
        RAISE NOTICE 'Элемент с id % не найден', p_id;
        RETURN 0;
    END IF;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при обновлении: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Удаление
CREATE OR REPLACE FUNCTION delete_tm(p_id BIGINT) RETURNS INTEGER AS
$$
BEGIN
    DELETE FROM tm WHERE id = p_id;

    IF FOUND THEN
        RETURN 1;
    ELSE
        RAISE NOTICE 'Элемент с id % не найден', p_id;
        RETURN 0;
    END IF;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при удалении: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

/*Дереянная ножка*/
SELECT insert_tm(3, 1, 15, 1, 2, 6); /*1*/
SELECT insert_tm(3, 2, 17, 3, 6, 8);
/*2*/

/*Деревенная столешница*/
SELECT insert_tm(5, 1, 16, 2, 4, 6); /*3*/
SELECT insert_tm(5, 2, 17, 3, 6, 8);
/*4*/

/*Деревянный стол*/
SELECT insert_tm(1, 1, 18, 4, 4, 5);
/*5*/

/*Металлическая ножка*/
SELECT insert_tm(4, 1, 15, 1, 1, 6); /*6*/
SELECT insert_tm(4, 2, 17, 3, 5, 8);
/*7*/

/*Металлическая столешница*/
SELECT insert_tm(6, 1, 16, 2, 3, 6); /*8*/
SELECT insert_tm(6, 2, 17, 3, 5, 8);
/*9*/

/*Металлическая стол*/
SELECT insert_tm(2, 1, 18, 4, 3, 5);
/*10*/

/*Деревенная заготовка*/
SELECT insert_tm(7, 1, 15, 1, 2, 8);
/*11*/

/*Металлическая заготовка*/
SELECT insert_tm(8, 1, 15, 1, 1, 8); /*12*/

SELECT *
FROM tm;
