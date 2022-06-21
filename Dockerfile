# debian:buster-slim is used instead of alpine because the cloud bigtable emulator requires glibc.
FROM debian:buster-slim

ARG CLOUD_SDK_VERSION=390.0.0

ENV PUBSUB_EMULATOR_HOST=localhost:8085
ENV PUBSUB_PROJECT_ID=test-container

ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
ENV PATH /google-cloud-sdk/bin:$PATH

RUN groupadd -r -g 1000 cloudsdk && \
    useradd -r -u 1000 -m -s /bin/bash -g cloudsdk cloudsdk

RUN echo -n "cloud-firestore-emulator pubsub-emulator" > /tmp/additional_components
RUN if [ `uname -m` = 'x86_64' ]; then echo -n " cloud-spanner-emulator" >> /tmp/additional_components; fi;
RUN cat /tmp/additional_components
RUN if [ `uname -m` = 'x86_64' ]; then echo -n "x86_64" > /tmp/arch; else echo -n "arm" > /tmp/arch; fi;

RUN ARCH=`cat /tmp/arch` && \
    mkdir -p /usr/share/man/man1/ && \
    apt-get update && \
    apt-get -y install \
        curl \
        python3-pip \
        python3 \
        python3-crcmod \
        bash \
        openjdk-11-jre-headless && \
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-${ARCH}.tar.gz && \
    tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-${ARCH}.tar.gz && \
    rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-${ARCH}.tar.gz && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image_emulator && \
    gcloud components remove anthoscli && \
    gcloud components install beta `cat /tmp/additional_components` && \
    rm /google-cloud-sdk/data/cli/gcloud.json && \
    rm -rf /google-cloud-sdk/.install/.backup/ && \
    find /google-cloud-sdk/ -name "__pycache__" -type d  | xargs -n 1 rm -rf && \
    rm -rf /var/lib/apt/lists tmp/*
 
RUN pip3 install google-cloud-pubsub==2.13.0

COPY helper /helper
COPY topic.py topic.py

RUN chmod -R +x /helper

ENTRYPOINT "helper/start"


    ## docker build -t pubsub .
    ## docker container run -it pubsub /bin/bash
    ## docker run pubsub -p 8500:8500