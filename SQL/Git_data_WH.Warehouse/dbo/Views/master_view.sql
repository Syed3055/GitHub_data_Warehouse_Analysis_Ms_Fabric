-- Auto Generated (Do not modify) D289886B49429C5CA1ECBC1EAB83F49A2C1799BAF1F8F23BB9F5D6B207A33D63
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