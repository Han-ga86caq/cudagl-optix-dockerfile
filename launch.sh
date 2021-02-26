#!/bin/bash

app_dir_default="" # /path/to/your/source/code (on the host)
data_dir_default="" # /path/to/your/data/folder (on the host)
image_default="ga86caq/cudagl-optix:vscode" #"ga86caq/cudagl-optix:7.0-ubuntu14.04" # Image name

unset flg OPTARG OPTIND
shared_vol=""

while getopts ":a:f:v:i:" flg; do 
    case $flg in
    	a) app_dir=$OPTARG;
    	   printf "Load app source code from: $OPTARG\n";; # Mount app directory
    	f) data_dir=$OPTARG;
    	   printf "Load data from: $OPTARG\n";; # Mount data directory
		v) shared_vol="-v $OPTARG $shared_vol";; # Other shared volumn
    	i) image=$OPTARG;
    	   printf "Launch container from image $image\n";;
    	\?) printf "Flag not understood...\nValid flags are:\n\t-a\t\"app\" source code directory on your host system (will mount to /app/ in countainer)\n\t-f\t\"file\" directory on you host system (will mount to /data/ in container)\n\t-v\tOther directory you want to mount, in format:\"-v /path/in/host/dir:/path/in/container\"\n\t-i\tImages to launch, default is the image \"ga86caq/cudagl-optix\"\n" >&2
		   exit 1
		;;
    esac
done

# Mount source code directory to /app
if [ -z "$app_dir" ] 
then 
	if [ -n "$app_dir_default" ] 
	then
		shared_vol="-v $app_dir_default:/app/ $shared_vol"
	fi
else
	shared_vol="-v $app_dir:/app/ $shared_vol"
fi
# Mount data directory to /data
if [ -z "$data_dir" ] 
then 
	if [ -n "$data_dir_default" ] 
	then
		shared_vol="-v $data_dir_default:/data/ $shared_vol"
	fi
else
	shared_vol="-v $data_dir:/data/ $shared_vol"
fi

if [ -z "$image" ]; then 
	image=$image_default 
fi

docker run -it \
           --gpus all \
           --runtime=nvidia \
           --privileged \
           -e DISPLAY=$DISPLAY \
           -e XAUTHORITY=$XAUTH \
           -e LC_ALL=C \
           -v /tmp/.X11-unix:/tmp/.X11-unix:ro $shared_vol \
           -v $XAUTH:$XAUTH \
           $image /bin/bash
