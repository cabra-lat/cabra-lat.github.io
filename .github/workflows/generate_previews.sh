#!/bin/bash

set -e # Exit on error

# Serve the site locally
echo "Starting local HTTP server..."
python3 -m http.server 8080 --directory _site &
SERVER_PID=$!

# Wait for server to start
sleep 5

# Create previews directory
mkdir -p _site/previews

# Generate previews
echo "Generating previews..."
for file in _site/*.html; do
    slug=$(basename "${file%.html}")
    output="_site/previews/${slug}.png"
    wkhtmltoimage --width 1200 --height 630 \
      --enable-local-file-access \
      "http://localhost:8080/${slug}.html" "$output"
    echo "Generated preview for $slug at $output"
done

# Kill local server
kill $SERVER_PID
echo "Local HTTP server stopped."
