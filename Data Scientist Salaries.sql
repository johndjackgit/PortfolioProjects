/*

    John D Jackson
    Using SQL to Clean a Dataset Containing Data Scientist Salaries

*/

--------------------------------------------------------------------------------
/*				              Dataset Description	   	                      */
--------------------------------------------------------------------------------

/*
The Data Scientist Salaries dataset provides detailed information about the 
compensation of professionals in various job disciplines within the data science 
field. This dataset includes job title, company name and location, years of 
experience, and compensation. 
*/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*				                 Select Statement      		  		       */
--------------------------------------------------------------------------------

/*
SELECT COUNT(*) counts the total number of rows in the salaries table including 
rows with NULL values in any column.  The output is 62640 rows which matches the 
number of rows in a copy of the dataset that was opened and examined in Excel. 
*/

SELECT COUNT(*) FROM 
salaries;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*				                   Backup Table     		  		           */
--------------------------------------------------------------------------------

CREATE TABLE salaries_backup AS
SELECT * 
FROM salaries;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
/*				                 Duplicate Column      		  		       */
--------------------------------------------------------------------------------

-- Add a duplicate column called 'company_duplicate'
ALTER TABLE salaries
ADD COLUMN company_duplicate TEXT;

-- Copy the values from the company column into the company_duplicate column
UPDATE salaries
SET company_duplicate = company;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

/*
Exploring the 'Race' column to identify NA's and change them to NULL.
*/

--Identification Query
SELECT Race,COUNT(Race)
FROM salaries
GROUP BY Race
ORDER BY Race;

--Update Query
UPDATE salaries
SET Race = NULL
WHERE Race = 'NA';

--Validation Query
SELECT COUNT(*) AS null_count
FROM salaries
WHERE Race IS NULL;

/*
The purpose of this modification is to clean the 'Race' column by replacing 
incorrect "NA" string entries with proper SQL `NULL` values, which better 
represent missing or unknown data. This ensures that the column is correctly 
standardized. The identification and validation queries are used to first assess 
the number of NA's and then confirm that the replacement of "NA" with `NULL` has 
been successfully applied.
*/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

/* 
Exploring the company column to identify alternate versions of company 
names listed in this column (e.g. American Airlines(21), American airlines(1), 
american airlines(1)). The 'update query' below standardizes the capitalization of 
"American Airlines" so all versions of this entry appear as "American Airlines" in 
the company column.
*/

--Identification Query
SELECT company,COUNT(company)
FROM salaries
GROUP BY company
ORDER BY company;

--Update Query
UPDATE salaries
SET company = 'American Airlines'
WHERE company IN ('American airlines', 'american airlines', 'American Airlines');

--Validation Query
SELECT company, COUNT(company) AS count
FROM salaries
WHERE company ILIKE '%american airlines%'
GROUP BY company
ORDER BY company;

/*
The purpose of this modification is to standardize the entries for 
"American Airlines" in the company column of the salaries table. It addresses 
variations such as "American airlines" and "amercan airlines" to ensure 
consistency in the data. This improves data quality and enables accurate 
reporting and analysis on the company field.
*/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

/*
Exploring the 'tag' column of the salaries table which includes additional labels 
or tags associated with specific job disciplines. These tags describe the specific 
focus or sub-discipline within data science that the role involves, adding 
additional granularity when analyzing the dataset. The update query below 
standardizes the alternate versions of "Full Stack" listed in this column so that 
all entries appear as "Full Stack".
*/

--Identification Query
SELECT tag,COUNT(tag)
FROM salaries
GROUP BY tag
ORDER BY tag;

--Update Query
UPDATE salaries
SET tag = 'Full Stack'
WHERE tag IN ('Full stack', 'Full Stack', 'Fullstack',
'Consulting - Full stack / API development / distributed systems',
'Full Stack (Infra > mid > mobile',
'Full Stack Architecture including cloud',
'Full Stack Development using Low Code platform',
'Full stack, data engineering, ml');

--Validation Query
SELECT tag, COUNT(tag) AS count
FROM salaries
WHERE tag ILIKE '%Full Stack%'
GROUP BY tag
ORDER BY tag;

/*
The purpose of this modification is to standardize the entries for "Full Stack" 
in the 'tag' column of the salaries table. It addresses variations such as 
"Full stack" and "Fullstack" to ensure consistency in the data. 
This improves data quality and enables accurate reporting and analysis on the 
'tag' field.
*/

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

/*
Converting four salary-related columns (total_yearly_compensation, base_salary, 
stock_grant_value, and bonus) in the salaries table to the money datatype. 
*/

--Identification Query
SELECT 
    column_name, 
    data_type
FROM 
    information_schema.columns
WHERE 
    table_name = 'salaries'
    AND column_name IN ('total_yearly_compensation', 'base_salary', 'stock_grant_value', 'bonus')
    AND data_type IN ('integer', 'numeric');


--Update Query
ALTER TABLE salaries
ALTER COLUMN total_yearly_compensation TYPE money USING total_yearly_compensation::money;

ALTER TABLE salaries
ALTER COLUMN base_salary TYPE money USING base_salary::money;

ALTER TABLE salaries
ALTER COLUMN stock_grant_value TYPE money USING stock_grant_value::money;

ALTER TABLE salaries
ALTER COLUMN bonus TYPE money USING bonus::money;


--Validation Query
SELECT 
    column_name, 
    data_type
FROM 
    information_schema.columns
WHERE 
    table_name = 'salaries'
    AND column_name IN ('total_yearly_compensation', 'base_salary', 'stock_grant_value', 'bonus')
    AND data_type = 'money';

	
/*
The purpose of this code is to update the datatype of four salary-related columns 
(total_yearly_compensation, base_salary, stock_grant_value, and bonus) in the 
salaries table to the money datatype, which is designed to handle monetary values 
in PostgreSQL. This ensures that these columns are optimized for financial calculations. 
*/


/*
Extracting the month, day, and year from each entry in the timestamp column 
and placing them in separate columns named "month", "day", and "year". 
*/

--Identification Query
SELECT timestamp,COUNT(timestamp)
FROM salaries
GROUP BY timestamp
ORDER BY timestamp;

--Update Query
ALTER TABLE salaries
ADD COLUMN month INT,
ADD COLUMN day INT,
ADD COLUMN year INT;


UPDATE salaries
SET 
    month = EXTRACT(MONTH FROM timestamp),
    day   = EXTRACT(DAY FROM timestamp),
    year  = EXTRACT(YEAR FROM timestamp);

--Validation Query
SELECT 
    timestamp, 
    month, 
    day, 
    year
FROM 
    salaries
LIMIT 10;

/*
The purpose of this code is to extract the month, day, and year from each entry 
in the timestamp column and store them in newly created columns (month, day, and year). 
This makes it easier to perform queries or analysis based on specific date 
components rather than working directly with the full timestamp. 
*/
--------------------------------------------------------------------------------
