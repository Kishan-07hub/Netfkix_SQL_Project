Overview
This project uses SQL to comprehensively analyze Netflix's movies and TV shows data. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

Objectives
Analyze the distribution of content types (movies vs TV shows).
Identify the most common ratings for movies and TV shows.
List and analyze content based on release years, countries, and durations.
Explore and categorize content based on specific criteria and keywords.

Schema
DROP TABLE IF EXISTS Netflix;
CREATE TABLE Netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
Business Problems and Solutions
--1. Count the number of Movies vs TV Shows
SELECT 
	type,
	COUNT(*) as Total_Content
FROM Netflix
GROUP BY 1

--2. Find the most common rating for movies and TV shows

SELECT 
        type,
        rating
    FROM
(
    SELECT 
        type,
        rating,
        Count(*),
        RANK() OVER (PARTITION BY type ORDER BY Count(*) DESC) AS Rank
    FROM Netflix
	group by 1,2
) as t1 
WHERE Rank = 1;

--3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM NETFLIX
WHERE 
	TYPE= 'Movie'
	and
	release_year= 2020

--4. Find the top 5 countries with the most content on Netflix

select
	UNNEST(string_to_array (country, ',')) as New_Country,
	count(show_id) as Total_content
	from netflix
group by 1
ORDER BY 2 DESC
LIMIT 5

5. Identify the longest movie

SELECT * FROM NETFLIX
WHERE 
	TYPE = 'Movie'
	and
	duration = (select max(duration) from netflix)

--6. Find content added in the last 5 years

select * 
from netflix
where
	To_date(date_added, 'Month dd, yyyy') >= current_date - interval '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix
	where director Ilike '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons

SELECT 
	*
FROM netflix
WHERE 
	type = 'TV Show'
	and
	SPLIT_PART(duration, ' ', 1)::numeric > 5

--9. Count the number of content items in each genre

select 
	unnest(string_to_array(listed_in, ',')) as genre,
	count(show_id) as total_content
from netflix
group by 1

--10.Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!

select 
	extract(year from to_date(date_added, 'month dd, yyyy')) as year,
	count(*),
	count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric * 100 as avg_content_per
from netflix
where country ='India'
GROUP BY 1

--11. List all movies that are documentaries

SELECT * FROM NETFLIX
WHERE 
	LISTED_IN ILIKE '%DOCUMENTARIES%'

--12. Find all content without a director

SELECT * FROM NETFLIX
WHERE 
	DIRECTOR IS NULL 

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM NETFLIX
WHERE 
	Casts ILIKE '%Salman Khan%'
	and
	release_year > extract (year from current_date) - 10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select
	unnest (string_to_array(casts, ',')) as actors,
	count (*) as total_content
from netflix
where country ILIKE '%INDIA'
group by 1
order by 2 desc
LIMIT 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

with new_table
as
(
SELECT 
*, 
	CASE 
	WHEN DESCRIPTION ILIKE '%KILL%' OR
	DESCRIPTION ILIKE '%VIOLENCE%' THEN 'Bad_Content'
	Else 'Good Content'
	end category
FROM NETFLIX
)
select 
	category,
	count(*) as total_content 
from new_table
group by 1
