#!/bin/bash

# add-path.sh - Helper to add external project paths to docker-compose.override.yaml

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./add-path.sh <local_path> <container_folder_name>"
    echo "Example: ./add-path.sh /Users/username/Projects/example/laravel laravel-project"
    exit 1
fi

LOCAL_PATH=$1
CONTAINER_NAME=$2
OVERRIDE_FILE="docker-compose.override.yaml"
EXAMPLE_FILE="docker-compose.override.example.yaml"

# Create override file if not exists
if [ ! -f "$OVERRIDE_FILE" ]; then
    echo "Creating $OVERRIDE_FILE from example..."
    cp "$EXAMPLE_FILE" "$OVERRIDE_FILE"
fi

# Prepare the volume string
VOLUME_LINE="      - ${LOCAL_PATH}:/var/www/${CONTAINER_NAME}"

# Check if already exists
if grep -q "$VOLUME_LINE" "$OVERRIDE_FILE"; then
    echo "Warning: This mapping already exists in $OVERRIDE_FILE"
    exit 0
fi

# Insert the volume line before the END marker
# We use a temporary file to handle the insertion safely
sed -i '' "/# -- CUSTOM VOLUMES END --/i\\
$VOLUME_LINE\\
" "$OVERRIDE_FILE"

echo "✅ Added mapping: $LOCAL_PATH -> /var/www/$CONTAINER_NAME"
echo "🔄 Recreating containers to apply changes..."
docker-compose up -d
echo "🎉 Done! Your project is mapped."
