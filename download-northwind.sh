#!/bin/bash

# Create the directory if it doesn't exist
mkdir -p neo4j/import

# Get URLs into a variable
urls=$(cat import.cypher | grep -o 'https://[^"]*')

echo
echo $urls
echo

# Loop over the URLs and download each one
for url in $urls; do
    # Use curl to download the file
    # -L follows redirects
    curl -L "$url" -o "neo4j/import/$(basename $url)"
done