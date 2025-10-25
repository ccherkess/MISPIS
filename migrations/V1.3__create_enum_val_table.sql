CREATE TABLE IF NOT EXISTS enum_val
(
    id            BIGSERIAL PRIMARY KEY,
    chem_class_id BIGINT REFERENCES chem_class (id) ON DELETE CASCADE,
    num           BIGINT       NOT NULL,
    short_name    VARCHAR(255) NOT NULL,
    name          VARCHAR(255) NOT NULL,
    real_val      REAL,
    int_val       INTEGER,
    text_val      TEXT
);

-- Вставка
CREATE OR REPLACE FUNCTION insert_enum_val(
    p_chem_class_id BIGINT,
    p_num BIGINT,
    p_short_name VARCHAR(255),
    p_name VARCHAR(255),
    p_real_val REAL DEFAULT NULL,
    p_int_val INTEGER DEFAULT NULL,
    p_text_val TEXT DEFAULT NULL
) RETURNS INTEGER AS
$$
BEGIN
    IF NOT is_descendant_of(p_chem_class_id, 5) THEN
        RAISE NOTICE 'chem_class_id должен наследоваться от перечеслений';
        RETURN 0;
    END IF;

    INSERT INTO enum_val (chem_class_id, num, short_name, name, real_val, int_val, text_val)
    VALUES (p_chem_class_id, p_num, p_short_name, p_name, p_real_val, p_int_val, p_text_val);
    RETURN 1;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при вставке: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Изменение
CREATE OR REPLACE FUNCTION update_enum_val(
    p_id BIGINT,
    p_chem_class_id BIGINT,
    p_num BIGINT,
    p_short_name VARCHAR(255),
    p_name VARCHAR(255),
    p_real_val REAL DEFAULT NULL,
    p_int_val INTEGER DEFAULT NULL,
    p_text_val TEXT DEFAULT NULL
) RETURNS INTEGER AS
$$
BEGIN
    IF NOT is_descendant_of(p_chem_class_id, 5) THEN
        RAISE NOTICE 'chem_class_id должен наследоваться от перечеслений';
        RETURN 0;
    END IF;

    UPDATE enum_val
    SET chem_class_id = p_chem_class_id,
        num           = p_num,
        short_name    = p_short_name,
        name          = p_name,
        real_val      = p_real_val,
        int_val       = p_int_val,
        text_val      = p_text_val
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
CREATE OR REPLACE FUNCTION delete_enum_val(p_id BIGINT) RETURNS INTEGER AS
$$
BEGIN
    DELETE FROM enum_val WHERE id = p_id;

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

-- Получение всех перечислений по chem_class_id
CREATE OR REPLACE FUNCTION get_enum_vals_by_chem_class(p_chem_class_id BIGINT)
    RETURNS TABLE
            (
                id            BIGINT,
                chem_class_id BIGINT,
                num           BIGINT,
                short_name    VARCHAR(255),
                name          VARCHAR(255),
                real_val      REAL,
                int_val       INTEGER,
                text_val      TEXT
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT e.id,
               e.chem_class_id,
               e.num,
               e.short_name,
               e.name,
               e.real_val,
               e.int_val,
               e.text_val
        FROM enum_val e
        WHERE e.chem_class_id = p_chem_class_id
        ORDER BY e.num;
END;
$$ LANGUAGE plpgsql;

-- Проверка на наследование
CREATE OR REPLACE FUNCTION check_enum_val_class(p_enum_val_id BIGINT, p_parent_class_id BIGINT)
    RETURNS BOOLEAN AS
$$
DECLARE
    v_chem_class_id BIGINT;
BEGIN
    SELECT chem_class_id
    INTO v_chem_class_id
    FROM enum_val
    WHERE id = p_enum_val_id;

    IF v_chem_class_id IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN is_descendant_of(v_chem_class_id, p_parent_class_id);
END;
$$ LANGUAGE plpgsql;

SELECT insert_chem_class('ПРОФ', 'Профессия', 5); /*12*/
SELECT insert_chem_class('КС', 'Классификация', 5); /*13*/
SELECT insert_chem_class('ЕИ', 'Еденица измерения', 5); /*14*/
SELECT insert_chem_class('ТО', 'Технологическая операция', 5); /*15*/

SELECT *
FROM chem_class;

SELECT insert_enum_val(12, 1, 'ТР', 'Токарь', null, null, 'Специалист по токарной обработке');
SELECT insert_enum_val(12, 2, 'ФК', 'Фрезеровщик', null, null, 'Специалист по фрезерной обработке');
SELECT insert_enum_val(12, 3, 'МР', 'Маляр', null, null, 'Специалист по малярным работам');
SELECT insert_enum_val(12, 4, 'СЛ', 'Слесарь', null, null, 'Специалист по слесарным работам');

SELECT get_enum_vals_by_chem_class(12);

SELECT insert_enum_val(13, 1, '1 РД', '1 Разряд', null, 1, null);
SELECT insert_enum_val(13, 2, '2 РД', '2 Разряд', null, 2, null);
SELECT insert_enum_val(13, 3, '3 РД', '3 Разряд', null, 3, null);
SELECT insert_enum_val(13, 4, '4 РД', '4 Разряд', null, 4, null);
SELECT insert_enum_val(13, 5, '5 РД', '5 Разряд', null, 5, null);

SELECT get_enum_vals_by_chem_class(13);

SELECT insert_enum_val(14, 1, 'М', 'Метр', null, null, null);
SELECT insert_enum_val(14, 2, 'КГ', 'Киллограм', null, null, null);
SELECT insert_enum_val(14, 3, 'Л', 'Литр', null, null, null);
SELECT insert_enum_val(14, 4, 'Ч', 'Час', null, null, null);
SELECT insert_enum_val(14, 5, 'Шт', 'Штук', null, null, null);

SELECT get_enum_vals_by_chem_class(14);

SELECT insert_enum_val(15, 1, 'Т', 'Токарная', 4, null, null);
SELECT insert_enum_val(15, 2, 'Ф', 'Фрезерная', 8, null, null);
SELECT insert_enum_val(15, 3, 'М', 'Малярная', 12, null, null);
SELECT insert_enum_val(15, 3, 'С', 'Слесарная', 2, null, null);

SELECT get_enum_vals_by_chem_class(15);
