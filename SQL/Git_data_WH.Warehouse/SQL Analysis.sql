----- Required Tables ------------------------
select * from [Git_LakeHouse].[Git_bronze_data].[customers.csv]

select * from [Git_LakeHouse].[Git_bronze_data].[Orders_Data.csv]
select * from [Git_LakeHouse].[Git_bronze_data].[products.csv]
-----------------------------------------------------------------------------------

----------------------------------------------------------------------
create procedure  master_table 
as
select o.* ,
c.CustomerName,
c.Email,
c.Location,
c.SignupDate,
p.ProductName,
p.Category,
p.Stock,
p.UnitPrice
from [Git_LakeHouse].[Git_bronze_data].[Orders_Data.csv] o
left join [Git_LakeHouse].[Git_bronze_data].[customers.csv] c 
on o.CustomerID=c.CustomerID 
left join [Git_LakeHouse].[Git_bronze_data].[products.csv] p 
on o.ProductID=p.ProductID
GO;
-----------Execution of the StoreProcedure-----
EXEC master_table;

--------First visited customer and Repeated customers---------------------------
with cte as (
select CustomerID, min(cast(SignupDate as Date)) first_visited
from [Git_LakeHouse].[Git_bronze_data].[customers.csv] group by CustomerID)
, total_cust as (
select c.CustomerID, case when c.SignupDate = cte.first_visited then 'new_cust' 
else 'repeated' end flag from [Git_LakeHouse].[Git_bronze_data].[customers.csv] c
 left join cte on c.CustomerID =cte.CustomerID)
 select flag, count(*) from total_cust group by flag

--------Total Product Sales----------------------------------
Select p.ProductName, sum(cast(o.TotalAmount as decimal(15,2))) total_amount
 

from [Git_LakeHouse].[Git_bronze_data].[products.csv] p
inner join [Git_LakeHouse].[Git_bronze_data].[Orders_Data.csv] o on p.ProductID=o.ProductID 
group by p.ProductName order by total_amount desc


--------Product sold by Quantity------------------------
select p.ProductName, o.Quantity from [Git_LakeHouse].[Git_bronze_data].[products.csv] p 
inner join [Git_LakeHouse].[Git_bronze_data].[Orders_Data.csv] o  on p.ProductID=o.ProductID 
order by Quantity desc

-----------Total Sales of Product with Percentage % share------------

select ProductName, sum(cast(TotalAmount as decimal(14,2))) total_amount, 
round(  100 * sum(cast(TotalAmount as decimal(14,2)))/(select sum(cast(TotalAmount as decimal(14,2))) 
from master_view ), 2)  percentage from master_view
group by ProductName order by total_amount desc

------------------Creating the View-----------------
Create  view master_view as(
select o.* ,
c.CustomerName,
c.Email,
c.Location,
c.SignupDate,
p.ProductName,
p.Category,
p.Stock,
p.UnitPrice
from [Git_LakeHouse].[Git_bronze_data].[Orders_Data.csv] o
left join [Git_LakeHouse].[Git_bronze_data].[customers.csv] c 
on o.CustomerID=c.CustomerID 
left join [Git_LakeHouse].[Git_bronze_data].[products.csv] p 
on o.ProductID=p.ProductID)
GO;

---------------------- Total Amount of Paymentmethod with percentage%------------------
select PaymentMethod, sum(cast(TotalAmount  as decimal(14,2))) as total_Amount,
(100 * sum(cast(TotalAmount as decimal(14,2))) / (select sum(cast(TotalAmount as decimal(14,2))) from master_view)) Percentage
from master_view
group by PaymentMethod 
order by total_Amount DESC

------------Avg Amount per Customer ------------------

select CustomerName, avg(cast(TotalAmount as decimal(14,2))) avg_amount  from master_view
group by CustomerName order by avg_amount desc


-----Monthly sales ----------------------
Select  CONCAT( Month(cast(OrderDate as date)),'_',year(cast(OrderDate as date))) as month_year,
Sum(cast(TotalAmount as DECIMAL(14,2))) total_sales from master_view 
group by Month(cast(OrderDate as date)),year(cast(OrderDate as date))
order by  Sum(cast(TotalAmount as DECIMAL(14,2))) desc 

----------Best product in month-----------
select ProductName,CONCAT( Month(cast(OrderDate as date)),'_',year(cast(OrderDate as date))) as month_year , 
sum(cast(TotalAmount as decimal(14,2))) total_amount from master_view 
group by ProductName, Month(cast(OrderDate as date)), year(cast(OrderDate as date))
order by  total_amount desc
----------MTD Sales----------

WITH daily AS (SELECT CAST(OrderDate AS date) AS order_day,SUM(CAST(TotalAmount AS decimal(14,2))) AS daily_sales
FROM master_view GROUP BY CAST(OrderDate AS date))

SELECT order_day AS datee, daily_sales, SUM(daily_sales) 
OVER (PARTITION BY YEAR(order_day), MONTH(order_day)ORDER BY order_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS mtd_sales
FROM daily
ORDER BY order_day;

----------YTD Sales-----------
WITH daily AS (
    SELECT
        CAST(OrderDate AS date) AS order_day,
        SUM(CAST(TotalAmount AS decimal(14,2))) AS daily_sales
    FROM master_view
    GROUP BY CAST(OrderDate AS date)
)
SELECT order_day AS datee, daily_sales,SUM(daily_sales) OVER (PARTITION BY YEAR(order_day) 
ORDER BY order_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS YTD_sales
FROM daily
ORDER BY order_day;

------------------ Daily Order count and their value  ------------
select cast(OrderDate as date) datee, count(*) ordercount, sum(cast(TotalAmount as Decimal(14,2))) Amount_value 
from master_view group by cast(OrderDate as date) order by datee

------------------Daily Order count and their value with PaymentMode ------------

select cast(OrderDate as date) datee, count(*) ordercount, sum(cast(TotalAmount as Decimal(14,2))) Amount_value 
,  string_agg(PaymentMethod,',') PaymentModes
from master_view group by cast(OrderDate as date) order by datee

-----------------Most used payment modes-----------

select PaymentMethod, count(*) as commanly_used_for_payment , row_number() over(order by count(*) desc) rankk
from master_view group by PaymentMethod order by  commanly_used_for_payment desc 

-----------------------------------------------Thank You -------------------------------------





