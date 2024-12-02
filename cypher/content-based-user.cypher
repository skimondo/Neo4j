// NAIVE IMPLEMENTATION, RECOMMENDS GAMES TO A USER BASED ON GENRE
MATCH (u:User {user_id: "firefreddy"})-[:PLAYS]->(g:Game)-[:BELONGS_TO]->(genre:Genre)
WITH u, collect(DISTINCT genre) AS user_genres

MATCH (other_game:Game)-[:BELONGS_TO]->(genre:Genre)
WHERE genre IN user_genres
  AND NOT (u)-[:PLAYS]->(other_game)

WITH other_game, count(DISTINCT genre) AS genre_match_count
RETURN other_game.game_name AS RecommendedGameName, 
       genre_match_count AS MatchingGenres
ORDER BY genre_match_count DESC
LIMIT 10;

