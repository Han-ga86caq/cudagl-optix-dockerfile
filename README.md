# cudagl-optix-dockerfile
The Dockerfile and relevant scripts that build or run the image `ga86caq/cudagl-optix`. OptiX is free to use within any application, including commercial and educational applications, whereas the download is only available for members. Therefore, in order to successfully build the image, you have to manually download NVIDIA-OptiX-SDK-3.9.2 from this [site](https://developer.nvidia.com/designworks/optix/downloads/3.9.2/linux64).

This image is based on [nvidia/opengl:1.0-glvnd-devel-ubuntu14.04](https://registry.hub.docker.com/layers/nvidia/opengl/1.0-glvnd-devel-ubuntu14.04/images/sha256-b3b8f57b7e0a83d9de4f6daaf7b662a8eb229f29ee26a8bf10fd4cbca71c269b?context=explore) and [nvidia/cuda:7.0-devel-ubuntu14.04](https://hub.docker.com/layers/nvidia/cuda/7.0-devel-ubuntu14.04/images/sha256-bc2af9e231e96c354019e736af7f1d578f9989ddac1a391f850d6989a6cb9d5f?context=explore), therefore, CUDA and OpenGL (including [glvnd](https://github.com/NVIDIA/libglvnd)) is inherently supported. In addition, the following packages are installed:
* `NVIDIA-OptiX-SDK-3.9.2`,
* `cmake-3.18.5`
* `boost-1.56.0`,
* `eigen-3.2.10`
* `thrust-1.8.1`, 
* `glm-0.9.5.4`,
* `OpenSceneGraph-3.2.1`,

which should be downloaded and unziped in the `Downloads` folder (except for Optix-SDK, other packages can be automatically downloaded via the `getdownloads.sh` script). Furthermore, a script `launch.sh` is written in order to ease the usage of the image, since your code might include GUI, which requires certain environment variables to be correctly set. To costomize the script `launch.sh`, the variable `app_dir_default` and `data_dir_default` can be set to the directory of your code and data, respectively, so that they will be automatically mounted (or shared with) the launched countainer.
