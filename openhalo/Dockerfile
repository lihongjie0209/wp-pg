# OpenHalo Dockerfile - MySQL Protocol Compatibility Layer for PostgreSQL
# Based on official OpenHalo: https://github.com/HaloTech-Co-Ltd/openHalo
# This provides a MySQL wire protocol interface to PostgreSQL

FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies required for OpenHalo build
# Reference: OpenHalo README installation requirements
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    ca-certificates \
    libreadline-dev \
    zlib1g-dev \
    libossp-uuid-dev \
    libicu-dev \
    pkg-config \
    bison \
    flex \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libkrb5-dev \
    libldap2-dev \
    libpam0g-dev \
    python3 \
    python3-dev \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create halo user and group (as per OpenHalo documentation)
RUN groupadd -g 1000 halo && \
    useradd -u 1000 -g halo -m -s /bin/bash halo

# Create runtime directory
RUN mkdir -p /var/run/openhalo && \
    chown halo:halo /var/run/openhalo

# Set working directory
WORKDIR /home/halo

# Clone OpenHalo repository from official source
RUN git clone https://github.com/HaloTech-Co-Ltd/openHalo.git && \
    chown -R halo:halo openHalo

# Switch to halo user for build
USER halo

# Build OpenHalo following official installation guide
# Reference: https://github.com/HaloTech-Co-Ltd/openHalo README
WORKDIR /home/halo/openHalo
RUN ./configure \
    --prefix=/home/halo/openhalo/1.0 \
    --enable-debug \
    --with-uuid=ossp \
    --with-icu \
    CFLAGS=-O2 && \
    make && \
    make install && \
    cd contrib && \
    make && \
    make install

# Set up environment variables as per OpenHalo documentation
ENV HALO_HOME=/home/halo/openhalo/1.0
ENV PGDATA=/home/halo/ohdata
ENV PATH=$HALO_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$HALO_HOME/lib
ENV PGHOST=/var/run/openhalo

# Create data directory
RUN mkdir -p $PGDATA

# Copy initialization script
COPY --chown=halo:halo entrypoint.sh /home/halo/entrypoint.sh
RUN chmod +x /home/halo/entrypoint.sh

# Expose both PostgreSQL and MySQL protocol ports
EXPOSE 5432
EXPOSE 3306

# Use entrypoint script to initialize and start OpenHalo
ENTRYPOINT ["/home/halo/entrypoint.sh"]
