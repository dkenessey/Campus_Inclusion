--Creating table for data
CREATE TABLE inclusion_table 
    (campus_name VARCHAR(255),
	campus_location VARCHAR(150),
    rating FLOAT,
	students INTEGER,
    community_type VARCHAR(200),
    community_size INTEGER);



--View data
SELECT * FROM inclusion_table;



--Remove duplicate rows
WITH RankedRows AS 
    (SELECT ctid, ROW_NUMBER() OVER 
        (PARTITION BY campus_name
        ORDER BY campus_name) AS rn
    FROM inclusion_table)

DELETE FROM inclusion_table
USING RankedRows
WHERE inclusion_table.ctid = RankedRows.ctid
AND RankedRows.rn > 1;



--Checking for missing values
SELECT 
    COUNT(CASE WHEN campus_name IS NULL THEN 1 END) AS null_campus_name,
    COUNT(CASE WHEN campus_location IS NULL THEN 1 END) AS null_campus_location,
    COUNT(CASE WHEN rating IS NULL THEN 1 END) AS null_rating,
	COUNT(CASE WHEN students IS NULL THEN 1 END) AS null_students,
	COUNT(CASE WHEN community_type IS NULL THEN 1 END) AS null_community_type,
	COUNT(CASE WHEN community_size IS NULL THEN 1 END) AS null_community_size
FROM inclusion_table;



--Splitting campus_location into two columns
ALTER TABLE inclusion_table
ADD COLUMN city VARCHAR(255),
ADD COLUMN state VARCHAR(10);

UPDATE inclusion_table
SET city = SPLIT_PART(campus_location, ',', 1),
    state = TRIM(SPLIT_PART(campus_location, ',', 2));



--Filling missing values in rating column with median state rating
WITH MedianRatings AS
    (SELECT
        state,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rating) AS median_rating
    FROM inclusion_table
    WHERE rating IS NOT NULL
    GROUP BY state)
SELECT * FROM MedianRatings;

UPDATE inclusion_table it
SET rating = COALESCE(it.rating, mr.median_rating)
FROM (SELECT
        state,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rating) AS median_rating
    FROM inclusion_table
    WHERE rating IS NOT NULL
    GROUP BY state) AS mr
WHERE it.state = mr.state
AND it.rating IS NULL;

SELECT * FROM inclusion_table;



--Dropping campus_location column
ALTER TABLE inclusion_table
DROP COLUMN campus_location;

SELECT * FROM inclusion_table;



--Filling missing values in community_type based on community_size
UPDATE inclusion_table
SET community_type = CASE
		WHEN community_size < 5000 THEN 'rural community'
		WHEN community_size BETWEEN 5000 AND 10000 THEN 'very small town'
		WHEN community_size BETWEEN 10000 AND 25000 THEN 'small town'
		WHEN community_size BETWEEN 25000 AND 100000 THEN 'small city'
		WHEN community_size BETWEEN 100000 AND 500000 THEN 'medium city'
		WHEN community_size > 500000 THEN 'large urban city'
END
WHERE community_type IS NULL;

SELECT * FROM inclusion_table;



--Filling missing values in community_size based on location
WITH FilledValues AS 
    (SELECT *,
           FIRST_VALUE(community_size) OVER (PARTITION BY city ORDER BY community_size ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS filled_community_size
    FROM inclusion_table)
UPDATE inclusion_table it
SET community_size = fv.filled_community_size
FROM FilledValues fv
WHERE it.city = fv.city
  AND it.community_size IS NULL
  AND fv.community_size IS NOT NULL;



--Creating consistent capitalization
UPDATE inclusion_table
SET campus_name = INITCAP(LOWER(campus_name));

UPDATE inclusion_table
SET city = INITCAP(LOWER(city));

SELECT * FROM inclusion_table;



--Calculating mean and median ratings by state
SELECT 
    state,
    ROUND(AVG(rating::numeric),2) AS mean_rating,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY rating) AS median_rating,
    COUNT(*) AS campus_count
FROM inclusion_table
GROUP BY state;



--Calculating mean and median ratings by community type
SELECT 
    community_type,
    ROUND(AVG(rating)::numeric, 2) AS mean_rating, 
    percentile_cont(0.5) WITHIN GROUP (ORDER BY rating) AS median_rating, 
    COUNT(*) AS campus_count
FROM inclusion_table
GROUP BY community_type; 



--Campuses with lowest inclusivity ratings
SELECT MIN(rating) FROM inclusion_table;

SELECT * FROM inclusion_table
WHERE rating = 1.5
ORDER BY campus_name;



--Campuses with highest inclusivity ratings
SELECT MAX(rating) FROM inclusion_table;

SELECT * FROM inclusion_table
WHERE rating = 5
ORDER BY campus_name;



--Campus ratings by student population
SELECT MIN(students) FROM inclusion_table;
SELECT MAX(students) FROM inclusion_table;

SELECT 
	CASE
		WHEN students <1000 THEN 'Very Small'
		WHEN students BETWEEN 1000 AND 10000 THEN 'Small'
		WHEN students BETWEEN 10000 AND 20000 THEN 'Medium'
		WHEN students BETWEEN 20000 AND 35000 THEN 'Large'
		WHEN students BETWEEN 35000 AND 50000 THEN 'Very Large'
	END AS student_body_size,
	COUNT(*) AS campus_count,
    ROUND(AVG(rating)::numeric, 2) AS average_rating,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY rating) AS median_rating
FROM inclusion_table
GROUP BY student_body_size
ORDER BY student_body_size;

SELECT * FROM student_pop_ratings;



--Adding a new column to dataset containing student body size categories
ALTER TABLE inclusion_table
ADD COLUMN student_population_category VARCHAR(255);

UPDATE inclusion_table
SET student_population_category = CASE 
    WHEN students <1000 THEN 'Very Small'
	WHEN students BETWEEN 1000 AND 10000 THEN 'Small'
	WHEN students BETWEEN 10000 AND 20000 THEN 'Medium'
	WHEN students BETWEEN 20000 AND 35000 THEN 'Large'
	WHEN students BETWEEN 35000 AND 50000 THEN 'Very Large'
END;



--Viewing final dataset
SELECT * FROM inclusion_table
ORDER BY campus_name