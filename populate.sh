#!/bin/bash

echo "Reducing dataset to 500 lines..."
head -n 500 data/australian_users_items.json > data/reduced_users_items.json

echo "Making sure the  Neo4j database is empty..."
cypher-shell -f cypher/drop.cypher > /dev/null

echo "Generating Cypher for bundles..."
python3 python/generate-cypher-bundles.py

echo "Adding bundles to Neo4j, please wait..."
cypher-shell -f cypher/bundles.cypher > /dev/null

echo "Generating Cypher for users and their items..."
python3 python/generate-cypher-users-items.py 

echo "Adding users and their items to Neo4j, please wait..."
cypher-shell -f cypher/steam_users.cypher > /dev/null

echo "Executing simple recommendation queries..."
cypher-shell -f cypher/recommendations.cypher

echo "Script execution completed successfully!"
