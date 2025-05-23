<!--
category: network
subcategory: denial-of-service
origin: nccgroup
risk_level: medium
possible_abuse: service disruption, DoS testing
hardening_tips: monitor for abnormal connection drops, rate-limit connections
related: dos, dropped connection, network, research
opsec: medium

tags: [network, dos, dropped-connection, research, testing]
-->
# DroppedConnection

Emulates a Cisco ASA Anyconnect VPN service, accepting any credentials (and logging them) before serving VBS to the client that gets executed in the context of the user.

Blog post: 
https://research.nccgroup.com/2023/03/01/making-new-connections-leveraging-cisco-anyconnect-client-to-drop-and-run-payloads/

# Usage Instructions
1. Copy the files to a server.
2. Make sure you have python2 (I know, but it works on appliances ;)) and pip installed, along with pyOpenSSL
- sudo apt-get update
- sudo apt install python2
- sudo apt install python-pip
- sudo pip2 install pyOpenSSL
3. Generate a certificate for the domain you're hosting it on.
4. Make sure that the private key and cert are in the same pemfile.pem in the working directory of the tool. For letsencrypt certs, this is just a case of catting privkey.pem and fullchain.pem into pemfile.pem.
5. Edit the 'OnDisconnect.vbs' and 'OnConnect.vbs' files in the 'files' directory to contain your payload. No need to edit the file name, it gets served as the required VBS file that anyconnect looks for.
6. Start the server: sudo python2 server.py <your vpn name>

