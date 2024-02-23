# neo4j-vector-index-demo

## Quickstart

Run Neo4j using Docker
```sh
docker run \
    --name neo4j \
    --publish=7474:7474 \
    --publish=7687:7687 \
    --env NEO4J_AUTH=none \
    --volume=$(pwd)/neo4j/import:/import \
    --volume=$(pwd)/neo4j/scripts:/scripts \
    neo4j:5.15
```

Generate embeddings
```sh
python3 src/generate_embeddings.py
```


Create the vector indexes