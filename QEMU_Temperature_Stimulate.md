# Temperature Monitoring System with QEMU ARM Emulation

A simulated temperature monitoring system running on an emulated ARM Cortex-M3 microcontroller (LM3S6965EVB) using QEMU.

## Overview

This project demonstrates how to create a temperature monitoring system using QEMU's ARM emulation capabilities. It simulates reading from a temperature sensor, processes the data, and responds with appropriate alerts and visual indicators based on temperature thresholds.

## Requirements

- ARM GCC Toolchain (`arm-none-eabi-gcc`)
- QEMU with ARM support (`qemu-system-arm`)

## Board Information
We're using the LM3S6965EVB board emulation in QEMU, which features:
- ARM Cortex-M3 CPU
- 256KB Flash memory
- 64KB SRAM
- UART, GPIO, and other peripherals

## Features

- Real-time temperature monitoring with simulated sensor data
- Status classification (Normal, Warning, Critical) based on temperature thresholds
- Visual feedback through simulated LED colors:
  - Green: Normal temperature (below 30°C)
  - Yellow: Warning temperature (30°C to 39°C)
  - Red: Critical temperature (40°C and above)
- UART output showing current temperature values and status
- Critical temperature it will alert system


## Project Structure

```
temperature-monitor/
├── temp_monitor.c      # Main source code
└── linker.ld           # This file
```

## Building the Project

## Source Code (`temp_monitor.c`)
```
#include <stdint.h>
#include <stdbool.h>

// Vector table entries
#define STACK_TOP 0x20008000

// UART registers for LM3S6965EVB
#define UART0_BASE 0x4000C000
#define UART0_DR   (*(volatile uint32_t *)(UART0_BASE + 0x000))
#define UART0_FR   (*(volatile uint32_t *)(UART0_BASE + 0x018))
#define UART0_IBRD (*(volatile uint32_t *)(UART0_BASE + 0x024))
#define UART0_FBRD (*(volatile uint32_t *)(UART0_BASE + 0x028))
#define UART0_LCRH (*(volatile uint32_t *)(UART0_BASE + 0x02C))
#define UART0_CTL  (*(volatile uint32_t *)(UART0_BASE + 0x030))

// System control
#define SYSCTL_BASE     0x400FE000
#define SYSCTL_RCGC2    (*(volatile uint32_t *)(SYSCTL_BASE + 0x108))

// GPIO registers for LEDs
#define GPIO_PORTF_BASE 0x40025000
#define GPIO_PORTF_DATA (*(volatile uint32_t *)(GPIO_PORTF_BASE + 0x3FC))
#define GPIO_PORTF_DIR  (*(volatile uint32_t *)(GPIO_PORTF_BASE + 0x400))
#define GPIO_PORTF_DEN  (*(volatile uint32_t *)(GPIO_PORTF_BASE + 0x51C))

// Temperature thresholds
#define TEMP_LOW       20
#define TEMP_HIGH      30
#define TEMP_CRITICAL  40

// System states
typedef enum {
    STATE_NORMAL,
    STATE_WARNING,
    STATE_CRITICAL
} SystemState;

// Function prototypes
void uart_init(void);
void uart_putc(char c);
void uart_puts(const char *s);
void led_init(void);
void set_led(uint8_t r, uint8_t g, uint8_t b);
uint16_t read_temperature(void);
void delay(volatile uint32_t count);
void main(void);
void int_to_str(int value, char *str);

// Global variables for simulation
volatile uint32_t simulated_temp = 25;  // Start at 25°C
volatile uint32_t temp_change_counter = 0;

// Vector table
__attribute__ ((section(".vectors")))
void (* const vector_table[])(void) = {
    (void (*)(void))STACK_TOP,  // Initial stack pointer
    main                        // Reset handler
};

// Main function
void main(void) {
    // System initialization
    uart_init();
    led_init();
    
    // Variables
    uint16_t temperature;
    SystemState current_state = STATE_NORMAL;
    SystemState previous_state = STATE_NORMAL;
    char temp_str[16];
    
    // Initial message
    uart_puts("\r\n--- Temperature Monitoring System ---\r\n");
    uart_puts("Initializing...\r\n");
    delay(1000000);
    
    // Main loop
    while (1) {
        // Read temperature
        temperature = read_temperature();
        
        // Determine system state
        if (temperature >= TEMP_CRITICAL) {
            current_state = STATE_CRITICAL;
            set_led(1, 0, 0);  // Red LED for critical
        } else if (temperature >= TEMP_HIGH) {
            current_state = STATE_WARNING;
            set_led(1, 1, 0);  // Yellow LED for warning
        } else {
            current_state = STATE_NORMAL;
            set_led(0, 1, 0);  // Green LED for normal
        }
        
        // Display temperature
        uart_puts("Temperature: ");
        int_to_str(temperature, temp_str);
        uart_puts(temp_str);
        uart_puts("C ");
        
        // Display status and take action based on state
        switch (current_state) {
            case STATE_NORMAL:
                uart_puts("[NORMAL]\r\n");
                break;
                
            case STATE_WARNING:
                uart_puts("[WARNING]\r\n");
                break;
                
            case STATE_CRITICAL:
                uart_puts("[CRITICAL ALERT!]\r\n");
                
                // If we just entered critical state, show alarm
                if (previous_state != STATE_CRITICAL) {
                    uart_puts("*** CRITICAL TEMPERATURE DETECTED! ***\r\n");
                    uart_puts("*** EMERGENCY COOLING ACTIVATED   ***\r\n");
                }
                break;
        }
        
        // Update previous state
        previous_state = current_state;
        
        // Wait before next reading
        delay(2000000);
    }
}

// Initialize UART
void uart_init(void) {
    // Enable UART0 clock
    SYSCTL_RCGC2 |= (1 << 0);
    
    // Small delay to ensure the clock is stable
    delay(10000);
    
    // Disable UART during configuration
    UART0_CTL = 0;
    
    // Configure baud rate (115200)
    UART0_IBRD = 8;    // Integer part
    UART0_FBRD = 44;   // Fractional part
    
    // 8 bits, no parity, 1 stop bit, FIFOs enabled
    UART0_LCRH = 0x70;
    
    // Enable UART, TX, and RX
    UART0_CTL = 0x301;
}

// Initialize LED
void led_init(void) {
    // Enable GPIO Port F
    SYSCTL_RCGC2 |= (1 << 5);
    
    // Small delay
    delay(10000);
    
    // Set pins 1, 2, 3 as outputs (RGB LEDs)
    GPIO_PORTF_DIR |= (1 << 1) | (1 << 2) | (1 << 3);
    GPIO_PORTF_DEN |= (1 << 1) | (1 << 2) | (1 << 3);
}

// Set LED colors (r,g,b are boolean values)
void set_led(uint8_t r, uint8_t g, uint8_t b) {
    uint32_t value = 0;
    
    if (r) value |= (1 << 1);  // Red is on PF1
    if (b) value |= (1 << 2);  // Blue is on PF2
    if (g) value |= (1 << 3);  // Green is on PF3
    
    // Update LED state
    GPIO_PORTF_DATA = value;
}

// Read temperature from simulated sensor
uint16_t read_temperature(void) {
    // Simulate temperature changes over time
    temp_change_counter++;
    
    if (temp_change_counter % 4 == 0) {
        // Every 4th reading, change temperature
        if (simulated_temp < 45) {
            simulated_temp++;
        } else {
            simulated_temp = 25;  // Reset back to normal
        }
    }
    
    // Return temperature
    return simulated_temp;
}

// Send a character over UART
void uart_putc(char c) {
    // Wait for transmit buffer to be empty
    while (UART0_FR & (1 << 5));
    
    // Send character
    UART0_DR = c;
}

// Send a string over UART
void uart_puts(const char *s) {
    while (*s) {
        uart_putc(*s++);
    }
}

// Simple delay function
void delay(volatile uint32_t count) {
    while (count--);
}

// Convert integer to string
void int_to_str(int value, char *str) {
    int i = 0;
    bool is_negative = false;
    
    // Handle 0 explicitly
    if (value == 0) {
        str[i++] = '0';
        str[i] = '\0';
        return;
    }
    
    // Handle negative numbers
    if (value < 0) {
        is_negative = true;
        value = -value;
    }
    
    // Process individual digits
    while (value != 0) {
        int rem = value % 10;
        str[i++] = rem + '0';
        value = value / 10;
    }
    
    // Add negative sign if needed
    if (is_negative) {
        str[i++] = '-';
    }
    
    str[i] = '\0'; // Null-terminate string
    
    // Reverse the string
    int start = 0;
    int end = i - 1;
    while (start < end) {
        char temp = str[start];
        str[start] = str[end];
        str[end] = temp;
        start++;
        end--;
    }
}
```

## Source Code (`linker.ld`)
```
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

### Using the Compiler Directly

```bash
# Compile the source file
arm-none-eabi-gcc -c -mcpu=cortex-m3 -mthumb -O2 -ffreestanding temp_monitor.c -o temp_monitor.o

# Link the object file
arm-none-eabi-ld -T linker.ld temp_monitor.o -o temp_monitor.elf
```

## Running in QEMU

```bash
qemu-system-arm -M lm3s6965evb -kernel temp_monitor.elf
```

## How It Works

### Temperature Simulation

The system simulates a temperature sensor by gradually increasing temperature from 25°C to 45°C and then resetting, creating a continuous temperature cycle.

### Hardware Utilized

- UART0: For console output and status messages
- GPIO Port F: For LED status indicators (simulated)
- System Control: For clock and peripheral configuration

### System States

The system defines three operational states based on temperature:

1. **Normal State** (below 30°C)
   - Green LED indicator
   - Normal operation message

2. **Warning State** (30°C to 39°C)
   - Yellow LED indicator
   - Warning message

3. **Critical State** (40°C and above)
   - Red LED indicator
   - Critical alert message
   - Emergency cooling activation message

## Example Output
![image](https://github.com/user-attachments/assets/ccea8368-06c5-47b5-a978-ec4244ec52ec)

## Acknowledgments

- ARM for the Cortex-M3 architecture
- QEMU team for providing the LM3S6965EVB emulation
