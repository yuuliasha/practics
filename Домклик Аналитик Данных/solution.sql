Ссылка на таблицу https://docs.google.com/spreadsheets/d/1osv35u1JcJf8XHKfka042Q1n7WjC4IDV/edit?gid=321232318#gid=321232318
																									
С помоощью SQL запросов получить:																									
1. Название страны, в которой находится город "Казань".			

Решение:
Нужно соединить таблицы cities, regions, и countries, чтобы найти страну, в которой находится город "Казань". 
Это требует связывания через внешний ключ.

SELECT c.name AS country_name
FROM countries c
JOIN regions r ON c.id = r.countryid
JOIN cities ct ON r.id = ct.regionid
WHERE ct.name = 'Казань';
																								
2. Количество городов в московской области																									
Решение:
Для решения задачи нужно подсчитать количество городов, принадлежащих Московской области (в таблице regions — Московская область).

SELECT COUNT(*) AS city_count
FROM cities ct
JOIN regions r ON ct.regionid = r.id
WHERE r.name = 'Московская область';
	
Пояснение:
JOIN cities ct ON ct.regionid = r.id — соединяем города с регионами.
WHERE r.name = 'Московская область' — фильтруем города Московской области.
COUNT(*) — считаем количество городов.
																															
3. Количество уборок снега проведенных с начала декабря 2020 по конец февраля 2021.																									
Решение:
Необходимо найти все события уборки снега (тип события "Уборка снега") за указанный период времени.

SELECT COUNT(*) AS snow_cleaning_count
FROM events e
JOIN types t ON e.typeid = t.id
WHERE t.name = 'Уборка снега' AND e.date BETWEEN '2020-12-01' AND '2021-02-28';

Пояснение:
JOIN types t ON e.typeid = t.id — соединяем события с типами событий.
WHERE t.name = 'Уборка снега' — фильтруем только события уборки снега.
AND e.date BETWEEN '2020-12-01' AND '2021-02-28' — выбираем события за указанный период.									
																									
4. Вывести городское население каждого региона.								
Решение:
Для получения общего населения городов по каждому региону, нужно соединить таблицы регионов и городов, а затем агрегировать по региону.
SELECT r.name AS region_name, SUM(ct.population) AS total_population
FROM cities ct
JOIN regions r ON ct.regionid = r.id
GROUP BY r.name;

Пояснение:
SUM(ct.population) — суммируем население городов для каждого региона.
GROUP BY r.name — группируем данные по регионам.

5.Посчитать кол-во уборок снега в Москве за последние 3 года																									
Решение:
Нужно выбрать события уборки снега, проведенные в Москве за последние 3 года.					

SELECT COUNT(*) AS snow_cleaning_count
FROM events e
JOIN types t ON e.typeid = t.id
JOIN cities ct ON e.cityid = ct.id
WHERE t.name = 'Уборка снега' AND ct.name = 'Москва' AND e.date >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR);

Пояснение:
JOIN cities ct ON e.cityid = ct.id — соединяем события с городами.
WHERE t.name = 'Уборка снега' AND ct.name = 'Москва' — фильтруем события уборки снега в Москве.
AND e.date >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR) — выбираем события за последние 3 года.
																								
6. Посчитать средние траты на каждый тип события за последние 5 лет в Санкт-Птеребурге																
страна  									
Решение:
Нужно найти события в Санкт-Петербурге за последние 5 лет и рассчитать средние траты по каждому типу событий.
SELECT t.name AS event_type, AVG(e.costs) AS avg_costs
FROM events e
JOIN types t ON e.typeid = t.id
JOIN cities ct ON e.cityid = ct.id
WHERE ct.name = 'Санкт-Петербург' AND e.date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
GROUP BY t.name;

Пояснение:
AVG(e.costs) — считаем средние траты на события.
WHERE ct.name = 'Санкт-Петербург' AND e.date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR) — фильтруем события в Санкт-Петербурге за последние 5 лет.

7. Посчитать среднее время между одинаковыми событиями для каждого города		
Решение:
Чтобы найти среднее время между одинаковыми событиями для каждого города, нужно рассчитать разницу между датами событий одного типа для каждого города.
WITH event_diffs AS (
SELECT e.cityid, e.typeid, DATEDIFF(LEAD(e.date) OVER (PARTITION BY e.cityid, e.typeid ORDER BY e.date), e.date) AS diff_days
FROM events e
)
SELECT ct.name AS city_name, t.name AS event_type, AVG(ed.diff_days) AS avg_diff_days
FROM event_diffs ed
JOIN cities ct ON ed.cityid = ct.id
JOIN types t ON ed.typeid = t.id
GROUP BY ct.name, t.name;

Пояснение:
LEAD(e.date) OVER (...) — используем оконную функцию, чтобы получить следующую дату события того же типа для города.
DATEDIFF(...) — считаем разницу в днях между событиями.
AVG(ed.diff_days) — считаем среднее время между событиями.

																												
 8. Посчитать среднюю стоимость трат по каждому типу события на 1 человека в год, для каждого региона																
регион	население								Регион	Тип	Стоимость на человека в год														
																													
Решение:
Нужно рассчитать средние траты на тип события на одного человека за год, разделив общие траты на население региона и количество лет.

WITH yearly_costs AS (
SELECT r.id AS region_id,t.name AS event_type, SUM(e.costs) / COUNT(DISTINCT YEAR(e.date)) AS total_yearly_costs
FROM events e
JOIN cities ct ON e.cityid = ct.id
JOIN regions r ON ct.regionid = r.id
JOIN types t ON e.typeid = t.id
GROUP BY r.id, t.name
)
SELECT r.name AS region_name, yc.event_type, 
    (yc.total_yearly_costs / SUM(ct.population)) AS cost_per_person
FROM yearly_costs yc
JOIN regions r ON yc.region_id = r.id
JOIN cities ct ON r.id = ct.regionid
GROUP BY r.name, yc.event_type;
Пояснение:
SUM(e.costs) / COUNT(DISTINCT YEAR(e.date)) — находим общие годовые траты по каждому региону и типу события.
(yc.total_yearly_costs / SUM(ct.population)) — делим траты на население региона, чтобы получить стоимость на одного человека.																									
																										
