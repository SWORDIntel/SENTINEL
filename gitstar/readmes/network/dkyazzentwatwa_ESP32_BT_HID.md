# Bluetooth HID Attacks with ESP32

This project utilizes an ESP32 microcontroller to act as a Bluetooth Human Interface Device (HID) that can perform a predefined set of keyboard actions. The project includes an OLED display to provide visual feedback.

## Features

- ESP32 microcontroller
- Bluetooth HID functionality
- OLED display (SSD1306) for visual feedback
- Demonstrates a "Rick Roll" script

## Hardware Requirements

- ESP32 WROOM 32E
- SSD1306 OLED display
- Connection wires
- Protoboard (optional)

## Libraries Used

- `BleKeyboard.h`: To enable Bluetooth keyboard functionality.
- `Adafruit_GFX.h` and `Adafruit_SSD1306.h`: To control the SSD1306 OLED display.
- `U8g2_for_Adafruit_GFX.h`: To provide additional font options for the OLED display.

## Installation

1. **Install Arduino IDE**: Ensure you have the latest version of the Arduino IDE installed.
2. **Add ESP32 Board**: In the Arduino IDE, add the ESP32 board through the Board Manager.
3. **Install Libraries**: Install the required libraries through the Library Manager in the Arduino IDE.

   - `BleKeyboard`
   - `Adafruit GFX Library`
   - `Adafruit SSD1306`
   - `U8g2 for Adafruit GFX`

## Wiring

| ESP32 Pin | OLED Pin  |
|-----------|-----------|
| 3.3V      | VCC       |
| GND       | GND       |
| SDA (21)  | SDA       |
| SCL (22)  | SCL       |

## Usage

1. **Setup**: Connect the hardware according to the wiring table.
2. **Upload Code**: Upload the provided code to the ESP32 using the Arduino IDE.
3. **Power On**: Power on the ESP32. The OLED display will show the initial screen.
4. **Bluetooth Pairing**: Pair the ESP32 with your device. The ESP32 will appear as `mangocookiez`.

## Operation

Once paired, the ESP32 will run the predefined "Rick Roll" script:
- It will open the default web browser.
- Type in the Rick Roll URL: `https://youtu.be/oHg5SJYRHA0?si=bfXXjVeR5UyKoh4n`
- Press Enter to open the URL.

The OLED display will provide visual feedback throughout the process.

## Future Improvements

- Add more keyboard shortcuts and functionalities.
- Add a way to select an attack from a list on the screen.
- Integrate more input devices.
- Improve the visual interface on the OLED display.


## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## Acknowledgments

- Adafruit for their excellent libraries.
- The open-source community for their contributions.
