/*ELECTRIC VEHICLE SALES DROP*/


CREATE DATABASE electric_vehicle;
USE electric_vehicle;


/*1.Find the total revenue generated from Sprint Scooter sales in the year 2016.*/

SELECT CONCAT(SUM(base_price),'$') AS Revenue_generated
FROM products AS p
INNER JOIN sales AS s
ON p.product_id=s.product_id
WHERE p.model='Sprint' AND p.product_type='scooter' AND YEAR(s.sales_transaction_date)=2016;

/*2.Calculate the average revenue generated on model 'DeltaPlus' through the dealership channel*/

SELECT ROUND(CONCAT(AVG(p.base_price),'$'),2) AS Avgrevenue
FROM products AS p INNER JOIN sales AS s
ON p.product_id=s.product_id
WHERE s.Channel='dealership' AND p.model='DeltaPlus';

/*3.Determine the month with the highest total sales revenue in 2016.*/

SELECT MONTHNAME(s.sales_transaction_date) AS month, CONCAT(SUM(p.base_price),' ','$') AS total_revenue
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
WHERE YEAR(s.sales_transaction_date) = 2016
GROUP BY month
ORDER BY total_revenue DESC
LIMIT 1;

/*4.Find the percentage of Sprint Scooter sales compared to total EV scooter sales in 2018*/

SELECT CONCAT(SUM(CASE WHEN p.model = 'Sprint' THEN 1 ELSE 0 END) / COUNT(*))* 100 AS '%sales'
FROM sales AS s
JOIN products AS p ON s.product_id = p.product_id
WHERE YEAR(s.sales_transaction_date) = 2018;

/*5.Calculate the total sales volume of Sprint Scooters for each dealership*/

SELECT s.dealership_id As dealerID, CONCAT(COUNT(p.base_price),' ','units') AS totalsales
FROM products AS p INNER JOIN sales AS s
ON p.product_id=s.product_id
WHERE s.dealership_id IS NOT NULL
GROUP BY dealerID
ORDER BY totalsales DESC;

/*6.Find the email subject that was opened the most*/

SELECT es.email_subject AS email_subject,COUNT(*) AS open_count
FROM email_subject AS es INNER JOIN emails AS e
ON es.email_subject_id=e.email_subject_id
WHERE e.opened='t'
GROUP BY email_subject
ORDER BY open_count DESC
LIMIT 1;


/*7.Identify the customer who opened the most emails.*/

SELECT customer_id AS CustomerID,COUNT(*) AS open_count
FROM emails
WHERE opened='t'
GROUP BY CustomerID
ORDER BY open_count DESC
LIMIT 1;

/*8.Calculate the average number of emails sent per customer*/

SELECT ROUND(AVG(email_count),2) AS average_emails_sent
FROM (SELECT DISTINCT customer_id, COUNT(*) AS email_count
FROM emails
GROUP BY customer_id) AS temptable;

/*9.Calculate the bounce rate for each email subject.*/

SELECT es.email_subject, 
SUM(CASE WHEN e.bounced = 't' THEN 1 ELSE 0 END) AS bounce_count,
COUNT(e.email_id) AS total_emails,
ROUND((SUM(CASE WHEN e.bounced = 't' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS bounce_rate
FROM emails e INNER JOIN email_subject AS es
ON e.email_subject_id=es.email_subject_id
GROUP BY es.email_subject
ORDER BY bounce_rate DESC;

/*10.Find the date on which the first Sprint Scooter was sold,what was it's price on that time*/


SELECT DATE(MIN(sales_transaction_date)) AS first_sale_date,p.base_price AS initialprice
FROM sales AS s INNER JOIN products AS p
ON s.product_id=p.product_id
WHERE p.model='Sprint'
GROUP BY initialprice;

/*11.What is the cumulative sales volume (in units) for the first 7 days
 between 10- 10 -2016 and 16-10-2016?*/
 
SELECT CONCAT(count(p.base_price), ' ','units') AS cumulative_sales_volume
FROM sales AS s INNER JOIN products AS p
ON p.product_id=s.product_id
WHERE s.sales_transaction_date BETWEEN '2016-10-10' AND '2016-10-16';

/*12.On 20th Oct, What are the last 7 days' Cumulative Sales of corpel automobile (in units)?*/

SELECT CONCAT(count(p.base_price), ' ','units') AS cumulative_sales_volume
FROM sales AS s INNER JOIN products AS p
ON p.product_id=s.product_id
WHERE s.sales_transaction_date BETWEEN '2016-10-10' AND '2016-10-16' AND p.model='Corpel';

/*13.On which date did the sales volume reach its highest point?*/

SELECT DATE(s.sales_transaction_date) AS date,COUNT(p.base_price) AS SellVol
FROM sales AS s INNER JOIN products AS p
ON s.product_id=p.product_id
GROUP BY date
ORDER BY SellVol DESC
LIMIT 1;

/*14.On 22-10-2016 by what percentage,
 cumulative sales of last 7 days dropped compared to last 7 days cumulative sales on 21-10-2016?*/
 

SELECT SUM(
CASE WHEN s.sales_transaction_date BETWEEN '2016-10-15' AND '2016-10-22' THEN p.base_price ELSE 0 END) AS Cms_1,
SUM(CASE WHEN s.sales_transaction_date BETWEEN '2016-10-14' AND '2016-10-21' THEN p.base_price ELSE 0 END) AS Cms_2,
CASE WHEN SUM(CASE WHEN s.sales_transaction_date BETWEEN '2016-10-14' AND '2016-10-21' THEN p.base_price ELSE 0 END) = 0 
THEN CONCAT('100.00', '%')
ELSE CONCAT(ROUND(((SUM(CASE WHEN s.sales_transaction_date BETWEEN '2016-10-15' AND '2016-10-22' THEN p.base_price ELSE 0 END) - SUM(CASE WHEN s.sales_transaction_date BETWEEN '2016-10-14' AND '2016-10-21' THEN p.base_price ELSE 0 END)) / SUM(CASE WHEN s.sales_transaction_date BETWEEN '2016-10-14' AND '2016-10-21' THEN p.base_price ELSE 0 END)) * 100, 2), '%')
END AS pct_sales_diff
FROM products AS p
INNER JOIN sales AS s ON p.product_id = s.product_id
WHERE s.sales_transaction_date BETWEEN '2016-10-14' AND '2016-10-22';


/*15.Calculate the average time it takes for a customer to make a second purchase*/

WITH CustomerPurchaseDates AS (SELECT customer_id, sales_transaction_date,
LAG(sales_transaction_date) OVER (PARTITION BY customer_id ORDER BY sales_transaction_date) AS previous_purchase_date
FROM sales)
SELECT CONCAT(ROUND(AVG(DATEDIFF(sales_transaction_date, previous_purchase_date)),2),' ','days') AS average_time_to_second_purchase
FROM CustomerPurchaseDates
WHERE previous_purchase_date IS NOT NULL;

/*16. Find the top 3 customers with the highest number of opened emails for each product model*/

WITH RankedCustomers AS (SELECT s.customer_id,p.model,
COUNT(e.opened) AS opened_emails_count,
ROW_NUMBER() OVER (PARTITION BY p.model ORDER BY COUNT(e.opened) DESC) AS RowNum
FROM emails AS e INNER JOIN sales AS s ON e.customer_id = s.customer_id
INNER JOIN products AS p ON s.product_id = p.product_id
WHERE e.opened = 't'
GROUP BY s.customer_id, p.model)
SELECT customer_id,model,opened_emails_count
FROM RankedCustomers
WHERE RowNum <= 3;

    
/*17.Identify the top 5 customers who opened the most emails and also made a purchase.
 Include the number of emails opened and the total purchase amount for each customer*/
 
 With RankedCustomers AS (SELECT e.customer_id AS customer_id,COUNT(e.email_id) AS open_count,
 SUM(CASE WHEN p.product_id IS NOT NULL THEN 1 ELSE 0 END) AS purchase_count,
 SUM(CASE WHEN p.product_id IS NOT NULL THEN p.base_price ELSE 0 END) AS purchase_amount
 FROM products AS p INNER JOIN sales AS s
 ON p.product_id=s.product_id
 INNER JOIN emails AS e ON s.customer_id=e.customer_id
 WHERE e.opened='t' AND s.product_id IS NOT NULL
 GROUP BY e.customer_id)
 SELECT customer_id,open_count,purchase_count,purchase_amount
 FROM RankedCustomers 
 ORDER BY open_count DESC
 LIMIT 5;
 
 /*18.Calculate the bounce rate for each email subject, considering only emails sent to customers
 who have made a purchase.Include the email subject and the bounce rate.*/
 
 
 With PurchasedCustomers AS (SELECT DISTINCT s.customer_id AS customers
 FROM sales AS s),
 BounceRates AS(SELECT es.email_subject AS email_subject,
 SUM(CASE WHEN e.bounced='t' THEN 1 ELSE 0 END) AS bounce_count,
 COUNT(e.email_id) AS total_emails,
 ROUND((SUM(CASE WHEN e.bounced='t' THEN 1 ELSE 0 END)/COUNT(e.email_id))* 100,2) AS bounce_rate
 FROM emails AS e INNER JOIN email_subject AS es
 ON e.email_subject_id=es.email_subject_id
 INNER JOIN PurchasedCustomers AS pc
 ON e.customer_id=pc.customers
 GROUP BY email_subject)
 
 SELECT *
 FROM BounceRates;
 
 /*19.Calculate the click-through rate (CTR) for top 2 email advertisement subject.*/
 
/*CTR (%) = (Number of Clicks / Number of Delivered Emails) * 100*/
SELECT es.email_subject,
SUM(CASE WHEN e.clicked = 't' THEN 1 ELSE 0 END) AS clicks,
COUNT(*) AS total_emails,
ROUND((SUM(CASE WHEN e.clicked = 't' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2) AS 'CTR(%)'
FROM emails AS  e INNER JOIN email_subject AS es ON e.email_subject_id = es.email_subject_id
GROUP BY es.email_subject
ORDER BY 'CTR%' DESC
LIMIT 3;













