select * from titles;

--BUSINESS PROBLEMS 

--1. Count the number of Movies vs TV Shows

	 SELECT TYPE, COUNT(*) AS TOTAL_CONTENT FROM TITLES
	 GROUP BY TYPE;

	 
--2. Find the most common rating for movies and TV shows

		select type, Rating from (SELECT  TYPE,
				RATING,
				COUNT(*),
				rank() over(partition by type order by count(*) desc) as ranking 
				FROM TITLES
				GROUP BY 1,2) as t1
				where ranking = 1;
				
				
	
--3. List all movies released in a specific year (e.g., 2020)

		select * from titles 
		where release_year=2020 and type = 'Movie';

	
--4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as country, 
		COUNT(*) as total_content
	FROM titles
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;


--5. Identify the longest movie

SELECT *
	FROM titles
where type = 'Movie' and 
duration= (select max(duration) from titles);

-- 5. Identify the longest movie or TV show duration

SELECT 
	*
FROM titles
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

 
--6. Find content added in the last 5 years

	SELECT * 
		FROM titles
	WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';   

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

		select * from titles
		where director ILIKE '%Rajiv Chilaka%';  

--8. List all TV shows with more than 5 seasons
		
		SELECT *
FROM titles
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5 
		
--9. Count the number of content items in each genre

		 select  UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,count(*) as total_content  
		 from titles
		 group by genre;
		 
	
--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

		SELECT 
	EXTRACT (YEAR from TO_DATE (date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
		COUNT(*)::numeric/(SELECT COUNT(show_id) FROM titles WHERE country = 'India')::numeric * 100,2)
		as avg_content_per_year
FROM titles
WHERE country = 'India' 
GROUP BY 1


--11. List all movies that are documentaries

SELECT * FROM titles
WHERE listed_in ILIKE '%Documentaries'

--12. Find all content without a director
	
	select * from titles
	WHERE director is null;
	
--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!


SELECT * FROM titles
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
	
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

	SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM titles
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10



--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM titles
) AS categorized_content
GROUP BY 1,2
ORDER BY 2