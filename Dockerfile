FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential unzip wget openjdk-11-jre time locales \
  libbz2-dev zlib1g zlib1g-dev liblzma-dev pkg-config libncurses5-dev 

RUN apt-get update && apt-get install -y --no-install-recommends  \
  python3-pip cpanminus curl
#  make python3-pip \
#  python3-dev \
#  cpanminus \
#  libncurses5-dev libbz2-dev liblzma-dev python \
#  bc parallel meson ninja-build libvcflib-tools vcftools zlib1g pkg-config cmake

RUN cpanm LWP::Simple

WORKDIR /usr/local/


RUN wget https://github.com/fbreitwieser/krakenuniq/archive/refs/tags/v1.0.2.tar.gz && \
	tar xzf v1.0.2.tar.gz && \
	cd krakenuniq-1.0.2 && \
	./install_krakenuniq.sh -j /usr/local/bin


RUN wget 'http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip' && \
  unzip fastqc_v0.11.5.zip && \
  rm fastqc_v0.11.5.zip && \
  cd FastQC && \
  chmod 755 fastqc && \
  ln -s /usr/local/FastQC/fastqc /usr/local/bin/fastqc

RUN pip install multiqc

ENV LC_ALL C
ENV PATH=/usr/local/bin:$PATH

# samtools
ARG SAMTOOLSVER=1.16.1
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLSVER}/samtools-${SAMTOOLSVER}.tar.bz2 && \
 tar -xjf samtools-${SAMTOOLSVER}.tar.bz2 && \
 rm samtools-${SAMTOOLSVER}.tar.bz2 && \
 cd samtools-${SAMTOOLSVER} && \
 ./configure && \
 make && \
 make install && rm -rf /usr/local/samtools-1.16.1

# Fastp
WORKDIR /usr/local/bin/
RUN wget http://opengene.org/fastp/fastp.0.23.1 && \
    mv fastp.0.23.1 fastp &&\
    chmod a+x ./fastp

# Cleanup apt package lists to save space
RUN rm -rf /var/lib/apt/lists/*

