-- Netflix Content Analysis using SQL
-- Solutions of 30 Business Problems

-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type;

--2. Find the most common rating for movies and TV shows

SELECT 
	type,
	rating
FROM

(
   SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1, 2
)as t1
WHERE
	ranking=1

--3. List all the movies releases in a specific year (e.g., 2020)

SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT (show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. Identify the longest movie?

SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)

-- 6. Find the content added in last 6 years

SELECT 
	* 
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '6 years'
	
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT 
	* 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 sessions

SELECT 
	* 
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1) :: numeric > 5 

-- 9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

-- 10. Find each year and the average numbers of content releases bu India on netflix, 
--     and return top 5 year with highest avg content release

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100
	,2) as avg_content_per_year	
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5 

-- 11. List all movies that are documentries

SELECT 
	* 
FROM netflix
WHERE 
	listed_in ILIKE '%documentaries%'\

-- 12. Find all content without director

SELECT 
	* 
FROM netflix
WHERE 
	director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years?

SELECT 
	* 
FROM netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in india

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) as total_content
FROM netflix
WHERE
	country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
-- Label content containing these keywords as 'Bad' and all other content as 'Good'.
-- Count how many items fall into each category


WITH new_table
AS
(
SELECT 
* ,
	CASE
	WHEN
	description ILIKE '%kill%'
	OR
	description ILIKE '%violence%' THEN 'Bad'
	ELSE 'Good'
END category
FROM netflix
)

SELECT
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1

-- 16. Which Year Recorded the Highest Number of Netflix Releases?

SELECT
    release_year,
    COUNT(*) AS total_content
FROM netflix
GROUP BY release_year
ORDER BY total_content DESC
LIMIT 1;

-- 17. Which Month Sees the Highest Content Addition?

SELECT
    EXTRACT(MONTH FROM TO_DATE(date_added,'Month DD, YYYY')) AS month_number,
    TO_CHAR(
        TO_DATE(date_added,'Month DD, YYYY'),
        'Month'
    ) AS month_name,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY month_number, month_name
ORDER BY total_content DESC;

-- 18. Which Day of the Week Has the Highest Content Addition?

SELECT
    EXTRACT(DOW FROM TO_DATE(date_added,'Month DD, YYYY')) AS day_number,
    TO_CHAR(
        TO_DATE(date_added,'Month DD, YYYY'),
        'Day'
    ) AS weekday,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY day_number, weekday
ORDER BY total_content DESC;

-- 19. Top 10 Directors with the Highest Number of Contents

SELECT
    director,
    COUNT(*) AS total_titles,
    COUNT(
        CASE
            WHEN type = 'Movie'
            THEN 1
        END
    ) AS total_movies,
    COUNT(
        CASE
            WHEN type = 'TV Show'
            THEN 1
        END
    ) AS total_tv_shows
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
ORDER BY total_content DESC
LIMIT 10;

-- 20. Which Countries Produce More Movies Than TV Shows?

WITH country_content AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name,
        type
    FROM netflix
    WHERE country IS NOT NULL
)
SELECT
    country_name,
    COUNT(
        CASE
            WHEN type = 'Movie'
            THEN 1
        END
    ) AS total_movies,

    COUNT(
        CASE
            WHEN type = 'TV Show'
            THEN 1
        END
    ) AS total_tv_shows,
    COUNT(*) AS total_content,
    ROUND(
        COUNT(
            CASE
                WHEN type='Movie'
                THEN 1
            END
        )::NUMERIC
        /
        COUNT(*) *100,
        2
    ) AS movie_percentage,
    ROUND(
        COUNT(
            CASE
                WHEN type='TV Show'
                THEN 1
            END
        )::NUMERIC
        /
        COUNT(*) *100,
        2
    ) AS tv_show_percentage
FROM country_content
GROUP BY country_name
HAVING COUNT(*) >= 10
ORDER BY movie_percentage DESC;

-- 21. What is the Average Movie Duration by Country?

WITH movie_country AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name,
        CAST(SPLIT_PART(duration,' ',1) AS INT) AS duration_minutes
    FROM netflix
    WHERE
        type = 'Movie'
        AND country IS NOT NULL
        AND duration IS NOT NULL
)
SELECT
    country_name,
    COUNT(*) AS total_movies,
    ROUND(AVG(duration_minutes),2) AS avg_movie_duration
FROM movie_country
GROUP BY country_name
HAVING COUNT(*) >= 10
ORDER BY avg_movie_duration DESC;

-- 22. Which Directors Have Worked Across the Highest Number of Genres?

WITH director_genre AS
(
    SELECT
        director,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
    WHERE director IS NOT NULL
)
SELECT
    director,
    COUNT(DISTINCT genre) AS distinct_genres,
    COUNT(*) AS total_genre_entries
FROM director_genre
GROUP BY director
ORDER BY distinct_genres DESC,
         total_genre_entries DESC
LIMIT 10;

-- 23. Which Actors Have Appeared in the Highest Number of Different Genres?

WITH actor_genre AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
    WHERE casts IS NOT NULL
)
SELECT
    actor,
    COUNT(DISTINCT genre) AS distinct_genres,
    COUNT(*) AS total_content
FROM actor_genre
GROUP BY actor
HAVING COUNT(*) >= 5
ORDER BY distinct_genres DESC,
         total_content DESC
LIMIT 15;

-- 24. Which Actor–Director Collaborations Produced the Most Titles?

WITH collaboration AS
(
    SELECT
        director,
        TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor
    FROM netflix
    WHERE
        director IS NOT NULL
        AND casts IS NOT NULL
)
SELECT
    director,
    actor,
    COUNT(*) AS total_content
FROM collaboration
GROUP BY director, actor
HAVING COUNT(*) >= 2
ORDER BY total_content DESC
LIMIT 20;

-- 25. Which Titles Took the Longest to Appear on Netflix After Their Release?

SELECT
    title,
    type,
    release_year,
    EXTRACT(
        YEAR
        FROM TO_DATE(date_added,'Month DD, YYYY')
    ) AS added_year,
    (
        EXTRACT(
            YEAR
            FROM TO_DATE(date_added,'Month DD, YYYY')
        ) - release_year
    ) AS years_to_netflix
FROM netflix
WHERE date_added IS NOT NULL
ORDER BY years_to_netflix DESC,
         release_year ASC
LIMIT 20;

-- 26. Rank Countries by Content Released Every Year

WITH country_year AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name,
        release_year,
        COUNT(*) AS total_content
    FROM netflix
    WHERE country IS NOT NULL
    GROUP BY 1,2
)
SELECT
    country_name,
    release_year,
    total_content,
    RANK() OVER(
        PARTITION BY release_year
        ORDER BY total_content DESC
    ) AS country_rank
FROM country_year
ORDER BY release_year DESC, country_rank;

-- 27. Find Netflix's Fastest Growing Years

WITH yearly_content AS
(
    SELECT
        EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) AS year_added,
        COUNT(*) AS total_content
    FROM netflix
    WHERE date_added IS NOT NULL
    GROUP BY 1
)
SELECT
    year_added,
    total_content,
    LAG(total_content)
    OVER(
        ORDER BY year_added
    ) AS previous_year,
    ROUND(
        (
            total_content -
            LAG(total_content)
            OVER(ORDER BY year_added)
        )::NUMERIC
        /
        NULLIF(
            LAG(total_content)
            OVER(ORDER BY year_added),
            0
        )
        *100
    ,2) AS growth_percentage
FROM yearly_content
ORDER BY year_added;

-- 28. Which Genres Are Growing the Fastest?

WITH genre_year AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,
        release_year,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1,2
)
SELECT
    genre,
    release_year,
    total_content,
    LAG(total_content)
    OVER(
        PARTITION BY genre
        ORDER BY release_year
    ) AS previous_year,
    total_content
    -
    LAG(total_content)
    OVER(
        PARTITION BY genre
        ORDER BY release_year
    ) AS yearly_growth
FROM genre_year
ORDER BY genre, release_year;

-- 29. Build a Content Diversity Score for Every Country

WITH country_genre AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country_name,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre
    FROM netflix
    WHERE country IS NOT NULL
)
SELECT
    country_name,
    COUNT(*) AS total_content,
    COUNT(DISTINCT genre) AS unique_genres,
    ROUND(
        COUNT(DISTINCT genre)::NUMERIC
        /
        COUNT(*) *100
    ,2) AS diversity_score
FROM country_genre
GROUP BY country_name
HAVING COUNT(*)>=20
ORDER BY diversity_score DESC;

-- 30. Executive Netflix Content Health Dashboard

WITH base AS
(
    SELECT *
    FROM netflix
)
SELECT
    COUNT(*) AS total_content,
    COUNT(
        CASE WHEN type='Movie' THEN 1 END
    ) AS total_movies,
    COUNT(
        CASE WHEN type='TV Show' THEN 1 END
    ) AS total_tv_shows,
    MIN(release_year) AS oldest_release,
    MAX(release_year) AS latest_release,
    ROUND(
        AVG(
            CASE
                WHEN type='Movie'
                THEN SPLIT_PART(duration,' ',1)::NUMERIC
            END
        )
    ,2) AS avg_movie_duration,
    ROUND(
        COUNT(
            CASE WHEN director IS NULL THEN 1 END
        )::NUMERIC
        /
        COUNT(*)*100
    ,2) AS missing_director_percentage,
    ROUND(
        COUNT(
            CASE WHEN country IS NULL THEN 1 END
        )::NUMERIC
        /
        COUNT(*)*100
    ,2) AS missing_country_percentage,
    (
        SELECT rating
        FROM netflix
        GROUP BY rating
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_common_rating,
    (
        SELECT listed_in
        FROM netflix
        GROUP BY listed_in
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_common_genre
FROM base;
