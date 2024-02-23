#!/bin/bash

# Create the directory if it doesn't exist
mkdir -p neo4j/import

# Set the base URL and the files to download
base_url=https://data.neo4j.com/northwind
files="products categories suppliers customers orders order-details"

# Loop over the URLs and download each one
for file in $files; do
    # Use curl to download the file
    # -L follows redirects
    curl -L "$base_url/$file.csv" -o "neo4j/import/$file.csv"
done