FROM nvidia/opengl:1.0-glvnd-devel-ubuntu14.04 AS GL

FROM nvidia/cuda:7.0-devel-ubuntu14.04

# Copy glvnd support from first stage
COPY --from=GL /usr/local/lib/x86_64-linux-gnu/ /usr/local/lib/x86_64-linux-gnu/
COPY --from=GL /usr/local/lib/i386-linux-gnu/ /usr/local/lib/i386-linux-gnu/
COPY --from=GL /usr/local/share/glvnd/ /usr/local/share/glvnd/
COPY --from=GL /usr/local/include/ /usr/local/include/
COPY --from=GL /usr/include/* /usr/include/

ENV NVIDIA_DRIVER_CAPABILITIES=graphics,compat32,utility,compute
ENV NVIDIA_VISIBLE_DEVICES=all
RUN echo '/usr/local/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf \
    && echo '/usr/local/lib/i386-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && ldconfig
ENV LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu:/usr/local/lib/i386-linux-gnu:/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

COPY Downloads /Downloads

ARG BOOST="boost_1_56_0"  
ARG CMAKE="cmake-3.18.5-Linux-x86_64"
ARG EIGEN="eigen-3.2.10"
ARG OPTIX="NVIDIA-OptiX-SDK-3.9.2-linux64"
ARG OSG="OpenSceneGraph-3.2.1"
ARG THRUST="thrust-1.8.1"
ARG CUDA="cuda-7.0"

USER root

# install basic packages
RUN dpkg --add-architecture i386; \
    apt-get update; \
    apt-get install -y lib32gcc1 lib32stdc++6 libcurl4-gnutls-dev:i386;\
    apt-get install -y build-essential subversion libxml2-dev freeglut3-dev libgtkglext1-dev \
    libtiff4-dev gcc-multilib libstdc++6-4.7-dev:i386 libstdc++6-4.7-dev:i386 subversion libxi6:i386 \
    libsm6:i386 libice6:i386 libc6:i386 libxext6:i386 libx11-6:i386;\
    apt-get install -y expect;

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

# Add cuda directory
RUN echo "/usr/local/${CUDA}/lib64"  | sudo tee -a /etc/ld.so.conf.d/additional_libs.conf\
    sudo ldconfig

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