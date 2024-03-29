FROM ubuntu:22.04 AS build

# Переменные Dockerfile
ARG YQ_VERSION=v4.40.5
ARG YQ_BINARY=yq_linux_amd64
ARG TASK_VERSION=v3.32.0
ARG TASK_BINARY=task_linux_amd64.tar.gz

# Скачиваем нужные пакеты (утилиты),
RUN apt-get update &&  \
    apt-get install -y \
      libfontconfig1 \
      libxtst6 \
      rubygems \
      wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN gem install yaml-cv
RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq \
    && chmod +x /usr/bin/yq

RUN wget -O- https://github.com/go-task/task/releases/download/${TASK_VERSION}/${TASK_BINARY} \
    | tar xz -C /usr/bin


WORKDIR /app

COPY .env .
COPY src/ src/
COPY scripts/ scripts/
COPY Taskfile.yaml .

RUN task build

FROM busybox AS release

WORKDIR /app

COPY --from=build /app/build/cv.html /app/index.html