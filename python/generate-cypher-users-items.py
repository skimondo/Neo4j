import json
import re

# Function to preprocess JSON lines (replace single quotes with double quotes)
def preprocess_json_line(line):
    # Replace single quotes with double quotes, ignoring numeric values and booleans
    line = re.sub(r"(?<!\\)'", '"', line)
    return line

# Function to escape single quotes for Cypher
def escape_single_quotes(value):
    if isinstance(value, str):
        return value.replace("'", "\\'")
    return value

# Function to parse and generate Cypher queries
def parse_and_generate_cypher(file_path):
    cypher_statements = []
    
    # Open the JSON file
    with open(file_path, 'r') as file:
        for line in file:
            try:
                # Preprocess line to replace single quotes with double quotes
                line = preprocess_json_line(line.strip())
                user_data = json.loads(line)

                # Generate Cypher query for the User node
                user_query = f"""
MERGE (u:User {{
    user_id: '{escape_single_quotes(user_data['user_id'])}',
    steam_id: '{escape_single_quotes(user_data['steam_id'])}',
    user_url: '{escape_single_quotes(user_data['user_url'])}'
}});
"""
                cypher_statements.append(user_query)

                # Generate Cypher queries for the games and relationships
                for item in user_data.get('items', []):
                    game_query = f"""
MERGE (g:Game {{
    game_id: '{escape_single_quotes(item['item_id'])}'
}})
ON CREATE SET
    g.game_name = '{escape_single_quotes(item['item_name'])}';
"""
                    relationship_query = f"""
MATCH (u:User {{user_id: '{escape_single_quotes(user_data['user_id'])}'}}), 
      (g:Game {{game_id: '{escape_single_quotes(item['item_id'])}'}})
MERGE (u)-[:PLAYS {{
    playtime_forever: {item.get('playtime_forever', 0)},
    playtime_2weeks: {item.get('playtime_2weeks', 0)}
}}]->(g);
"""
                    cypher_statements.append(game_query)
                    cypher_statements.append(relationship_query)

            # except json.JSONDecodeError as e:
                # with open("log/users_parsing_errors.log", "a") as log_file:
                    # log_file.write(f"JSON decode error: {line}\nError: {e}\n")
            except Exception as e:
                pass
                # with open("log/users_parsing_errors.log", "a") as log_file:
                    # log_file.write(f"Error parsing line: {line}\nError: {e}\n")
    
    return cypher_statements


# Path to the input JSON file
input_file_path = 'data/reduced_users_items.json'

# Generate the Cypher queries
try:
    cypher_queries = parse_and_generate_cypher(input_file_path)

    # Write the Cypher queries to a file
    output_file_path = './cypher/steam_users.cypher'
    with open(output_file_path, 'w') as f:
        f.write("\n".join(cypher_queries))
    
    if not cypher_queries:
        print("No Cypher queries were generated. Check input data.")
    else:
        print(f"Cypher queries have been written to {output_file_path}")
except Exception as e:
    print(f"Error: {e}")
