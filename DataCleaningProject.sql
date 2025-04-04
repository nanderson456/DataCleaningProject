-- Data Cleaning


SELECT *
FROM layoffs;


-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns (If necessary)


CREATE TABLE layoffs_staging LIKE layoffs;


SELECT 
    *
FROM
    layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT 
    *
FROM
    layoffs_staging;

-- Now we have a working copy so that we do not alter the raw data
-- Find Duplicates

SELECT 
    *,
    ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM
    layoffs_staging;
    
WITH duplicate_cte AS
(SELECT 
    *,
    ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM
    layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Check to make sure that the rows returned are indeed duplicates

SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT 
    *,
    ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`,
    stage, country, funds_raised_millions) AS row_num
FROM
    layoffs_staging;
    
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;


-- Standardizing Data

SELECT company, (TRIM(company))
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET company = TRIM(company)
;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- This next code chunk will update all Crypto% in the industry column to Crypto
UPDATE layoffs_staging2
SET industry = 'Crypto%'
WHERE indusrty LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- This next code chunk removes the '.' that was accidentally placed after United States in one of the rows
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`
FROM layoffs_staging2;

-- This code chunk updates the format of the date column
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- This code chunk alters the table and changes the data type of the date column from text to date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Now we will look for NULL values to remove / update / or change

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';


UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Update your data with the new values

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2;


-- The rows returned here likely do not help us at all in our analysis and "can" be delted in our working copy (NOT THE ORIGINAL)
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove the row_num column that we created
SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
