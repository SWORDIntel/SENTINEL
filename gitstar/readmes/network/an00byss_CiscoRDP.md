# ciscoRDP
A powershell POC to bypass the “AllowRemoteUsers” setting set in Cisco Adaptive Security Device Manager (ASDM)

## Overview
<p>This vulnerability was manifested by my laziness for carrying too many laptops. When using Cisco AnyConnect Secure Mobility Client to connect to a vpn, AnyConnect checks if the connection is being initiated from a Remote Desktop session. If an orgainzation has the "AllowRemoteUsers" setting set to deny in ASDM, Anyconnect will block the connection. However, due to a bug in the checking process it is possible to bypass that restriction. Cisco says this vulnerability is a low and a security advisory isn't warranted instead they will add to the release notes of bug CSCvu14970, so here's the tool.

Vulnerability has been reported to Cisco PSIRT on: 05/04/2020
</p>

### Note
If Company XYZ has autoconnect configured for their clients the script will autoconnect to the network bypassing the Remote Desktop Check and authentication.

## Usage
A user session must be present if not, RDP to the machine to create one. If a user session is already present you can skip this step. An interactive remote shell will be needed to run the script. WinRM, PsExec and WmiExec all work with this, once the VPN connects you can simply kill the script.

* If script kills anyconnect but doesn't connect to vpn, re-run as it may take 2 or 3 times.

## Demo
![](ciscoRDP-official.gif)

## Affected Versions
Affects Cisco AnyConnect Secure Mobility Client 4.9.x and prior
