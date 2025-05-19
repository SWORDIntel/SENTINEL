# Handshaker

Handshaker is a Windows batch script designed for capturing Wi-Fi handshakes through a deauthentication attack. This tool automates the process of capturing handshake packets, making it easier for penetration testers and security researchers to assess the security of Wi-Fi networks.

## Features

- Automated Wi-Fi handshake capture.
- Deauthentication attack to force client devices to reconnect and generate handshakes.
- Easy-to-use batch script interface.
- Customizable settings for target network parameters.

## Requirements

- **Windows Operating System**: Handshaker is specifically designed for Windows.
- **Two Network Adapters**: Handshaker requires two network adapters, one of which must support packet capture and monitor mode. This adapter is used for capturing Wi-Fi traffic and performing the deauthentication attack. The second adapter is used for internet connectivity and general network communication.
- **Wireshark**: Wireshark must be installed and added to the system PATH to utilize the packet capture functionality.

## Usage

1. Ensure that your system meets the requirements specified above.
2. Download or clone the Handshaker repository to your local machine.
3. Run the `handshaker.bat` script with administrative privileges.
4. Follow the on-screen prompts to select the appropriate network adapters and target Wi-Fi network.
5. Handshaker will automatically initiate the deauthentication attack and capture Wi-Fi handshakes.

## Rogue Access Point Setup

To create a rogue access point with the SSID of the target network, Handshaker utilizes two additional batch scripts: `ap.bat` and `f.bat`. These scripts are responsible for spawning the rogue access point and initiating the deauthentication attack, respectively.

### `ap.bat`

This script sets up the rogue access point with a randomly generated SSID and starts the hosted network.

### `f.bat`

This script performs the deauthentication attack on the target network, forcing client devices to disconnect and attempt to reconnect to the rogue access point.

**Note**: Ensure that the appropriate network adapter is selected and configured for monitor mode before running these scripts.

## Disclaimer

Usage of Handshaker for capturing Wi-Fi handshakes without explicit permission from the network owner may be illegal in some jurisdictions. It is your responsibility to ensure compliance with local laws and regulations before using this tool.

Please note that Windows driver support for network adapters with monitor mode capability can be glitchy and may not work well with certain programs, including Handshaker. Compatibility issues may arise, and users should be aware of potential limitations when using this tool.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

