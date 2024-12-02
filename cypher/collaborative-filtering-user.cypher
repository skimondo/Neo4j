// COSINE SIMILARITY IMPLEMENTATION, RECOMMENDS SIMILAR USERS BASED ON PLAYTIME
MATCH (u1:User {user_id: "firefreddy"})-[p1:PLAYS]->(g:Game)<-[p2:PLAYS]-(u2:User)
WHERE p1.playtime_forever > 0 AND p2.playtime_forever > 0
WITH COUNT(g) AS numberOfGames, 
     SUM(p1.playtime_forever * p2.playtime_forever) AS dotProduct,
     SQRT(REDUCE(x = 0.0, a IN COLLECT(p1.playtime_forever) | x + a^2)) AS xLength,
     SQRT(REDUCE(y = 0.0, b IN COLLECT(p2.playtime_forever) | y + b^2)) AS yLength,
     u1, u2
WHERE numberOfGames > 1 AND xLength > 0 AND yLength > 0
RETURN u1.user_id AS Username,
       u2.user_id AS SimilarUsername,
       dotProduct / (xLength * yLength) AS cosineSimilarity
ORDER BY cosineSimilarity DESC
LIMIT 10;
