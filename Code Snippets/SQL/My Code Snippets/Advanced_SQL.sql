select * from
(select 
	OrderID,
	ProductID,
	OrderDate,
	Sales,
	sum(Coalesce(Sales,0)) over(partition by ProductID) as sum_sales,
	count(Coalesce(Sales,0)) over(partition by ProductID) as count_sales,
	AVG(Coalesce(Sales,0)) over() as avg_sales,
	AVG(Coalesce(Sales,0)) over(partition by ProductID) as avg_sales_by_product
from sales.Orders) as av
where Sales > av.avg_sales 