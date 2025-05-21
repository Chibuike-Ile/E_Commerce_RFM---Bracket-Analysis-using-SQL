select * from e_commerce;


select max(`Order Date`) FROM e_commerce;
--- RFM Analysis.
set @today  = "2020-01-01";
select max(Date) from e_commerce;
--- To get the most recent purchase date of each customer.
select `Purchase Address`as Customers_Address, max(Date) as Most_recent_purchase_date,
@today as Today_date
from e_commerce group by `Purchase Address`;



select `Purchase Address`as Customers_Address, max(Date) as Most_recent_purchase_date,
@today as Todays_date,
datediff(@today, Max(Date)) as Recency_score
from e_commerce group by `Purchase Address`;

select date `Order Date`  from e_commerce;
 


--- to calculate the frequency and monetary value.

select `Purchase Address`as Customers_Address, max(Date) as Most_recent_purchase_date,
datediff(@today, Max(Date)) as Recency_score,
count(`Order ID`) as Frequency_score,
round(sum(Sales), 2) as Monetary_score
from e_commerce group by `Purchase Address`;

--- for RFM Analysis


CREATE TEMPORARY TABLE Base AS 
     select `Purchase Address`as Customers_Address, 
	 datediff(@today, Max(Date)) as Recency_score,
     count(`Order ID`) as Frequency_score,
     round(sum(Sales), 2) as Monetary_score
     from e_commerce group by `Purchase Address`;
     


--- TO Group the scores into brackets, we group it into 5 ( 5 is the highest and 1 is the lowest)

select Customers_Address, Recency_score, Frequency_score, Monetary_score,
ntile(5) over (order by Recency_score desc) as R,
ntile(5) over (order by Frequency_score asc) as F,
ntile(5) over (order by Monetary_score asc) as M
from Base;

--- for RFM Analysis we need to create another temporary table called RFM_Score

create temporary table RFM_Score as
select Customers_Address, Recency_score, Frequency_score, Monetary_score,
ntile(5) over (order by Recency_score desc) as R,
ntile(5) over (order by Frequency_score asc) as F,
ntile(5) over (order by Monetary_score asc) as M
from Base;



 select Customers_Address, 
 concat_ws( - R,   F, -  M ) as RFM_Cell,
 round(((R + F + M) / 3), 2) as Avg_RFM_Socres
 from RFM_Score;
 
 
 
 select round(((R + F + M) / 3), 0) as RFM_Grouping from RFM_Score;
 
 
 
 select 
 round(((R + F + M) / 3), 0) as RFM_Grouping,
 count(Customers_Address) as Customer_Count
 from RFM_Score group by RFM_Grouping;
 
 
 
 select round(((R + F + M) / 3), 0) as RFM_Grouping,
 count(RFM_Score.Customers_Address) as No_Of_Customers,
 round(sum(Base.Monetary_score), 2) as Total_Sales,
 round(sum(Base.Monetary_score) / count(RFM_Score.Customers_Address), 2) as Avg_Sales_per_Customer 
 from RFM_Score 
 inner join Base on Base.Customers_Address = RFM_Score.Customers_Address 
 group by RFM_Grouping
 order by RFM_Grouping desc;
 
 --- Basket Analysis
--- Determine which products are frequently ordered together by the same customers. 



select
	a.`Purchase Address` as Customer_Address,
    a.`Product` as Product_A,
    b.`Product` as Product_B,
    COUNT(*) as Number_Of_Times_Bought_Together
from
    e_commerce a
join
    e_commerce b
    on a.`Order ID` = b.`Order ID`
    and a.`Product` < b.`Product`  
group by 
    Customer_Address, Product_A, Product_B
order by 
    Number_Of_Times_Bought_Together desc
    limit 100;








