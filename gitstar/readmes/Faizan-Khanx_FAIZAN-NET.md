
# FAIZAN NET - Subnet Calculation & Network Information Tool

**FAIZAN NET** is a powerful network tool designed to help network administrators, engineers, and enthusiasts calculate and visualize subnets for both IPv4 and IPv6 addresses. It offers functionality for checking host statuses, scanning for open ports, and identifying operating systems. The tool also allows exporting results in CSV or JSON format for further analysis or reporting.

## Features

- **Subnet Calculation**: Calculate detailed information for both IPv4 and IPv6 networks, including netmask, CIDR, broadcast address, and host range.
- **Host Status Check**: Detect if hosts within the subnet are "UP" (online) or "DOWN" (offline).
- **Port Scanning & OS Detection**: scan hosts for open ports and identify operating systems.
- **Visualization**: Provide visual representations of subnets, showing binary representations of IP addresses, network addresses, and netmask.
- **Export Data**: Export calculated subnet details to CSV or JSON format for easy sharing and further processing.
- **Class-Based Subnet Classification**: Automatically classify subnets as Class A, B, C, D, or E for IPv4 networks.
- **CIDR Notation Support**: Support for both IPv4 and IPv6 CIDR notation. FAIZAN NET allows you to calculate subnets and provide network information for both IP versions.
- **Visual Representation**: Get a binary representation of the network and detailed host information, including IP range and netmask.
- **Command-line Interface (CLI)**: Simple and user-friendly interface for easy input and output.

## Installation

To use Faizan Net, you need Python 3.x installed on your system. Additionally, the tool depends on the following libraries:

- `nmap` (for port scanning and OS detection)

### Install Required Dependencies

```bash
pip install python-nmap
```

```
git clone https://github.com/Faizan-Khanx/Faizan-Net.git
cd Faizan-Net
pip install -r requirements.txt
sudo python3 FaizanNet.py
```

## Usage

Faizan Net is a command-line tool. You can use various command-line options to calculate and export subnet details or scan hosts in the subnet. The script also supports both IPv4 and IPv6.

### Example Usage

1. **Calculate Subnet for IPv4 Address And Visualize an IPv4 Subnet with Host Status and Port Scanning**:

    ```bash
   sudo python FaizanNet.py 
    ```
      Run This Command And Choose 1 To Calculate Subnet For IPv4 Address

     ![menu](https://github.com/user-attachments/assets/412e6cb9-4694-4196-9b48-dbb265a2032b)

2. **Calculate Subnet for IPv6 Address**

    ```bash
    sudo python FaizanNet.py -
    ```
    Run This Command And Choose 2 To Calculate Subnet For IPv6 Address
  
    ![menu](https://github.com/user-attachments/assets/412e6cb9-4694-4196-9b48-dbb265a2032b)

## Output Details

When you run SubnetWizard, you get detailed subnet information displayed in a structured manner, including:

- **IP Address**: The starting IP of the subnet.
- **Netmask**: The subnet mask associated with the given IP.
- **CIDR Notation**: The CIDR (Classless Inter-Domain Routing) representation of the subnet.
- **Broadcast Address**: The broadcast address for the network.
- **Host Range**: The range of hosts within the subnet.
- **Host Status**: Whether each host is "UP" or "DOWN".
- **Port Information**: Open ports on each host.
- **Operating System Information**: Detected OS for each host (if available).

### Export Options For IPv4

- **CSV**: Export subnet For IPv4  details to a CSV file.
  
After Scan Done It will ask you for exporting the data if you want to export then press 'yes' or 'y'

After This It Will Ask You For Format press '1' to export in CSV
    This will create a `FaizanNetV4.csv` file containing all subnet details.

- **JSON**: Export subnet For IPv4  details to a JSON file for structured data storage.
  
  After Scan Done It will ask you for exporting the data if you want to export then press 'yes' or 'y'

After This It Will Ask You For Format press '2' to export in JSON

    This will create a `FaizanNetV4.json` file containing all subnet details.

  ### Export Options For IPv6

- **CSV**: Export subnet For IPv6  details to a CSV file.
  
After Scan Done It will ask you for exporting the data if you want to export then press 'yes' or 'y'

After This It Will Ask You For Format press '1' to export in CSV
    This will create a `FaizanNetV6.csv` file containing all subnet details.

- **JSON**: Export subnet For IPv6  details to a JSON file for structured data storage.
  
  After Scan Done It will ask you for exporting the data if you want to export then press 'yes' or 'y'

After This It Will Ask You For Format press '2' to export in JSON

    This will create a `FaizanNetV6.json` file containing all subnet details.

## Visual Representation

FaizanNet provides a detailed visual output for each host in the subnet. This includes:

- **Host IP Address**
- **Binary Representation of Host, Network, and Netmask**
- **Host Status** (colored as green for "UP" and red for "DOWN")
- **Open Ports** (if any)
- **OS Information** (detected OS)

### IPv4 Subnet Visualization Example

```
Host               | Binary Representation                    | Status  | Network Binary                           | Netmask Binary                           | Ports                     | OS Info                  
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
144.76.3.1         | 10010000.01001100.00000011.00000001      | UP      | 10010000.01001100.00000011.00000000      | 11111111.11111111.11111111.10000000      | 21                        | Unknown                  
144.76.3.2         | 10010000.01001100.00000011.00000010      | UP      | 10010000.01001100.00000011.00000000      | 11111111.11111111.11111111.10000000      | 21, 22                    | Unknown                  
144.76.3.3         | 10010000.01001100.00000011.00000011      | UP      | 10010000.01001100.00000011.00000000      | 11111111.11111111.11111111.10000000      | 21, 22, 80, 443           | Unknown                  
144.76.3.4         | 10010000.01001100.00000011.00000100      | UP      | 10010000.01001100.00000011.00000000      | 11111111.11111111.11111111.10000000      | 21                        | Unknown                  
144.76.3.5         | 10010000.01001100.00000011.00000101      | UP      | 10010000.01001100.00000011.00000000      | 11111111.11111111.11111111.10000000      | 21, 7070                  | Unknown                  
144.76.3.6         | 10010000.01001100.00000011.00000110      | UP      | 10010000.01001100.00000011.00000000      | 11111111.11111111.11111111.10000000      | 21, 22, 80, 443, 5432     | Unknown                  
144.76.3.7         | 10010000.01001100.00000011.00000111      | UP      | 10010000.01001100.00000011.00000000      | 11111111.11111111.11111111.10000000      | 21, 22, 53, 80, 443, 1500 | Unknown                  
144.76.3.8         | 10010000.01001100.00000011.00001000      | UP      | 10010000.01001100.00000011.00000000      | 11111111.11111111.11111111.10000000      | 21                        | Unknown                  
144.76.3.9         | 10010000.01001100.00000011.00001001      | UP      | 10010000.01001100.00000011.00000000      | 11111111.11111111.11111111.10000000      | 21, 22, 80, 443, 993      | Unknown                  
```

## Screenshots

### IPv4 Subnet Visualization

![v4](https://github.com/user-attachments/assets/c05f0832-f0ac-444c-a7c5-8568a8a78b4a)

### IPv6 Subnet Visualization

![V6](https://github.com/user-attachments/assets/a137d291-f703-45ac-8ea2-d70ae6b4364b)

### Scan Visualization
![v44](https://github.com/user-attachments/assets/da5a30eb-5242-4705-a30b-4576f6f5b530)

### Exported Data Example (CSV)

![V6csv](https://github.com/user-attachments/assets/dc8c3ee5-0863-49ef-8c6b-95d3701c77b8)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

FAIZAN-NET is developed by **Faizan Khan**.

- **GitHub**: [Faizan-Khanx](https://github.com/Faizan-Khanx)
- **Instagram**: [@EthicalFaizan](https://instagram.com/EthicalFaizan)

Feel free to contribute to this project or suggest improvements by raising issues or pull requests on GitHub.

## Contact

For any questions or feedback, please contact [E-Mail Me](mailto:fk776794@gmail.com?subject=Feedback%20on%20Faizan%20Net&body=Hello%20Faizan,%0A%0AI%20have%20some%20feedback%20to%20share%20about%20your%20Faizan%20Net%20tool.%0A%0A%2D%20Issue%2FComplaint%3A%20[Please%20describe%20the%20issue%20or%20complaint]%0A%2D%20Suggestions%2FChanges%3A%20[Please%20provide%20your%20suggestions%20or%20changes]%0A%0AThank%20you!%0A%0ARegards,%0A[Your%20Name])

<!-- display the social media buttons in your README -->

[![instagram](https://github.com/shikhar1020jais1/Git-Social/blob/master/Icons/Instagram.png (Instagram))][2]
[![twitter](https://github.com/shikhar1020jais1/Git-Social/blob/master/Icons/Twitter.png (Twitter))][3]
[![linkedin](https://github.com/shikhar1020jais1/Git-Social/blob/master/Icons/LinkedIn.png (LinkedIn))][4]
[![github](https://github.com/shikhar1020jais1/Git-Social/blob/master/Icons/Github.png (Github))][5]

<!-- To Link your profile to the media buttons -->

[2]: https://www.instagram.com/EthicalFaizan
[3]: https://www.twitter.com/EthicalFaizan
[4]: https://www.linkedin.com/in/EthicalFaizan
[5]: https://www.github.com/faizan-khanx

## GITHUB STATS

![Faizan's GitHub stats](https://github-readme-stats.vercel.app/api?username=faizan-khanx&show=reviews,discussions_started,discussions_answered,prs_merged,prs_merged_percentage&theme=dark#gh-dark-mode-only)
