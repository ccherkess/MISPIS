SELECT ins_item(4, 'Кирпич рядовой полнотелый', 146988, 27);
SELECT ins_item(5, 'Кирпич рядовой поризованный', 96941, 19);
SELECT ins_item(8, 'Блок бетонный перегородочный', 10437, 83);
SELECT ins_item(10, 'Газобетон ЛСР', 18275, 8288);
SELECT ins_item(12, 'Фундаментный блок ФБС', 2117, 330);

SELECT ins_item(14, 'Газабетонное ограждение из ЛСР', 10, 10000);
SELECT ins_item(15, 'Кирпичное ограждение из полнотелого кирпича', 10, 5000);

SELECT ins_spec_item(6, 4, 100, 0);
SELECT ins_spec_item(6, 5, 10, 1);

SELECT ins_spec_item(7, 1, 500, 0);
SELECT ins_spec_item(7, 5, 15, 1);

SELECT create_modification(6, 'Газабетонное ограждение из ЛСР УСИЛЕННОЕ');
SELECT create_modification(7, 'Кирпичное ограждение из полнотелого кирпича УСИЛЕННОЕ');

SELECT upd_spec_item(5, null, 1000, null, null);
SELECT upd_spec_item(7, null, 5000, null, null);

SELECT ins_item(16, 'Комбинированное ограждение из кирпичных и газобетонных стен', 1, 500000);


SELECT ins_spec_item(10, 6, 1000, 0);
SELECT ins_spec_item(10, 9, 1000, 1);
