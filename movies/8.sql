SELECT name FROM movies LEFT JOIN stars ON movies.id = stars.movie_id LEFT JOIN people ON stars.person_id = people.id WHERE title LIKE 'Toy Story';
