create table if not exists grc
(
    id            BIGSERIAL PRIMARY KEY,
    chem_class_id BIGINT REFERENCES chem_class (id) ON DELETE CASCADE,
    shd           BIGINT REFERENCES shd (id) ON DELETE CASCADE,
    name          varchar(255) NOT NULL
);

-- Вставка
CREATE OR REPLACE FUNCTION insert_grc(p_chem_class_id BIGINT, p_shd BIGINT, p_name VARCHAR(255)) RETURNS INTEGER AS
$$
BEGIN
    IF NOT is_descendant_of(p_chem_class_id, 4) THEN
        RAISE NOTICE 'chem_class_id должен наследоваться от Групповой Рабочий Центр';
        RETURN 0;
    END IF;

    INSERT INTO grc (chem_class_id, shd, name) VALUES (p_chem_class_id, p_shd, p_name);
    RETURN 1;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при вставке: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Изменение
CREATE OR REPLACE FUNCTION update_grc(p_id BIGINT, p_chem_class_id BIGINT, p_shd BIGINT,
                                      p_name VARCHAR(255)) RETURNS INTEGER AS
$$
BEGIN
    IF NOT is_descendant_of(p_chem_class_id, 4) THEN
        RAISE NOTICE 'chem_class_id должен наследоваться от Групповой Рабочий Центр';
        RETURN 0;
    END IF;

    UPDATE grc SET chem_class_id = p_chem_class_id, shd = p_shd, name = p_name WHERE id = p_id;

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
CREATE OR REPLACE FUNCTION delete_grc(p_id BIGINT) RETURNS INTEGER AS
$$
BEGIN
    DELETE FROM grc WHERE id = p_id;

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

-- Вывод по chem_class_id
CREATE OR REPLACE FUNCTION get_grc_by_chem_class(p_chem_class_id BIGINT)
    RETURNS TABLE
            (
                id            BIGINT,
                chem_class_id BIGINT,
                shd           BIGINT,
                name          VARCHAR(255)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT g.id, g.chem_class_id, g.shd, g.name
        FROM grc g
        WHERE g.chem_class_id = p_chem_class_id
        ORDER BY g.id;
END;
$$ LANGUAGE plpgsql;

SELECT insert_chem_class('ТЦ', 'Токарный центр', 4); /*9*/
SELECT insert_chem_class('ФР', 'Фрезерный центр', 4); /*10*/
SELECT insert_chem_class('МЦ', 'Малярный центр', 4); /*11*/

SELECT *
FROM chem_class;

SELECT insert_grc(9, 1, 'Металлообрабатывающий токарный центр');
SELECT insert_grc(9, 2, 'Деревообрабатывающий токарный центр');

SELECT get_grc_by_chem_class(9);

SELECT insert_grc(10, 1, 'Металлообрабатывающий фрезерный центр');
SELECT insert_grc(10, 2, 'Деревообрабатывающий фрезерный центр');

SELECT get_grc_by_chem_class(10);

SELECT insert_grc(11, 3, 'Малярный центр по металлу');
SELECT insert_grc(11, 3, 'Малярный центр по дереверу');

SELECT get_grc_by_chem_class(11);
