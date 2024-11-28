# Задание для Junior data analyst
**Компания:** Самокат
**Уровень:** Junior  
**Навыки:** SQL

## Описание задачи
Необходимо написать sql запросы для выгрузки данных из базы ms sql используя следующие таблицы:		
		
warehouses (справочник складов)		
warehouse_id	integer	идентификатор склада
name	varchar	наименование склада
city	varchar	город
date_open	date	дата открытия склада
date_close	date	дата закрытия склада
		
product (справочник товаров)		
product_id	integer	идентификатор товара
name	varchar	наименование товара
group1	varchar	группа товаров 1 уровня
group2	varchar	группа товаров 2 уровня
group3	varchar	группа товаров 3 уровня
weight	decimal	вес товара
shelf_life	integer	срок годности товара в днях
		
orders (заказы)		
order_id	integer	идентификатор заказа
warehouse_id	integer	идентификатор склада
user_id	integer	идентификатор клиента
date	datetime	дата и время создания заказа
paid_amount	decimal	сумма заказа
quantity	decimal	количество единиц товаров в заказе
		
order_line (состав заказа)		
order_id	integer	идентификатор заказа
date	datetime	дата и время создания заказа
warehouse_id	integer	идентификатор склада
product_id	integer	идентификатор товара
price	decimal	цена продажи
regular_price	decimal	регулярная цена
cost_price	decimal	цена в себестоимости
quantity	decimal	количество единиц проданных товаров
paid_amount	decimal	сумма продаж
		
lost (потери)		
date	datetime	дата и время проведения потерь
warehouse_id	integer	идентификатор склада
product_id	integer	идентификатор товара
item_id	integer	идентификатор статьи потерь
quantity	decimal	потери в количестве
amount	decimal	сумма потерь

