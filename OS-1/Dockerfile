FROM ubuntu:22.04

# Install QEMU and necessary tools
RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    novnc \
    websockify \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create a working directory for OS images
WORKDIR /os-exploration

# This volume will be used to share files between host and container
VOLUME ["/os-images"]

# Expose VNC and noVNC ports
EXPOSE 5900
EXPOSE 6080

# Default command to keep container running
CMD ["bash"]
