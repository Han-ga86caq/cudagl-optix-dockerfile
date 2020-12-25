FROM nvidia/opengl:1.0-glvnd-devel-ubuntu14.04

COPY Downloads /Downloads

ARG BOOST="boost_1_56_0"  
ARG CMAKE="cmake-3.18.5-Linux-x86_64"
ARG EIGEN="eigen-3.2.10"
ARG OPTIX="NVIDIA-OptiX-SDK-3.9.2-linux64"
ARG OSG="OpenSceneGraph-3.2.1"
ARG THRUST="thrust-1.8.1"
ARG CUDA="cuda-7.0"
ARG CUDA_INSTALL="cuda_7.0.28_linux.run"

USER root

# install basic packages
RUN dpkg --add-architecture i386; \
    apt-get update; \
    apt-get install -y lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386;\
    apt-get install -y build-essential subversion libxml2-dev freeglut3-dev libgtkglext1-dev \
    libtiff4-dev gcc-multilib libstdc++6-4.7-dev:i386 libstdc++6-4.7-dev:i386 subversion libxi6:i386 \
    libsm6:i386 libice6:i386 libc6:i386 libxext6:i386 libx11-6:i386;\
    apt-get install -y expect;

# install CUDA
WORKDIR /Downloads/
RUN chmod +x ${CUDA_INSTALL};\ 
    chmod +x cuda-auto-install.sh;\
    ./cuda-auto-install.sh ${CUDA_INSTALL};\
    ls /usr/local;\
    echo "/usr/local/${CUDA}" |  tee -a /etc/ld.so.conf.d/additional_libs.conf;\
    ldconfig;\
    rm /Downloads/${CUDA_INSTALL}
ENV PATH="/usr/local/${CUDA}/bin:${PATH}"

# install cmake
WORKDIR /Downloads
RUN chmod +x ${CMAKE}.sh && echo y | ./${CMAKE}.sh;\
    cd / && rm /Downloads/${CMAKE}.sh;
ENV PATH="/Downloads/${CMAKE}/bin:${PATH}"

# install boost 
WORKDIR /Downloads/${BOOST}
RUN chmod -R 777 /opt; ./bootstrap.sh; \
    ./b2 install --prefix=/opt/${BOOST};\
    cd / && rm -rf /Downloads/${BOOST}
ENV BOOST_ROOT="/opt/${BOOST}"

# install OpenSceneGraph
WORKDIR /Downloads/${OSG}
RUN ./configure;  make install;\
    cd / && rm -rf /Downloads/${OSG};
ENV LD_LIBRARY_PATH="/usr/local/lib64:/usr/local/lib:${LD_LIBRARY_PATH}"
ENV OPENTHREADS_INC_DIR="/usr/local/include"
ENV OPENTHREADS_LIB_DIR="/usr/local/lib64:/usr/local/lib"
ENV PATH="${OPENTHREADS_LIB_DIR}:${PATH}"

# install OptiX
WORKDIR /Downloads/
RUN chmod -R 777 /opt;\
    chmod +x ${OPTIX}.sh && echo y | ./${OPTIX}.sh --prefix=/opt;\
    echo "/opt/${OPTIX}/lib64"  |  tee -a /etc/ld.so.conf.d/additional_libs.conf;\
    ldconfig;\
    rm ${OPTIX}.sh && cd /
ENV OptiX_INSTALL_DIR="/opt/${OPTIX}"

# install Thrust 
RUN mv /Downloads/${THRUST} /opt/;
ENV THRUST_INSTALL_DIR="/opt/${THRUST}"

# install GLM
RUN mv /Downloads/glm /opt/;
ENV GLM_ROOT_DIR="/opt/glm"

# install Eigen 
WORKDIR /Downloads/${EIGEN}
RUN mkdir build; cd build; cmake .. &&  make install;\
    cd /; rm -rf /Downloads/${EIGEN};

WORKDIR /