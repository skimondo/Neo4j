// JACKARD INDEX, RECOMMENDATION GAMES SIMILAR TO A GAME BASED ON GENRE
MATCH (game:Game {game_name: "Galactic Hitman"})-[:BELONGS_TO]->(genre:Genre)<-[:BELONGS_TO]-(other_game:Game)
WITH game, other_game, COUNT(genre) AS intersection, COLLECT(genre.genre_name) AS i

MATCH (game)-[:BELONGS_TO]->(mg:Genre)
WITH game, other_game, intersection, i, COLLECT(mg.genre_name) AS s1

MATCH (other_game)-[:BELONGS_TO]->(og:Genre)
WITH game, other_game, intersection, i, s1, COLLECT(og.genre_name) AS s2

WITH game, other_game, intersection, s1+[x IN s2 WHERE NOT x IN s1] AS union, s1, s2
RETURN other_game.game_name AS RecommendedGameName, 
       ROUND(toFloat(intersection) / toFloat(SIZE(union)) * 1000) / 1000 AS JaccardIndex
ORDER BY JaccardIndex DESC
LIMIT 20;