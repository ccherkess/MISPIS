create table if not exists prod
(
    id            BIGSERIAL PRIMARY KEY,
    chem_class_id BIGINT REFERENCES chem_class (id) ON DELETE CASCADE,
    amount        BIGINT NOT NULL,
    price         REAL   NOT NULL
);

-- Вставка
CREATE OR REPLACE FUNCTION insert_prod(
    p_chem_class_id BIGINT,
    p_amount BIGINT,
    p_price REAL
) RETURNS INTEGER AS
$$
BEGIN
    IF NOT is_descendant_of(p_chem_class_id, 2) THEN
        RAISE NOTICE 'chem_class_id должен наследоваться от Продукт';
        RETURN 0;
    END IF;

    INSERT INTO prod (chem_class_id, amount, price)
    VALUES (p_chem_class_id, p_amount, p_price);
    RETURN 1;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Ошибка при вставке: %', SQLERRM;
        RETURN 0;
END;
$$ LANGUAGE plpgsql;

-- Изменение
CREATE OR REPLACE FUNCTION update_prod(
    p_id BIGINT,
    p_chem_class_id BIGINT,
    p_amount BIGINT,
    p_price REAL
) RETURNS INTEGER AS
$$
BEGIN
    IF NOT is_descendant_of(p_chem_class_id, 2) THEN
        RAISE NOTICE 'chem_class_id должен наследоваться от Продукт';
        RETURN 0;
    END IF;

    UPDATE prod
    SET chem_class_id = p_chem_class_id,
        amount        = p_amount,
        price         = p_price
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
CREATE OR REPLACE FUNCTION delete_prod(p_id BIGINT) RETURNS INTEGER AS
$$
BEGIN
    DELETE FROM prod WHERE id = p_id;

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

SELECT insert_chem_class('СЛ', 'Стол', 2); /*16*/
SELECT insert_chem_class('ДСЛ', 'Деревянный Стол', 16); /*17*/
SELECT insert_chem_class('МСЛ', 'Металлический Стол', 16); /*18*/

SELECT insert_chem_class('НС', 'Ножка стола', 2); /*19*/
SELECT insert_chem_class('ДНС', 'Деревянная Ножка стола', 19); /*20*/
SELECT insert_chem_class('МНС', 'Металлическая Ножка стола', 19); /*21*/

SELECT insert_chem_class('С', 'Столешница', 2); /*22*/
SELECT insert_chem_class('ДС', 'Деревянная Столешница', 22); /*23*/
SELECT insert_chem_class('МС', 'Металлическая Столешница', 22); /*24*/

SELECT insert_chem_class('З', 'Заготовка', 2);/*25*/
SELECT insert_chem_class('ДЗ', 'Деревенная Заготовка', 2);/*26*/
SELECT insert_chem_class('МЗ', 'Металлическая Заготовка', 2);/*27*/

SELECT *
FROM chem_class;

SELECT insert_prod(17, 10, 15000); /*1*/
SELECT insert_prod(18, 10, 30000); /*2*/
SELECT insert_prod(20, 30, 1000); /*3*/
SELECT insert_prod(21, 30, 1800); /*4*/
SELECT insert_prod(23, 20, 10000); /*5*/
SELECT insert_prod(24, 20, 20000); /*6*/
SELECT insert_prod(26, 1000, 500); /*7*/
SELECT insert_prod(27, 1000, 1000); /*8*/

SELECT *
FROM prod;
