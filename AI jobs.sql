-- Create the database
CREATE DATABASE ai_jobs_db

USE ai_jobs_db

CREATE TABLE ai_jobs (
    job_id VARCHAR(50) PRIMARY KEY,
    job_title VARCHAR(255),
    salary_usd INT,
    salary_currency VARCHAR(10),
    experience_level VARCHAR(10), -- EN, MI, SE, EX
    employment_type VARCHAR(10), -- FT, PT, CT, FL
    company_location VARCHAR(100),
    company_size VARCHAR(10), -- S, M, L
    employee_residence VARCHAR(100),
    remote_ratio INT, -- 0, 50, 100
    required_skills TEXT,
    education_required VARCHAR(50),
    years_experience INT,
    industry VARCHAR(100),
    posting_date DATE,
    application_deadline DATE,
    job_description_length INT,
    benefits_score DECIMAL(3, 1),
    company_name VARCHAR(255)
); 

-- 30 Business Intelligence Scenarios

--  Market Overview: Retrieve all columns for the first 100 rows to understand the data distribution. 
select * from ai_jobs limit 100;

-- Specific Roles: Find all jobs with the title 'Data Scientist' or 'Machine Learning Engineer'.
select * from ai_jobs
where job_title = 'Data Scientist'
or job_title = 'Machine Learning Engineer';

-- Salary Filter: List all job details where the salary_usd is greater than $200,000.
SELECT * FROM ai_jobs 
WHERE salary_usd > 200000;

-- Remote Opportunities: Find all 'Full-Time' (FT) jobs that offer 100% remote work.
SELECT * FROM ai_jobs 
WHERE employment_type = 'FT' 
AND remote_ratio = 100;

-- Skill Match: Search for all jobs that require 'SQL' as a skill 
SELECT * FROM ai_jobs 
WHERE required_skills LIKE '%SQL%';

-- Salary by Level: Calculate the average salary for each experience_level.
SELECT experience_level, AVG(salary_usd) AS average_salary
FROM ai_jobs
GROUP BY experience_level; 

-- Industry Ranking: Rank all jobs within each industry by their salary_usd in descending order using RANK()
SELECT *, 
       RANK() OVER (PARTITION BY industry ORDER BY salary_usd DESC) as salary_rank
FROM ai_jobs;

-- Subquery Analysis: Find jobs that pay more than the overall average salary of the entire dataset.
SELECT * FROM ai_jobs 
WHERE salary_usd > (SELECT AVG(salary_usd) FROM ai_jobs);

-- Cross-Border Analysis: Find the percentage of jobs where the employee_residence is different from the company_location
SELECT 
    ROUND(100.0 * SUM(CASE WHEN employee_residence <> company_location THEN 1 ELSE 0 END) / COUNT(*), 2) AS cross_border_percentage
FROM ai_jobs;

-- Monthly Trends: Extract the month from posting_date and find which month had the most job postings.
SELECT 
    MONTHNAME(posting_date) AS month_name, 
    COUNT(*) AS total_postings
FROM ai_jobs
GROUP BY month_name
ORDER BY total_postings DESC
LIMIT 1;

-- Salary Benchmarking (CTE): Create a CTE to find the average salary per industry, then join it with the main table to show how much each job is above/below its industry average.
WITH IndustryAvg AS (
    -- Pehle har industry ka average nikal lo
    SELECT industry, AVG(salary_usd) AS avg_industry_salary
    FROM ai_jobs
    GROUP BY industry
)
SELECT 
    a.job_title, 
    a.industry, 
    a.salary_usd, 
    i.avg_industry_salary,
    (a.salary_usd - i.avg_industry_salary) AS difference_from_avg
FROM ai_jobs a
JOIN IndustryAvg i ON a.industry = i.industry;

-- Top 2 per Category: Using DENSE_RANK(), find the top 2 highest-paying jobs for each experience_level.
WITH RankedJobs AS (
    SELECT *, 
           DENSE_RANK() OVER (PARTITION BY experience_level ORDER BY salary_usd DESC) as salary_rank
    FROM ai_jobs
)
SELECT * FROM RankedJobs 
WHERE salary_rank <= 2;

-- Cumulative Salary: Calculate the running total of salaries for each company, ordered by posting_date
SELECT 
    company_name, 
    posting_date, 
    salary_usd,
    SUM(salary_usd) OVER (PARTITION BY company_name ORDER BY posting_date) AS running_total
FROM ai_jobs;

-- String Manipulation: List all jobs that require more than 3 skills (Hint: Count the commas in the required_skills column).
SELECT job_title, required_skills 
FROM ai_jobs
WHERE (LENGTH(required_skills) - LENGTH(REPLACE(required_skills, ',', ''))) >= 3;

-- The 'PhD' Gap: Calculate the difference between the average salary of a 'PhD' holder and a 'Bachelor' holder within the 'Consulting' industry.
SELECT 
    AVG(CASE WHEN education_required = 'PhD' THEN salary_usd END) - 
    AVG(CASE WHEN education_required = 'Bachelor' THEN salary_usd END) 
AS phd_salary_gap
FROM ai_jobs
WHERE industry = 'Consulting';

-- Hiring Momentum: Identify companies that posted more than 5 jobs in a single month.
SELECT 
    company_name, 
    MONTHNAME(posting_date) AS hiring_month, 
    COUNT(*) AS job_count
FROM ai_jobs
GROUP BY company_name, hiring_month
HAVING COUNT(*) > 5
ORDER BY job_count DESC;