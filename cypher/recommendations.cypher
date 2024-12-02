MATCH (g:Game {game_name: "Galactic Hitman"})-[:BELONGS_TO]->(genre:Genre)
WITH g, collect(DISTINCT genre) AS game_genres

MATCH (other_game:Game)-[:BELONGS_TO]->(genre:Genre)
WHERE genre IN game_genres AND other_game <> g

WITH other_game, count(DISTINCT genre) AS matching_genres
RETURN other_game.game_id AS RecommendedGameID, 
       other_game.game_name AS RecommendedGameName, 
       matching_genres AS MatchingGenres
ORDER BY matching_genres DESC
LIMIT 5;
