# Embedded Linux QEMU Project

This repository contains structured documentation for building and running an embedded Linux system on QEMU. The project involves creating kernel images, root filesystems, and bootloader images, customizing QEMU machine tools, and testing software before deploying to real hardware.

## Documentation

For detailed instructions and guidelines, refer to the [QEMU User Documentation](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/821395464/QEMU+User+Documentation).

## README File Contents

### 1. Kernel Image Creation
**Path:** `/1_Kernel_Image_Creation/README.md`
**Contents:**
- Steps for compiling the Linux kernel (make zImage, bzImage, uImage)
- Configuring the kernel with `menuconfig`
- Compiling the device tree (`dtc -O dtb -o myboard.dtb myboard.dts`)

### 2. Root Filesystem
**Path:** `/2_Root_Filesystem/README.md`
**Contents:**
- Creating RootFS using Buildroot or Yocto
- Filesystem formats: ext4, squashfs, initramfs

### 3. Bootloader (U-Boot)
**Path:** `/3_Bootloader/README.md`
**Contents:**
- Building U-Boot (`make u-boot.bin`)
- Setting up the U-Boot environment for kernel boot

### 4. Cross-Compilation
**Path:** `/4_Cross_Compilation/README.md`
**Contents:**
- Using GCC cross-toolchain (`arm-linux-gnueabi-gcc`)
- Compiling kernel and RootFS for different architectures

### 5. Final Image Packaging
**Path:** `/5_Final_Image_Packaging/README.md`
**Contents:**
- Combining kernel, rootfs, and bootloader
- Using `mkimage` for U-Boot

### 6. QEMU Setup
**Path:** `/6_QEMU_Setup/README.md`
**Contents:**
- Installing and configuring QEMU
- Selecting the target architecture (`qemu-system-arm`, `qemu-system-riscv64`)
- Setting up hardware configurations (`-M versatilepb`, `-cpu cortex-a9`)

### 7. Testing and Debugging
**Path:** `/7_Testing_and_Debugging/README.md`
**Contents:**
- Running Linux in QEMU
- Debugging with GDB and serial console
- Checking logs and troubleshooting

### 8. Deployment to Real Hardware
**Path:** `/8_Deployment_to_Real_Hardware/README.md`
**Contents:**
- Flashing images to physical hardware
- Running the embedded system on STM32 or Raspberry Pi
