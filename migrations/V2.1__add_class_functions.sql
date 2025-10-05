-- =============================================
-- Название: ins_class
-- Цель: Добавление нового класса изделия
-- Параметры:
--   p_name VARCHAR – Название класса
--   p_unit_id INTEGER – ID единицы измерения
--   p_parent_id INTEGER – ID родительского класса
-- Возвращает: TABLE (oIdClass INTEGER, oRes INTEGER)
--   oIdClass – ID нового класса
--   oRes – 1 при успехе, 0 при ошибке или если имя уже существует
-- =============================================
CREATE OR REPLACE FUNCTION ins_class(
    p_name VARCHAR,
    p_unit_id INTEGER,
    p_parent_id INTEGER
)
    RETURNS TABLE
            (
                oIdClass INTEGER,
                oRes     INTEGER
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM class WHERE name = p_name) THEN
            oRes := 0;
        ELSE
            INSERT INTO class (name, unit_id, parent_id)
            VALUES (p_name, p_unit_id, p_parent_id)
            RETURNING id INTO oIdClass;
            oRes := 1;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            oRes := 0;
    END;

    RETURN NEXT;
END;
$$;

-- =============================================
-- Название: del_class
-- Цель: Удаление класса изделия по ID
-- Параметры:
--   p_id INTEGER – ID удаляемого класса
-- Возвращает: INTEGER
--   1 – если успешно удалено
--   0 – если не найден или произошла ошибка
-- =============================================
CREATE OR REPLACE FUNCTION del_class(p_id INTEGER)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    oRes INTEGER := 1;
BEGIN
    BEGIN
        DELETE FROM class WHERE id = p_id;

        oRes := 1;
        IF NOT FOUND THEN
            oRes := 0; -- Класс не найден
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            oRes := 0; -- Ошибка
    END;

    RETURN oRes;
END;
$$;

-- =============================================
-- Название: upd_class
-- Цель: Обновление информации о классе изделия
-- Параметры:
--   p_id INTEGER – ID класса
--   p_name VARCHAR – Новое имя
--   p_unit_id INTEGER – Новая единица измерения
--   p_parent_id INTEGER – Новый родитель
-- Возвращает: INTEGER
--   1 – если успешно обновлено
--   0 – если не найден или произошла ошибка
-- =============================================
CREATE OR REPLACE FUNCTION upd_class(
    p_id INTEGER,
    p_name VARCHAR,
    p_unit_id INTEGER,
    p_parent_id INTEGER
)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    oRes INTEGER := 1;
BEGIN
    BEGIN
        UPDATE class
        SET name      = p_name,
            unit_id   = p_unit_id,
            id_parent = p_parent_id
        WHERE id = p_id;

        IF NOT FOUND THEN
            oRes := 0; -- Класс не найден
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            oRes := 0; -- Ошибка
    END;

    RETURN oRes;
END;
$$;

-- =============================================
-- Название: upd_class_parent
-- Цель: Изменение родителя у класса
-- Параметры:
--   p_class_id INTEGER – ID изменяемого класса
--   p_new_parent_id INTEGER – Новый родительский класс
-- Возвращает: INTEGER
--   1 – если успешно
--   0 – если ошибка или класс не найден
-- =============================================
CREATE OR REPLACE FUNCTION upd_class_parent(
    p_class_id INTEGER,
    p_new_parent_id INTEGER
)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    BEGIN
        UPDATE class
        SET id_parent = p_new_parent_id
        WHERE id = p_class_id;

        IF NOT FOUND THEN
            RETURN 0; -- Класс не найден
        END IF;
        RETURN 1; -- Успешно
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0; -- Ошибка
    END;
END;
$$;

-- =============================================
-- Название: has_circular_dependency
-- Цель: Проверка на наличие циклов в иерархии классов
-- Параметры: отсутствуют
-- Возвращает: BOOLEAN
--   TRUE – если найден цикл (ошибочная иерархия)
--   FALSE – если всё корректно
-- =============================================
CREATE OR REPLACE FUNCTION has_circular_dependency()
    RETURNS BOOLEAN
    LANGUAGE plpgsql
AS
$$
DECLARE
    class_rec   RECORD;
    visited_ids INTEGER[] := '{}';
    rec_stack   INTEGER[];
    parent_id   INTEGER;
    has_cycle   BOOLEAN   := FALSE;
BEGIN
    FOR class_rec IN SELECT id FROM class
        LOOP
            IF NOT class_rec.id = ANY (visited_ids) THEN
                rec_stack := '{}';
                LOOP
                    EXIT WHEN class_rec.id IS NULL;

                    IF class_rec.id = ANY (rec_stack) THEN
                        has_cycle := TRUE;
                        RETURN TRUE;
                    END IF;

                    rec_stack := array_append(rec_stack, class_rec.id);
                    visited_ids := array_append(visited_ids, class_rec.id);

                    SELECT id_parent INTO parent_id FROM class WHERE id = class_rec.id;

                    IF parent_id IS NOT NULL THEN
                        class_rec.id := parent_id;
                    ELSE
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
        END LOOP;

    RETURN has_cycle;
END;
$$;

-- =============================================
-- Название: get_descendants
-- Цель: Получение всех потомков заданного класса
-- Параметры:
--   p_class_id INTEGER – ID родительского класса
-- Возвращает: TABLE (classId INTEGER, className VARCHAR)
--   classId – ID потомка
--   className – Название потомка
-- =============================================
CREATE OR REPLACE FUNCTION get_descendants(p_class_id INTEGER)
    RETURNS TABLE
            (
                classId   INTEGER,
                className VARCHAR
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        WITH RECURSIVE descendants AS (SELECT c.id AS class_id, c.name AS class_name
                                       FROM class c
                                       WHERE c.id = p_class_id

                                       UNION ALL

                                       SELECT c.id, c.name
                                       FROM class c
                                                INNER JOIN descendants d ON c.id_parent = d.class_id)
        SELECT d.class_id, d.class_name
        FROM descendants d
        WHERE id <> p_class_id;
END;
$$;

-- =============================================
-- Название: change_child_order
-- Цель: Изменение порядка вывода потомка в иерархии
-- Параметры:
--   p_class_id INTEGER – ID класса, у которого меняется порядок
--   p_new_order INTEGER – Новое значение позиции
-- Возвращает: VOID
-- =============================================
CREATE OR REPLACE FUNCTION change_child_order(p_class_id INTEGER, p_new_order INTEGER)
    RETURNS VOID
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE class
    SET order_position = p_new_order
    WHERE id = p_class_id;
END;
$$;

-- =============================================
-- Название: get_ancestors
-- Цель: Получение всех родителей заданного класса
-- Параметры:
--   p_class_id INTEGER – ID потомка
-- Возвращает: TABLE (classId INTEGER, className VARCHAR)
--   classId – ID родителя
--   className – Название родителя
-- =============================================
CREATE OR REPLACE FUNCTION get_ancestors(p_class_id INTEGER)
    RETURNS TABLE
            (
                classId   INTEGER,
                className VARCHAR
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        WITH RECURSIVE ancestors AS (SELECT c.id, c.name, c.id_parent
                                     FROM class AS c
                                     WHERE c.id = p_class_id

                                     UNION ALL

                                     SELECT c.id, c.name, c.id_parent
                                     FROM class AS c
                                              JOIN ancestors AS a ON c.id = a.id_parent)
        SELECT id, name
        FROM ancestors
        WHERE id <> p_class_id;
END;
$$;

-- =============================================
-- Название: get_terminal_classes
-- Цель: Получение всех терминальных (листовых) классов
-- Параметры:
--   start_id INTEGER – ID начального (родительского) класса
-- Возвращает: TABLE (classId INTEGER, className VARCHAR)
--   classId – ID терминального класса
--   className – Название терминального класса
-- =============================================
CREATE OR REPLACE FUNCTION get_terminal_classes(start_id INTEGER)
    RETURNS TABLE
            (
                classId   INTEGER,
                className VARCHAR
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        WITH RECURSIVE descendants AS (
            -- Первый уровень потомков
            SELECT c.id, c.name
            FROM class c
            WHERE c.id_parent = start_id

            UNION ALL

            -- Рекурсивный выбор всех вложенных потомков
            SELECT c.id, c.name
            FROM class c
                     JOIN descendants d ON c.id_parent = d.id)
        -- Оставляем у кого нет детей
        SELECT d.id, d.name
        FROM descendants d
        WHERE NOT EXISTS (SELECT 1
                          FROM class c
                          WHERE c.id_parent = d.id);
END;
$$;
