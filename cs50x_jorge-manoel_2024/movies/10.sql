SELECT DISTINCT name
FROM people
INNER JOIN directors ON people.id = directors.person_id
LEFT JOIN movies ON directors.movie_id = movies.id
INNER JOIN ratings ON movies.id = ratings.movie_id
WHERE rating >= 9;
