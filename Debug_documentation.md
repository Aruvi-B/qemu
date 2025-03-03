# QEMU Debugging Guide: From Beginner to Advanced

## Table of Contents
1. [Introduction to QEMU](#introduction-to-qemu)
2. [Getting Started](#getting-started)
3. [Basic Debugging Workflow](#basic-debugging-workflow)
4. [QEMU Command Reference](#qemu-command-reference)
5. [GDB Commands for Firmware Debugging](#gdb-commands-for-firmware-debugging)
6. [QEMU Monitor Interface](#qemu-monitor-interface)
7. [Advanced Debugging Techniques](#advanced-debugging-techniques)
8. [Troubleshooting Common Issues](#troubleshooting-common-issues)
9. [Glossary](#glossary)

## Introduction to QEMU

### What is QEMU?

QEMU (Quick Emulator) is a free and open-source software that simulates computer hardware. In simple terms, it allows your computer to pretend to be a different computer or device. This is extremely useful for testing firmware without needing the actual physical hardware.

Think of QEMU like a "virtual device" that runs on your computer. When developing for hardware like microcontrollers, QEMU lets you test your code without having to upload it to the real device each time.

### What is Firmware?

Firmware is special software that controls how hardware devices work. It's like an operating system for devices like routers, smart thermostats, or microcontrollers. Firmware typically runs directly on the hardware and provides the basic functions that make the device work.

### Why Use QEMU for Firmware Testing?

- **Cost-effective**: Test without purchasing multiple hardware devices
- **Faster development**: No need to flash firmware to physical devices for every test
- **Better debugging**: Access to powerful debugging tools not available on real hardware
- **Reproducibility**: Create consistent test environments

## Getting Started

### Installing QEMU

Before you can use QEMU, you need to install it on your computer:

**Windows:**
Download the installer from the QEMU website or use Windows Subsystem for Linux (WSL).
Using Windows Subsystem for Linux (WSL)

Install WSL by opening PowerShell as Administrator and running:
```wsl --install```

Restart your computer when prompted
Open the Ubuntu terminal that was installed
 
**Ubuntu/Debian Linux:**
```bash
sudo apt-get install qemu-system
```

**macOS:**
```bash
brew install qemu
```

### First QEMU Test

Let's start with a simple command to make sure everything is working:

```bash
qemu-system-arm -M stm32vldiscovery -kernel firmware.bin
```

This command:
- Starts the ARM version of QEMU (`qemu-system-arm`)
- Tells it to simulate an STM32F4 Discovery board (`-M stm32vldiscovery`)
- Loads your firmware file (`-kernel firmware.bin`)

If successful, a QEMU window should open showing the emulated system.

💡 **Beginner Tip**: If this command gives an error about "unsupported machine type," you can see what machine types are supported with:
```bash
qemu-system-arm -M help
```

## Basic Debugging Workflow

### Step 1: Start QEMU in Debug Mode

Start QEMU with special options that enable debugging:

```bash
qemu-system-arm -M stm32vldiscovery -kernel firmware.bin -s -S
```

What these options do:
- `-s` opens a debugging port (1234) that allows a debugger to connect
- `-S` freezes the CPU at startup until the debugger tells it to run

You'll see QEMU start, but it will appear frozen. This is normal! It's waiting for a debugger to connect.

### Step 2: Connect a Debugger (GDB)

GDB (GNU Debugger) is a powerful tool that helps you inspect what's happening inside your firmware. Open a new terminal window and run:

```bash
gdb-multiarch firmware.elf
```

Or if you have the ARM-specific version:
```bash
arm-none-eabi-gdb firmware.elf
```

Inside GDB, connect to QEMU by typing:
```
target remote localhost:1234
```

💡 **Beginner Tip**: The `.elf` file contains your firmware plus extra information that helps GDB understand it better, like function names and variables.

### Step 3: Basic Debugging Commands

Now you can control the execution of your firmware using GDB commands:

| Command | What It Does | Example |
|---------|-------------|---------|
| `continue` or `c` | Start/resume running the firmware | `c` |
| `break main` | Set a stopping point at the main function | `break main` |
| `break *0x08000500` | Set a stopping point at a specific memory address | `break *0x08000500` |
| `step` or `s` | Execute one line of code, following into functions | `s` |
| `next` or `n` | Execute one line of code, skipping over function calls | `n` |
| `print variable_name` | Show the value of a variable | `print counter` |
| `print/x $r0` | Show the value of the r0 register in hexadecimal | `print/x $r0` |
| `info registers` | Show all CPU registers | `info registers` |
| `quit` or `q` | Exit GDB | `q` |

Example debugging session:
```
(gdb) target remote localhost:1234
(gdb) break main
(gdb) continue
(gdb) next
(gdb) print counter
$1 = 42
(gdb) quit
```

## QEMU Command Reference

### Basic QEMU Options

| Option | Description | Example |
|--------|-------------|---------|
| `-M machine` | Specify the machine type to emulate | `-M stm32vldiscovery` |
| `-kernel file` | Use file as kernel image | `-kernel firmware.bin` |
| `-s` | Start a GDB server on TCP port 1234 | `-s` |
| `-S` | Freeze CPU at startup | `-S` |
| `-nographic` | Run without graphical output | `-nographic` |
| `-serial stdio` | Redirect serial port to terminal | `-serial stdio` |
| `-monitor stdio` | Redirect monitor to terminal | `-monitor stdio` |

### Debug-Specific Options

| Option | Description | Example |
|--------|-------------|---------|
| `-d items` | Enable debug output (comma-separated list) | `-d in_asm,cpu` |
| `-D file` | Save debug output to file | `-D trace.log` |
| `-gdb tcp::port` | Start GDB server on specified port | `-gdb tcp::5555` |
| `-semihosting` | Enable semihosting (ARM-specific feature for I/O) | `-semihosting` |

### Common Debug Items for `-d` Option

| Item | What It Shows | Technical Details |
|------|--------------|-------------------|
| `in_asm` | The instructions being executed | Logs disassembled instructions as they're executed |
| `out_asm` | Generated code | Shows translated code blocks |
| `cpu` | CPU state changes | Logs when registers are modified |
| `int` | Interrupts | Shows interrupt entry and exit |
| `guest_errors` | Errors in the emulated system | Hardware exceptions and faults |
| `page` | Memory management | Page allocations and translations |

Example with multiple debug options:
```bash
qemu-system-arm -d in_asm,cpu -D trace.log -M stm32vldiscovery -kernel firmware.bin
```

This saves a detailed log of executed instructions and CPU state changes to `trace.log`.

## GDB Commands for Firmware Debugging

### Controlling Execution

| Command | Description | Example |
|---------|-------------|---------|
| `target remote host:port` | Connect to QEMU | `target remote localhost:1234` |
| `load` | Load program into emulator memory | `load` |
| `continue` or `c` | Continue execution | `c` |
| `step` or `s` | Step one source line, entering functions | `s` |
| `next` or `n` | Step one source line, stepping over functions | `n` |
| `stepi` or `si` | Step one assembly instruction | `si` |
| `finish` | Run until current function returns | `finish` |
| `until location` | Run until specified location | `until 45` (line 45) |

### Breakpoints and Watchpoints

| Command | Description | Example |
|---------|-------------|---------|
| `break location` | Set a breakpoint | `break main` |
| `watch expression` | Stop when expression changes | `watch counter` |
| `rwatch expression` | Stop when expression is read | `rwatch *0x20000100` |
| `awatch expression` | Stop when expression is read or written | `awatch *0x20000100` |
| `info breakpoints` | List breakpoints | `info breakpoints` |
| `delete num` | Delete breakpoint number | `delete 2` |
| `disable num` | Disable breakpoint | `disable 1` |
| `enable num` | Enable breakpoint | `enable 1` |

### Examining Memory and Registers

| Command | Description | Example |
|---------|-------------|---------|
| `info registers` | Show all registers | `info registers` |
| `print expression` | Evaluate and print expression | `print counter` |
| `x/NFU addr` | Examine memory at address | `x/10wx 0x20000000` |
| `info variables` | Show all global/static variables | `info variables` |
| `info locals` | Show local variables | `info locals` |
| `ptype variable` | Show type of variable | `ptype counter` |

For the `x` command format:
- N = number of units to display
- F = display format (x=hex, d=decimal, s=string, i=instruction)
- U = unit size (b=byte, h=halfword, w=word, g=giant word)

Example: `x/10xw 0x20000000` shows 10 words at address 0x20000000 in hexadecimal format.

### Backtrace and Frame Navigation

| Command | Description | Example |
|---------|-------------|---------|
| `backtrace` or `bt` | Show call stack | `bt` |
| `frame n` | Select frame number n | `frame 2` |
| `up` | Move up one frame | `up` |
| `down` | Move down one frame | `down` |
| `info frame` | Info about current frame | `info frame` |

## QEMU Monitor Interface

The QEMU monitor is a control interface for the emulator itself. It allows you to inspect and manipulate the virtual hardware while it's running.

### Accessing the Monitor

There are two main ways to access the monitor:

1. **Default method**: Press `Ctrl+Alt+2` during emulation (use `Ctrl+Alt+1` to return to the main display)

2. **Command line method**: Start QEMU with the monitor attached to your terminal:
   ```bash
   qemu-system-arm -M stm32vldiscovery -kernel firmware.bin -monitor stdio
   ```

### Basic Monitor Commands

| Command | What It Does | Example |
|---------|-------------|---------|
| `help` or `?` | Show help message | `help` |
| `info registers` | Show CPU registers | `info registers` |
| `system_reset` | Reset the virtual machine | `system_reset` |
| `quit` or `q` | Exit QEMU | `quit` |
| `stop` | Pause emulation | `stop` |
| `cont` | Continue emulation | `cont` |

### Memory Commands

| Command | What It Does | Example |
|---------|-------------|---------|
| `xp /FMT ADDR` | Examine physical memory | `xp /10xw 0x20000000` |
| `memsave ADDR SIZE FILE` | Save memory to file | `memsave 0x20000000 1024 dump.bin` |

### System Information Commands

| Command | What It Does | Example |
|---------|-------------|---------|
| `info mtree` | Show memory tree | `info mtree` |
| `info tlb` | Show translation lookaside buffer | `info tlb` |
| `info cpus` | Show CPUs | `info cpus` |
| `info block` | Show block devices | `info block` |
| `info network` | Show network status | `info network` |
| `info usb` | Show USB devices | `info usb` |
| `info qtree` | Show device tree | `info qtree` |

### Snapshot Commands

| Command | What It Does | Example |
|---------|-------------|---------|
| `savevm NAME` | Save a virtual machine snapshot | `savevm my_checkpoint` |
| `loadvm NAME` | Restore a virtual machine snapshot | `loadvm my_checkpoint` |
| `info snapshots` | List available snapshots | `info snapshots` |

💡 **Beginner Tip**: Think of snapshots like save points in a video game. They let you experiment and easily return to a previous state.

## Advanced Debugging Techniques

### Memory Watchpoints

Watchpoints are special breakpoints that trigger when a memory address is accessed. They're extremely useful for tracking down bugs where memory is being corrupted.

**In GDB:**
```
(gdb) watch *0x20000100
(gdb) rwatch *0x20000100  # Breaks when read
(gdb) awatch *0x20000100  # Breaks when read or written
```

### Instruction Tracing

To understand exactly what your firmware is doing, you can log every instruction:

```bash
qemu-system-arm -d in_asm -D trace.log -M stm32vldiscovery -kernel firmware.bin
```

The resulting `trace.log` file will contain a detailed record of every instruction executed.

### Semihosting

Semihosting allows firmware running in QEMU to use features of your host computer, like file operations and printing to the console. This makes debugging much easier.

1. Start QEMU with semihosting enabled:
   ```bash
   qemu-system-arm -M stm32vldiscovery -kernel firmware.bin -semihosting
   ```

2. In your firmware code:
   ```c
   #include <stdio.h>
   extern void initialise_monitor_handles(void);
   
   int main(void) {
       initialise_monitor_handles();  // Initialize semihosting
       printf("Hello from firmware!\n");
       // ...
   }
   ```

### Fault Injection Testing

To test how robust your firmware is, you can simulate hardware faults:

```bash
qemu-system-arm -d guest_errors -M stm32vldiscovery -kernel firmware.bin
```

Then use the QEMU monitor to manipulate hardware state, like corrupting memory or triggering interrupts.

### Dynamic Binary Instrumentation

For the most advanced analysis, you can use QEMU plugins to instrument code:

1. Create a plugin file (my_plugin.c):
   ```c
   #include <stdio.h>
   #include <glib.h>
   #include "qemu/plugin.h"

   static void vcpu_insn_exec(unsigned int cpu_index, void *udata) {
       printf("Executing instruction on CPU %d\n", cpu_index);
   }

   QEMU_PLUGIN_EXPORT int qemu_plugin_install(qemu_plugin_id_t id,
                                           const qemu_info_t *info,
                                           int argc, char **argv) {
       qemu_plugin_register_vcpu_insn_exec_cb(id, vcpu_insn_exec, 
                                             QEMU_PLUGIN_CB_NO_REGS, NULL);
       return 0;
   }
   ```

2. Build plugin:
   ```bash
   gcc -fPIC -shared -o my_plugin.so my_plugin.c $(pkg-config --cflags glib-2.0)
   ```

3. Run QEMU with plugin:
   ```bash
   qemu-system-arm -plugin ./my_plugin.so -M stm32vldiscovery -kernel firmware.bin
   ```

💡 **Technical Note**: This requires building QEMU with plugin support.

## Troubleshooting Common Issues

### Problem: "Command not found" errors

**Symptoms:** You see error messages like `arm-none-eabi-gdb: command not found`

**Solutions:**
- Install the missing tools:
  ```bash
  sudo apt install gdb-multiarch
  ```
- For ARM tools specifically:
  ```bash
  sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi
  ```
- If not available in your package manager, download from ARM's website

### Problem: QEMU says "unsupported machine type"

**Symptoms:** Error message: `qemu-system-arm: unsupported machine type`

**Solutions:**
- Check available machine types:
  ```bash
  qemu-system-arm -machine help
  ```
- Use a machine type that's in the list
- For STM32, try alternatives like `stm32vldiscovery` or `stm32-p103`
- For generic ARM testing, use `virt`

### Problem: Can't connect GDB to QEMU

**Symptoms:** GDB shows `Connection refused` or times out

**Solutions:**
- Ensure QEMU is running with `-s -S` or `-gdb tcp::PORT`
- Check if another process is using port 1234
- If using a firewall, ensure the port is open
- Try a different port:
  ```bash
  qemu-system-arm -M stm32vldiscovery -kernel firmware.bin -gdb tcp::5555 -S
  ```
  And in GDB:
  ```
  target remote localhost:5555
  ```

### Problem: Firmware works on real hardware but not in QEMU

**Symptoms:** Firmware behavior differs between real hardware and QEMU

**Solutions:**
- QEMU may not implement all hardware features perfectly
- Check if you're using peripherals not supported in QEMU
- Modify firmware to handle hardware differences
- Look for QEMU-specific workarounds or patches

## Glossary

| Term | Definition |
|------|------------|
| **Breakpoint** | A marker that tells the debugger to pause at a specific point in code |
| **Emulation** | Using software to mimic the behavior of hardware |
| **Firmware** | Software that controls hardware devices |
| **GDB** | GNU Debugger, a tool for analyzing and debugging programs |
| **Memory address** | A number that identifies a specific location in memory |
| **Monitor** | QEMU's control panel for managing the emulated system |
| **Port** | A communication channel used for network connections |
| **Register** | A small storage location inside the CPU |
| **Semihosting** | A technique allowing emulated programs to use host computer features |
| **Watchpoint** | A debugging tool that stops execution when memory is accessed |
