# QEMU Command Reference Guide

This guide provides a comprehensive overview of QEMU command-line options and usage patterns for virtual machine creation and management.

## Table of Contents
- [Basic Command Structure](#basic-command-structure)
- [Architecture Selection](#architecture-selection)
- [Machine Options](#machine-options)
- [Storage Options](#storage-options)
- [Boot Options](#boot-options)
- [Display Options](#display-options)
- [Network Options](#network-options)
- [USB Options](#usb-options)
- [Other Common Options](#other-common-options)
- [Common Example Commands](#common-example-commands)
- [Disk Image Management](#disk-image-management)

## Basic Command Structure

```
qemu-system-<arch> [machine options] [device options] [display options] [boot options] [disk options] [network options] [other options]
```

## Architecture Selection

Select the architecture with the appropriate QEMU binary:

| Command | Architecture |
|---------|-------------|
| `qemu-system-x86_64` | 64-bit x86 systems |
| `qemu-system-i386` | 32-bit x86 systems |
| `qemu-system-arm` | ARM systems |
| `qemu-system-aarch64` | 64-bit ARM systems |
| `qemu-system-ppc` | PowerPC systems |
| `qemu-system-mips` | MIPS systems |

## Machine Options

```
-machine [type=]name[,prop=value[,...]]
-M name                   # shorthand for machine type
-cpu model                # specify CPU model
-smp [cpus=]n[,cores=cores][,threads=threads][,sockets=sockets][,maxcpus=maxcpus]
-m [size=]megs[,slots=n,maxmem=size]  # memory size
-accel kvm|xen|hax|hvf|whpx|tcg[,property=value[,...]]  # accelerator
```

## Storage Options

```
# IDE drives
-hda file            # first IDE hard disk image
-hdb file            # second IDE hard disk image
-hdc file            # third IDE hard disk image
-hdd file            # fourth IDE hard disk image

# CD/DVD drives
-cdrom file          # CD-ROM image or device

# Generic drive syntax
-drive [file=file][,if=type][,bus=n][,unit=m][,media=d][,index=i]
       [,snapshot=on|off][,cache=mode][,format=f][,discard=ignore|unmap]
       [,readonly=on|off][,aio=threads|native][,id=name][,serial=s]
```

Common interface types for `-drive if=` parameter:
- `ide`: IDE interface
- `scsi`: SCSI interface
- `sd`: SD card interface
- `mtd`: Flash memory interface
- `floppy`: Floppy disk interface
- `pflash`: Parallel flash memory
- `virtio`: VirtIO interface (recommended for best performance)
- `none`: No specific interface

## Boot Options

```
-boot [order=drives][,once=drives][,menu=on|off]
      [,splash=sp][,splash-time=st][,reboot-timeout=rt]
      [,strict=on|off]
```

Boot order characters:
- `a`, `b`: Floppy drives 1 and 2
- `c`: First hard disk
- `d`: First CD-ROM
- `n`-`p`: Etherboot from network adapters 1-4

Example: Boot from CD first, then hard disk:
```
-boot order=dc
```

## Display Options

```
-display type[,option=value[,...]]
   # Types: sdl, curses, gtk, vnc, none, etc.

-vnc display[,option[,option[,...]]]
   # VNC display
   
-spice option[,option[,...]]
   # SPICE display

-nographic           # Disable graphical output
-serial dev          # Redirect serial port to char device
-monitor dev         # Redirect monitor to char device
-vga type            # Select VGA type (std, cirrus, vmware, qxl, none)
```

## Network Options

```
-netdev type,id=name[,option[,...]]
   # Types: user, tap, bridge, socket, vde, vhost-user, hubport

-device driver,netdev=id[,mac=macaddr][,...]
   # Network device
```

Common network device drivers:
- `e1000`: Intel E1000 Gigabit Ethernet
- `rtl8139`: Realtek RTL8139 Ethernet
- `virtio-net-pci`: VirtIO network interface (best performance)

Simple user mode networking example:
```
-netdev user,id=net0 -device e1000,netdev=net0
```

## USB Options

```
-usb                 # Enable USB
-device usb-host,hostbus=bus,hostaddr=addr  # Pass through USB device
-device usb-tablet   # Add USB tablet interface (helps with mouse integration)
-device usb-kbd      # Add USB keyboard interface
```

## Other Common Options

```
-name str            # Set guest name
-uuid uuid           # Set system UUID
-rtc [base=utc|localtime][,clock=host|rt|vm][,driftfix=none|slew]
-soundhw card1[,card2,...] # Enable audio
-daemonize           # Daemonize QEMU after initialization
-readconfig file     # Read config file
-writeconfig file    # Write config file
-nodefaults          # Don't create default devices
-device driver[,prop[=value][,...]]  # Add device
-smbios type=0[,vendor=str][,version=str][,...]
```

## Common Example Commands

### Basic VM with IDE disk and CD-ROM boot:
```
qemu-system-x86_64 -m 2048 -boot d -cdrom install.iso -hda disk.qcow2
```

### VM with KVM acceleration and VirtIO disk:
```
qemu-system-x86_64 -enable-kvm -m 4096 -cpu host \
  -drive file=disk.qcow2,format=qcow2,if=virtio \
  -cdrom install.iso
```

### VM with VNC display and bridged networking:
```
qemu-system-x86_64 -m 2048 -hda disk.qcow2 \
  -netdev bridge,id=net0,br=br0 \
  -device virtio-net-pci,netdev=net0 \
  -vnc :1
```

### VM with UEFI firmware:
```
qemu-system-x86_64 -m 2048 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
  -drive if=pflash,format=raw,file=OVMF_VARS.fd \
  -hda disk.qcow2
```

### VM with multiple CPUs:
```
qemu-system-x86_64 -smp cores=4,threads=2 -m 4096 -hda disk.qcow2
```

### Start a VM with noVNC web access:
```
qemu-system-x86_64 -m 2048 -hda disk.qcow2 \
  -vnc :0 -monitor stdio
```
Then start noVNC with:
```
websockify --web=/usr/share/novnc/ 6080 localhost:5900
```

## Disk Image Management

### Create a new disk image:
```
qemu-img create -f qcow2 disk.qcow2 20G
```

### Convert between formats:
```
qemu-img convert -f raw -O qcow2 disk.raw disk.qcow2
```

### Resize an existing image:
```
qemu-img resize disk.qcow2 +10G
```

### Get information about an image:
```
qemu-img info disk.qcow2
```

### Common disk image formats:
- `raw`: Simple raw disk image format
- `qcow2`: QEMU Copy-On-Write v2 (preferred format with snapshot support)
- `vmdk`: VMware disk format
- `vdi`: VirtualBox disk format
- `vhd`: Hyper-V disk format

---

This guide covers the most commonly used QEMU commands and options. For more detailed information, refer to the official QEMU documentation or run `man qemu-system-x86_64` (or the appropriate architecture) for the complete manual.
