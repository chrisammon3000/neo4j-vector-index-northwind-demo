# neo4j-vector-index-northwind-demo
Basic usage of Neo4j's vector index for similarity search using the Northwind dataset.

## Description
Create a vector index for the `productName` property of the `Product` nodes in the Northwind dataset. Embed a query using the OpenAI API and use the vector index to find similar products.

## Prerequisites
Before you begin, make sure to create a `.env` file and add your OpenAI API key.
```sh
OPENAI_API_KEY=<your-api-key>
```

## Installation
Create a Python virtual environment and install the required packages.
```sh
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## Usage
Download the Northwind dataset.
```sh
bash download-northwind.sh
```

Generate embeddings for product names.
```sh
python3 src/generate_embeddings.py
```

Run Neo4j using Docker
```sh
docker run \
    --name neo4j \
    --publish=7474:7474 \
    --publish=7687:7687 \
    --env "NEO4J_AUTH=none" \
    --env "NEO4J_dbms_security_procedures_allowlist=apoc.*" \
    --env "NEO4J_apoc_import_file_enabled=true" \
    --env NEO4J_PLUGINS='["apoc", "apoc-extended", "graph-data-science"]' \
    --volume=$(pwd)/neo4j/import:/var/lib/neo4j/import \
    neo4j:5.15
```

Run Cypher to load Neo4j and create the vector indexes.
```sh
cat import.cypher | docker exec -i neo4j "/var/lib/neo4j/bin/cypher-shell"
```

Embed a query using the helper script.
```sh
python3 src/generate_query_embeddings.py
>>> Enter query: french cheese
# Find output in ./examples/french_cheese
```

Copy and paste the query embedding into a new param in Neo4j, make sure to wrap in single-quotes.
```cypher
:param query => toFloatList(split('<embedding>', ","))
```

Query the graph using the vector index.
```cypher
MATCH (p:Product)
CALL db.index.vector.queryNodes('product-name-embeddings', 5, $query)
YIELD node AS similarProduct, score
MATCH (similarProduct)
RETURN DISTINCT similarProduct.productName, score ORDER BY score DESC;
```

## Clean Up
Stop and remove the Neo4j container.
```sh
docker stop neo4j
docker rm neo4j
```

Deactivate the Python virtual environment.
```sh
deactivate
rm -rf .venv
```

Remove artifacts.
```sh
rm -rf neo4j examples
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References
- https://neo4j.com/docs/cypher-manual/current/indexes/semantic-indexes/vector-indexes/#indexes-vector-create
- https://neo4j.com/docs/cypher-manual/current/syntax/parameters/