#!/bin/bash

# Check if the number of arguments is less than 2
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <repository_url> <destination_folder>"
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

# Pull changes from the remote repository
git pull
echo "Changes pulled successfully."

# Building new container image
echo "Building new container..."
docker-compose build
echo "Image built successfully."

# Shutting down old instance
echo "Removing old container"
docker-compose down
echo "Old container removed successfully."

# Starting new instance
echo "Starting new instance"
docker-compose up -d
echo "New instance started successfully."
