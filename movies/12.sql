SELECT title FROM people INNER JOIN stars ON people.id = stars.person_id INNER JOIN movies ON stars.movie_id = movies.id WHERE name = 'Bradley Cooper'
INTERSECT
SELECT title FROM people INNER JOIN stars ON people.id = stars.person_id INNER JOIN movies ON stars.movie_id = movies.id WHERE name = 'Jennifer Lawrence';
