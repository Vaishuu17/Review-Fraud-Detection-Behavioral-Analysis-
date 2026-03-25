CREATE DATABASE fake_reviews_detection;
USE fake_reviews_detection;
CREATE TABLE reviews(
review_id INT,
product_id VARCHAR(100),
user_id VARCHAR(100),
profile_name VARCHAR(200),
helpfulness_numerator INT,
helpfulness_denominator INT,
rating INT,
time INT
);

LOAD DATA INFILE 'C:\Users\vaish\OneDrive\Desktop\reviews_sample.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM reviews;                                                                          M 

ALTER TABLE reviews
ADD review_date DATETIME 
GENERATED ALWAYS AS (FROM_UNIXTIME(time));

DESCRIBE reviews;

SELECT * FROM reviews
WHERE product_id IS NULL;

SELECT * FROM reviews
WHERE rating IS NULL;

SELECT review_id , COUNT(*)
FROM reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

SELECT COUNT(DISTINCT user_id)
FROM reviews;

SELECT COUNT(DISTINCT product_id)
FROM reviews;

SELECT AVG(rating) FROM reviews;

SELECT rating, COUNT(*) AS total_reviews
FROM reviews
GROUP BY rating;

-- MOST REVIEWED PRODUCTS >>
SELECT product_id, COUNT(rating) AS total_reviews 
FROM reviews
GROUP BY product_id
ORDER BY total_reviews DESC
LIMIT 10 ;

--  AVERAGE RATING PER PRODUCT >>
SELECT product_id, AVG(rating) AS avg_rating 
FROM reviews
GROUP BY product_id;

-- PRODUCTS WITH HEIGHEST RATING >>
SELECT product_id, AVG(rating) AS avg_rating
FROM reviews
GROUP BY product_id
ORDER BY avg_rating DESC
LIMIT 10 ;

-- PRODUCTS WITH LOWEST RATING >>
SELECT product_id, AVG(rating) AS avg_rating
FROM reviews
GROUP BY product_id
ORDER BY avg_rating ASC
LIMIT 10 ;

-- USERS WHO WROTE MOST REVIEWS >>
SELECT user_id , COUNT(rating) AS total_reviews
FROM reviews
GROUP BY user_id
ORDER BY total_reviews DESC 
LIMIT 10;

--  AVERAGE RATING GIVEN BY EACH USER >>
SELECT user_id , AVG(rating) AS avg_rating
FROM reviews
GROUP BY user_id;

-- USER REVIEWING MANY PRODUCTS >>
 SELECT user_id , COUNT(DISTINCT product_id) AS products_reviewed
FROM reviews
GROUP BY user_id
ORDER BY products_reviewed DESC ;


-- SUSPICIOUS BEHAVIOUR DETECTION >>>
-- USERS POSTING TOO MANY REVIEWS IN ONE DAY >>
SELECT user_id ,review_date , COUNT(rating) AS reviews_per_day
FROM reviews
GROUP BY user_id,review_date
HAVING COUNT(rating) > 5;

-- PRODUCTS RECEIVING SUDDEN REVIEWS SPIKES >>
SELECT product_id , review_date , COUNT(rating) AS daily_reviews 
FROM reviews
GROUP BY product_id,review_date
HAVING COUNT(rating) > 20;

-- USERS GIVING ONLY 5-STAR RATINGS >>
SELECT user_id
FROM reviews
GROUP BY user_id
HAVING MAX(rating) = 5  AND MIN(rating) = 5;

-- USERS GIVING ONLY 1-STAR RATING >>
SELECT user_id
FROM reviews
GROUP BY user_id
HAVING MAX(rating) = 1  
AND MIN(rating) = 1;

-- PRODUCTS WITH SUSPICIOUS HEIGH RATING >>
SELECT product_id , AVG(rating) AS avg_rating, COUNT(rating) AS total_reviews
FROM reviews
GROUP BY product_id
HAVING AVG(rating) > 4.8 AND COUNT(rating) < 10;

-- PRODUCTS WITH SUDDEN INCREASE IN REVIEWS>>
SELECT review_date , COUNT(rating)
FROM reviews
GROUP BY review_date
ORDER BY review_date;


-- TIME ANALYSIS >>>
-- REVIEWS PER MONTH >>
SELECT MONTH(review_date), COUNT(rating)
FROM reviews
GROUP BY MONTH(review_date);
 
-- REVIEWS PER YEAR >>
SELECT YEAR(review_date), COUNT(rating)
FROM reviews
GROUP BY YEAR(review_date);

-- ADVANCED ANALYSIS >>>
-- RANK CUSTOMERS BY RATINGS >>
SELECT product_id ,AVG(rating) AS avg_rating,
RANK() OVER (ORDER BY AVG(rating)) ranking
FROM reviews
GROUP BY product_id;

-- RANK USERS BY NUMBER OF REVIEWS >>
SELECT user_id,COUNT(*) total_rating,
RANK() OVER(ORDER BY COUNT(*) DESC) raking
FROM reviews
GROUP BY user_id; 

-- TOP REVIEWS EACH MONTH >>
SELECT user_id , MONTH(review_date) review_month , COUNT(*) total_reviews
FROM reviews
GROUP BY  user_id , MONTH(review_date);

-- REVIEWS WITH HEIGHEST HELPFULNESS >>
SELECT review_id , helpfulness_numerator, helpfulness_denominator 
FROM reviews
ORDER BY helpfulness_denominator DESC
LIMIT 10;

-- CALCULATE HELPFULNESS RATIO >>
SELECT review_id ,
helpfulness_numerator / NULLIF(helpfulness_denominator,0) AS helpful_ratio
FROM reviews
WHERE helpfulness_numerator > 0;

-- MOST HELPFUL REVIEWERS >>
SELECT user_id , SUM(helpfulness_numerator) AS helpful_votes
FROM reviews
GROUP BY user_id
ORDER BY SUM(helpfulness_numerator) DESC
LIMIT 10;

 -- REVIEWERS WITH LOW HELPFULNESS >>
 SELECT * 
 FROM reviews
 WHERE helpfulness_denominator > 10
 AND helpfulness_numerator < 2;
 
 -- FIND REVIEWS WITH HEIGH RATING BUT LOW HELPFULNESS >>
SELECT review_id , rating, helpfulness_numerator ,helpfulness_denominator
FROM reviews
WHERE rating = 5
and helpfulness_numerator = 0;

-- DETECT USERS WITH LOW AVERAGE HELPFULNESS >>
SELECT user_id,
AVG(helpfulness_numerator / NULLIF(helpfulness_denominator,0)) AS avg_helpfulness
FROM reviews
GROUP BY user_id
HAVING avg_helpfulness < 0.2;

-- COMPARE EARLY VS LATE REVIEWS >>
SELECT product_id,
MIN(review_date) AS first_review,
MAX(review_date) AS last_review,
COUNT(*) AS total_reviews
FROM reviews
GROUP BY product_id;

-- DETECT SAME USER REVIEWING SAME PROUDCT MULTIPLE TIMES >>
SELECT user_id , product_id ,COUNT(*) AS review_count
FROM reviews
GROUP BY user_id,product_id
HAVING COUNT(*) > 1; 
 
 -- FIND PRODUTS WITH HEIGH VERIENCE IN RATING >>
 SELECT product_id ,
AVG(rating) AS avg_rating,
STDDEV(rating) AS rating_variation 
FROM reviews
GROUP BY product_id
ORDER BY STDDEV(rating) DESC;

-- MONTHLY REVIEW SPIKE DETECTION >>
SELECT YEAR(review_date) AS year,
MONTH(review_date) AS month,
COUNT(*) AS total_reviews
FROM reviews
GROUP BY year, month
ORDER BY total_reviews DESC;
 
-- TOP SUSPICIOUS USERS >>
SELECT user_id,
COUNT(*) AS  total_reviews,
AVG(rating) AS avg_rating
FROM reviews
GROUP BY user_id
HAVING COUNT(*) > 10
AND AVG(rating) > 3;

-- PRODUCTS DOMINATED BY FEW USERS >>
SELECT product_id,
COUNT(*) AS total_reviews,
COUNT(DISTINCT user_id) AS unique_users
FROM reviews
GROUP BY product_id
HAVING total_reviews > 10
AND unique_users < 5; 

-- DETECT REVIEWS GAPS (INACTIVE AND THEN SUDDEN ACTIVITIES)
SELECT product_id,
DATEDIFF(MAX(review_date),MIN(review_date)) AS active_days,
COUNT(*) AS total_reviews 
FROM reviews
GROUP BY product_id;

-- FAKE REVIEW INDICATOR >>
SELECT user_id,
CASE 
    WHEN COUNT(*) > 20 THEN 1 ELSE 0 END +
CASE 
    WHEN AVG(rating) = 5 THEN 1 ELSE 0 END +
CASE 
    WHEN AVG(helpfulness_numerator / NULLIF(helpfulness_denominator,0)) < 0.2 THEN 1 ELSE 0 END
AS suspicious_score
FROM reviews
GROUP BY user_id; 

-- REVIEW BURST DETECTION >>
SELECT product_id,review_date,
COUNT(*) AS reviews,
LAG(COUNT(*),1,0) OVER (PARTITION BY product_id ORDER BY review_date) prev_day
FROM reviews
GROUP BY product_id, review_date; 