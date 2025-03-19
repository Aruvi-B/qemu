# Setting Up a Virtual Machine with QEMU

## Overview
This document provides a step-by-step guide on how to set up and run a virtual machine using QEMU with specific configurations.

## Prerequisites
- QEMU installed on your system
- A disk image file (`mydisk.qcow2`)
- An ISO file for installation (`ubuntu.iso`)
- Basic knowledge of virtual machines and command-line operations

## Command Explanation
The following command sets up and runs a virtual machine using QEMU with various configurations:

Create the mydisk.img
```
qemu-img create -f qcow2 mydisk.img 20
```

Donwload the ISO [Ubuntu](https://ubuntu.com/download/desktop)

Command to Open the QEMU-VM
```bash
qemu-system-x86_64 -machine type=q35,accel=kvm -cpu host -smp 4 -m 12G -drive file=mydisk.qcow2,format=qcow2,if=virtio -cdrom ubuntu.iso -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22 -device ich9-intel-hda -device hda-duplex -device qemu-xhci -device usb-tablet -vga virtio
```

### Command Breakdown
- `qemu-system-x86_64`: Launches QEMU to emulate a 64-bit x86 architecture.
- `-machine type=q35,accel=kvm`: Specifies the machine type as `q35` and uses KVM for hardware acceleration.
- `-cpu host`: Uses the host's CPU model for the virtual machine.
- `-smp 4`: Allocates 4 CPU cores to the virtual machine.
- `-m 12G`: Allocates 12GB of RAM to the virtual machine.
- `-drive file=mydisk.qcow2,format=qcow2,if=virtio`: Specifies the disk image file (`mydisk.qcow2`) with the `qcow2` format and uses the `virtio` interface for better performance.
- `-cdrom ubuntu.iso`: Specifies the installation ISO file.
- `-device virtio-net-pci,netdev=net0`: Adds a `virtio` network device.
- `-netdev user,id=net0,hostfwd=tcp::2222-:22`: Sets up user-mode networking with port forwarding from host port 2222 to guest port 22 (SSH).
- `-device ich9-intel-hda`: Adds an Intel High Definition Audio device.
- `-device hda-duplex`: Adds a duplex HDA audio codec.
- `-device qemu-xhci`: Adds a USB 3.0 controller.
- `-device usb-tablet`: Adds a USB tablet device for better mouse integration.
- `-vga virtio`: Uses the `virtio` VGA device for better graphical performance.

## Running the Command
1. Open a terminal.
2. Navigate to the directory containing your disk image and ISO file.
3. Run the following command:

```bash
qemu-system-x86_64 -machine type=q35,accel=kvm -cpu host -smp 4 -m 12G -drive file=mydisk.qcow2,format=qcow2,if=virtio -cdrom ubuntu.iso -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2222-:22 -device ich9-intel-hda -device hda-duplex -device qemu-xhci -device usb-tablet -vga virtio
```

4. The virtual machine should start, booting from the specified ISO file.

## Conclusion
This document provides a comprehensive guide to setting up and running a virtual machine with QEMU using specific configurations. By following the steps outlined, you can successfully create and manage a virtual machine tailored to your requirements.
