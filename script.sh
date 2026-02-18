#!/bin/bash

# Check if the number of arguments is less than 2 or more than 3
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <repository_url> <destination_folder> [optional_argument]"
    exit 1
fi

# Get the repository URL and destination folder from command-line arguments
repo_url="$1"
destination_folder="$2"

# Check if the destination folder already exists
if [ ! -d "$destination_folder" ]; then
    # If it doesn't exist, clone the repository
    git clone "$repo_url" "$destination_folder"
    echo "Repository cloned successfully."
fi

# Change the current directory to the destination folder
cd "$destination_folder" || exit

# Stash changes
git stash

# Remove all stashed changes
git stash clear

# Pull changes from the remote repository
git pull
echo "Changes pulled successfully."

# Building new container image
echo "Building new container..."
docker compose build
echo "Image built successfully."

# Shutting down old instance
echo "Removing old container"
docker compose down
echo "Old container removed successfully."

# Check if an *.env file exists in the current directory
if ls *.env 1> /dev/null 2>&1; then
    # Use the docker-compose --env-file command if an env file exists
    echo "Building new container with environment file..."
    docker compose --env-file=environments.env up -d
else
    # Use the regular docker-compose up -d command if no env file is found
    echo "Building new container..."
    docker compose up -d
fi

echo "Container started successfully."
