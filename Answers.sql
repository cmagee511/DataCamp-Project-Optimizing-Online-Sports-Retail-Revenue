--Question 1

```sql

-- Count all columns as total_rows
-- Count the number of non-missing entries for description, listing_price, and last_visited
-- Join info, finance, and traffic

SELECT COUNT(*) as total_rows,
       COUNT(i.description) as count_description,
       COUNT(f.listing_price) as count_listing_price,
       COUNT(t.last_visited) as count_last_visited
FROM info as i
INNER JOIN finance as f ON i.product_id = f.product_id
INNER JOIN traffic as t ON t.product_id = f.product_id;
```
  
--Question 2

```sql


-- Select the brand, listing_price as an integer, and a count of all products in finance 
-- Join brands to finance on product_id
-- Filter for products with a listing_price more than zero
-- Aggregate results by brand and listing_price, and sort the results by listing_price in descending order

SELECT b.brand, f.listing_price::integer, COUNT(f.*)
FROM finance AS f
INNER JOIN brands AS b 
    ON f.product_id = b.product_id
WHERE listing_price > 0
GROUP BY b.brand, f.listing_price
ORDER BY listing_price DESC;
```

-- Question 3
```sql
-- Select the brand, a count of all products in the finance table, and total revenue
-- Create four labels for products based on their price range, aliasing as price_category
-- Join brands to finance on product_id and filter out products missing a value for brand
-- Group results by brand and price_category, sort by total_revenue

SELECT b.brand,
       COUNT(f.*),
       SUM(f.revenue) as total_revenue,
       CASE WHEN (f.listing_price < 42) THEN 'Budget'
       WHEN (f.listing_price >= 42 AND f.listing_price < 74) THEN 'Average'
       WHEN (f.listing_price >= 74 AND f.listing_price < 129) THEN 'Expensive'
       ELSE 'Elite' END AS price_category
FROM brands as b
JOIN finance as f ON b.product_id = f.product_id
WHERE brand IS NOT NULL
GROUP BY b.brand,price_category
ORDER BY total_revenue DESC;
```
-- Question 4

```sql
-- Select brand and average_discount as a percentage
-- Join brands to finance on product_id
-- Aggregate by brand
-- Filter for products without missing values for brand

SELECT b.brand,
       avg(f.discount)*100 as average_discount
FROM brands as b 
LEFT JOIN finance as f ON b.product_id = f.product_id
WHERE b.brand IS NOT NULL
GROUP BY b.brand;
```

-- Question 5

```sql
-- Calculate the correlation between reviews and revenue as review_revenue_corr
-- Join the reviews and finance tables on product_id

SELECT CORR(r.reviews,f.revenue) as review_revenue_corr
FROM reviews as r 
LEFT JOIN finance as f ON r.product_id = f.product_id;
```
-- Question 6

```sql
-- Calculate description_length
-- Convert rating to a numeric data type and calculate average_rating
-- Join info to reviews on product_id and group the results by description_length
-- Filter for products without missing values for description, and sort results by description_length

SELECT TRUNC(LENGTH(i.description),-2) as description_length,
       ROUND(AVG(r.rating::numeric),2) as average_rating
From info as i
LEFT JOIN reviews as r ON i.product_id = r.product_id
WHERE i.description IS NOT NULL
GROUP BY description_length
ORDER BY description_length ASC;
```

-- Question 7 

```sql
-- Select brand, month from last_visited, and a count of all products in reviews aliased as num_reviews
-- Join traffic with reviews and brands on product_id
-- Group by brand and month, filtering out missing values for brand and month
-- Order the results by brand and month

SELECT b.brand,
       EXTRACT(month FROM t.last_visited) as month,
       COUNT(r.*) as num_reviews
FROM traffic as t
INNER JOIN reviews as r ON t.product_id = r.product_id
INNER JOIN brands as b ON  t.product_id = b.product_id
WHERE b.brand IS NOT NULL
AND t.last_visited IS NOT NULL
GROUP BY b.brand, month
ORDER BY b.brand, month;
```

-- Question 8

```sql
-- Create the footwear CTE, containing description and revenue
-- Filter footwear for products with a description containing %shoe%, %trainer, or %foot%
-- Also filter for products that are not missing values for description
-- Calculate the number of products and median revenue for footwear products

WITH footwear AS 
(
  SELECT i.description,
         f.revenue
  FROM info as i
  INNER JOIN finance as f ON i.product_id = f.product_id
  WHERE i.description ILIKE '%shoe%' 
  OR i.description ILIKE '%trainer%' 
  OR i.description ILIKE '%foot%'
  AND i.description IS NOT NULL
)
SELECT COUNT(*) AS num_footwear_products, 
    percentile_disc(0.5) WITHIN GROUP (ORDER BY revenue) AS median_footwear_revenue
FROM footwear;
```
-- Question 9 

WITH footwear AS 
(
  SELECT i.description,
         f.revenue
  FROM info as i
  INNER JOIN finance as f ON i.product_id = f.product_id
  WHERE i.description ILIKE '%shoe%' 
  OR i.description ILIKE '%trainer%' 
  OR i.description ILIKE '%foot%'
  AND i.description IS NOT NULL
)
SELECT COUNT(i.*) AS num_clothing_products, 
    percentile_disc(0.5) WITHIN GROUP (ORDER BY f.revenue) AS median_clothing_revenue
FROM info AS i
INNER JOIN finance AS f on i.product_id = f.product_id
WHERE i.description NOT IN (SELECT description FROM footwear);
```
