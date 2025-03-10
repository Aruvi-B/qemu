# Linux OS Exploration with QEMU in GitHub Codespaces

This repository provides a complete environment for exploring multiple Linux distributions using QEMU within a GitHub Codespace.

## Overview

This project allows you to download, run, and explore various Linux distributions in a virtual environment. It's perfect for:
- Learning about different Linux distributions
- Testing OS features without installing on physical hardware
- Developing and testing cross-platform software
- Educational purposes for OS fundamentals

## Getting Started

### Prerequisites

- An active GitHub Codespace
- Basic familiarity with terminal commands

## Directory Structure

```
.
├── Dockerfile              # Configuration for the QEMU environment
├── README.md               # This documentation file
├── download-os.sh          # Script to download OS images
├── run-os.sh               # Script to run OS images in QEMU
└── os-images/              # Directory for storing OS images
    ├── alpine-virt-3.16.0-x86_64.iso  # Alpine Linux ISO
    ├── alpine.qcow2                   # Disk image for Alpine
    ├── TinyCore-current.iso           # TinyCore Linux ISO
    ├── tinycore.qcow2                 # Disk image for TinyCore
    ├── custom-distro.qcow2            # Custom disk image
    └── other OS images...             # Additional OS images
```

## Building the Docker Image

Build the Docker image containing QEMU and related tools:

```bash
docker build -t qemu-explorer -f Dockerfile .
```

## Downloading OS Images

The repository includes a script to download various Linux distributions:

```bash
./download-os.sh
```

This interactive script offers options to download:
1. TinyCore Linux - A minimal Linux distribution (~16MB)
2. Alpine Linux - A security-focused lightweight distribution
3. Custom disk image - Create an empty disk image for custom installations

You can modify the script to add more distributions as needed.

## Running the OS Images

### Web-Based Display with noVNC (Recommended Method)

For a full graphical experience, use noVNC to access your virtual machines through a web browser:

1. Install required packages:
   ```bash
   sudo apt-get update && sudo apt-get install -y novnc websockify
   ```

2. Start the noVNC server:
   ```bash
   websockify -D --web=/usr/share/novnc/ 6080 localhost:5900
   ```

3. Run QEMU with VNC display:
   ```bash
   qemu-system-x86_64 -m 1024 -cdrom os-images/[ISO-FILE] -hda os-images/[DISK-IMAGE] -boot d -vnc :0
   ```

4. Access the VM through port 6080 in your VS Code PORTS tab by clicking on the browser icon

Example for Alpine Linux:
```bash
qemu-system-x86_64 -m 1024 -cdrom os-images/alpine-virt-3.16.0-x86_64.iso -hda os-images/alpine.qcow2 -boot d -vnc :0
```

Or using Docker:
```bash
docker run -it --rm -v $(pwd)/os-images:/os-images -p 5900:5900 qemu-explorer bash -c "qemu-system-x86_64 -m 1024 -cdrom /os-images/alpine-virt-3.16.0-x86_64.iso -hda /os-images/alpine.qcow2 -boot d -vnc :0"
```

### Terminal-Based Display (Alternative Method)

1. Install required packages:
   ```bash
   sudo apt-get update && sudo apt-get install -y novnc websockify
   ```

2. Start the noVNC server:
   ```bash
   websockify -D --web=/usr/share/novnc/ 6080 localhost:5900
   ```

3. Run QEMU with VNC display:
   ```bash
   qemu-system-x86_64 -m 1024 -cdrom os-images/[ISO-FILE] -hda os-images/[DISK-IMAGE] -boot d -vnc :0
   ```

4. Access the VM through port 6080 in your VS Code PORTS tab

## Exploring Different Linux Distributions Using noVNC

Access the graphical environment of each distribution through the noVNC web interface for a complete exploration experience.

### TinyCore Linux

**Features:**
- Extremely small footprint (~16MB)
- Runs entirely in RAM
- Modular package system (TCZ extensions)
- Graphical desktop environment available

**Running with noVNC:**
```bash
# Start noVNC server (if not already running)
websockify -D --web=/usr/share/novnc/ 6080 localhost:5900

# Run TinyCore Linux
qemu-system-x86_64 -m 1024 -cdrom os-images/TinyCore-current.iso -hda os-images/tinycore.qcow2 -boot d -vnc :0
```

**Login:** No login required on boot

**Key Commands:**
```bash
tce-load -wi [package]  # Install a package
```

### Alpine Linux

**Features:**
- Security-focused
- Lightweight (uses musl libc and busybox)
- Popular for containers and embedded systems

**Running with noVNC:**
```bash
# Start noVNC server (if not already running)
websockify -D --web=/usr/share/novnc/ 6080 localhost:5900

# Run Alpine Linux
qemu-system-x86_64 -m 1024 -cdrom os-images/alpine-virt-3.16.0-x86_64.iso -hda os-images/alpine.qcow2 -boot d -vnc :0
```

**Login:** Username: `root` (no password on first boot from ISO)

**Key Commands:**
```bash
apk update              # Update package index
apk add [package]       # Install a package
setup-alpine            # Run the installation wizard
apk add xorg-server     # Add X server for GUI
apk add xfce4           # Add XFCE desktop environment
```

### Creating and Exploring a Custom OS with GUI

1. Create a custom disk image:
   ```bash
   ./download-os.sh     # Select option 3 for custom disk
   ```

2. Download an ISO of your choice (Ubuntu, Fedora, Debian, etc.)

3. Boot from the ISO using noVNC for a graphical installation experience:
   ```bash
   # Start noVNC server (if not already running)
   websockify -D --web=/usr/share/novnc/ 6080 localhost:5900
   
   # Example with Ubuntu Desktop ISO
   qemu-system-x86_64 -m 2048 -cdrom os-images/ubuntu-desktop.iso -hda os-images/custom-distro.qcow2 -boot d -vnc :0
   ```

4. Access the installer through the noVNC web interface (port 6080)

5. After installation, boot directly from the disk image:
   ```bash
   qemu-system-x86_64 -m 2048 -hda os-images/custom-distro.qcow2 -vnc :0
   ```

## Advanced QEMU Usage

### Creating and Managing Snapshots

Create a snapshot of your VM state:
```bash
qemu-img snapshot -c snapshot1 os-images/alpine.qcow2
```

Restore from a snapshot:
```bash
qemu-img snapshot -a snapshot1 os-images/alpine.qcow2
```

### Increasing Disk Size

If you need more space in your disk image:
```bash
qemu-img resize os-images/alpine.qcow2 +2G  # Add 2GB to the image
```

### Mounting Disk Images for Exploration

```bash
sudo apt-get install -y libguestfs-tools
sudo guestmount -a os-images/alpine.qcow2 -m /dev/sda1 /mnt/temp
```

### Network Configuration

Enable user-mode networking:
```bash
docker run -it --rm -v $(pwd)/os-images:/os-images qemu-explorer bash -c "qemu-system-x86_64 -m 1024 -hda /os-images/alpine.qcow2 -net nic,model=virtio -net user -vnc :0"
```

## Troubleshooting

### Common Issues

1. **Disk image lock error**
   ```
   Failed to get "write" lock. Is another process using the image?
   ```
   
   Solution:
   - Check for running QEMU processes: `ps aux | grep qemu`
   - Kill any running processes: `kill <process_id>`
   - Create a new disk image if needed

2. **noVNC connection issues**
   - Verify port 6080 is forwarded in the PORTS tab
   - Make sure websockify is running: `ps aux | grep websockify`
   - Restart websockify if needed
   - Check that QEMU is using the correct VNC display number (-vnc :0)
   - Verify in the terminal output that QEMU started successfully

3. **Blank or black screen in noVNC**
   - Wait a moment, as some distributions take time to boot
   - Try pressing Enter or moving the mouse
   - Check if the VM is using a supported graphics mode
   - Increase VM memory if needed

3. **Boot or installation failures**
   - Verify the ISO file isn't corrupted
   - Try increasing memory allocation (-m parameter)
   - Check if the OS is compatible with the emulated hardware

## Setting Up for Graphical Exploration

### Enhancing noVNC Experience

For better usability with noVNC:

1. Increase memory allocation for graphics-intensive distributions:
   ```bash
   qemu-system-x86_64 -m 2048 -cdrom os-images/[ISO-FILE] -hda os-images/[DISK-IMAGE] -boot d -vnc :0
   ```

2. Add more virtual CPUs for better performance:
   ```bash
   qemu-system-x86_64 -m 2048 -smp 2 -cdrom os-images/[ISO-FILE] -hda os-images/[DISK-IMAGE] -boot d -vnc :0
   ```

3. Enable clipboard sharing (in Docker):
   ```bash
   docker run -it --rm -v $(pwd)/os-images:/os-images -p 5900:5900 qemu-explorer bash -c "qemu-system-x86_64 -m 2048 -cdrom /os-images/[ISO-FILE] -hda /os-images/[DISK-IMAGE] -boot d -vnc :0,clipboard=on"
   ```

### Quick Launch Commands for Different Distributions

Create a `launch-os.sh` script:

```bash
#!/bin/bash

# Start noVNC
websockify -D --web=/usr/share/novnc/ 6080 localhost:5900

case "$1" in
  "alpine")
    qemu-system-x86_64 -m 1024 -cdrom os-images/alpine-virt-3.16.0-x86_64.iso -hda os-images/alpine.qcow2 -boot d -vnc :0
    ;;
  "tinycore")
    qemu-system-x86_64 -m 1024 -cdrom os-images/TinyCore-current.iso -hda os-images/tinycore.qcow2 -boot d -vnc :0
    ;;
  "custom")
    qemu-system-x86_64 -m 2048 -hda os-images/custom-distro.qcow2 -vnc :0
    ;;
  *)
    echo "Usage: $0 [alpine|tinycore|custom]"
    ;;
esac
```

Make it executable: `chmod +x launch-os.sh`

## Useful Resources

- [Official QEMU Documentation](https://www.qemu.org/documentation/)
- [noVNC GitHub Project](https://github.com/novnc/noVNC)
- [Alpine Linux Wiki](https://wiki.alpinelinux.org/)
- [TinyCore Linux Documentation](http://tinycorelinux.net/docs.html)
- [QEMU Image Formats](https://www.qemu.org/docs/master/system/images.html)
