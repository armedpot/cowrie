FROM alpine:3.15 as builder

ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

RUN apk -U --no-cache add \
    ca-certificates \
    gcc \
    git \
    libffi-dev \
    openssl-dev \
    py3-pip \
    py3-virtualenv \
    python3 \
    python3-dev \
    build-base \
    mariadb-dev \
    snappy-dev &&\
    mkdir -p /home/cowrie && \
    cd /home/cowrie && \
    git clone --separate-git-dir=/tmp/cowrie.git https://github.com/cowrie/cowrie ./cowrie-git && \
    sed -i 's/cryptography==.*/cryptography==3\.4\.6/' ./cowrie-git/requirements.txt && \
    python3 -m venv cowrie-env && \
    . cowrie-env/bin/activate && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --upgrade cffi && \
    pip install --no-cache-dir --upgrade setuptools && \
    pip install --no-cache-dir --upgrade -r cowrie-git/requirements.txt && \
    pip install --no-cache-dir --upgrade -r cowrie-git/requirements-output.txt && \
    rm -rf /home/cowrie/cowrie-git/etc/* && \
    find . -type f -name .gitignore -exec rm {} \; && \
    mkdir -p /home/cowrie/cowrie-git/var/lib/cowrie/keys


FROM alpine:3.15

ARG VERSION TITLE DESCRIPTION LICENSES URL CREATED REVISION

LABEL org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.authors="armedpot <armedpot@norad.de>" \
      org.opencontainers.image.title="$TITLE" \
      org.opencontainers.image.description="$DESCRIPTION" \
      org.opencontainers.image.licenses="$LICENSES" \
      org.opencontainers.image.url="$URL" \
      org.opencontainers.image.created="$CREATED" \
      org.opencontainers.image.revision="$REVISION"
      
RUN apk -U --no-cache add \
    python3 \
    sqlite \
    libssl1.1 \
    procps \
    ca-certificates \
    libffi \
    py3-distutils-extra && \
    adduser --disabled-password --shell /bin/ash --uid 2000 cowrie

COPY --chown=cowrie:cowrie --from=builder /home/cowrie /home/cowrie
ADD --chown=cowrie:cowrie dist/cowrie.cfg /home/cowrie/cowrie-git/etc
ENV PATH=/home/cowrie/cowrie-env/bin:${PATH}

RUN chown -R cowrie:cowrie /home/cowrie

STOPSIGNAL SIGKILL

USER cowrie:cowrie
WORKDIR /home/cowrie/cowrie-git

CMD [ "ash", "bin/cowrie", "start", "-n" ]
