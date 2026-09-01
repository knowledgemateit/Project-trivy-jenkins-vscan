#!/bin/bash
set -e

echo "Building Java web application..."
mvn clean install

echo "Copying WAR to Docker build directory..."
cp target/docker-java-sample-webapp-1.0-SNAPSHOT.war src/main/docker/

echo "Building Docker image..."
cd src/main/docker
docker build -t java-sample-webapp:latest .

echo "Build complete!"
