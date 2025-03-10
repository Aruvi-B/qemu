#!/bin/bash

# Create directory for OS images if it doesn't exist
mkdir -p os-images
cd os-images

# Function to download TinyCore Linux
download_tinycore() {
    echo "Downloading TinyCore Linux..."
    wget http://tinycorelinux.net/13.x/x86/release/TinyCore-current.iso
    
    # Create a disk image to install TinyCore on
    qemu-img create -f qcow2 tinycore.qcow2 1G
    
    echo "TinyCore Linux downloaded and disk image created."
}

# Function to download Alpine Linux
download_alpine() {
    echo "Downloading Alpine Linux..."
    wget https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-virt-3.16.0-x86_64.iso
    
    # Create a disk image to install Alpine on
    qemu-img create -f qcow2 alpine.qcow2 2G
    
    echo "Alpine Linux downloaded and disk image created."
}

# Main menu
echo "Select an OS to download:"
echo "1) TinyCore Linux"
echo "2) Alpine Linux"
echo "3) Custom (Create empty disk image)"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        download_tinycore
        ;;
    2)
        download_alpine
        ;;
    3)
        read -p "Enter size in GB for the disk image: " size
        read -p "Enter name for the disk image (without extension): " name
        qemu-img create -f qcow2 "${name}.qcow2" "${size}G"
        echo "Empty disk image ${name}.qcow2 of size ${size}GB created."
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

echo "Done! You can now run the OS using the run-os.sh script."
