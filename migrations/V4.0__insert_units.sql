SELECT ins_unit('Метр', 'м', 1, NULL);
SELECT ins_unit('Килограмм', 'кг', 1, NULL);
SELECT ins_unit('Литр', 'л', 1, NULL);

SELECT ins_unit('Километр', 'км', 1000, 1);
SELECT ins_unit('Дециметр', 'дм', 0.1, 1);
SELECT ins_unit('Сантиметр', 'см', 0.01, 1);
SELECT ins_unit('Миллиметр', 'мм', 0.001, 1);
SELECT ins_unit('Микрометр', 'мкм', 0.000001, 1);
SELECT ins_unit('Нанометр', 'нм', 0.000000001, 1);
SELECT ins_unit('Морская миля', 'M', 1852, 1);
SELECT ins_unit('Ярд', 'yd', 0.9144, 1);
SELECT ins_unit('Фут', 'ft', 0.3048, 1);
SELECT ins_unit('Дюйм', 'in', 0.0254, 1);

SELECT ins_unit('Грамм', 'г', 0.001, 2);
SELECT ins_unit('Миллиграмм', 'мг', 0.000001, 2);
SELECT ins_unit('Центнер', 'ц', 100, 2);
SELECT ins_unit('Тонна', 'т', 1000, 2);
SELECT ins_unit('Фунт', 'lb', 0.453592, 2);
SELECT ins_unit('Унция', 'oz', 0.0283495, 2);
SELECT ins_unit('Карат', 'ct', 0.0002, 2);

SELECT ins_unit('Миллилитр', 'мл', 0.001, 3);
SELECT ins_unit('Кубический метр', 'м³', 1000, 3);
SELECT ins_unit('Кубический сантиметр', 'см³', 0.001, 3);
SELECT ins_unit('Галлон (US)', 'gal', 3.78541, 3);
SELECT ins_unit('Пинта (US)', 'pt', 0.473176, 3);
SELECT ins_unit('Кварта (US)', 'qt', 0.946353, 3);
SELECT ins_unit('Баррель нефтяной', 'bbl', 158.987, 3);
