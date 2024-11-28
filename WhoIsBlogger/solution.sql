Решение:
1. Наполнение данных
Начнем с генерации данных для таблиц Users, Purchases, и Items, чтобы мы могли протестировать запросы.

-- Создаем таблицу Users
CREATE TABLE Users (userId INTEGER PRIMARY KEY, age INTEGER);
-- Вставляем данные для Users
INSERT INTO Users (userId, age)
VALUES (1, 20), (2, 22), (3, 28), (4, 30), (5, 40), (6, 36), (7, 19), (8, 45);

-- Создаем таблицу Items
CREATE TABLE Items (itemId INTEGER PRIMARY KEY, price DECIMAL );

-- Вставляем данные для Items
INSERT INTO Items (itemId, price)
VALUES (1, 50.00), (2, 30.00), (3, 100.00), (4, 200.00), (5, 75.00);

-- Создаем таблицу Purchases
CREATE TABLE Purchases (purchaseId INTEGER PRIMARY KEY, userId INTEGER, itemId INTEGER, date DATE,
FOREIGN KEY (userId) REFERENCES Users(userId),
FOREIGN KEY (itemId) REFERENCES Items(itemId));

-- Вставляем данные для Purchases
INSERT INTO Purchases (purchaseId, userId, itemId, date)
VALUES (1, 1, 1, '2023-01-15'), (2, 2, 2, '2023-02-12'), (3, 3, 3, '2023-03-22'), 
(4, 4, 4, '2023-03-25'), (5, 5, 1, '2023-04-17'), (6, 6, 5, '2023-05-10'), 
(7, 1, 3, '2023-06-21'),(8, 7, 1, '2023-07-19'),(9, 8, 4, '2023-08-05'), (10, 5, 2, '2023-09-14');

Задание А: Средняя сумма покупок в месяц для пользователей 18-25 и 26-35 лет
-- Средняя сумма покупок в месяц для возрастной группы 18-25 лет
Решение:
1. Используем таблицы Purchases, Users и Items.
2. Фильтруем пользователей по возрасту, используя диапазоны: для первой группы возраст между 18 и 25 лет включительно, для второй группы — 26-35 лет.
3. Для каждого пользователя получаем его покупки, соединяя таблицы Purchases и Items, чтобы извлечь цену товара.
4. Используем функцию AVG() для расчета средней суммы покупок.
5. Используем функцию STRFTIME('%m', date) (или эквивалент в PostgreSQL) для группировки по месяцам.

Результат: Получим средние траты за каждый месяц для каждой возрастной группы.

SELECT EXTRACT(MONTH FROM p.date) AS month, AVG(i.price) AS avg_monthly_spend
FROM Purchases p
JOIN Users u ON p.userId = u.userId
JOIN Items i ON p.itemId = i.itemId
WHERE u.age BETWEEN 18 AND 25
GROUP BY EXTRACT(MONTH FROM p.date)
ORDER BY month

-- Средняя сумма покупок в месяц для возрастной группы 26-35 лет
SELECT EXTRACT(MONTH FROM p.date) AS month, AVG(i.price) AS avg_monthly_spend
FROM Purchases p
JOIN Users u ON p.userId = u.userId
JOIN Items i ON p.itemId = i.itemId
WHERE u.age BETWEEN 26 AND 35
GROUP BY EXTRACT(MONTH FROM p.date)
ORDER BY month;

Задание Б: Месяц с наибольшей выручкой для пользователей 35+
Решение: 
1. Фильтруем пользователей, чей возраст больше 35 лет.
2. Соединяем таблицы Purchases, Users и Items, чтобы связать покупки с товарами и получить их стоимость.
3. Группируем данные по месяцам с помощью функции STRFTIME('%m', date) (для SQLite) или EXTRACT(MONTH FROM date) (для PostgreSQL).
4. Используем функцию SUM() для расчета общей выручки за каждый месяц.
5. Сортируем данные по убыванию выручки и выбираем месяц с максимальной выручкой (с помощью LIMIT 1).

Результат: Получим месяц с наибольшей выручкой от пользователей старше 35 лет.

SELECT EXTRACT(MONTH FROM p.date) AS month, SUM(i.price) AS total_revenue
FROM Purchases p
JOIN Users u ON p.userId = u.userId
JOIN Items i ON p.itemId = i.itemId
WHERE u.age > 35
GROUP BY EXTRACT(MONTH FROM p.date)
ORDER BY total_revenue DESC
LIMIT 1;

Задание В: Товар с наибольшим вкладом в выручку за последний год
-- Предположим, что текущий год - 2023
Решение: 
1. Соединяем таблицы Purchases и Items, чтобы связать покупки с товарами и получить их стоимость.
2. Отфильтровываем данные по дате покупок, начиная с начала предыдущего года (или заданного периода).
3. Используем функцию SUM() для расчета общей выручки по каждому товару.
Сортируем результаты по убыванию общей выручки и выбираем товар с наибольшей выручкой (с помощью LIMIT 1).

Результат: Получим товар с наибольшим вкладом в общую выручку за последний год.

SELECT p.itemId, SUM(i.price) AS total_revenue
FROM Purchases p
JOIN Items i ON p.itemId = i.itemId
WHERE p.date >= '2022-01-01'
GROUP BY p.itemId
ORDER BY total_revenue DESC
LIMIT 1;

Задание Г: Топ-3 товаров по выручке и их доля в общей выручке за год
Решение:
1. В первом подзапросе TotalRevenue считаем общую выручку за год с помощью функции SUM().
2. Во втором подзапросе TopItems считаем выручку для каждого товара и сортируем результаты по убыванию выручки. 
Ограничиваем выборку тремя товарами с помощью LIMIT 3.
3. В основном запросе считаем долю выручки каждого товара в общей выручке, используя формулу (item_revenue / total_revenue) * 100, чтобы получить процент.
Результат: Получим топ-3 товаров по выручке и их процентную долю в общей выручке за указанный год.

WITH TotalRevenue AS (
    SELECT SUM(i.price) AS total_revenue
    FROM Purchases p
    JOIN Items i ON p.itemId = i.itemId
    WHERE p.date BETWEEN '2023-01-01' AND '2023-12-31'),
TopItems AS (
    SELECT p.itemId, SUM(i.price) AS item_revenue
    FROM Purchases p
    JOIN Items i ON p.itemId = i.itemId
    WHERE p.date BETWEEN '2023-01-01' AND '2023-12-31'
    GROUP BY p.itemId
    ORDER BY item_revenue DESC
    LIMIT 3)
SELECT t.itemId, t.item_revenue, ROUND((t.item_revenue / tr.total_revenue) * 100, 2) AS revenue_share_percentage
FROM TopItems t, TotalRevenue tr;
