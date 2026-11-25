use projectdb;
select count(*) from superstore;
select * from superstore limit 5;

-- 1. What are the total sales and total profits of each year?
select year(`order date`) as year,round(sum(Sales),2) as total_sales,round(sum(profit),2) as total_profit from superstore
group by year(`order date`)
order by year;

-- 2. What are the total profits and total sales per quarter?
select year(`Order Date`) as year,
case
   when month(`Order Date`) in (1,2,3) then 'Q1'
   when month(`Order Date`) in (4,5,6) then 'Q2'
   when month(`Order Date`) in (7,8,9) then 'Q3'
   else 'Q4'
end as quarter,
round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit from superstore
group by year(`Order Date`),quarter
order by year,quarter;

-- 3. What region generates the highest sales and profits?
select region,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit from superstore
group by region
order by total_sales desc;
-- each regions profit margin for further analysis
-- ROUND(SUM(profit) / SUM(sales)*100,2)
select region,round(sum(profit) / sum(sales)*100,2) as profit_margin from superstore
group by region
order by profit_margin desc;

-- 4. What state and city brings in the highest sales and profits ?
-- state-wise
select state,round(sum(sales),2) as total_sales,round(sum(profit),2)  as total_profit,
            round(sum(profit) / sum(sales)*100,2) as profit_margin from superstore
group by state
order by total_profit desc limit 10;
-- city-wise
select city,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit,
		    round(sum(profit) / sum(sales)*100,2) as profit_margin from superstore
group by city
order by total_profit desc limit 10;

-- 5. The relationship between discount and sales and the total discount per category
-- total discount per category
select category,round(sum(discount),2) as total_discount from superstore
group by category
order by total_discount;
-- relantionship between discount and sale
select discount,round(avg(sales),2) as avg_sales from superstore
group by Discount  
order by avg_sales;

-- most discounted sub-categories (product type)
select category,`sub-category`,round(sum(discount),2) as total_discount from superstore
group by category,`sub-category`
order by total_discount desc limit 5;

-- 6. What category generates the highest sales and profits in each region and state ?
select category,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit,
       round(sum(profit) / sum(sales)*100,2) as profit_margin
from superstore
group by category
order by total_profit;
-- Region wise category sales and profits
select region,category,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit,
     round(sum(profit) / sum(sales)*100,2) as profit_margin from superstore
group by region,category
order by total_profit desc;
-- State wise category sales and profit
select state,category,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit,
     round(sum(profit) / sum(sales)*100,2) as profit_margin from superstore
group by state,category
order by total_profit desc;

-- 7. What subcategory generates the highest sales and profits in each region and state ?
select `Sub-Category`,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit,
                  round(sum(profit) / sum(sales)*100,2) as profit_margin from superstore
group by `Sub-Category`
order by total_profit desc;
-- Region wise sub-category sales and profits
select region,`sub-category`,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit,
     round(sum(profit) / sum(sales)*100,2) as profit_margin from superstore
group by region,`sub-category`
order by total_profit desc;
-- State wise sub-category sales and profit
select state,`sub-category`,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit,
     round(sum(profit) / sum(sales)*100,2) as profit_margin from superstore
group by state,`sub-category`
order by total_profit desc;

-- 8. What are the names of the products that are the most and least profitable to us?
select `product name`,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit from superstore
group by `product name`
order by total_profit desc limit 10;

select `product name`,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit from superstore
group by `product name`
order by total_profit limit 10;

-- 9. What segment makes the most of our profits and sales ?
select segment,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit from superstore
group by segment
order by total_profit desc;

-- 10. How many customers do we have (unique customer IDs) in total and how much per region and state?
select count(distinct `customer id`) as total_customers from superstore;
-- Region wise
select region,count(distinct `customer id`) as total_customers from superstore
group by region
order by total_customers desc;
-- State wise
select state,count(distinct `customer id`) as total_customers from superstore
group by state
order by total_customers desc;

-- 11. Customer rewards program
select `customer id`,`customer name`,round(sum(sales),2) as total_sales,round(sum(profit),2) as total_profit from superstore
group by `customer id`,`customer name`
order by total_sales desc limit 15; 

-- 12. Average shipping time per class and in total
select avg(datediff(`ship date`,`order date`)) as avg_shipping_time from superstore;
-- ship mode
select `ship mode`, avg(datediff(`ship date`,`order date`)) as avg_shipping_time from superstore
group by `ship mode`
order by avg_shipping_time;

-- 13. Which products sell above the average product-level sales ?
select `product name`,round(sum(sales),2) as total_sales from superstore
group by `product name` 
having sum(sales) > ( select avg(product_sales) 
                    from ( select `product name`, sum(sales) as product_sales from superstore
                          group by `product name`) 
                          as avg_sales)
order by total_sales desc;

-- 14. Which customers have bought from all three product categories
select `customer id`,`customer name` from superstore
group by `customer id`,`customer name`
having count(distinct category) = 3;

-- 15. What is the y-o-y growth in sales and profit ?
with yearly_total as (
    select year(`order date`) as order_year, round(sum(sales),2) as total_sales, round(sum(profit),2) as total_profit 
    from superstore
    group by year(`order date`) 
    ),
growth as ( select order_year,total_sales,total_profit, 
        lag(total_sales) over(order by order_year) as previous_sales,
        lag(total_profit) over(order by order_year) as previous_profit
        from yearly_total
        )
select order_year,total_sales,total_profit,
round((total_sales - previous_sales) / nullif(previous_sales,0)*100,2) as sales_growth_pct,
round((total_profit - previous_profit) / nullif(previous_profit,0)*100,2) as profit_growth_pct 
from growth
order by order_year;


-- 16. What are the top 3 most profitable products in each category ?
with product_profit as (
        select category, `product name`, round(sum(profit),2) as  total_profit from superstore
        group by category, `product name` ),
ranked_product as (
        select category, `product name` , total_profit, dense_rank() over (partition by category order by total_profit desc) as rnk
        from product_profit)
select category, `product name`, total_profit, rnk from ranked_product
where rnk <= 3
order by category, rnk;

-- 17. What is the running total of sales within each year,month by month ?
select year,month,monthly_sales,round(sum(monthly_sales) over(partition by year order by month
                                            rows between unbounded preceding and current row),2) as running_total
from
    (select year(`order date`) as year,month(`order date`) as month,round(sum(sales),2) as monthly_sales
     from superstore
	group by year(`order date`),month(`order date`)) as year;
    
-- 18. Product contribution to total revenue
select `product name`,total_sales,revenue,round(total_sales/revenue*100,2) as per_contribution from
(select `product name`, round(sum(sales*quantity),2) as total_sales,
   (select round(sum(sales*quantity),2) as revenue from superstore) as revenue
    from superstore
group by `product name`
order by total_sales desc) as rn;

-- 19.category wise contribution to total revenue
select category,total_sales,revenue,round(total_sales/revenue*100,2) as per_contribution from
(select category, round(sum(sales*quantity),2) as total_sales,
   (select round(sum(sales*quantity),2) as revenue from superstore) as revenue
    from superstore
group by category
order by total_sales desc) as rn;


   
	







