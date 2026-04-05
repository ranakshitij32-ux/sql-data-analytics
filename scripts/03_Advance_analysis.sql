
-- ============================================================
-- Advance Analysis
-- ============================================================

-- Get total sale every month
select year(order_date) as order_year, month(order_date) as order_month,
count(year(order_date))as total_orders,count(distinct(customer_key)) as total_customers,
sum(sales_amount) as total_sale from fact_sales where order_date is not null
group by year(order_date),month(order_date)
order by year(order_date);

-- get running total sale (resets every year)
select order_year,order_month,total_sale,
sum(total_sale) over (partition by order_year order by order_year,order_month) as running_total_sale
from(
select year(order_date) as order_year, month(order_date) as order_month,sum(sales_amount) as total_sale
from fact_sales where order_date is not null
group by year(order_date),month(order_date)
order by year(order_date)
)s;


-- get sales comparison by comparing with previous year
select order_year,total_sale,
lead(total_sale) over() as prev_year_sale,
case 
	when lead(total_sale) over()> total_sale then "Not Good"
	when lead(total_sale) over()< total_sale then "Good"
    else null
end as sales_comparison,avg_sales
from(
select year(f.order_date)order_year,sum(f.sales_amount)as total_sale,avg(f.sales_amount) as avg_sales
from fact_sales f
group by year(f.order_date)
order by year(f.order_date)desc,total_sale desc)h;

-- get sale comparison for every product every year
with yearly_product_sales as (
select p.product_name,year(f.order_date) as sale_year,sum(f.sales_amount)as total_sales from fact_sales f
join dim_products p on f.product_key = p.product_key
where f.order_date is not null
group by year(f.order_date),p.product_name
)
SELECT product_name,sale_year,
round(avg(total_sales) over(partition by product_name)) as avg_sales,
total_sales-round(avg(total_sales) over(partition by product_name)) as diff_avg,
case
when total_sales-round(avg(total_sales) over(partition by product_name))>0
then "Above Average"
when total_sales-round(avg(total_sales) over(partition by product_name))<0
then "Below average"
else "Perfect"
end as avg_change,
total_sales,
lead(total_sales) over(partition by product_name order by sale_year desc) as prev_year_sales,
total_sales-lead(total_sales) over(partition by product_name order by sale_year desc) as diff_py,
case
when total_sales-lead(total_sales) over(partition by product_name order by sale_year desc)>0
then "Increase"
when total_sales- lead(total_sales) over(partition by product_name order by sale_year desc)<0
then "Decrease"
else
"No change"
end as sales_change
FROM yearly_product_sales
ORDER BY product_name, sale_year DESC;


-- get percentage of sales covered by each category
with category_sales as(
select p.category,sum(f.sales_amount) as total_sales from fact_sales f 
left join dim_products p on f.product_key = p.product_key
group by p.category order by total_sales desc 
)
select category,total_sales,
sum(total_sales) over() as overall_sale,
round((total_sales/sum(total_sales) over())*100,2) as percentage_of_total
 from category_sales;


-- get total customer by cust_category
with cust_total_spent as 
(
select c.customer_key,concat(c.first_name,'  ',c.last_name)as customer_name,
sum(s.sales_amount)as total_spent,timestampdiff(month,min(s.order_date),max(s.order_date)) as total_months,

CASE
    -- VIP: 12+ months AND spending > 5000
    WHEN TIMESTAMPDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) >= 12 
         AND SUM(s.sales_amount) > 5000 THEN 'VIP'
    
    -- Regular: 12+ months AND spending <= 5000
    WHEN TIMESTAMPDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) >= 12 
         AND SUM(s.sales_amount) <= 5000 THEN 'Regular'
    
    -- Emerging VIP: Less than 12 months AND spending > 5000
    WHEN TIMESTAMPDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) < 12 
         AND SUM(s.sales_amount) > 5000 THEN 'Emerging VIP'
    
    -- New: Less than 12 months (spending <= 5000 by default)
    WHEN TIMESTAMPDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) < 12 
         THEN 'New'
    
    ELSE 'Other'

end as cust_category
from fact_sales s
join dim_customers c on s.customer_key=c.customer_key
group by c.customer_key,concat(c.first_name,'  ',c.last_name)
order by sum(s.sales_amount) desc
)
select cust_category,count(cust_category) as total_customer from cust_total_spent
where cust_category is not null
group by cust_category
order by count(cust_category)desc;

-- create customer's report view
create view report_customers as
with customer_detail as(
select f.order_number,f.product_key,c.customer_key,concat(c.first_name,' ',last_name) as customer_name,c.birthdate,c.gender,f.order_date,f.sales_amount 
,timestampdiff(year,birthdate,now()) as age,f.quantity
from fact_sales f
join dim_customers c on f.customer_key=c.customer_key
where f.order_date is not null
)
,customer_aggregation as(
select customer_key,customer_name,age,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_spent,
sum(quantity)as total_quant,
count(distinct product_key) as total_product,
timestampdiff(month,min(order_date),max(order_date)) as lifespan,
CASE
    -- VIP: 12+ months AND spending > 5000
    WHEN TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) >= 12 
         AND SUM(sales_amount) > 5000 THEN 'VIP'
    
    -- Regular: 12+ months AND spending <= 5000
    WHEN TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) >= 12 
         AND SUM(sales_amount) <= 5000 THEN 'Regular'
    
    -- Emerging VIP: Less than 12 months AND spending > 5000
    WHEN TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) < 12 
         AND SUM(sales_amount) > 5000 THEN 'Emerging VIP'
    
    -- New: Less than 12 months (spending <= 5000 by default)
    WHEN TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) < 12 
         THEN 'New'
    
    ELSE 'Other'
    end as cust_lvl,max(order_date) as last_order_date
from customer_detail
group by customer_key,customer_name,age
)
select customer_key,customer_name,age,
total_orders,
total_spent,
total_quant,
total_product,timestampdiff(month,last_order_date,now()) as recency,
case
	when total_quant =0 then total_spent
    else
    round(total_spent/total_quant,2)
    end as avg_order_value,
lifespan,
case 
	when lifespan=0 then total_spent
    else
    round(total_spent/lifespan,2)
end
as average_monthly_spend
,cust_lvl,
case 
	when age < 20 then "Under 20"
	when age between 20 and 29 then "20-29"
    when age between 30 and 39 then "30-39"
    when age between 40 and 49 then "40-49"
    when age between 50 and 59 then "50-59"
    else
    "60 and above" 
end as age_group 
from customer_aggregation;

-- select report_customer view
select * from report_customers;
    

-- create product_report
create view product_report as
with first_query as(
select f.customer_key,f.order_number,p.product_key,p.product_name,p.category,p.subcategory,p.cost,f.order_date,f.sales_amount,f.quantity

from fact_sales f 
left join dim_products p on f.product_key = p.product_key 
),second_query as(
select  product_key,product_name,
timestampdiff(month,min(order_date),max(order_date)) as lifespan_month,
max(order_date) as last_order,
category,
subcategory,
sum(cost*quantity) as total_cost,
sum(sales_amount) as total_sales,
count(order_number)as total_order,
count(quantity)as total_quantity_sold,
count(distinct(customer_key)) as total_unique_customers,
case 
	when sum(sales_amount)>500000 then "High-Performer"
    when sum(sales_amount)>100000 then "Mid-Range"
    else "Low-Performers"
    end as product_segment
from first_query
group by product_key,product_name,category,subcategory
)
select product_key,
product_name,
lifespan_month,
category,
subcategory,
total_cost,
total_sales,
total_order,
 total_quantity_sold,
total_unique_customers,
timestampdiff(month,last_order,now()) as recency,
round((total_sales/total_order)) as average_order_revenue,
total_sales-total_cost as total_profit,
case 
	when lifespan_month =0 then total_sales
    else
    total_sales/lifespan_month
    end as average_monthly_revenue
,
 product_segment from second_query;
 -- select product_report
 select * from product_report;