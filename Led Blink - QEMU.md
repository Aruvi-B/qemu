# LED Blinking on ARM Cortex-M3 with QEMU

## Overview
This document outlines how to create and run a simulated LED blinking program on an emulated ARM Cortex-M3 microcontroller using QEMU.

## Prerequisites
- QEMU installed with ARM support
- ARM GCC toolchain (arm-none-eabi-gcc)
- Basic knowledge of C programming

## Board Information
We're using the LM3S6965EVB board emulation in QEMU, which features:
- ARM Cortex-M3 CPU
- 256KB Flash memory
- 64KB SRAM
- UART, GPIO, and other peripherals

## Project Structure
```
project/
├── main.c     # Main source code
└── linker.ld      # Linker script
```

## Source Code (`main.c`)
```c
#include <stdint.h>

// Vector table entries
#define STACK_TOP 0x20008000

// UART registers
#define UART0_BASE 0x4000C000
#define UART0_DR   (*((volatile uint32_t *)(UART0_BASE + 0x000)))
#define UART0_FR   (*((volatile uint32_t *)(UART0_BASE + 0x018)))
#define UART0_IBRD (*((volatile uint32_t *)(UART0_BASE + 0x024)))
#define UART0_FBRD (*((volatile uint32_t *)(UART0_BASE + 0x028)))
#define UART0_LCRH (*((volatile uint32_t *)(UART0_BASE + 0x02C)))
#define UART0_CTL  (*((volatile uint32_t *)(UART0_BASE + 0x030)))

// GPIO registers
#define GPIO_PORTF_BASE 0x40025000
#define GPIO_PORTF_DATA (*((volatile uint32_t *)(GPIO_PORTF_BASE + 0x3FC)))
#define GPIO_PORTF_DIR  (*((volatile uint32_t *)(GPIO_PORTF_BASE + 0x400)))
#define GPIO_PORTF_DEN  (*((volatile uint32_t *)(GPIO_PORTF_BASE + 0x51C)))

// System control
#define SYSCTL_BASE     0x400FE000
#define SYSCTL_RCGC2    (*((volatile uint32_t *)(SYSCTL_BASE + 0x108)))

// Function declarations
void uart_init(void);
void uart_putc(char c);
void uart_puts(const char *s);
void delay(int count);
void main(void);

// Vector table
__attribute__ ((section(".vectors")))
void (* const vector_table[])(void) = {
    (void (*)(void))STACK_TOP,  // Initial stack pointer
    main                        // Reset handler
};

// Main entry point
void main(void) {
    // Enable UART0 and GPIO Port F
    SYSCTL_RCGC2 |= 0x21;  // Enable UART0 and GPIO Port F clocks
    
    // Small delay to ensure the clocks are stable
    delay(10000);
    
    // Configure UART
    uart_init();
    
    // Configure LED (PF0)
    GPIO_PORTF_DIR |= 0x01;  // Set PF0 as output
    GPIO_PORTF_DEN |= 0x01;  // Enable digital function on PF0
    
    uart_puts("LED Blinking Program Started\r\n");
    uart_puts("---------------------------\r\n");
    
    // Blink LED forever
    while (1) {
        // Turn LED on
        GPIO_PORTF_DATA |= 0x01;
        uart_puts("LED ON\r\n");
        delay(2000000);
        
        // Turn LED off
        GPIO_PORTF_DATA &= ~0x01;
        uart_puts("LED OFF\r\n");
        delay(2000000);
    }
}

// Initialize UART
void uart_init(void) {
    // Disable UART while configuring
    UART0_CTL = 0;
    
    // Configure baud rate (115200)
    UART0_IBRD = 8;
    UART0_FBRD = 44;
    
    // 8 bits, no parity, 1 stop bit, FIFOs enabled
    UART0_LCRH = 0x70;
    
    // Enable UART, TX, and RX
    UART0_CTL = 0x301;
}

// Send character to UART
void uart_putc(char c) {
    // Wait until there's space in the FIFO
    while (UART0_FR & 0x20);
    
    // Write the character
    UART0_DR = c;
}

// Send string to UART
void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

// Simple delay
void delay(int count) {
    while (count--);
}
```

## Linker Script (`linker.ld`)
```ld
MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 256K
    SRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 64K
}

SECTIONS
{
    .vectors :
    {
        *(.vectors)
    } > FLASH

    .text :
    {
        *(.text*)
        *(.rodata*)
    } > FLASH

    .data :
    {
        *(.data*)
    } > SRAM AT > FLASH

    .bss :
    {
        *(.bss*)
        *(COMMON)
    } > SRAM
}
```

## Compilation and Linking
```bash
arm-none-eabi-gcc -c -mcpu=cortex-m3 -mthumb -O2 -ffreestanding main.c -o main.o
arm-none-eabi-ld -T linker.ld main.o -o firmware.elf
arm-none-eabi-objcopy -O binary firmware.elf firmware.bin
```

## Running the Program
```bash
qemu-system-arm -M lm3s6965evb -kernel firmware.elf
```

This command will run the program in QEMU, and you should see UART output in your terminal indicating the status of the LED.

## Conclusion
This project demonstrates how to create and run a simple LED blinking program on an emulated ARM Cortex-M3 using QEMU. With the provided source code and linker script, you can compile, link, and run the program to observe the simulated LED behavior and UART output.
