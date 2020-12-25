#!/bin/bash

unset flg OPTARG OPTIND

while getopts ":a:f:" flg; do 
    case $flg in
    	a) app_dir=$OPTARG;
    	   printf "Load app source code from:\n$OPTARG\n";; # Mount app directory
    	f) data_dir=$OPTARG;
    	   printf "Load data from:\n$OPTARG\n";; # Mount data directory
    	\?) echo "Unknown flag name!" >&2;;
    esac
done

shared_vol="-v $app_dir:/app/ -v $data_dir:/data/"

docker run --gpus all --runtime=nvidia -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro $shared_vol --privileged \
ga86caq/cudagl-optix:7.0-ubuntu14.04 /bin/bash