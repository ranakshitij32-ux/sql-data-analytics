-- ============================================================
-- EDA Analysis
-- ============================================================

-- -- Get column details (names, data types, nullability) for the dim_customers table
select * from information_schema.columns where table_name = 'dim_customers';

-- get unique country from column
select distinct country from dim_customers;

-- get category,subcategory and producut_name column
select distinct category, subcategory, product_name from dim_products order by 1,2,3;

-- get table for selected schema
show tables;

select * from dim_products;

select * from fact_sales;

-- Finding earliest and latest order date with time difference in year
select min(order_date) earliest_date, max(order_date) latest_date ,timestampdiff(year,min(order_date),
max(order_date)) Years,timestampdiff(month,min(order_date),max(order_date))%12 as months from fact_sales;

-- Finding youngest and oldest customer 
select min(birthdate) as oldest_birthdate,timestampdiff(year,min(birthdate),now())as oldest_age, max(birthdate) as youngest_birthdate,
timestampdiff(year,max(birthdate),now())as youngest_age from dim_customers;

-- Find the total sales
select sum(sales_amount) as total_sales from fact_sales;

-- Find how many items are sold
select sum(quantity) as total_quantity_sold from fact_sales;

-- Find the average selling price
select avg(price) as avg_selling_price from fact_sales;

-- find the total number of orders;
select count(distinct(order_number)) as total_orders from fact_sales;


-- Find the total number of products
select count(distinct(product_number)) as total_products from dim_products;

-- find the total number of customers
select count(*) as total_customers from dim_customers;

-- find the total number of customers who had actually ordered
select count(distinct(c.customer_key)) as customers_who_ordered from fact_sales f 
join dim_customers c on c.customer_key = f.customer_key;


-- combine all the measures and create a procedure
delimiter //
create procedure measure_value()
begin
select 'Total Sales' as measure_name, sum(sales_amount) as measure_value from fact_sales
union all
select 'Total product sold' as measure_name, sum(quantity) as measure_value from fact_sales
union all
select 'Total products' as measure_name, count(distinct(product_number))as measure_value from dim_products
union all 
select 'Total customers' as measure_name, count(*)as measure_value from dim_customers
union all
select 'Total customer who ordered' as measure_name,  count(distinct(customer_key)) as measure_value from fact_sales;
end //
delimiter ;

call measure_value;
