USE inclusion;
  
  
  
#View data
SELECT *
FROM inclusion_table;



#Remove duplicate rows
SELECT
	campus_name,
    COUNT(*)
FROM inclusion_table
GROUP BY campus_name
HAVING COUNT(*) > 1;

ALTER TABLE inclusion_table 
ADD COLUMN temp_id 
INT AUTO_INCREMENT PRIMARY KEY;

DELETE t1 FROM inclusion_table t1
INNER JOIN inclusion_table t2 
ON t1.campus_name = t2.campus_name 
AND t1.temp_id > t2.temp_id;
    
ALTER TABLE inclusion_table DROP COLUMN temp_id;



#Checking for missing values
SELECT 
    COUNT(CASE WHEN campus_name = '' THEN 1 END) AS null_campus_name,
    COUNT(CASE WHEN campus_location = '' THEN 1 END) AS null_campus_location,
    COUNT(CASE WHEN rating = '' THEN 1 END) AS null_rating,
	COUNT(CASE WHEN students = '' THEN 1 END) AS null_students,
	COUNT(CASE WHEN community_type = '' THEN 1 END) AS null_community_type,
	COUNT(CASE WHEN community_size = '' THEN 1 END) AS null_community_size
FROM inclusion_table;



#Splitting campus_location into two columns
ALTER TABLE inclusion_table
ADD COLUMN city VARCHAR(255),
ADD COLUMN state VARCHAR(10);

UPDATE inclusion_table
SET city = SUBSTRING_INDEX(campus_location, ',', 1),
    state = TRIM(SUBSTRING_INDEX(campus_location, ',', -1));



#Filling missing values in rating column with average state rating
UPDATE inclusion_table
JOIN 
    (SELECT 
        state,
        AVG(rating) AS avg_rating
    FROM inclusion_table
    WHERE rating IS NOT NULL
    GROUP BY state) AS avg_ratings
ON inclusion_table.state = avg_ratings.state
SET inclusion_table.rating = avg_ratings.avg_rating
WHERE inclusion_table.rating = '';

SELECT * FROM inclusion_table;



#Dropping campus_location column
ALTER TABLE inclusion_table
DROP COLUMN campus_location;

SELECT * FROM inclusion_table;



#Filling missing values in community_type based on community_size
UPDATE inclusion_table
SET community_type = CASE
		WHEN community_size < 5000 THEN 'rural community'
		WHEN community_size BETWEEN 5000 AND 10000 THEN 'very small town'
		WHEN community_size BETWEEN 10000 AND 25000 THEN 'small town'
		WHEN community_size BETWEEN 25000 AND 100000 THEN 'small city'
		WHEN community_size BETWEEN 100000 AND 500000 THEN 'medium city'
		WHEN community_size > 500000 THEN 'large urban city'
END
WHERE community_type = '';

SELECT * FROM inclusion_table;



#Creating consistent capitalization
SELECT campus_name
FROM inclusion_table
WHERE BINARY campus_name = UPPER(campus_name);

UPDATE inclusion_table
SET campus_name = 'University of Miami'
WHERE campus_name = 'UNIVERSITY OF MIAMI';

UPDATE inclusion_table
SET campus_name = 'Washington State University'
WHERE campus_name = 'WASHINGTON STATE UNIVERSITY';

UPDATE inclusion_table
SET campus_name = 'University of North Dakota'
WHERE campus_name = 'UNIVERSITY OF NORTH DAKOTA';

UPDATE inclusion_table
SET campus_name = 'SUNY Rockland Community College'
WHERE campus_name = 'SUNY ROCKLAND COMMUNITY COLLEGE';

UPDATE inclusion_table
SET campus_name = 'Norco College'
WHERE campus_name = 'NORCO COLLEGE';

UPDATE inclusion_table
SET campus_name = 'Bates College'
WHERE campus_name = 'BATES COLLEGE';

UPDATE inclusion_table
SET campus_name = 'Woodbury University'
WHERE campus_name = 'WOODBURY UNIVERSITY';

SELECT campus_name
FROM inclusion_table
WHERE BINARY campus_name = LOWER(campus_name);

SELECT city
FROM inclusion_table
WHERE BINARY city = UPPER(city);

UPDATE inclusion_table
SET city = 'Coral Gables'
WHERE city = 'CORAL GABLES';

UPDATE inclusion_table
SET city = 'Grand Forks'
WHERE city = 'GRAND FORKS';

UPDATE inclusion_table
SET city = 'Dallas'
WHERE city = 'DALLAS';

UPDATE inclusion_table
SET city = 'Suffern'
WHERE city = 'SUFFERN';

UPDATE inclusion_table
SET city = 'Virginia Beach'
WHERE city = 'VIRGINIA BEACH';

UPDATE inclusion_table
SET city = 'Fitchburg'
WHERE city = 'FITCHBURG'; 

UPDATE inclusion_table
SET city = 'Norco'
WHERE city = 'NORCO';

UPDATE inclusion_table
SET city = 'Los Angeles'
WHERE city = 'LOS ANGELES';

UPDATE inclusion_table
SET city = 'Pullman'
WHERE city = 'PULLMAN';

SELECT city
FROM inclusion_table
WHERE BINARY city = LOWER(city);

UPDATE inclusion_table
SET city = 'Youngstown'
WHERE city = 'youngstown';

SELECT state
FROM inclusion_table
WHERE BINARY state = LOWER(state);

SELECT * FROM inclusion_table;



#Transforming variables
UPDATE inclusion_table
SET rating = CAST(rating AS DECIMAL(5,2)),
    students = CAST(students AS UNSIGNED),
    community_size = CAST(community_size AS UNSIGNED);



#Calculating mean by state
SELECT 
    state,
    ROUND(AVG(rating),2) AS mean_rating,
    COUNT(*) AS campus_count
FROM inclusion_table
GROUP BY state
ORDER BY state;



#Calculating mean ratings by community type
SELECT 
    community_type,
    ROUND(AVG(rating), 2) AS mean_rating, 
    COUNT(*) AS campus_count
FROM inclusion_table
GROUP BY community_type
ORDER BY community_type; 



#Campuses with lowest inclusivity ratings
SELECT MIN(rating) FROM inclusion_table;

SELECT * 
FROM inclusion_table
WHERE rating = 1.5
ORDER BY campus_name;



#Campuses with highest inclusivity ratings
SELECT MAX(rating) 
FROM inclusion_table;

SELECT * 
FROM inclusion_table
WHERE rating = 5
ORDER BY campus_name;



#Campus ratings by student population
SELECT 
	MIN(CAST(students AS UNSIGNED)) AS min_students,
    MAX(CAST(students AS UNSIGNED)) AS max_students
FROM inclusion_table;

ALTER TABLE inclusion_table
ADD COLUMN student_body_size VARCHAR(20);

UPDATE inclusion_table
SET student_body_size = CASE
    WHEN students < 1000 THEN 'Very Small'
    WHEN students BETWEEN 1000 AND 10000 THEN 'Small'
    WHEN students BETWEEN 10000 AND 20000 THEN 'Medium'
    WHEN students BETWEEN 20000 AND 35000 THEN 'Large'
    WHEN students BETWEEN 35000 AND 50000 THEN 'Very Large'
END;

SELECT 
    student_body_size,
    COUNT(*) AS campus_count,
    ROUND(AVG(rating), 2) AS average_rating
FROM inclusion_table
GROUP BY student_body_size
ORDER BY student_body_size;



#Viewing final dataset
SELECT * FROM inclusion_table
ORDER BY campus_name