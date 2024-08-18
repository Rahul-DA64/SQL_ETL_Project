create table df_orders (
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code varchar(20),
region varchar(20),
category varchar(20),
sub_category varchar(20),
product_id varchar(50),
quantity int,
discount decimal(7,2),
sale_price decimal(7,2),
profit decimal(7,2)
)




-- Find top 10 highest reveue generating products
SELECT product_id, SUM(sale_price) as revenue
FROM df_orders
GROUP BY product_id
ORDER BY revenue 
DESC Limit 10;

-- Find top 5 highest selling products in each region
-- select * from df_orders;
with cte as (select region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id
)
select * from (select *,
rank() over(partition by region order by sales desc) as rn
from cte) as x
where rn<=5;

-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
-- select * from df_orders
with cte as (select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
from df_orders
group by year(order_date), month(order_date)
-- order by year(order_date), month(order_date)
)
select order_month,
SUM(case when order_year = 2022 then sales else 0 end) as sales_2022,
SUM(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- For each category which month had highest sales
-- select * from df_orders

with cte as 
(select date_format(order_date,'%Y - %m') as order_year_month, category, sum(sale_price) as sales
from df_orders
group by order_year_month, category
-- order by order_year_month, category
)
select * from
(select *,
row_number() over(partition by category order by sales desc) as rn
from cte) as x
where rn = 1;

-- Which sub category had highest growth by profit in 2023 compare to 2022
-- select * from df_orders
with cte as 
(select sub_category, year(order_date) as order_year, sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
)
, cte2 as (Select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
Select *, sales_2023-sales_2022 as growth
from cte2
order by growth desc
limit 1;





