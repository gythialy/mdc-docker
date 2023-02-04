FROM ghcr.io/gythialy/mdc-builder:latest as build-stage

ENV MDC_TAG=${MDC_TAG:-6.5.1}

RUN mkdir -p /tmp/mdc && cd /tmp/mdc && \
    # download mdc source code
    wget -O- https://github.com/yoshiko2/Movie_Data_Capture/archive/refs/tags/${MDC_TAG}.tar.gz | tar xz -C /tmp/mdc --strip-components 1 && \
    # build mdc
    pyinstaller \
        --onefile Movie_Data_Capture.py \
        --python-option u \
        --hidden-import "ImageProcessing.cnn" \
        --add-data "$(python -c 'import cloudscraper as _; print(_.__path__[0])' | tail -n 1):cloudscraper" \
        --add-data "$(python -c 'import opencc as _; print(_.__path__[0])' | tail -n 1):opencc" \
        --add-data "$(python -c 'import face_recognition_models as _; print(_.__path__[0])' | tail -n 1):face_recognition_models" \
        --add-data "Img:Img" \
        --add-data "config.ini:." 

FROM alpine:3.17

ENV GOSU_VERSION 1.16
RUN set -eux; \
	\
	apk add --no-cache --virtual .gosu-deps \
		ca-certificates \
		dpkg \
		gnupg \
	; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
# clean up fetch dependencies
	apk del --no-network .gosu-deps; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu --version; \
	gosu nobody true 

RUN apk add --no-cache ca-certificates coreutils shadow tzdata libxcb

ENV TZ="Asia/Shanghai"
ENV UID=99
ENV GID=100
ENV UMASK=002

ADD docker-entrypoint.sh docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh && \
    mkdir -p /app && \
    mkdir -p /data && \
    mkdir -p /config && \
    useradd -d /config -s /bin/sh mdc && \
    chown -R mdc /config && \
    chown -R mdc /data

COPY --from=build-stage /tmp/mdc/dist/Movie_Data_Capture /app
COPY --from=build-stage /tmp/mdc/config.ini /app/config.template

VOLUME [ "/data", "/config" ]

ENTRYPOINT ["/docker-entrypoint.sh"]
