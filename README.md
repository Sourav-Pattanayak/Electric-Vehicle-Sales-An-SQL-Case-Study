# ⚡Electric-Vehicle-Sales-An-SQL-Case-Study

CREATE DATABASE electric_vehicle;
USE electric_vehicle;


1️⃣ FIND THE TOTAL REVENUE GENERATED FROM SPRINT SCOOTER SALES IN THE YEAR 2016.

SELECT CONCAT(SUM(base_price),'$') AS Revenue_generated
FROM products AS p
INNER JOIN sales AS s
ON p.product_id=s.product_id
WHERE p.model='Sprint' AND p.product_type='scooter' AND YEAR(s.sales_transaction_date)=2016;

2️⃣ CALCULATE THE AVERAGE REVENUE GENERATED ON MODEL 'DELTAPLUS' THROUGH THE DEALERSHIP CHANNEL.

SELECT ROUND(CONCAT(AVG(p.base_price),'$'),2) AS Avgrevenue
FROM products AS p INNER JOIN sales AS s
ON p.product_id=s.product_id
WHERE s.Channel='dealership' AND p.model='DeltaPlus';

3️⃣ DETERMINE THE MONTH WITH THE HIGHEST TOTAL SALES REVENUE IN 2016.

SELECT MONTHNAME(s.sales_transaction_date) AS month, CONCAT(SUM(p.base_price),' ','$') AS total_revenue
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
WHERE YEAR(s.sales_transaction_date) = 2016
GROUP BY month
ORDER BY total_revenue DESC
LIMIT 1;

4️⃣ FIND THE PERCENTAGE OF SPRINT SCOOTER SALES COMPARED TO TOTAL EV SCOOTER SALES IN 2018.

SELECT CONCAT(SUM(CASE WHEN p.model = 'Sprint' THEN 1 ELSE 0 END) / COUNT(*))* 100 AS '%sales'
FROM sales AS s
JOIN products AS p ON s.product_id = p.product_id
WHERE YEAR(s.sales_transaction_date) = 2018;

5️⃣ CALCULATE THE TOTAL SALES VOLUME OF SPRINT SCOOTERS FOR EACH DEALERSHIP.

SELECT s.dealership_id As dealerID, CONCAT(COUNT(p.base_price),' ','units') AS totalsales
FROM products AS p INNER JOIN sales AS s
ON p.product_id=s.product_id
WHERE s.dealership_id IS NOT NULL
GROUP BY dealerID
ORDER BY totalsales DESC;

6️⃣ FIND THE EMAIL SUBJECT THAT WAS OPENED THE MOST.

SELECT es.email_subject AS email_subject,COUNT(*) AS open_count
FROM email_subject AS es INNER JOIN emails AS e
ON es.email_subject_id=e.email_subject_id
WHERE e.opened='t'
GROUP BY email_subject
ORDER BY open_count DESC
LIMIT 1;


7️⃣ IDENTIFY THE CUSTOMER WHO OPENED THE MOST EMAILS.

SELECT customer_id AS CustomerID,COUNT(*) AS open_count
FROM emails
WHERE opened='t'
GROUP BY CustomerID
ORDER BY open_count DESC
LIMIT 1;

8️⃣ CALCULATE THE AVERAGE NUMBER OF EMAILS SENT PER CUSTOMER.

SELECT ROUND(AVG(email_count),2) AS average_emails_sent
FROM (SELECT DISTINCT customer_id, COUNT(*) AS email_count
FROM emails
GROUP BY customer_id) AS temptable;

9️⃣ CALCULATE THE BOUNCE RATE FOR EACH EMAIL SUBJECT.

SELECT es.email_subject, 
SUM(CASE WHEN e.bounced = 't' THEN 1 ELSE 0 END) AS bounce_count,
COUNT(e.email_id) AS total_emails,
ROUND((SUM(CASE WHEN e.bounced = 't' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS bounce_rate
FROM emails e INNER JOIN email_subject AS es
ON e.email_subject_id=es.email_subject_id
GROUP BY es.email_subject
ORDER BY bounce_rate DESC;

🔟 FIND THE DATE ON WHICH THE FIRST SPRINT SCOOTER WAS SOLD, WHAT WAS ITS PRICE AT THAT TIME.

SELECT DATE(MIN(sales_transaction_date)) AS first_sale_date,p.base_price AS initialprice
FROM sales AS s INNER JOIN products AS p
ON s.product_id=p.product_id
WHERE p.model='Sprint'
GROUP BY initialprice;

1️⃣1️⃣ WHAT IS THE CUMULATIVE SALES VOLUME (IN UNITS) FOR THE FIRST 7 DAYS BETWEEN 10-10-2016 AND 16-10-2016?
 
SELECT CONCAT(count(p.base_price), ' ','units') AS cumulative_sales_volume
FROM sales AS s INNER JOIN products AS p
ON p.product_id=s.product_id
WHERE s.sales_transaction_date BETWEEN '2016-10-10' AND '2016-10-16';

1️⃣2️⃣ ON 20TH OCT, WHAT ARE THE LAST 7 DAYS' CUMULATIVE SALES OF CORPEL AUTOMOBILE (IN UNITS)?

SELECT CONCAT(COUNT(p.base_price), ' ', 'units') AS cumulative_sales_volume
FROM sales AS s
INNER JOIN products AS p ON p.product_id = s.product_id
WHERE s.sales_transaction_date BETWEEN '2016-10-14' AND '2016-10-20' -- Last 7 days leading to 20th Oct
AND p.model = 'Corpel';


1️⃣3️⃣ ON WHICH DATE DID THE SALES VOLUME REACH ITS HIGHEST POINT?

SELECT DATE(s.sales_transaction_date) AS date,COUNT(p.base_price) AS SellVol
FROM sales AS s INNER JOIN products AS p
ON s.product_id=p.product_id
GROUP BY date
ORDER BY SellVol DESC
LIMIT 1;

1️⃣4️⃣ ON 22-10-2016 BY WHAT PERCENTAGE, CUMULATIVE SALES OF LAST 7 DAYS DROPPED COMPARED TO LAST 7 DAYS CUMULATIVE SALES ON 21-10-2016?
 

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


1️⃣5️⃣ CALCULATE THE AVERAGE TIME IT TAKES FOR A CUSTOMER TO MAKE A SECOND PURCHASE.

WITH CustomerPurchaseDates AS (SELECT customer_id, sales_transaction_date,
LAG(sales_transaction_date) OVER (PARTITION BY customer_id ORDER BY sales_transaction_date) AS previous_purchase_date
FROM sales)
SELECT CONCAT(ROUND(AVG(DATEDIFF(sales_transaction_date, previous_purchase_date)),2),' ','days') AS average_time_to_second_purchase
FROM CustomerPurchaseDates
WHERE previous_purchase_date IS NOT NULL;

1️⃣6️⃣ FIND THE TOP 3 CUSTOMERS WITH THE HIGHEST NUMBER OF OPENED EMAILS FOR EACH PRODUCT MODEL.

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

    
1️⃣7️⃣ IDENTIFY THE TOP 5 CUSTOMERS WHO OPENED THE MOST EMAILS AND ALSO MADE A PURCHASE. INCLUDE THE NUMBER OF EMAILS OPENED AND THE TOTAL PURCHASE AMOUNT FOR EACH CUSTOMER.
 
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
 
1️⃣8️⃣ CALCULATE THE BOUNCE RATE FOR EACH EMAIL SUBJECT, CONSIDERING ONLY EMAILS SENT TO CUSTOMERS WHO HAVE MADE A PURCHASE. INCLUDE THE EMAIL SUBJECT AND THE BOUNCE RATE.
 
 
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
 
 1️⃣9️⃣ CALCULATE THE CLICK-THROUGH RATE (CTR) FOR TOP 2 EMAIL ADVERTISEMENT SUBJECTS.
 
/*CTR (%) = (Number of Clicks / Number of Delivered Emails) * 100*/
SELECT es.email_subject,
SUM(CASE WHEN e.clicked = 't' THEN 1 ELSE 0 END) AS clicks,
COUNT(*) AS total_emails,
ROUND((SUM(CASE WHEN e.clicked = 't' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2) AS 'CTR(%)'
FROM emails AS  e INNER JOIN email_subject AS es ON e.email_subject_id = es.email_subject_id
GROUP BY es.email_subject
ORDER BY 'CTR%' DESC
LIMIT 3;













