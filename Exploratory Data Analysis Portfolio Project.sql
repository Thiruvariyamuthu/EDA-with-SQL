-- EDA

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

use  world_layoffs;

SELECT *
FROM LAYOFFS_STAGING_2;

-- EASIER QUERIES

SELECT MAX(total_laid_off)
FROM LAYOFFS_STAGING_2;

SELECT MIN(total_laid_off)
FROM layoffs_staging_2;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),MIN(percentage_laid_off)
FROM layoffs_staging_2
WHERE percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off=1;
-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funds_raised_millions we can see how big some of these companies were
SELECT *
FROM layoffs_staging_2
where percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch



-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------------------------------------------


-- Companies with the biggest single Layoff

SELECT company,total_laid_off
FROM layoffs_staging_2
ORDER BY 2 DESC
LIMIT 5;
-- now that's just on a single day


-- Companies with the most Total Layoffs

SELECT company,SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;




-- by location
SELECT location,SUM(total_laid_off)
FROM layoffs_staging_2
group by location
ORDER BY 2 DESC
LIMIT 10;

-- this it total in the 3 years or in the dataset

SELECT COUNTRY,SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY COUNTRY
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(TOTAL_LAID_OFF)
FROM layoffs_staging_2
group by YEAR(`date`)
ORDER BY 1 ASC;

SELECT INDUSTRY,SUM(TOTAL_LAID_OFF)
FROM layoffs_staging_2
GROUP BY 1
ORDER BY 2 DESC;

SELECT stage,sum(total_laid_off)
FROM layoffs_staging_2
GROUP BY 1
ORDER BY 2 DESC;




-- TOUGHER QUERIES------------------------------------------------------------------------------------------------------------------------------------

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- I want to look at

WITH Company_year(company,years,total_laid_off) as
(
SELECT COMPANY,YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY COMPANY,YEAR(`date`)
),
COMPANY_YEAR_RANK AS
(
SELECT *,
dense_rank() OVER(PARTITION BY YEARS ORDER BY total_laid_off DESC) as ranking
FROM Company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM COMPANY_YEAR_RANK
WHERE RANKING<=3;




-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(`date`,1,7) as dates,SUM(TOTAL_LAID_OFF)
FROM layoffs_staging_2
where SUBSTRING(`date`,1,7) is not null
GROUP BY dates
ORDER BY 1 ASC;

 -- now use it in a CTE so we can query off of i
WITH DATE_CTE AS
(
SELECT SUBSTRING(`date`,1,7) as dates,SUM(TOTAL_LAID_OFF) AS total_laid_off
FROM layoffs_staging_2
where SUBSTRING(`date`,1,7) is not null
GROUP BY dates
ORDER BY 1 ASC
)
SELECT dates,sum(total_laid_off) OVER(ORDER BY DATES ASC) AS rolling_total_offs
FROM DATE_CTE
ORDER BY DATES ASC;



