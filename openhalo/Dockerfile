# OpenHalo Dockerfile - MySQL Protocol Compatibility Layer for PostgreSQL
# This provides a MySQL wire protocol interface to PostgreSQL

FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies required for OpenHalo build
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    libreadline-dev \
    zlib1g-dev \
    libossp-uuid-dev \
    libicu-dev \
    pkg-config \
    bison \
    flex \
    libssl-dev \
    python3 \
    python3-pip \
    netcat \
    mysql-client \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Create halo user and group
RUN groupadd -g 1000 halo && \
    useradd -u 1000 -g halo -m -s /bin/bash halo

# Set working directory
WORKDIR /home/halo

# Clone OpenHalo repository
RUN git clone https://github.com/HaloTech-Co-Ltd/openHalo.git && \
    chown -R halo:halo openHalo

# Switch to halo user for build
USER halo

# Build OpenHalo
WORKDIR /home/halo/openHalo
RUN ./configure \
    --prefix=/home/halo/openhalo \
    --with-uuid=ossp \
    --with-icu \
    CFLAGS=-O2 && \
    make && \
    make install && \
    cd contrib && \
    make && \
    make install

# Set up environment variables
ENV HALO_HOME=/home/halo/openhalo
ENV PATH=$HALO_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$HALO_HOME/lib
ENV PGDATA=/home/halo/pgdata
ENV PGHOST=/tmp

# Create data directory
RUN mkdir -p /home/halo/pgdata

# Copy initialization script
COPY --chown=halo:halo entrypoint.sh /home/halo/entrypoint.sh
RUN chmod +x /home/halo/entrypoint.sh

# Expose MySQL protocol port
EXPOSE 3306

# Use entrypoint script to initialize and start OpenHalo
ENTRYPOINT ["/home/halo/entrypoint.sh"]
