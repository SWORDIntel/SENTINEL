
# Pegasus Spyware Samples Decompiled & Recompiled
# Pegasus Spyware Product Manual 2013
## Author: Jonathan Scott @jonathandata1    
### CURRENT VERSION 4.0

## About Jonathan Scott

> My name is Jonathan Scott, and I'm an American Security Researcher. I am currently a computer science PhD student at North Central University. My research focus is mobile spyware. I have been a mobile security engineer for ~13 years. 

> I was recently assigned an LVE from LG that affects all LG mobile devices in the world.  I discovered a backdoor in all LG Mobile Devices that allows the attacker to live inside your device undetected. This has been built into the MTK chipsets since the 1st LG Smart Mobile Device (Cellphones and Tablets).

**LVE-SMP-210010**
source: https://lgsecurity.lge.com/bulletins/mobile#updateDetails
![PEGASUS SPYWARE 5.1](https://i.postimg.cc/wMFBLpyf/Screen-Shot-2022-01-03-at-6-00-46-PM.png)


## Description: 

> ### Operating System: AndroidOS 
> ### Samples 1-5.1 are executable and functional. I am still working on cleaning up Sample #6, but most the XML data can be read.

## Steps To Install & Research The Spyware Samples

1. Enable ADB on your android
2. Disable Android Protect
3. adb install sample#.apk
4. launch the apk, example 
`adb shell am start com.xxGameAssistant.pao/.SplashActivity`

## Update: Sample 5.1
### This sample can be installed as a standalone apk, but you will need to uninstall sample 5. 
`adb uninstall com.network.android `

### Sample 5.1 is also called com.network.android

## Samples Included

| Sample #   | Hash                                                             |
|------------|------------------------------------------------------------------|
| Sample 1   | d257cfde7599f4e20ee08a62053e6b3b936c87d373e6805f0e0c65f1d39ec320 |
| Sample 2   | cc9517aafb58279091ac17533293edc1                                 |
| Sample 3   | bd8cda80aaee3e4a17e9967a1c062ac5c8e4aefd7eaa3362f54044c2c94db52a |
| Sample 4   | 144778790d4a43a1d93dff6b660a6acb3a6d37a19e6a6f0a6bf1ef47e919648e |
| Sample 5   | 7c3ad8fec33465fed6563bbfabb5b13d                                 |
| Sample 5.1 | 3474625e63d0893fc8f83034e835472d95195254e1e4bdf99153b7c74eb44d86 |
| Sample 6   | 530b4f4d139f3ef987d661b2a9f74f5f                                 |
| Product Manual 2013 | f6f0170d41075766b5ea18508453fa68dc946b8c58eaea4281b36207a32c7ade|
                   

## Acknowledgements
### @vxunderground for providing the samples
### @recordedfuture for sample validation
### @silascutler - Silas Cutler - Security Researcher (Malware / Reverse Engineering / Exploitation) Formerly CrowdStrike/Dell SecureWorks, Chronicle, Google) - Document Reference
### @botherder Claudio Guarnieri  - (Head of Security Lab at Amnesty International) - 2013 Product Manual

    
![PEGASUS SPYWARE 5.1](https://i.postimg.cc/tJ9QtqvQ/pegaus-sample-5-1.jpg)


## Product Manual: 2013 Edition
### Author: Guy Molho - Former NSO Director, Product Management
### Author LinkedIn: https://www.linkedin.com/in/guymolho/

**Document Hash:** f6f0170d41075766b5ea18508453fa68dc946b8c58eaea4281b36207a32c7ade
https://www.virustotal.com/gui/file/f6f0170d41075766b5ea18508453fa68dc946b8c58eaea4281b36207a32c7ade

## Author Validation: 
`exiftool 2013-NSO-Pegasus.pdf
Creator Tool                    : Adobe Acrobat 8.0 Combine Files
Create Date                     : 2013:12:23 14:53:39-06:00
Metadata Date                   : 2013:12:23 14:53:39-06:00
Producer                        : Adobe Acrobat 8.0
Creator                         : Guy Molho
Format                          : application/pdf`


![PEGASUS SPYWARE User Manual](https://i.postimg.cc/tgKwFtP4/Untitled-design-Max-Quality-2022-01-12-T170128-993.jpg)


![PEGASUS SPYWARE RAW DECOMPILED](https://i.postimg.cc/mZd92vqK/pegasus-spyware-android.jpg)


    
