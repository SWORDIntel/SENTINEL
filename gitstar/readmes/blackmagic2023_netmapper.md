# NetMapper

NetMapper is a Python script that scans the local network for connected devices and provides information such as IP address, MAC address, and vendor details. It can be used for network reconnaissance and OSINT (Open-Source Intelligence) purposes.

## Features

- Automatically detects the local network range based on the current network configuration.
- Scans the network for connected devices using ARP (Address Resolution Protocol).
- Retrieves device information including IP address, MAC address, and vendor details.
- Outputs the scan results in a formatted table.

## Usage

1. Clone the repository or download the `netmapper.py` file to your local machine.

2. Install the required dependencies:
   ```bash
   pip install scapy netifaces
   ```
3. Run the script using Python:
   ```bash
   python3 netmapper.py
   ```
4. The script will automatically detect the local network range and scan for connected devices.

# Modifying the Code

- If you need to modify the code, you can do so by opening the `netmapper.py` file in a text editor or IDE of your choice. Here are some areas you might want to customize:

- Network interface: By default, the script uses the `eth0` interface. If your system uses a different interface, you can modify the `get_local_ip()` and `get_subnet_mask()` functions to retrieve the correct network information.

- Output formatting: You can customize the output format by modifying the `print_results()` function. For example, you can add additional information or change the formatting of the printed results.

- Error handling: The script includes basic error handling for retrieving network information. You can extend this error handling or add additional error checks as needed.

# Contributing

Contributions to NetMapper are welcome! If you encounter any issues or have suggestions for improvements, feel free to open an issue or submit a pull request on GitHub.
License

## NetMapper is licensed under the MIT License.





