# DataCamp-Project-Optimizing-Online-Sports-Retail-Revenue

## 1. Counting missing values
<p>Sports clothing and athleisure attire is a huge industry, worth approximately <a href="https://www.statista.com/statistics/254489/total-revenue-of-the-global-sports-apparel-market/">$193 billion in 2021</a> with a strong growth forecast over the next decade! </p>
<p>In this notebook, we play the role of a product analyst for an online sports clothing company. The company is specifically interested in how it can improve revenue. We will dive into product data such as pricing, reviews, descriptions, and ratings, as well as revenue and website traffic, to produce recommendations for its marketing and sales teams.  </p>
<p>The database provided to us, <code>sports</code>, contains five tables, with <code>product_id</code> being the primary key for all of them: </p>
<h3 id="info"><code>info</code></h3>
<table>
<thead>
<tr>
<th>column</th>
<th>data type</th>
<th>description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>product_name</code></td>
<td><code>varchar</code></td>
<td>Name of the product</td>
</tr>
<tr>
<td><code>product_id</code></td>
<td><code>varchar</code></td>
<td>Unique ID for product</td>
</tr>
<tr>
<td><code>description</code></td>
<td><code>varchar</code></td>
<td>Description of the product</td>
</tr>
</tbody>
</table>
<h3 id="finance"><code>finance</code></h3>
<table>
<thead>
<tr>
<th>column</th>
<th>data type</th>
<th>description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>product_id</code></td>
<td><code>varchar</code></td>
<td>Unique ID for product</td>
</tr>
<tr>
<td><code>listing_price</code></td>
<td><code>float</code></td>
<td>Listing price for product</td>
</tr>
<tr>
<td><code>sale_price</code></td>
<td><code>float</code></td>
<td>Price of the product when on sale</td>
</tr>
<tr>
<td><code>discount</code></td>
<td><code>float</code></td>
<td>Discount, as a decimal, applied to the sale price</td>
</tr>
<tr>
<td><code>revenue</code></td>
<td><code>float</code></td>
<td>Amount of revenue generated by each product, in US dollars</td>
</tr>
</tbody>
</table>
<h3 id="reviews"><code>reviews</code></h3>
<table>
<thead>
<tr>
<th>column</th>
<th>data type</th>
<th>description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>product_name</code></td>
<td><code>varchar</code></td>
<td>Name of the product</td>
</tr>
<tr>
<td><code>product_id</code></td>
<td><code>varchar</code></td>
<td>Unique ID for product</td>
</tr>
<tr>
<td><code>rating</code></td>
<td><code>float</code></td>
<td>Product rating, scored from <code>1.0</code> to <code>5.0</code></td>
</tr>
<tr>
<td><code>reviews</code></td>
<td><code>float</code></td>
<td>Number of reviews for the product</td>
</tr>
</tbody>
</table>
<h3 id="traffic"><code>traffic</code></h3>
<table>
<thead>
<tr>
<th>column</th>
<th>data type</th>
<th>description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>product_id</code></td>
<td><code>varchar</code></td>
<td>Unique ID for product</td>
</tr>
<tr>
<td><code>last_visited</code></td>
<td><code>timestamp</code></td>
<td>Date and time the product was last viewed on the website</td>
</tr>
</tbody>
</table>
<h3 id="brands"><code>brands</code></h3>
<table>
<thead>
<tr>
<th>column</th>
<th>data type</th>
<th>description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>product_id</code></td>
<td><code>varchar</code></td>
<td>Unique ID for product</td>
</tr>
<tr>
<td><code>brand</code></td>
<td><code>varchar</code></td>
<td>Brand of the product</td>
</tr>
</tbody>
</table>
<p>We will be dealing with missing data as well as numeric, string, and timestamp data types to draw insights about the products in the online store. Let's start by finding out how complete the data is.</p>


```sql
%%sql
postgresql:///sports

-- Count all columns as total_rows
-- Count the number of non-missing entries for description, listing_price, and last_visited
-- Join info, finance, and traffic

SELECT COUNT(*) as total_rows,
       COUNT(i.description) as count_description,
       COUNT(f.listing_price) as count_listing_price,
       COUNT(t.last_visited) as count_last_visited
FROM info as i
INNER JOIN finance as f ON i.product_id = f.product_id
INNER JOIN traffic as t ON t.product_id = f.product_id
```

  





<table>
    <tr>
        <th>total_rows</th>
        <th>count_description</th>
        <th>count_listing_price</th>
        <th>count_last_visited</th>
    </tr>
    <tr>
        <td>3179</td>
        <td>3117</td>
        <td>3120</td>
        <td>2928</td>
    </tr>
</table>




## 2. Nike vs Adidas pricing
<p>We can see the database contains 3,179 products in total. Of the columns we previewed, only one &mdash; <code>last_visited</code> &mdash; is missing more than five percent of its values. Now let's turn our attention to pricing. </p>
<p>How do the price points of Nike and Adidas products differ? Answering this question can help us build a picture of the company's stock range and customer market. We will run a query to produce a distribution of the <code>listing_price</code> and the count for each price, grouped by <code>brand</code>. </p>


```sql
%%sql

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

    



<table>
    <tr>
        <th>brand</th>
        <th>listing_price</th>
        <th>count</th>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>300</td>
        <td>2</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>280</td>
        <td>4</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>240</td>
        <td>5</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>230</td>
        <td>8</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>220</td>
        <td>11</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>200</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>200</td>
        <td>8</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>190</td>
        <td>2</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>190</td>
        <td>7</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>180</td>
        <td>4</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>180</td>
        <td>34</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>170</td>
        <td>14</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>170</td>
        <td>27</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>160</td>
        <td>31</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>160</td>
        <td>28</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>150</td>
        <td>41</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>150</td>
        <td>6</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>140</td>
        <td>36</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>140</td>
        <td>12</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>130</td>
        <td>96</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>130</td>
        <td>12</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>120</td>
        <td>115</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>120</td>
        <td>16</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>110</td>
        <td>17</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>110</td>
        <td>91</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>100</td>
        <td>14</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>100</td>
        <td>72</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>96</td>
        <td>2</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>95</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>90</td>
        <td>13</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>90</td>
        <td>89</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>86</td>
        <td>7</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>85</td>
        <td>5</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>85</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>80</td>
        <td>322</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>80</td>
        <td>16</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>79</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>76</td>
        <td>149</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>75</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>75</td>
        <td>7</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>70</td>
        <td>87</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>70</td>
        <td>4</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>66</td>
        <td>102</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>65</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>63</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>60</td>
        <td>2</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>60</td>
        <td>211</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>56</td>
        <td>174</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>55</td>
        <td>2</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>53</td>
        <td>43</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>50</td>
        <td>5</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>50</td>
        <td>183</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>48</td>
        <td>42</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>48</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>46</td>
        <td>163</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>45</td>
        <td>3</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>45</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>43</td>
        <td>51</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>40</td>
        <td>81</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>40</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>38</td>
        <td>24</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>36</td>
        <td>25</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>33</td>
        <td>24</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>30</td>
        <td>37</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>30</td>
        <td>2</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>28</td>
        <td>38</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>27</td>
        <td>18</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>25</td>
        <td>28</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>23</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>20</td>
        <td>8</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>18</td>
        <td>4</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>16</td>
        <td>4</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>15</td>
        <td>27</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>13</td>
        <td>27</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>12</td>
        <td>1</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>10</td>
        <td>11</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>9</td>
        <td>1</td>
    </tr>
</table>



## 3. Labeling price ranges
<p>It turns out there are 77 unique prices for the products in our database, which makes the output of our last query quite difficult to analyze. </p>
<p>Let's build on our previous query by assigning labels to different price ranges, grouping by <code>brand</code> and <code>label</code>. We will also include the total <code>revenue</code> for each price range and <code>brand</code>. </p>


```sql
%%sql

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






<table>
    <tr>
        <th>brand</th>
        <th>count</th>
        <th>total_revenue</th>
        <th>price_category</th>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>849</td>
        <td>4626980.069999999</td>
        <td>Expensive</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>1060</td>
        <td>3233661.060000001</td>
        <td>Average</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>307</td>
        <td>3014316.8299999987</td>
        <td>Elite</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>359</td>
        <td>651661.1200000002</td>
        <td>Budget</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>357</td>
        <td>595341.0199999992</td>
        <td>Budget</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>82</td>
        <td>128475.59000000003</td>
        <td>Elite</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>90</td>
        <td>71843.15000000004</td>
        <td>Expensive</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>16</td>
        <td>6623.5</td>
        <td>Average</td>
    </tr>
</table>



## 4. Average discount by brand
<p>Interestingly, grouping products by brand and price range allows us to see that Adidas items generate more total revenue regardless of price category! Specifically, <code>"Elite"</code> Adidas products priced \$129 or more typically generate the highest revenue, so the company can potentially increase revenue by shifting their stock to have a larger proportion of these products!</p>
<p>Note we have been looking at <code>listing_price</code> so far. The <code>listing_price</code> may not be the price that the product is ultimately sold for. To understand <code>revenue</code> better, let's take a look at the <code>discount</code>, which is the percent reduction in the <code>listing_price</code> when the product is actually sold. We would like to know whether there is a difference in the amount of <code>discount</code> offered between brands, as this could be influencing <code>revenue</code>.</p>


```sql
%%sql

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




<table>
    <tr>
        <th>brand</th>
        <th>average_discount</th>
    </tr>
    <tr>
        <td>Nike</td>
        <td>0.0</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>33.452427184465606</td>
    </tr>
</table>




## 5. Correlation between revenue and reviews
<p>Strangely, no <code>discount</code> is offered on Nike products! In comparison, not only do Adidas products generate the most revenue, but these products are also heavily discounted! </p>
<p>To improve revenue further, the company could try to reduce the amount of discount offered on Adidas products, and monitor sales volume to see if it remains stable. Alternatively, it could try offering a small discount on Nike products. This would reduce average revenue for these products, but may increase revenue overall if there is an increase in the volume of Nike products sold. </p>
<p>Now explore whether relationships exist between the columns in our database. We will check the strength and direction of a correlation between <code>revenue</code> and <code>reviews</code>. </p>


```sql
%%sql

-- Calculate the correlation between reviews and revenue as review_revenue_corr
-- Join the reviews and finance tables on product_id

SELECT CORR(r.reviews,f.revenue) as review_revenue_corr
FROM reviews as r 
LEFT JOIN finance as f ON r.product_id = f.product_id

```

    



<table>
    <tr>
        <th>review_revenue_corr</th>
    </tr>
    <tr>
        <td>0.6518512283481301</td>
    </tr>
</table>





## 6. Ratings and reviews by product description length
<p>Interestingly, there is a strong positive correlation between <code>revenue</code> and <code>reviews</code>. This means, potentially, if we can get more reviews on the company's website, it may increase sales of those items with a larger number of reviews. </p>
<p>Perhaps the length of a product's <code>description</code> might influence a product's <code>rating</code> and <code>reviews</code> &mdash; if so, the company can produce content guidelines for listing products on their website and test if this influences <code>revenue</code>. Let's check this out!</p>


```sql
%%sql

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
ORDER BY description_length ASC
```

 




<table>
    <tr>
        <th>description_length</th>
        <th>average_rating</th>
    </tr>
    <tr>
        <td>0</td>
        <td>1.87</td>
    </tr>
    <tr>
        <td>100</td>
        <td>3.21</td>
    </tr>
    <tr>
        <td>200</td>
        <td>3.27</td>
    </tr>
    <tr>
        <td>300</td>
        <td>3.29</td>
    </tr>
    <tr>
        <td>400</td>
        <td>3.32</td>
    </tr>
    <tr>
        <td>500</td>
        <td>3.12</td>
    </tr>
    <tr>
        <td>600</td>
        <td>3.65</td>
    </tr>
</table>




## 7. Reviews by month and brand
<p>Unfortunately, there doesn't appear to be a clear pattern between the length of a product's <code>description</code> and its <code>rating</code>.</p>
<p>As we know a correlation exists between <code>reviews</code> and <code>revenue</code>, one approach the company could take is to run experiments with different sales processes encouraging more reviews from customers about their purchases, such as by offering a small discount on future purchases. </p>
<p>Let's take a look at the volume of <code>reviews</code> by month to see if there are any trends or gaps we can look to exploit.</p>


```sql
%%sql

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

  


<table>
    <tr>
        <th>brand</th>
        <th>month</th>
        <th>num_reviews</th>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>1</td>
        <td>253</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>2</td>
        <td>272</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>3</td>
        <td>269</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>4</td>
        <td>180</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>5</td>
        <td>172</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>6</td>
        <td>159</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>7</td>
        <td>170</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>8</td>
        <td>189</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>9</td>
        <td>181</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>10</td>
        <td>192</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>11</td>
        <td>150</td>
    </tr>
    <tr>
        <td>Adidas</td>
        <td>12</td>
        <td>190</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>1</td>
        <td>52</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>2</td>
        <td>52</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>3</td>
        <td>55</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>4</td>
        <td>42</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>5</td>
        <td>41</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>6</td>
        <td>43</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>7</td>
        <td>37</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>8</td>
        <td>29</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>9</td>
        <td>28</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>10</td>
        <td>47</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>11</td>
        <td>38</td>
    </tr>
    <tr>
        <td>Nike</td>
        <td>12</td>
        <td>35</td>
    </tr>
</table>



## 8. Footwear product performance
<p>Looks like product reviews are highest in the first quarter of the calendar year, so there is scope to run experiments aiming to increase the volume of reviews in the other nine months!</p>
<p>So far, we have been primarily analyzing Adidas vs Nike products. Now, let's switch our attention to the type of products being sold. As there are no labels for product type, we will create a Common Table Expression (CTE) that filters <code>description</code> for keywords, then use the results to find out how much of the company's stock consists of footwear products and the median <code>revenue</code> generated by these items.</p>


```sql
%%sql

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

    



<table>
    <tr>
        <th>num_footwear_products</th>
        <th>median_footwear_revenue</th>
    </tr>
    <tr>
        <td>2700</td>
        <td>3118.36</td>
    </tr>
</table>





## 9. Clothing product performance
<p>Recall from the first task that we found there are 3,117 products without missing values for <code>description</code>. Of those, 2,700 are footwear products, which accounts for around 85% of the company's stock. They also generate a median revenue of over $3000 dollars!</p>
<p>This is interesting, but we have no point of reference for whether footwear's <code>median_revenue</code> is good or bad compared to other products. So, for our final task, let's examine how this differs to clothing products. We will re-use <code>footwear</code>, adding a filter afterward to count the number of products and <code>median_revenue</code> of products that are not in <code>footwear</code>.</p>


```sql
%%sql

-- Copy the footwear CTE from the previous task
-- Calculate the number of products in info and median revenue from finance
-- Inner join info with finance on product_id
-- Filter the selection for products with a description not in footwear


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


<table>
    <tr>
        <th>num_clothing_products</th>
        <th>median_clothing_revenue</th>
    </tr>
    <tr>
        <td>417</td>
        <td>503.82</td>
    </tr>
</table>




