#!/bin/bash

mkdir -p data
cd projet

wget -P data https://datarepo.eng.ucsd.edu/mcauley_group/data/steam/bundle_data.json.gz
wget -P data https://datarepo.eng.ucsd.edu/mcauley_group/data/steam/australian_users_items.json.gz

gunzip data/bundle_data.json.gz
gunzip data/australian_users_items.json.gz

docker run -d \
  --name neo4j-container \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=none \
  neo4j