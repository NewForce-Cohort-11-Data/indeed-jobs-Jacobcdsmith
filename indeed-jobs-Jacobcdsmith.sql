-- How many rows are in the data_analyst_jobs table?
SELECT
  COUNT(*) AS total_rows
FROM data_analyst_jobs;

-- Write a query to look at just the first 10 rows.
-- What company is associated with the job posting on the 10th row?

select *
from data_analyst_jobs
LIMIT 10 ;


SELECT company
FROM data_analyst_jobs
LIMIT 1
OFFSET 9 ;



-- How many postings are in Tennessee? How many are there in either Tennessee or Kentucky?-

SELECT
  COUNT(*) FILTER (WHERE location = 'TN')       AS tn_only,
  COUNT(*) FILTER (WHERE location IN ('TN','KY')) AS tn_or_ky
FROM data_analyst_jobs;






-- How many postings in Tennessee have star_rating > 4?

SELECT
 count(*) AS tn_high_rating
FROM data_analyst_jobs
WHERE
  location = 'TN'
  AND star_rating  >  4;






-- How many postings have a reveiw_count between 500 and 1000?
SELECT
  COUNT(*) AS postings_500_1000_reviews
FROM data_analyst_jobs
WHERE
  reveiw_count BETWEEN 500 AND 1000;





  -- average star rating by state
SELECT
  location        AS state,
  ROUND(AVG(star_rating), 2) AS avg_rating
FROM data_analyst_jobs
GROUP BY location
ORDER BY avg_rating DESC;







--  Which state has the highest average rating?
SELECT
  location        AS state,
  ROUND(AVG(star_rating), 2) AS avg_rating
FROM  data_analyst_jobs
GROUP BY location
ORDER BY avg_rating DESC
LIMIT 1;









-- How many unique job titles are there?


SELECT
  COUNT(DISTINCT title) AS unique_title_count
FROM data_analyst_jobs;










-- How many unique job titles are there for California companies?
SELECT
  COUNT(DISTINCT title) AS ca_unique_titles
FROM data_analyst_jobs
WHERE location = 'CA';










-- Find the name of each company and its average star rating for all companies 
-- that have more than 5000 reviews across all locations. How many companies are there with 
-- more that 5000 reviews across all locations?


SELECT
  company,
  ROUND(AVG(star_rating), 2) AS avg_rating,
  SUM(reveiw_count) AS total_reviews
FROM data_analyst_jobs
GROUP BY company
HAVING SUM(reveiw_count) > 5000
ORDER BY avg_rating DESC;





-- Count of companies with more than 5000 reviews across all locations
WITH big_companies AS (
  SELECT
    company
  FROM data_analyst_jobs
  GROUP BY company
  HAVING SUM(reveiw_count) > 5000
)
SELECT
  COUNT(*) AS company_count
FROM big_companies;


-- Add the code to order the query in #9 from highest to lowest average star rating.
-- Which company with more than 5000 reviews across all locations in the dataset has the highest star rating?
-- What is that rating?




SELECT
  company,
  ROUND(AVG(star_rating), 2)    AS avg_rating,
  SUM(reveiw_count)             AS total_reviews
FROM data_analyst_jobs
GROUP BY company
HAVING SUM(reveiw_count) > 5000
ORDER BY avg_rating DESC
LIMIT 1;





-- Find all the job titles that contain the word ‘Analyst’. How many different job titles are there?



--a  List all distinct titles containing “Analyst”

SELECT DISTINCT title AS analyst_title
FROM data_analyst_jobs
WHERE title ILIKE '%Analyst%';

--b Count how many distinct ones there are

SELECT COUNT(DISTINCT title) AS analyst_title_num
FROM data_analyst_jobs
WHERE title ILIKE '%Analyst%';









--How many different job titles do not contain either the word ‘Analyst’ or the word ‘Analytics’? 
--What word do these positions have in common?




-- Count the titles that don’t mention “Analyst” or “Analytics”
SELECT COUNT(DISTINCT title) AS non_analyst_title_num
FROM data_analyst_jobs
WHERE title NOT ILIKE '%Analyst%'
  AND title NOT ILIKE '%Analytics%';



  --  See which titles those are
SELECT DISTINCT title
FROM data_analyst_jobs
WHERE title NOT ILIKE '%Analyst%'
  AND title NOT ILIKE '%Analytics%'
ORDER BY title;



-- Find the word they all share
WITH non_analyst AS (
  SELECT DISTINCT title
  FROM data_analyst_jobs
  WHERE title NOT ILIKE '%Analyst%' AND title NOT ILIKE '%Analytics%'
),
tokens AS (
  SELECT LOWER(unnest(string_to_array(regexp_replace(title, '[^A-Za-z ]', '', 'g'), ' '))) AS token
  FROM non_analyst
)
SELECT token, COUNT(*) AS appearances
FROM tokens
WHERE token <> ''
GROUP BY token
ORDER BY appearances DESC
LIMIT 1;  






-- BONUS: You want to understand which jobs requiring SQL are hard to fill. Find the number of jobs by industry (domain) that require SQL and have been posted longer than 3 weeks.

-- Disregard any postings where the domain is NULL.
-- Order your results so that the domain with the greatest number of hard to fill jobs is at the top.
-- Which three industries are in the top 4 on this list? How many jobs have been listed for more than 3 weeks for each of the top 4?

-- 1) Get the top 4 industries and their hard‑to‑fill counts:
WITH ranked_domains AS (
  SELECT
    domain,
    COUNT(*) AS jobs_over_3_weeks,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rn
  FROM data_analyst_jobs
  WHERE domain IS NOT NULL
    AND skill ILIKE '%sql%'
    AND days_since_posting > 21
  GROUP BY domain
)
SELECT
  domain             AS industry,
  jobs_over_3_weeks
FROM ranked_domains
WHERE rn <= 4;



