#  Netflix Content Analysis using SQL

![](04_netflix_logo.png)

---

# Overview

This project presents an end-to-end SQL analysis of the Netflix Movies and TV Shows dataset. The objective is to explore the dataset, perform exploratory data analysis (EDA), and answer real-world business questions using PostgreSQL.

The project demonstrates practical SQL skills including data exploration, aggregation, filtering, window functions, Common Table Expressions (CTEs), string manipulation, date functions, ranking, and business-oriented analytics.

---

# Objectives

- Understand the overall structure of the Netflix content library.
- Perform Exploratory Data Analysis (EDA) to identify trends and data quality issues.
- Analyze movies and TV shows across countries, genres, ratings, directors, and actors.
- Generate business insights using advanced SQL techniques.
- Build an executive-level content health report.

---

#  Dataset

**Dataset Name:** Netflix Movies and TV Shows

**Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

Dataset contains information about Netflix titles, including:

- Movies and TV Shows
- Directors
- Cast
- Country
- Release Year
- Rating
- Duration
- Genre
- Date Added
- Description

---

# Schema

```sql
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
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
```
## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
	type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT (show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 6 Years

```sql
SELECT 
	* 
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '6 years'
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT 
	* 
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT 
	* 
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1) :: numeric > 5 

```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT 
	* 
FROM netflix
WHERE 
	listed_in ILIKE '%documentaries%'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT 
	* 
FROM netflix
WHERE 
	director IS NULL

```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT 
	* 
FROM netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) as total_content
FROM netflix
WHERE
	country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

### 16. Identify the Year with the Highest Number of Netflix Releases

```sql
SELECT
    release_year,
    COUNT(*) AS total_content
FROM netflix
GROUP BY release_year
ORDER BY total_content DESC
LIMIT 1;
```

**Objective:** Identify the year with the highest number of content releases on Netflix.

---

### 17. Determine the Month with the Highest Content Additions

```sql
SELECT
    TO_CHAR(TO_DATE(date_added, 'Month DD, YYYY'), 'Month') AS month_name,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY month_name
ORDER BY total_content DESC;
```

**Objective:** Identify the month in which Netflix added the highest number of titles.

---

### 18. Identify the Weekday with the Highest Content Additions

```sql
SELECT
    TO_CHAR(TO_DATE(date_added, 'Month DD, YYYY'), 'Day') AS weekday,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY weekday
ORDER BY total_content DESC;
```

**Objective:** Determine the weekday on which Netflix adds the most content.

---

### 19. Find the Top Directors with the Highest Number of Movies and TV Shows

```sql
WITH director_titles AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director_name,
        type
    FROM netflix
    WHERE director IS NOT NULL
)

SELECT
    director_name,
    COUNT(*) AS total_titles,
    COUNT(CASE WHEN type = 'Movie' THEN 1 END) AS total_movies,
    COUNT(CASE WHEN type = 'TV Show' THEN 1 END) AS total_tv_shows
FROM director_titles
GROUP BY director_name
ORDER BY total_titles DESC
LIMIT 10;
```

**Objective:** Identify the directors with the highest number of movies and TV shows available on Netflix.

---

### 20. Compare Movie vs TV Show Production Percentage by Country

```sql
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
    ROUND(
        COUNT(CASE WHEN type = 'Movie' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS movie_percentage,
    ROUND(
        COUNT(CASE WHEN type = 'TV Show' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS tv_show_percentage
FROM country_content
GROUP BY country_name
ORDER BY country_name;
```

**Objective:** Compare the percentage distribution of movies and TV shows produced by each country.

### 21. Calculate the Average Movie Duration by Country

```sql
WITH country_movies AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name,
        SPLIT_PART(duration, ' ', 1)::INT AS movie_duration
    FROM netflix
    WHERE type = 'Movie'
      AND country IS NOT NULL
)

SELECT
    country_name,
    ROUND(AVG(movie_duration), 2) AS avg_duration_minutes
FROM country_movies
GROUP BY country_name
ORDER BY avg_duration_minutes DESC;
```

**Objective:** Calculate the average duration of movies for each country to compare production characteristics.

---

### 22. Identify Directors with the Highest Genre Diversity

```sql
WITH director_genres AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director_name,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
    WHERE director IS NOT NULL
)

SELECT
    director_name,
    COUNT(DISTINCT genre) AS total_genres
FROM director_genres
GROUP BY director_name
ORDER BY total_genres DESC
LIMIT 10;
```

**Objective:** Identify directors who have worked across the greatest variety of genres on Netflix.

---

### 23. Find Actors with the Most Diverse Genre Portfolios

```sql
WITH actor_genres AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor_name,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
    WHERE casts IS NOT NULL
)

SELECT
    actor_name,
    COUNT(DISTINCT genre) AS total_genres
FROM actor_genres
GROUP BY actor_name
ORDER BY total_genres DESC
LIMIT 10;
```

**Objective:** Identify actors who have appeared across the widest variety of genres on Netflix.

---

### 24. Analyze the Most Successful Actor–Director Collaborations

```sql
WITH collaborations AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director_name,
        TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor_name
    FROM netflix
    WHERE director IS NOT NULL
      AND casts IS NOT NULL
)

SELECT
    director_name,
    actor_name,
    COUNT(*) AS total_collaborations
FROM collaborations
GROUP BY director_name, actor_name
ORDER BY total_collaborations DESC
LIMIT 10;
```

**Objective:** Identify the actor–director pairs with the highest number of collaborations on Netflix.

---

### 25. Identify Titles with the Longest Delay Between Release and Netflix Addition

```sql
SELECT
    title,
    release_year,
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS added_year,
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) - release_year AS years_to_add
FROM netflix
WHERE date_added IS NOT NULL
ORDER BY years_to_add DESC
LIMIT 10;
```

**Objective:** Calculate the time gap between a title's release year and the year it was added to Netflix to identify delayed acquisitions.

### 26. Rank Countries by Yearly Content Production

```sql
WITH country_yearly_content AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name,
        release_year,
        COUNT(*) AS total_content
    FROM netflix
    WHERE country IS NOT NULL
    GROUP BY country_name, release_year
)

SELECT
    country_name,
    release_year,
    total_content,
    RANK() OVER(PARTITION BY release_year ORDER BY total_content DESC) AS country_rank
FROM country_yearly_content
ORDER BY release_year, country_rank;
```

**Objective:** Rank countries based on the number of content titles released each year to identify the leading content producers.

---

### 27. Perform Year-over-Year (YoY) Growth Analysis of Netflix Content

```sql
WITH yearly_content AS
(
    SELECT
        release_year,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY release_year
)

SELECT
    release_year,
    total_content,
    LAG(total_content) OVER(ORDER BY release_year) AS previous_year,
    ROUND(
        ((total_content - LAG(total_content) OVER(ORDER BY release_year))::NUMERIC
        / LAG(total_content) OVER(ORDER BY release_year)) * 100,
        2
    ) AS yoy_growth_percentage
FROM yearly_content
ORDER BY release_year;
```

**Objective:** Analyze the year-over-year growth in Netflix content releases to identify growth and decline trends over time.

---

### 28. Analyze Year-over-Year (YoY) Growth of Individual Genres

```sql
WITH genre_yearly_content AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
        release_year,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY genre, release_year
)

SELECT
    genre,
    release_year,
    total_content,
    LAG(total_content) OVER(PARTITION BY genre ORDER BY release_year) AS previous_year,
    ROUND(
        ((total_content - LAG(total_content) OVER(PARTITION BY genre ORDER BY release_year))::NUMERIC
        / LAG(total_content) OVER(PARTITION BY genre ORDER BY release_year)) * 100,
        2
    ) AS yoy_growth_percentage
FROM genre_yearly_content
ORDER BY genre, release_year;
```

**Objective:** Evaluate the year-over-year growth of each genre to identify emerging and declining content categories.

---

### 29. Calculate a Content Diversity Score for Each Country

```sql
WITH country_genres AS
(
    SELECT
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_name,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
    WHERE country IS NOT NULL
)

SELECT
    country_name,
    COUNT(DISTINCT genre) AS diversity_score
FROM country_genres
GROUP BY country_name
ORDER BY diversity_score DESC;
```

**Objective:** Measure the diversity of content produced by each country based on the variety of genres available.

---

### 30. Build an Executive Content Health Dashboard

```sql
WITH base AS
(
    SELECT *
    FROM netflix
)

SELECT
    COUNT(*) AS total_titles,

    COUNT(CASE WHEN type = 'Movie' THEN 1 END) AS total_movies,

    COUNT(CASE WHEN type = 'TV Show' THEN 1 END) AS total_tv_shows,

    MIN(release_year) AS oldest_release,

    MAX(release_year) AS latest_release,

    ROUND(
        AVG(
            CASE
                WHEN type = 'Movie'
                THEN SPLIT_PART(duration, ' ', 1)::NUMERIC
            END
        ),
        2
    ) AS avg_movie_duration,

    ROUND(
        COUNT(CASE WHEN director IS NULL THEN 1 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS missing_director_percentage,

    ROUND(
        COUNT(CASE WHEN country IS NULL THEN 1 END)::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS missing_country_percentage,

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
```

**Objective:** Generate an executive summary of the Netflix content catalog by reporting key metrics such as content distribution, metadata quality, ratings, genres, and average movie duration to assess the overall health of the dataset.

---

# Tools Used

- PostgreSQL
- SQL
- Git & GitHub

---

# Project Structure

```
Netflix-Content-Analysis
│
├── Dataset
│   └──00_netflix_titles.csv
│
├── SQL Scripts
│   ├── 01_Business_Problems.sql
│   ├── 02_Database_Schema.sql
│   └── 03_Business_Analytics.sql
│
├── Images
│   └── 04_netflix_logo.png
│
└── README.md
```

---

# SQL Concepts Used

This project demonstrates practical use of:

- SELECT
- WHERE
- GROUP BY
- ORDER BY
- HAVING
- Aggregate Functions
- CASE WHEN
- Common Table Expressions (CTEs)
- Window Functions
- RANK()
- LAG()
- STRING_TO_ARRAY()
- UNNEST()
- SPLIT_PART()
- TO_DATE()
- EXTRACT()
- Subqueries
- Conditional Aggregation

---

## Key Insights

- Movies constitute the majority of Netflix's content catalog compared to TV Shows.
- A small number of countries contribute the largest share of Netflix's content library.
- Content production has experienced significant growth over the years.
- Netflix follows consistent monthly and weekly content addition patterns.
- Certain directors and actors have made a substantial contribution to the platform's content.
- Genre popularity varies over time, reflecting changing audience preferences.
- Some countries offer a more diverse range of genres than others.
- Several titles were added to Netflix years after their original release, indicating long-term licensing strategies.
- Missing metadata in fields such as **Director** and **Country** highlights opportunities to improve data quality.
- The Executive Content Health Dashboard provides a consolidated overview of key catalog performance metrics.

---

## Business Recommendations

- Increase investment in countries with consistently high content production and audience reach.
- Optimize content release schedules based on historical monthly and weekday trends.
- Expand production in emerging and underrepresented genres to diversify the content portfolio.
- Strengthen partnerships with high-performing directors and actors to improve audience engagement.
- Improve metadata quality by minimizing missing values in critical fields.
- Reduce delays between content release and Netflix availability through better licensing strategies.
- Monitor Year-over-Year content growth to support long-term content planning.
- Track genre performance regularly to align future investments with audience demand.
- Enhance regional content diversity to better serve global audiences.
- Utilize the Executive Content Health Dashboard to support strategic and data-driven business decisions.

---

## Challenges Faced

- Handling multi-valued columns such as **Country**, **Director**, **Cast**, and **Genre** using `STRING_TO_ARRAY()` and `UNNEST()`.
- Converting text-based date fields into proper date format for time-based analysis.
- Managing missing values in important columns like **Director**, **Country**, and **Date Added**.
- Extracting numeric values from the **Duration** column to perform calculations and comparisons.
- Eliminating duplicate records while working with multi-valued attributes.
- Applying advanced SQL concepts such as **CTEs**, **Window Functions**, **RANK()**, and **LAG()** to solve complex business problems.
- Writing optimized and well-structured SQL queries for efficient data analysis.
- Organizing the project into a clear workflow to improve readability and maintainability.

## Conclusion

This project demonstrates how SQL can be used to explore, analyze, and extract meaningful insights from real-world data. From understanding the dataset through Exploratory Data Analysis (EDA) to solving business-oriented problems with advanced SQL techniques, the project reflects a structured data analysis workflow. It also highlights the importance of SQL in supporting data-driven decision-making and generating actionable business insights.

---

## About Me

**Mohd Affan**

**Email:** mohdaffan020@gmail.com
