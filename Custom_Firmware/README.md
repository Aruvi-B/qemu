# Custom Firmware for Arduino

This repository contains custom firmware for Arduino projects. The main objective of this firmware is to modify the functionality of digital pin 7 to act as a PWM digital pin.

## Folder Structure

```
/D:/Arduino - Access/Custom_Firmware/
│
├── src/
│   ├── main.ino
│   └── pin_config.h
│
├── lib/
│   └── custom_pwm/
│       ├── custom_pwm.cpp
│       └── custom_pwm.h
│
├── README.md
└── LICENSE
```

## Modifying Digital Pin 7 to PWM

To modify digital pin 7 to function as a PWM digital pin, follow these steps:

1. **Edit `pin_config.h`**:
    - Define pin 7 as a PWM pin.

    ```cpp
    #define PWM_PIN 7
    ```

2. **Implement PWM functionality in `custom_pwm.cpp`**:
    - Write the necessary code to initialize and control PWM on pin 7.

    ```cpp
    #include "custom_pwm.h"

    void setupPWM() {
        pinMode(PWM_PIN, OUTPUT);
        // Additional setup code for PWM
    }

    void setPWMDutyCycle(int dutyCycle) {
        analogWrite(PWM_PIN, dutyCycle);
    }
    ```

3. **Include and use the PWM library in `main.ino`**:
    - Initialize and use the PWM functionality.

    ```cpp
    #include "pin_config.h"
    #include "custom_pwm/custom_pwm.h"

    void setup() {
        setupPWM();
    }

    void loop() {
        // Example usage: Set PWM duty cycle to 128 (50%)
        setPWMDutyCycle(128);
        delay(1000);
    }
    ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.