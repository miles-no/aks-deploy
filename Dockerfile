FROM azuresdk/azure-cli-python:latest

LABEL maintainer="azzlack <ove.andersen@miles.no>, Olsenius <andreas.olsen@miles.no>"

# From https://github.com/trinitronx/docker-build-tools/blob/master/docker-platforms/alpine-3.6/Dockerfile
RUN set -x && \
    apk --no-cache update && \
    apk --no-cache add ca-certificates wget curl groff less openssh-client git python openssl py-pip && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

# Git permissions
RUN mkdir /root/.ssh/

# Check azure cli version
RUN set -x && \
    az --version

# Install kubectl
ENV K8S_VERSION=1.10.6

RUN set -x && \
    wget -O /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl -q && \
    chmod +x /bin/kubectl

COPY /run.sh /run.sh
# COPY /id_rsa /root/.ssh/id_rsa
# COPY /id_rsa.pub /root/.ssh/id_rsa.pub

RUN chmod +x /run.sh

CMD ["/run.sh"]
