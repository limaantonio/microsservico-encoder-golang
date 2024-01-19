FROM golang:1.21.6-alpine3.18 as base

# Instala as dependências necessárias para o build
RUN apk --update --no-cache add \
        curl \
        python3 \
        bash \
        gcc \
        g++ \
        scons

# Configura o diretório de trabalho padrão
WORKDIR /opt/bento4

# Define variáveis de ambiente para o Bento4
ARG BENTO4_BASE_URL="https://zebulon.bok.net/Bento4/source"
ARG BENTO4_VERSION="1-5-0-615"
ARG BENTO4_CHECKSUM="5378dbb374343bc274981d6e2ef93bce0851bda1"
ARG BENTO4_TARGET=""
ENV BENTO4_PATH="/opt/bento4"
ENV BENTO4_TYPE="SRC"

# Fase para download do Bento4
FROM base as downloader

# Download e verifica o Bento4
RUN apk --update --no-cache add curl \
    && curl -k -LO "${BENTO4_BASE_URL}/Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip" \
    && echo "${BENTO4_CHECKSUM} *Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip" | sha1sum -c - \
    && unzip "Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip" -d /opt/bento4 \
    && rm "Bento4-${BENTO4_TYPE}-${BENTO4_VERSION}${BENTO4_TARGET}.zip"

# Fase para a construção final
FROM base as builder

# Copia os arquivos baixados da fase de downloader
COPY --from=downloader /opt/bento4 /opt/bento4

# Configurações adicionais após o build
RUN apk --update --no-cache add \
        py3-pip

# Instalação do SCons
RUN pip3 install 'SCons==3.0.5'

# Verifica se o diretório Build existe
RUN ls -l /opt/bento4/Build

# Configuração do SCons para usar Python 3
RUN sed -i '1s/python$/python3/' /opt/bento4/Build/Boot.scons

# Limpeza
RUN rm -rf /var/cache/apk/*


# Configura o diretório de trabalho para /go/src
WORKDIR /go/src

# Configura o ponto de entrada para tail, segurando o processo rodando
ENTRYPOINT ["tail", "-f", "/dev/null"]
