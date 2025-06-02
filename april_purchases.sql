--total sales by vendor (used to verify monthly statements)

SELECT vendor, SUM(total) AS total_purchased
FROM April_purchases.dbo.april_purchases
GROUP BY vendor;

--quantity and total spent on parts by part name (used to see what techs are buying and how much, quantity high to low)

SELECT part_name, 
		SUM(quantity) AS number_purchased, 
		SUM(total) AS total_purchases_by_part
FROM April_purchases.dbo.april_purchases
GROUP BY part_name
ORDER BY number_purchased DESC;



--finding the average, max, min, price difference of parts for the month

SELECT part_name, 
		ROUND(AVG(price_per_unit),2) AS avg_price,
		MAX(price_per_unit) AS max_price,
		MIN(price_per_unit)	AS min_price,
		MAX(price_per_unit) - MIN(price_per_unit) AS price_change
FROM April_purchases.dbo.april_purchases
GROUP BY part_name;


--Parts totals from WO -- wo_totals

SELECT wo_number,
		SUM(total) AS total_by_wo
FROM April_purchases.dbo.april_purchases
GROUP BY wo_number;


--Creating a table of wo_totals from purchase data (eliminates human error)

CREATE TABLE wo_totals (wo_number INT, total_by_wo MONEY)

INSERT INTO wo_totals
SELECT wo_number,
		SUM(total) AS total_by_wo
FROM April_purchases.dbo.april_purchases
GROUP BY wo_number;

-- table for cost of each job
SELECT inv.wo_number, customer_name, Description, Amount_Invoiced, tot.total_by_wo
		
FROM April_purchases.dbo.[Monthly Work Orders] AS inv
INNER JOIN wo_totals AS tot
	ON inv.wo_number = tot.wo_number;



--joining tables and selecting to include cost by wo_number, Cost analysis for jobs and removing warranty and Truck Stock WO's

SELECT inv.wo_number, customer_name, Description, Amount_Invoiced, tot.total_by_wo, total_by_wo / Amount_Invoiced *100 as COGS		
FROM April_purchases.dbo.[Monthly Work Orders] AS inv
INNER JOIN wo_totals AS tot
	ON inv.wo_number = tot.wo_number
WHERE Amount_Invoiced <> 0;


-- Checking for work orders classified as stock orders

SELECT wo_number
FROM April_purchases.dbo.[Monthly Work Orders]
WHERE description like '%stock%';



-- Checking stock purchases

SELECT part_name, SUM(quantity) AS quantity_purchased, SUM(total) AS stock_cost
FROM April_purchases.dbo.april_purchases
WHERE  wo_number = 37643 or wo_number = 68882 or wo_number = 63021
GROUP BY part_name
ORDER BY quantity_purchased DESC;
