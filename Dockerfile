# this image mimics buildpack-deps but uses 
# nvidia's official devel cuda image as base 
# and adds the full cuda toolkit for tensorflow

# FROM nvidia/cudagl:11.4.2-devel-ubuntu20.04
# FROM nvidia/cuda:11.7.1-devel-ubuntu22.04
# FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
#FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=en_US.UTF-8
ENV PASSWORD password
ENV SHELL=/bin/bash
ENV WORKSPACE=/tmp/workspace/buildpack-deps-cuda

# this may not be necessary but may give insight on source files
COPY . ${WORKSPACE}/

RUN chsh -s /bin/bash

# buildpack-deps curl: https://github.com/docker-library/buildpack-deps/blob/master/ubuntu/jammy/curl/Dockerfile

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
# https://bugs.debian.org/929417
		tzdata \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

# buildpack-deps scm: https://github.com/docker-library/buildpack-deps/blob/master/ubuntu/jammy/scm/Dockerfile

# procps is very common in build systems, and is a reasonably small package
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        mercurial \
        openssh-client \
        subversion \
        \
        procps \
    && rm -rf /var/lib/apt/lists/*

# buildpack-deps: https://github.com/docker-library/buildpack-deps/blob/master/ubuntu/jammy/Dockerfile

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		bzip2 \
		dpkg-dev \
		file \
		g++ \
		gcc \
		imagemagick \
		libbz2-dev \
		libc6-dev \
		libcurl4-openssl-dev \
		libdb-dev \
		libevent-dev \
		libffi-dev \
		libgdbm-dev \
		libglib2.0-dev \
		libgmp-dev \
		libjpeg-dev \
		libkrb5-dev \
		liblzma-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libmaxminddb-dev \
		libncurses5-dev \
		libncursesw5-dev \
		libpng-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libtool \
		libwebp-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		make \
		patch \
		unzip \
		xz-utils \
		zlib1g-dev \
		\
# https://lists.debian.org/debian-devel-announce/2016/09/msg00000.html
		$( \
# if we use just "apt-cache show" here, it returns zero because "Can't select versions from package 'libmysqlclient-dev' as it is purely virtual", hence the pipe to grep
			if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
				echo 'default-libmysqlclient-dev'; \
			else \
				echo 'libmysqlclient-dev'; \
			fi \
		) \
	; \
	rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
	software-properties-common \
	apt-utils \
	libncursesw5 \
	libtinfo5

