FROM ubuntu:22.04
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

RUN apt-get update \
  && apt-get install --assume-yes \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
RUN curl -fsSL https://downloads.mender.io/repos/debian/gpg | tee /etc/apt/trusted.gpg.d/mender.asc

RUN echo "deb [arch=$(dpkg --print-architecture)] https://downloads.mender.io/repos/debian ubuntu/jammy/stable main" \
  tee /etc/apt/sources.list.d/mender.list > /dev/null

RUN apt-get update \
  && apt-get install --assume-yes mender-artifact

RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && apt-get install -y python3 \
  && rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash apprunner
USER apprunner