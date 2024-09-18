#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Check if the number of arguments is less than 2 or more than 3
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <repository_url> <destination_folder> [env_file]"
    exit 1
fi

# Get the repository URL and destination folder from command-line arguments
repo_url="$1"
destination_folder="$2"

# Optional: Get the environment file from the third argument, if provided
env_file="${3:-}"

# Check if the destination folder already exists
if [ ! -d "$destination_folder" ]; then
    # If it doesn't exist, clone the repository
    git clone "$repo_url" "$destination_folder"
    echo "Repository cloned successfully."
fi

# Change the current directory to the destination folder
cd "$destination_folder" || exit

# Stash any local changes and clear stashed changes
git stash
git stash clear

# Pull changes from the remote repository
git pull
echo "Changes pulled successfully."

# Build the new container image
echo "Building new container..."
docker-compose build || { echo 'Docker build failed'; exit 1; }
echo "Image built successfully."

# Shut down the old instance
echo "Removing old container..."
docker-compose down || { echo 'Docker container removal failed'; exit 1; }
echo "Old container removed successfully."

# Check if the environment file is provided and exists
if [ -n "$env_file" ] && [ -f "$env_file" ]; then
    # Use the docker-compose with the env file
    echo "Building new container with environment file: $env_file"
    docker-compose --env-file "$env_file" up -d || { echo 'Docker up with env file failed'; exit 1; }
else
    # Use the regular docker-compose up -d command
    echo "Building new container..."
    docker-compose up -d || { echo 'Docker up failed'; exit 1; }
fi

echo "Container started successfully."
