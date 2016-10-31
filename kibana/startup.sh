#!/usr/bin/env bash

# Wait for the Elasticsearch container to be ready before starting Kibana.
echo "Waiting for Elasticsearch to come online..."
while true; do
    nc -q 1 elasticsearch 9200 2>/dev/null && break
done

echo "Elasticsearch is up and running. Starting Kibana..."
exec kibana
