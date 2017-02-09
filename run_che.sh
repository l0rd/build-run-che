#!/bin/bash

# if it builds, lets run it locally

DataDir=~/.che/
mkdir -p ${DataDir}/lib
mkdir -p ${DataDir}/workspaces
mkdir -p ${DataDir}/storage

docker run -d \
	    -p 8080:8080 \
	    --name che \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    -v ~/.che:/data:Z \
	    --security-opt label:disable \
	    rhche/che-server:nightly
