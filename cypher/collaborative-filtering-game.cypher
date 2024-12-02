MATCH (u1:User {user_id: "firefreddy"})-[p:PLAYS]->(:Game)
WITH u1, avg(p.playtime_forever) AS u1_mean_playtime

MATCH (u1)-[p1:PLAYS]->(g:Game)<-[p2:PLAYS]-(u2)
WITH u1, u1_mean_playtime, u2, COLLECT({p1: p1, p2: p2}) AS plays WHERE size(plays) > 1

MATCH (u2)-[p:PLAYS]->(g:Game)
WITH u1, u1_mean_playtime, u2, avg(p.playtime_forever) AS u2_mean_playtime, plays
UNWIND plays AS play
WITH SUM( (play.p1.playtime_forever - u1_mean_playtime) * (play.p2.playtime_forever - u2_mean_playtime) ) AS nom,
     SQRT( SUM( (play.p1.playtime_forever - u1_mean_playtime)^2 ) * SUM( (play.p2.playtime_forever - u2_mean_playtime)^2 ) ) AS denom,
     u1, u2
WHERE denom <> 0
RETURN u1.user_id AS UserID,
        u2.user_id AS SimilarUserID,
       nom / denom AS PearsonCorrelation

ORDER BY PearsonCorrelation DESC
LIMIT 20;

        
MATCH (u1:User {user_id: "firefreddy"})-[p:PLAYS]->(:Game)
WITH u1, avg(p.playtime_forever) AS u1_mean_playtime

MATCH (u1)-[p1:PLAYS]->(g:Game)<-[p2:PLAYS]-(u2)
WITH u1, u1_mean_playtime, u2, COLLECT({p1: p1, p2: p2}) AS plays WHERE size(plays) > 1

MATCH (u2)-[p:PLAYS]->(g:Game)
WITH u1, u1_mean_playtime, u2, avg(p.playtime_forever) AS u2_mean_playtime, plays
UNWIND plays AS play
WITH SUM( (play.p1.playtime_forever - u1_mean_playtime) * (play.p2.playtime_forever - u2_mean_playtime) ) AS nom,
     SQRT( SUM( (play.p1.playtime_forever - u1_mean_playtime)^2 ) * SUM( (play.p2.playtime_forever - u2_mean_playtime)^2 ) ) AS denom,
     u1, u2
WHERE denom <> 0
WITH u1, u2, nom / denom AS PearsonCorrelation

ORDER BY PearsonCorrelation DESC
LIMIT 20
MATCH (u2:User)-[p:PLAYS]->(g:Game) WHERE NOT EXISTS( (u1)-[:PLAYS]->(g) )
RETURN g.game_name AS RecommendedGameName, 
          ROUND(SUM(PearsonCorrelation * p.playtime_forever) * 100) / 100000.0 AS Score
ORDER BY Score DESC
LIMIT 30;
