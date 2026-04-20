--1 Total revenue per day
SELECT date(order_purchase_timestamp) date
, sum(price+fs.FREIGHT_VALUE) revenue
FROM FACT_SALES fs 
GROUP BY date
ORDER BY date;

--2. Top 5 products by revenue in last 30 days
SELECT dp.PRODUCT_CATEGORY_NAME ,sum(price) revenue  FROM (
    SELECT fs.*, max(date(ORDER_PURCHASE_TIMESTAMP)) OVER () max_date
    FROM FACT_SALES fs 
)  sales 
JOIN DIM_PRODUCTS dp ON sales.PRODUCT_ID =dp.PRODUCT_ID 
WHERE 
    date(ORDER_PURCHASE_TIMESTAMP ) >= date(max_date - INTERVAL '30 day')
    --date(ORDER_PURCHASE_TIMESTAMP ) >= date(max_date - INTERVAL '30 day')
GROUP BY dp.PRODUCT_CATEGORY_NAME
ORDER BY REVENUE DESC
LIMIT 5;

--3 Monthly active customers
SELECT 
	DATE_TRUNC('month',ORDER_PURCHASE_TIMESTAMP) MONTH ,
	count(DISTINCT CUSTOMER_ID) total_customers
FROM FACT_SALES fs 
GROUP BY MONTH
ORDER by MONTH DESC;

--4. Average order value per customer
SELECT fs.CUSTOMER_ID , sum (fs.TOTAL_AMOUNT ) / count(DISTINCT ORDER_ID) avg
FROM FACT_SALES fs
GROUP BY fs.CUSTOMER_ID
ORDER BY avg DESC;

--5. Data anomaly:
---- price <= 0
SELECT * 
FROM FACT_SALES fs 
WHERE fs.PRICE <= 0;
----quantity <= 0
---- tidak menemukan kolom quantity, saya coba tampilkan data order dengan jumlah/ order items 0

SELECT ro.ORDER_ID, count(DISTINCT ORDER_ITEM_ID) jml
FROM RAW_ORDERs ro 
LEFT JOIN RAW_ORDER_ITEMS roi ON ro.ORDER_ID = roi.ORDER_ID
group BY ro.ORDER_ID
HAVING count(DISTINCT ORDER_ITEM_ID) = 0;
---- missing customer_id
SELECT * 
FROM FACT_SALES fs
WHERE customer_id IS NULL;
