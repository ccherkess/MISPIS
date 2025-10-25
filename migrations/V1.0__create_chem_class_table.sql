CREATE TABLE IF NOT EXISTS chem_class
(
    id         BIGSERIAL PRIMARY KEY,
    short_name VARCHAR(255) NOT NULL,
    name       VARCHAR(255) NOT NULL,
    parent_id  BIGINT       REFERENCES chem_class (id) ON DELETE SET NULL
);

-- Вставка
CREATE OR REPLACE FUNCTION insert_chem_class(
    p_short_name VARCHAR(255),
    p_name VARCHAR(255),
    p_parent_id BIGINT DEFAULT NULL
) RETURNS INTEGER AS
$$
BEGIN
    INSERT INTO chem_class (short_name, name, parent_id)
    VALUES (p_short_name, p_name, p_parent_id);
    RETURN 1;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при вставке: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Изменение
CREATE OR REPLACE FUNCTION update_chem_class(
    p_id BIGINT,
    p_short_name VARCHAR(255),
    p_name VARCHAR(255),
    p_parent_id BIGINT DEFAULT NULL
) RETURNS INTEGER AS
$$
BEGIN
    UPDATE chem_class
    SET short_name = p_short_name,
        name       = p_name,
        parent_id  = p_parent_id
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
CREATE OR REPLACE FUNCTION delete_chem_class(p_id BIGINT) RETURNS INTEGER AS
$$
BEGIN
    DELETE FROM chem_class WHERE id = p_id;

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

-- проверка на наследование
CREATE OR REPLACE FUNCTION is_descendant_of(
    p_child_id BIGINT,
    p_parent_id BIGINT
) RETURNS BOOLEAN AS
$$
DECLARE
    current_id BIGINT := p_child_id;
BEGIN
    WHILE current_id IS NOT NULL AND current_id != p_parent_id
        LOOP
            SELECT parent_id
            INTO current_id
            FROM chem_class
            WHERE id = current_id;
        END LOOP;

    RETURN current_id = p_parent_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prevent_delete_root()
    RETURNS TRIGGER AS
$$
BEGIN
    IF OLD.id = 1 OR OLD.id = 2 OR OLD.id = 3 OR OLD.id = 4 OR OLD.id = 5 THEN
        RAISE EXCEPTION 'Запрещено удалять базовые классы!';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_root_deletion
    BEFORE DELETE
    ON chem_class
    FOR EACH ROW
EXECUTE FUNCTION prevent_delete_root();

SELECT insert_chem_class('БЗ', 'Базовый класс', NULL); /*1*/
SELECT insert_chem_class('ПР', 'Продукт', 1); /*2*/
SELECT insert_chem_class('CХД', 'Субъект Хозяйственной Деятельности', 1); /*3*/
SELECT insert_chem_class('ГРЦ', 'Групповой Рабочий Центр', 1); /*4*/
SELECT insert_chem_class('ПЕР', 'Перечисления', 1); /*5*/

SELECT *
FROM chem_class;
