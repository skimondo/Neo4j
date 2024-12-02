import ast

# Function to escape special characters for Cypher
def escape_special_characters(value):
    if isinstance(value, str):
        # Escape single and double quotes
        value = value.replace("'", "\\'")
        value = value.replace('"', '\\"')
    return value


# Function to escape single quotes for Cypher
def escape_single_quotes(value):
    return value.replace("'", "\\'")


# Function to parse and generate Cypher queries
def parse_and_generate_cypher(file_path):
    cypher_statements = []
    
    # Open the file with the original syntax
    with open(file_path, 'r') as file:
        for line in file:
            try:
                bundle = ast.literal_eval(line.strip())
                
                # Create or merge Bundle nodes
                bundle_query = f"""
MERGE (b:Bundle {{
    bundle_id: "{escape_special_characters(bundle['bundle_id'])}",
    bundle_name: "{escape_special_characters(bundle['bundle_name'])}",
    bundle_price: "{escape_special_characters(bundle['bundle_price'])}",
    bundle_final_price: "{escape_special_characters(bundle['bundle_final_price'])}",
    bundle_discount: "{escape_special_characters(bundle['bundle_discount'])}"
}});
"""
                cypher_statements.append(bundle_query)

                for item in bundle.get('items', []):
                    # Create or merge Game nodes with unique `game_id`
                    game_query = f"""
MERGE (g:Game {{
    game_id: "{escape_special_characters(item['item_id'])}"
}})
ON CREATE SET 
    g.game_name = "{escape_special_characters(item['item_name'])}";
"""
                    cypher_statements.append(game_query)

                    # Create relationships between Bundle and Game
                    relationship_query = f"""
MATCH (b:Bundle {{bundle_id: "{escape_special_characters(bundle['bundle_id'])}"}}), 
      (g:Game {{game_id: "{escape_special_characters(item['item_id'])}"}})
MERGE (b)-[:CONTAINS {{
    game_discounted_price: "{escape_special_characters(item['discounted_price'])}"
}}]->(g);
"""
                    cypher_statements.append(relationship_query)

                    # Create Genre nodes and relationships
                    genres = item.get('genre', '').split(',')
                    for genre in genres:
                        genre = genre.strip()
                        genre_query = f"""
MERGE (genre:Genre {{
    genre_name: "{escape_special_characters(genre)}"
}})
MERGE (g:Game {{game_id: "{escape_special_characters(item['item_id'])}"}})
MERGE (g)-[:BELONGS_TO]->(genre);
"""
                        cypher_statements.append(genre_query)
            
            except Exception as e:
                pass
                # with open("log/bundles_parsing_errors.log", "a") as log_file:
                    # log_file.write(f"Error parsing line: {line}\nError: {e}\n")
    
    return cypher_statements


# Path to the file with original syntax
original_file_path = './data/bundle_data.json'

# Generate the Cypher queries
cypher_queries = parse_and_generate_cypher(original_file_path)

# Write the Cypher queries to a file
output_file_path = './cypher/bundles.cypher'
with open(output_file_path, 'w') as f:
    f.write("\n".join(cypher_queries))

print(f"Cypher queries have been written to {output_file_path}")
