FROM nvcr.io/nvidia/tensorflow:19.12-tf1-py3
#borrowed from Claudio Fahey :)
#FROM nvcr.io/nvidia/tensorflow:18.04-py2
# Install required packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
libmlx5-1 \
librdmacm-dev \
librdmacm1 \
openssh-client \
openssh-server \
infiniband-diags \
rdmacm-utils \
ibutils \
ibverbs-utils \
lsof \
&& \
rm -rf /var/lib/apt/lists/*
# (Optional) Install a newer version of OpenMPI
#ENV OPENMPI_VERSION 3.1.0
#ENV OPENMPI_URL https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-${OPENMPI_VERSION}.tar.gz
#RUN wget -q -O - ${OPENMPI_URL} | tar -xzf - && \
#cd openmpi-${OPENMPI_VERSION} && \
#./configure --enable-orterun-prefix-by-default \
#--with-cuda --with-verbs \
#--prefix=/usr/local/mpi --disable-getpwuid && \
#make -j"$(nproc)" install && \
#cd .. && rm -rf openmpi-${OPENMPI_VERSION}
#ENV PATH /usr/local/mpi/bin:$PATH
# Configure SSHD for MPI.
RUN mkdir -p /var/run/sshd && \
    mkdir -p /root/.ssh && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    echo "UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config && \
    sed -i 's/^#*Port 22/Port 2222/' /etc/ssh/sshd_config && \
    echo "HOST *" >> /root/.ssh/config && \
    echo "PORT 2222" >> /root/.ssh/config && \
    mkdir -p /root/.ssh && \
    ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/*
# Install Python libraries.
COPY requirements.txt /tmp/requirements.txt
RUN pip install --requirement /tmp/requirements.txt
WORKDIR /scripts
RUN ldconfig
EXPOSE 2222
