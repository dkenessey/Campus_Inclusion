--View data
SELECT * FROM inclusion_table;

--Remove duplicate rows
SELECT DISTINCT ON (campus_name) *
FROM inclusion_table
ORDER BY campus_name;

SELECT * FROM inclusion_table

--Checking for missing values
SELECT 
    COUNT(CASE WHEN campus_name IS NULL THEN 1 END) AS null_campus_name,
    COUNT(CASE WHEN campus_location IS NULL THEN 1 END) AS null_campus_location,
    COUNT(CASE WHEN rating IS NULL THEN 1 END) AS null_rating,
	COUNT(CASE WHEN students IS NULL THEN 1 END) AS null_students,
	COUNT(CASE WHEN community_type IS NULL THEN 1 END) AS null_community_type,
	COUNT(CASE WHEN community_size IS NULL THEN 1 END) AS null_community_size
FROM inclusion_table;

--Filling missing values in rating column with median state rating
ALTER TABLE inclusion_table
ADD COLUMN city VARCHAR(255),
ADD COLUMN state VARCHAR(10);

UPDATE inclusion_table
SET city = SPLIT_PART(campus_location, ',', 1),
    state = TRIM(SPLIT_PART(campus_location, ',', 2));

CREATE TABLE state_median_ratings AS
SELECT state, PERCENTILE_CONT(0.5) 
WITHIN GROUP (ORDER BY rating) AS median
FROM inclusion_table
GROUP BY state;

UPDATE inclusion_table
SET rating = state_median_ratings.median
FROM state_median_ratings
WHERE inclusion_table.state = state_median_ratings.state
AND inclusion_table.rating IS NULL;

SELECT * FROM inclusion_table;

--Dropping campus_location column
ALTER TABLE inclusion_table
DROP COLUMN campus_location;

SELECT * FROM inclusion_table;

--Filling missing values in community_type based on community_size
CREATE TABLE community_size_mapping AS
SELECT
    community_size,
	CASE
		WHEN community_size < 5000 THEN 'rural community'
		WHEN community_size BETWEEN 5000 AND 10000 THEN 'very small town'
		WHEN community_size BETWEEN 10000 AND 25000 THEN 'small town'
		WHEN community_size BETWEEN 25000 AND 100000 THEN 'small city'
		WHEN community_size BETWEEN 100000 AND 500000 THEN 'medium city'
		WHEN community_size > 500000 THEN 'large urban city'
	END AS community_type
FROM inclusion_table;

UPDATE inclusion_table
SET community_type = map.community_type
FROM community_size_mapping map
WHERE inclusion_table.community_size = map.community_size
AND inclusion_table.community_type IS NULL;

SELECT * FROM inclusion_table;

--Filling missing values in community_size based on location
SELECT *
FROM inclusion_table
WHERE community_size IS NULL;

UPDATE inclusion_table AS t1
SET community_size = t2.community_size
FROM inclusion_table AS t2
WHERE t1.city = t2.city
  AND t1.community_size IS NULL
  AND t2.community_size IS NOT NULL;

SELECT * FROM inclusion_table
WHERE community_size IS NULL;

--Creating consistent capitalization
UPDATE inclusion_table
SET campus_name = INITCAP(LOWER(campus_name));

UPDATE inclusion_table
SET city = INITCAP(LOWER(city));

SELECT * FROM inclusion_table;

--Median inclusion rating by state
ALTER TABLE state_median_ratings
ADD COLUMN campus_count INT;

UPDATE state_median_ratings AS median
SET campus_count = 
    (SELECT COUNT(*)
    FROM inclusion_table 
    WHERE inclusion_table.state = median.state);

SELECT * FROM state_median_ratings;

--Average inclusion rating by state
CREATE TABLE avg_state_ratings AS
SELECT state, ROUND(AVG(rating), 1) AS mean, COUNT(*) AS campus_count
FROM inclusion_table
GROUP BY state;

SELECT * FROM avg_state_ratings;

--Creating a table containing both mean and median ratings by state
SELECT mean.state, mean, median, mean.campus_count FROM state_median_ratings AS median
INNER JOIN avg_state_ratings AS mean
ON median.state = mean.state
ORDER BY mean.state;

--Mean campus rating by community type
CREATE TABLE community_avg_ratings AS
SELECT community_type, ROUND(AVG(rating), 1) AS mean, COUNT(*) AS campus_count
FROM inclusion_table
GROUP BY community_type;

SELECT * FROM community_avg_ratings;

--Median campus rating by community type
CREATE TABLE community_median_ratings AS
SELECT community_type, PERCENTILE_CONT(0.5)
WITHIN GROUP (ORDER BY rating) AS median
FROM inclusion_table
GROUP BY community_type;

SELECT * FROM community_median_ratings;

--Creating a table containing both mean and median ratings by community type
SELECT mean.community_type, mean, median, mean.campus_count FROM community_median_ratings AS median
INNER JOIN community_avg_ratings AS mean
ON median.community_type = mean.community_type
ORDER BY mean.community_type;

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

CREATE TABLE student_pop_ratings AS
SELECT students, rating,
	CASE
		WHEN students <1000 THEN 'Very Small'
		WHEN students BETWEEN 1000 AND 10000 THEN 'Small'
		WHEN students BETWEEN 10000 AND 20000 THEN 'Medium'
		WHEN students BETWEEN 20000 AND 35000 THEN 'Large'
		WHEN students BETWEEN 35000 AND 50000 THEN 'Very Large'
	END AS student_body_size
FROM inclusion_table;

SELECT * FROM student_pop_ratings;

--Mean campus rating by student body size
CREATE TABLE student_size_avg_ratings AS
SELECT student_body_size, ROUND(AVG(rating), 1) AS mean, COUNT(*) AS campus_count
FROM student_pop_ratings
GROUP BY student_body_size;

SELECT * FROM student_size_avg_ratings;

--Median campus rating by student body size
CREATE TABLE student_size_median_ratings AS
SELECT student_body_size, PERCENTILE_CONT(0.5)
WITHIN GROUP (ORDER BY rating) AS median
FROM student_pop_ratings
GROUP BY student_body_size;

SELECT * FROM student_size_median_ratings;

--Creating a table containing both mean and median ratings by student body size
SELECT mean.student_body_size, mean, median, mean.campus_count FROM student_size_median_ratings AS median
INNER JOIN student_size_avg_ratings AS mean
ON median.student_body_size = mean.student_body_size
ORDER BY mean.student_body_size;