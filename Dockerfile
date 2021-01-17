# docker build --pull -t ericsgagnon/buildpack-deps-cuda:ubuntu20.04-cuda11.0 -f Dockerfile .
# docker run --rm --name buildpacks-nvidia-dev --gpus all ericsgagnon/buildpack-deps-cuda:ubuntu20.04-cuda11.0 nvidia-smi
# overview: this image simply mimics buildpack-deps but uses nvidia's official devel cuda image as base

FROM nvidia/cudagl:11.0-devel-ubuntu20.04

# environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LANG=en_US.UTF-8
ENV PASSWORD password
ENV SHELL=/bin/bash
ENV WORKSPACE=/workspace

# this may not be necessary but may give insight on source files
COPY . ${WORKSPACE}/

RUN chsh -s /bin/bash

# # first imitate the cudagl docker images: https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.0/ubuntu20.04-x86_64/devel/Dockerfile

# ENV NCCL_VERSION 2.7.8

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     cuda-nvml-dev-11-0=11.0.167-1 \
#     cuda-command-line-tools-11-0=11.0.3-1 \
#     cuda-nvprof-11-0=11.0.221-1 \
#     libnpp-dev-11-0=11.1.0.245-1 \
#     cuda-libraries-dev-11-0=11.0.3-1 \
#     cuda-minimal-build-11-0=11.0.3-1 \
#     libcublas-dev-11-0=11.2.0.252-1 \
#     libcusparse-11-0=11.1.1.245-1 \
#     libcusparse-dev-11-0=11.1.1.245-1 \
#     && rm -rf /var/lib/apt/lists/*

# RUN apt update && apt install curl xz-utils -y --no-install-recommends && NCCL_DOWNLOAD_SUM=34000cbe6a0118bfd4ad898ebc5f59bf5d532bbf2453793891fa3f1621e25653 && \
#     curl -fsSL https://developer.download.nvidia.com/compute/redist/nccl/v2.7/nccl_2.7.8-1+cuda11.0_x86_64.txz -O && \
#     echo "$NCCL_DOWNLOAD_SUM  nccl_2.7.8-1+cuda11.0_x86_64.txz" | sha256sum -c - && \
#     tar --no-same-owner --keep-old-files --lzma -xvf  nccl_2.7.8-1+cuda11.0_x86_64.txz -C /usr/local/cuda/include/ --strip-components=2 --wildcards '*/include/*' && \
#     tar --no-same-owner --keep-old-files --lzma -xvf  nccl_2.7.8-1+cuda11.0_x86_64.txz -C /usr/local/cuda/lib64/ --strip-components=2 --wildcards '*/lib/libnccl.so' && \
#     rm nccl_2.7.8-1+cuda11.0_x86_64.txz && \
#     ldconfig && rm -rf /var/lib/apt/lists/*

# ENV LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LIBRARY_PATH}

# https://gitlab.com/nvidia/container-images/opengl/blob/ubuntu20.04/glvnd/devel/Dockerfile

RUN apt-get update && apt-get install -y --no-install-recommends \
        pkg-config \
        libglvnd-dev libglvnd-dev:i386 \
        libgl1-mesa-dev libgl1-mesa-dev:i386 \
        libegl1-mesa-dev libegl1-mesa-dev:i386 \
        libgles2-mesa-dev libgles2-mesa-dev:i386 && \
    rm -rf /var/lib/apt/lists/*



# buildpack-deps curl: https://github.com/docker-library/buildpack-deps/blob/master/ubuntu/focal/curl/Dockerfile

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

# buildpack-deps scm: https://github.com/docker-library/buildpack-deps/blob/master/ubuntu/focal/scm/Dockerfile

# procps is very common in build systems, and is a reasonably small package
RUN apt-get update && apt-get install -y --no-install-recommends \
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion \
		\
		procps \
	&& rm -rf /var/lib/apt/lists/*

# buildpack-deps: https://github.com/docker-library/buildpack-deps/blob/master/ubuntu/focal/Dockerfile

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
