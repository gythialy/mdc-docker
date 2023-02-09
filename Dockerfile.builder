FROM python:3.11.2-alpine

# Official Python base image is needed or some applications will segfault.
# PyInstaller needs zlib-dev, gcc, libc-dev, and musl-dev
RUN apk --update --no-cache add \
    zlib-dev \
    musl-dev \
    libc-dev \
    libffi-dev \
    gcc \
    g++ \
    git \
    make \
    cmake \
    pwgen \
    jpeg-dev \
    # mdc builder depenencies
    libxml2-dev \
    libxslt-dev \
    # download utils
    wget && \
    # update pip
    pip install --upgrade pip && \
    pip install pyinstaller

# install requirements
RUN set -eux; cd /tmp && \
    wget https://raw.githubusercontent.com/yoshiko2/Movie_Data_Capture/master/requirements.txt && \
    pip install -r requirements.txt
