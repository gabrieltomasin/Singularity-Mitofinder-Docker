# ----------- Stage 1: Build Singularity -----------
    FROM ubuntu:24.04 AS builder

    # Install build dependencies
    RUN apt-get update && \
        apt-get install -y \
            build-essential \
            libssl-dev \
            uuid-dev \
            libgpgme-dev \
            squashfs-tools \
            git \
            curl \
            libseccomp-dev \
            libglib2.0-dev \
            libfuse3-dev \
            autoconf \
            libtool \
            ca-certificates \
        && update-ca-certificates \
        && rm -rf /var/lib/apt/lists/*
    
    # Set Go version and environment
    ENV GO_VERSION=1.22.6 \
        GOPATH=/go \
        PATH=/usr/local/go/bin:/go/bin:${PATH}
    
    # Install Go
    RUN curl -OL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
        tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
        rm go${GO_VERSION}.linux-amd64.tar.gz
    
    # Build Singularity
    WORKDIR $GOPATH/src/github.com/sylabs/singularity
    RUN git clone https://github.com/sylabs/singularity.git . && \
        git submodule update --init && \
        ./mconfig && \
        make -C builddir && \
        make -C builddir install
    
    # Pull MitoFinder image
    WORKDIR /home/ubuntu
    RUN singularity pull --arch amd64 library://remiallio/default/mitofinder:v1.4.2
    
    # ----------- Stage 2: Final Minimal Image -----------
    FROM ubuntu:24.04
    
    # Copy Singularity from build stage
    COPY --from=builder /usr/local /usr/local
    COPY --from=builder /home/ubuntu /home/ubuntu
    
    # Install runtime dependencies
    WORKDIR /home/ubuntu
    RUN apt-get update && \
        apt-get install -y \
            tzdata \
            squashfs-tools \
            libfuse3-dev \
        && rm -rf /var/lib/apt/lists/* \
        && p=$(pwd) && \
            export PATH=$PATH:$p
    # Set environment variables
    ENV TZ="America/Sao_Paulo"
        
    # Optionally set Singularity as entrypoint:
    CMD ["/bin/bash"]
