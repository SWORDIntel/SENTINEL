# Automated Collection and Enrichment
The Automated Collection and Enrichment (ACE) platform is a suite of tools for threat hunters to collect data from many endpoints in a network and automatically enrich the data. The data is collected by running scripts on each computer without installing any software on the target. ACE supports collecting from Windows, macOS, and Linux hosts.

ACE is meant to simplify the process of remotely collecting data across an environment by offering credential management, scheduling, centralized script management, and remote file downloading. ACE is designed to complement a SIEM by collecting data and enriching data; final analysis is best suited for SIEM tools such as Splunk, ELK, or the tools the analyst prefers.

![alt text](resources/images/ACE_Infrastructure.png "ACE Infrastructure")

## Why use ACE?
ACE grew out of the need to perform Compromise Assessments in places with common restrictions:
* A dedicated software agent can’t be installed on the target hosts.
* Copying and running executables (such as Sysinternals tools) is not feasible.
* The customer cannot enable Windows Remoting (WinRM).
* The customer’s visibility into macOS/Linux hosts is limited or nonexistent.
* New scripts/tools must be created for customer-specific data.
* Network segmentation requires multiple credentials to access all machines in the environment.


## Installation/What is the architecture of ACE?
ACE has four components: the ACE Web Service, the ACE Nginx web proxy, the ACE SQL database, and the ACE RabbitMQ message queue. The Web Service is a RESTful API that takes requests from clients to schedule and manage scans. The SQL database stores the configuration and data from scans. The RabbitMQ service handles automated enrichment of data.

1) Identify the IP Address of both your Linux Docker host and your Windows host.

### ACE Docker Images

### ACEWebService
1) Download the Configure-AceWebService.ps1 script from the Release page
2) 

## Usage/How do I use ACE?
The ACE repository includes a collection of PowerShell scripts to interact with the ACE Web Service, including adding users, managing credentials, uploading collection scripts, and scheduling scans. 

After deploying the ACE servers, use **New-AceUser** to create a new ACE user.

Remove the default “Admin” user with **Remove-AceUser**.

Use **New-AceCredential** to enter a set of credentials.

Run **Start-AceDiscovery** to automatically find computers on the Windows domain.

Run **Start-AceSweep** to start a sweep to run the selected scripts across the discovered endpoints.



## More Resources
* [ACE GitHub Wiki](https://github.com/Invoke-IR/ACE/wiki)
* [ACE BlackHat Arsenal slides](https://www.slideshare.net/JaredAtkinson/automated-collection-and-enrichment-ace)

## Contributing
Contributions to ACE are always welcome.
