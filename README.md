#  Review Fraud Detection & Behavioral Analysis using SQL

## 📖 Overview
This project focuses on detecting **fraudulent and suspicious product reviews** using SQL-based data analysis techniques.  
It analyzes user behavior, rating patterns, and review activity to identify anomalies and potential fake reviews.

---

##  Problem Statement
Online platforms often suffer from **fake or manipulated reviews**, which can mislead customers and impact product credibility.  

This project aims to:
- Detect suspicious user behavior  
- Identify manipulated product ratings  
- Analyze review trends over time  

---

##  Dataset Description
The dataset contains product review data with the following key attributes:

- `review_id` – Unique identifier for each review  
- `product_id` – Unique product identifier  
- `user_id` – Unique user identifier  
- `profile_name` – Reviewer name  
- `rating` – Rating given (1–5)  
- `helpfulness_numerator` – Helpful votes  
- `helpfulness_denominator` – Total votes  
- `time` – Unix timestamp  

---

##  Data Cleaning & Preparation
- Converted Unix timestamps into readable date format  
- Handled missing values and checked data consistency  
- Identified duplicate records using `review_id`  
- Prevented division errors using `NULLIF()`  

---

##  Exploratory Data Analysis (EDA)
Performed analysis to understand overall trends:

- Total number of reviews, users, and products  
- Rating distribution across dataset  
- Most reviewed products  
- Most active users  
- Average rating per product  

---

##  Suspicious Behavior Detection

###  User-Level Patterns
- Users giving only extreme ratings (only 5★ or 1★)  
- High-frequency reviewers (multiple reviews per day)  
- Same user reviewing the same product multiple times  
- Users with low helpfulness scores  

###  Product-Level Patterns
- Sudden spikes in review activity  
- High ratings with very few reviews  
- Products dominated by a small group of users  
- High variance in ratings  

---

##  Advanced Analysis
- Ranking users based on activity using window functions  
- Ranking products based on ratings  
- Time-based analysis (monthly and yearly trends)  
- Helpfulness ratio analysis  

---

##  Fraud Detection Logic
A rule-based scoring approach was used to identify suspicious users:

```sql
SELECT user_id,
CASE WHEN COUNT(*) > 20 THEN 1 ELSE 0 END +
CASE WHEN AVG(rating) = 5 THEN 1 ELSE 0 END +
CASE WHEN AVG(helpfulness_numerator / NULLIF(helpfulness_denominator,0)) < 0.2 THEN 1 ELSE 0 END
AS suspicious_score
FROM reviews
GROUP BY user_id;
```
* Higher score indicates higher likelihood of fraudulent behavior.

---

##  Key Insights
A group of users consistently gave only 5-star ratings → potential fake reviewers
Some products showed unusually high ratings with very few reviews
Sudden spikes in review activity indicate coordinated behavior
Many high-rated reviews had low or zero helpfulness votes

---

## Business Impact
Improved fraud detection efficiency through automated SQL analysis
Identified high-risk users and products
Enabled data-driven decision-making for review authenticity

---

## Conclusion

This project demonstrates how SQL can be used beyond querying to detect real-world fraud patterns.

By analyzing user behavior, rating trends, and review activity, it successfully identifies suspicious patterns that may indicate fake reviews, helping improve trust and reliability in digital platforms.

---
## Tech Stack
SQL (MySQL)
Data Analysis
Data Cleaning
Exploratory Data Analysis (EDA)

---

## Future Enhancements
Machine Learning-based fake review classification
Sentiment analysis on review text
Interactive dashboard using Power BI or Tableau
