FROM nvidia/cuda:7.0-devel

COPY Downloads /Downloads

ARG BOOST="boost_1_56_0"  
ARG CMAKE="cmake-3.18.5-Linux-x86_64"
ARG EIGEN="eigen-3.2.10"
ARG OPTIX="NVIDIA-OptiX-SDK-3.9.2-linux64"
ARG OSG="OpenSceneGraph-3.2.1"
ARG THRUST="thrust-1.8.1"

ENV PATH="/Downloads/${CMAKE}/bin:${PATH}"
ENV BOOST_ROOT=/opt/${BOOST}
ENV OptiX_INSTALL_DIR="/opt/${OPTIX}"
ENV THRUST_INSTALL_DIR="/opt/${THRUST}"
ENV GLM_ROOT_DIR="/opt/glm"

# install basic packages
RUN sudo dpkg --add-architecture i386; \
    sudo apt-get update && sudo apt-get upgrade; \
    sudo apt-get install -y lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386;\
    sudo apt-get install -y build-essential subversion libxml2-dev freeglut3-dev libgtkglext1-dev \
    libtiff4-dev gcc-multilib libstdc++6-4.7-dev:i386 libstdc++6-4.7-dev:i386 subversion libxi6:i386 \
    libsm6:i386 libice6:i386 libc6:i386 libxext6:i386 libx11-6:i386

# install cmake
WORKDIR /Downloads
RUN chmod +x ${CMAKE}.sh && echo y | ./${CMAKE}.sh;\
    cd / && rm /Downloads/${CMAKE}.sh;

# install boost 
WORKDIR /Downloads/${BOOST}
RUN sudo chmod -R 777 /opt; ./bootstrap.sh; \
    ./b2 install --prefix=/opt/${BOOST};\
    echo "export BOOST_ROOT=/opt/${BOOST}"  | sudo tee -a /etc/profile;\
    cd / && rm -rf /Downloads/${BOOST}

# install OpenSceneGraph
WORKDIR /Downloads/${OSG}
RUN ./configure; sudo make install;\
    cd / && rm -rf /Downloads/${OSG}

# install OptiX
WORKDIR /Downloads/
RUN sudo chmod 777 /opt;\
    chmod +x ${OPTIX}.sh && echo y | ./${OPTIX}.sh --prefix=/opt;\
    echo "/opt/${OPTIX}/lib64"  | sudo tee -a /etc/ld.so.conf.d/additional_libs.conf;\
    sudo ldconfig;\
    echo "export OptiX_INSTALL_DIR=/opt/${OPTIX}"  | sudo tee -a /etc/profile;\
    rm ${OPTIX}.sh && cd /

# install Thrust 
RUN mv /Downloads/${THRUST} /opt/;\
    echo "export THRUST_INSTALL_DIR=/opt/${THRUST}"  | sudo tee -a /etc/profile;

# install GLM
RUN mv /Downloads/glm /opt/;\
    echo "export GLM_ROOT_DIR=/opt/glm"  | sudo tee -a /etc/profile; 

# install Eigen 
WORKDIR /Downloads/${EIGEN}
RUN mkdir build; cd build; cmake .. && sudo make install;\
    cd /; rm -rf /Downloads/${EIGEN};