-- ============= DATABASE ===============
-- link https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows
-- Create database
CREATE DATABASE	movies_db;

-- Use database
USE movies_db;
-- ======================================

-- ========= CREATE TABLE ===============
-- Drop table if table already created
DROP TABLE IF EXISTS movies_data_table;

-- Create new movies data table with specified columns
CREATE TABLE movies_data_table (
	movie_poster VARCHAR(200),
    title VARCHAR(100),
    year_released VARCHAR(100),
    movie_certificate VARCHAR(10),
    movie_runtime VARCHAR(10),
    movie_genre VARCHAR(100),
    imdb_rating VARCHAR(5),
    movie_desc VARCHAR(500),
    meta_score VARCHAR(10),
    movie_director VARCHAR(100),
    first_star_actor VARCHAR(100),
    second_star_actor VARCHAR(100),
    third_star_actor VARCHAR(100),
    fourth_star_actor VARCHAR(100),
    votes_count INTEGER,
    gross_income VARCHAR(100)
);

-- Load data from csv file to newly created data table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/imdb_top_1000.csv'
INTO TABLE movies_data_table
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ======================================


-- ========= REPAIR TABLE DATA ===========
-- add ID column to the table so we can use it as condition in WHERE later
ALTER TABLE movies_data_table ADD COLUMN id INTEGER PRIMARY KEY AUTO_INCREMENT;

-- Convert gross_income from VARCHAR to INTEGER
-- update NOT NULL values
UPDATE movies_data_table
SET gross_income = REPLACE(gross_income, ',', '') -- Replace comma values with blank, so we can have pure numbers
WHERE id > 0 AND gross_income IS NOT NULL; -- for all IDs and NOT NUll values
-- Update NULL values
UPDATE movies_data_table
SET gross_income = NULLIF(gross_income, 0) WHERE id > 0; -- SET to return NULL values for empty income values
-- when all income values are modified
-- Alter table and MODIFY COLUMN gross income to INTEGER field type
ALTER TABLE movies_data_table MODIFY COLUMN gross_income INTEGER;

-- ======================================


-- ====== PRACTICE MOVIE QUESTIONS ======
-- 1. What is the number of movies released in 2016 ?
SELECT COUNT(*)
FROM movies_data_table
WHERE year_released = 2016;

-- 2. Show the number of movies released per year in descending order?
SELECT year_released, COUNT(*)
FROM movies_data_table
GROUP BY year_released
HAVING year_released REGEXP '^[0-9]*$' -- need REGEXP to include only numerical values due to mistake in master table data
ORDER BY year_released DESC;


-- 3. Show the cast of movie Avangers:Infinity War
-- Solution 1) By selecting required column
SELECT first_star_actor, second_star_actor, third_star_actor, fourth_star_actor
FROM movies_data_table
WHERE title = 'Avengers: Infinity War';
-- Solution 2) By creating 2 columns (actor_role and actor_name)
-- and then Unify queris in order to get all actors listed in the same column
SELECT 'Star Actor #1' AS actor_role, first_star_actor AS actor_name
FROM movies_data_table
WHERE title = 'Avengers: Infinity War'
UNION ALL
SELECT 'Star Actor #2' AS actor_role, second_star_actor AS actor_name
FROM movies_data_table
WHERE title = 'Avengers: Infinity War'
UNION ALL
SELECT 'Star Actor #3' AS actor_role, third_star_actor AS actor_name
FROM movies_data_table
WHERE title = 'Avengers: Infinity War'
UNION ALL
SELECT 'Star Actor #4' AS actor_role, fourth_star_actor AS actor_name
FROM movies_data_table
WHERE title = 'Avengers: Infinity War';

-- 4. List all the movies and publishing year that were directed by the same director who directed Interstellar movie
-- Solution 1) using Subquery
SELECT title, year_released
FROM movies_data_table
WHERE movie_director = 
	(SELECT movie_director
    FROM movies_data_table
    WHERE title = 'Interstellar'
	);
-- Solution 2) using INNER JOIN as it is more effective than using subqueries
SELECT title, year_released
FROM movies_data_table
INNER JOIN (
    SELECT movie_director
    FROM movies_data_table
    WHERE title = 'Interstellar'
) AS interstellar_director
ON movies_data_table.movie_director = interstellar_director.movie_director;

-- 5. List all the movies and gross_income with income 10x greater than average movie gross income
-- Solution 1) Using Subquery
SELECT title, gross_income
FROM movies_data_table
WHERE gross_income > 10 * (
		SELECT AVG(gross_income)
		FROM movies_data_table)
ORDER BY gross_income DESC;
        
-- Solution 2) Using JOIN
SELECT title, gross_income
FROM movies_data_table
JOIN (SELECT AVG(gross_income) as avg_gross_income
	FROM movies_data_table) avg_table
WHERE gross_income > 10 * avg_table.avg_gross_income
ORDER BY gross_income DESC;

-- 6. What are TOP 5 rated Drama genre movies with more than 1.000.000 reviews?
SELECT title, imdb_rating, votes_count
FROM movies_data_table
WHERE movie_genre LIKE '%Drama%' AND votes_count > 1000000
ORDER BY imdb_rating DESC
LIMIT 5;

-- 7. List all actors that played in action movies
SELECT DISTINCT actor_name
FROM (
	SELECT first_star_actor AS actor_name
	FROM movies_data_table
	WHERE movie_genre LIKE '%Action%'
	UNION ALL
	SELECT second_star_actor AS actor_name
	FROM movies_data_table
	WHERE movie_genre LIKE '%Action%'
	UNION ALL
	SELECT third_star_actor AS actor_name
	FROM movies_data_table
	WHERE movie_genre LIKE '%Action%'
	UNION ALL
	SELECT fourth_star_actor AS actor_name
	FROM movies_data_table
	WHERE movie_genre LIKE '%Action%') AS action_actors_list;

-- 8. Rank actors by the times they had leading role in a movie
-- With GROUP BY
SELECT first_star_actor, COUNT(*) as "star_roles_number"
FROM movies_data_table
GROUP BY first_star_actor
ORDER BY star_roles_number DESC;
-- With WINDOW FUNCTIONS
SELECT DISTINCT first_star_actor, COUNT(*) OVER(PARTITION BY first_star_actor) AS roles_count
FROM movies_data_table
ORDER BY roles_count DESC;

-- ======================================

SELECT * FROM movies_data_table;