use [mobile_manufacture]
select * from [dbo].[DIM_CUSTOMER]
select * from[dbo].[DIM_DATE]
select * from[dbo].[DIM_LOCATION]
select * from[dbo].[DIM_MANUFACTURER]
select * from[dbo].[DIM_MODEL]
select * from[dbo].[FACT_TRANSACTIONS]

--Q1 List all the states in which we have customers who have bought cellphones from 2005 till today
	
select state from DIM_LOCATION l
join FACT_TRANSACTIONS t
on l.IDLocation=t.IDLocation
where date>'2005'
group by state

--Q1--END

--Q2 What state in the US is buying the most 'Samsung' cell phones?   


SELECT top 1 country,state, COUNT(*) AS num_transactions
FROM FACT_TRANSACTIONS t
JOIN DIM_LOCATION l
ON t.IDLocation=l.IDLocation
JOIN DIM_MODEL mo
ON mo.IDModel = t.IDModel
JOIN DIM_MANUFACTURER m
ON m.IDManufacturer=mo.IDManufacturer
where Manufacturer_Name='samsung' and country='us'
GROUP BY state,Country
ORDER BY num_transactions desc


--Q2--END

--Q3 Show the number of transactions for each model per zip code per state.        


SELECT count(*) AS num_transactionsstate,Model_Name AS model,ZipCode,state
FROM FACT_TRANSACTIONS t
JOIN DIM_MODEL m
ON t.IDModel = m.IDModel
JOIN DIM_LOCATION l
ON t.IDLocation=l.IDLocation
GROUP BY state, zipcode,model_name
ORDER BY Model_Name 


--Q3--END

--Q4 Show the cheapest cellphone (Output should contain the price also) 


select top 1 totalprice as Price  , model_name as cheapest_cellphone from FACT_TRANSACTIONS t
join DIM_MODEL m
on t.IDModel=m.IDModel
order by totalprice


--Q4--END

/*Q5 Find out the average price for each model in the top5 manufacturers in  
terms of sales quantity and order by average price. */  
 

SELECT model_name AS model, AVG(totalprice) AS avg_price
FROM FACT_TRANSACTIONS t
JOIN DIM_MODEL mo
ON t.IDModel = mo.IDModel
WHERE mo.IDModel IN (
  SELECT top 5 IDModel
  FROM FACT_TRANSACTIONS
  GROUP BY IDModel
  ORDER BY COUNT(*) DESC
)
GROUP BY Model_Name
ORDER BY avg_price 



--Q5--END

/* Q6 List the names of the customers and the average amount spent in 2009,  
where the average is higher than 500 */ 


select Customer_Name,avg(totalprice) as avg_price from DIM_CUSTOMER c
join FACT_TRANSACTIONS t
on c.IDCustomer=t.IDCustomer
where year(date)='2009'
group by Customer_Name
having avg(totalprice)>500 
order by avg(totalprice) desc




--Q6--END
	
--Q7 List if there is any model that was in the top 5 in terms of quantity,  simultaneously in 2008, 2009 and 2010   

select top 5 count(quantity) as quantity_in_2008_2009_2010 , model_name from fact_transactions t
join DIM_MODEL mo
on t.IDModel=mo.IDModel
where year(date) in ('2008','2009','2010')
group by model_name
order by model_name desc




--Q7--END	

--Q8 Show the manufacturer with the 2nd top sales in the year of 2009 and the  manufacturer with the 2nd top sales in the year of 2010.  


select * from (
select top 1 Manufacturer_Name, sum(TotalPrice) as sales
from (select top 2 Manufacturer_Name, sum(TotalPrice) as totalprice from 
FACT_TRANSACTIONS t
right join DIM_MODEL mo
on t.IDModel = mo.IDModel
right join DIM_MANUFACTURER m
on mo.IDManufacturer = m.IDManufacturer
right join DIM_DATE d
on t.Date = d.DATE
where year = 2009
group by Manufacturer_Name
order by sum(TotalPrice) desc) as subquery
group by Manufacturer_Name
order by sum(TotalPrice) asc) t3
union 
select * from (
select top 1 Manufacturer_Name, sum(TotalPrice) as sales
from (select top 2 Manufacturer_Name, sum(TotalPrice) as totalprice from 
FACT_TRANSACTIONS t
right join DIM_MODEL mo
on t.IDModel = mo.IDModel
right join DIM_MANUFACTURER ma
on mo.IDManufacturer = ma.IDManufacturer
right join DIM_DATE d
on t.Date = d.DATE
where year = 2010
group by Manufacturer_Name
order by sum(TotalPrice) desc) as subquery
group by Manufacturer_Name
order by sum(TotalPrice) asc) t3



--Q8--END

--Q9 Show the manufacturers that sold cellphones in 2010 but did not in 2009.   

	
SELECT * FROM dim_manufacturer m
WHERE EXISTS (
  SELECT *
  FROM fact_transactions t
  JOIN DIM_MODEL mo 
  on t.IDModel=mo.IDModel
  WHERE m.IDManufacturer = mo.IDManufacturer
    AND t.date >= '2010-01-01'
    AND t.date < '2011-01-01'
)
AND NOT EXISTS (
  SELECT *
  FROM fact_transactions t
  JOIN dim_model mo 
    on t.IDModel=mo.IDModel
  WHERE m.IDManufacturer = mo.IDManufacturer
    AND t.date >= '2009-01-01'
    AND t.date < '2010-01-01'
)


--Q9--END
