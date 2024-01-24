# Use a imagem Alpine como base para a instalação do Bento4
FROM alpine:3.10 as bento4-base

ENV PATH="$PATH:/bin/bash" \
    BENTO4_BIN="/opt/bento4/bin" \
    PATH="$PATH:/opt/bento4/bin"

# FFMPEG
RUN apk add --update ffmpeg bash make

# Instale o Python 2 antes de instalar o Bento4
RUN apk add --update --upgrade python2 && \
    wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz && \
    tar xf Python-2.7.18.tar.xz && \
    cd Python-2.7.18 && \
    ./configure && \
    make && \
    make install

# Defina a variável de ambiente PYTHON para garantir que o Bento4 o encontre
ENV PYTHON="/usr/bin/python2"

# Install Bento
WORKDIR /tmp/bento4
ENV BENTO4_BASE_URL="http://zebulon.bok.net/Bento4/source/" \
    BENTO4_VERSION="1-5-0-615" \
    BENTO4_CHECKSUM="5378dbb374343bc274981d6e2ef93bce0851bda1" \
    BENTO4_TARGET="" \
    BENTO4_PATH="/opt/bento4" \
    BENTO4_TYPE="SRC"

RUN apk add --update --upgrade unzip bash gcc g++ scons && \
    wget -q ${BENTO4_BASE_URL}/Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip && \
    sha1sum -b Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip | grep -o "^$BENTO4_CHECKSUM " && \
    mkdir -p ${BENTO4_PATH} && \
    unzip Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip -d ${BENTO4_PATH} && \
    rm -rf Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip

# Compile o Bento4
RUN cd ${BENTO4_PATH} && scons -u build_config=Release target=x86_64-unknown-linux && \
    cp -R ${BENTO4_PATH}/Build/Targets/x86_64-unknown-linux/Release ${BENTO4_PATH}/bin && \
    cp -R ${BENTO4_PATH}/Source/Python/utils ${BENTO4_PATH}/utils && \
    cp -a ${BENTO4_PATH}/Source/Python/wrappers/. ${BENTO4_PATH}/bin

# Use a imagem Golang como base para a aplicação Go
FROM golang:1.21.6-alpine3.18 as base

# Copie o Bento4 da imagem intermediária
COPY --from=bento4-base /opt/bento4 /opt/bento4
ENV PATH="$PATH:/opt/bento4/bin"

# Configure o suporte a CGO
ENV CGO_ENABLED=1

# Defina o diretório de trabalho da aplicação Go
WORKDIR /go/src

RUN apk add --no-cache build-base bash

ENTRYPOINT ["tail", "-f", "/dev/null"]
