create table if not exists shd
(
    id            BIGSERIAL PRIMARY KEY,
    chem_class_id BIGINT REFERENCES chem_class (id) ON DELETE CASCADE,
    name          VARCHAR(255) not null
);

-- Вставка
CREATE OR REPLACE FUNCTION insert_shd(p_chem_class_id BIGINT, p_name VARCHAR(255)) RETURNS INTEGER AS
$$
BEGIN
    IF NOT is_descendant_of(p_chem_class_id, 3) THEN
        RAISE NOTICE 'chem_class_id должен наследоваться от СХД';
        RETURN 0;
    END IF;

    INSERT INTO shd (chem_class_id, name) VALUES (p_chem_class_id, p_name);
    RETURN 1;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при вставке: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Изменение
CREATE OR REPLACE FUNCTION update_shd(p_id BIGINT, p_chem_class_id BIGINT, p_name VARCHAR(255)) RETURNS INTEGER AS
$$
BEGIN
    IF NOT is_descendant_of(p_chem_class_id, 3) THEN
        RAISE NOTICE 'chem_class_id должен наследоваться от СХД';
        RETURN 0;
    END IF;

    UPDATE shd SET chem_class_id = p_chem_class_id, name = p_name WHERE id = p_id;

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
CREATE OR REPLACE FUNCTION delete_shd(p_id BIGINT) RETURNS INTEGER AS
$$
BEGIN
    DELETE FROM shd WHERE id = p_id;

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

-- Вывод всех СХД по chem_class_id
CREATE OR REPLACE FUNCTION get_shd_by_chem_class(p_chem_class_id BIGINT)
    RETURNS TABLE
            (
                id            BIGINT,
                chem_class_id BIGINT,
                name          VARCHAR(255)
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT s.id, s.chem_class_id, s.name
        FROM shd s
        WHERE s.chem_class_id = p_chem_class_id
        ORDER BY s.id;
END;
$$ LANGUAGE plpgsql;

SELECT insert_chem_class('СК', 'Склад', 3); /*6*/
SELECT insert_chem_class('ЦХ', 'Цех', 3); /*7*/
SELECT insert_chem_class('ОТ', 'Отдел', 3); /*8*/

SELECT *
FROM chem_class;

SELECT insert_shd(6, 'Склад большой');
SELECT insert_shd(6, 'Склад средний');
SELECT insert_shd(6, 'Склад маленький');

SELECT get_shd_by_chem_class(6);

SELECT insert_shd(7, 'Цех большой');
SELECT insert_shd(7, 'Цех средний');
SELECT insert_shd(7, 'Цех маленький');

SELECT get_shd_by_chem_class(7);

SELECT insert_shd(8, 'Отдел большой');
SELECT insert_shd(8, 'Отдел средний');
SELECT insert_shd(8, 'Отдел маленький');

SELECT get_shd_by_chem_class(8);
