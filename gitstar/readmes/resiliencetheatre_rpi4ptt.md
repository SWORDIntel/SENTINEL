# rpi4ptt

External tree for [buildroot](https://buildroot.org) to build RaspberryPi4 based 
secure push-to-talk (ptt) firmware image. Please note that this code is under
development and does not offer product like implementation just yet. 

![rpi4ptt](https://raw.githubusercontent.com/resiliencetheatre/rpi4ptt/main/doc/rpi4ptt.png?raw=true)

This development release does not (yet) contain provisioning environment, which
configures communication and One-Time-Pad keying of units. You need to have provisioning
done before this image turns into working solution.

Please note that this repository is made for public reference and must be tailored for
each use case separately. This repository acts as great example how embedded cross compilation
with buildroot can be made to support very specific embedded Linux targets. 

You can use this repository also for training purposes where your teams needs to figure out
how this kind of technology and build system actually works. There are several interesting
implementation decisions made and feel free to understand them fully. 

You've been warned!

## Features

This is small (< 100 MB) firmware image for RaspberryPi 4, which will act like
Secure PTT node for you. It will encrypt and decrypt OPUS encoded speech with 
One-Time-Pad to and from other similar nodes. 

* Buildroot 'master' with Linux kernel 6.1.77 
* USB audio support, tested with Jabra Evolve2 30 and various USB-C HF's
* Raspberry Pi Codec Zero audio and button supported
* Codec Zero can be wired to Kenwood SMC-34 monofone

Please note that this is embedded software 'firmware' and it's not based on any
"raspberry pi distribution" as such. This implementation aligns to D.I.E model.

## Initialization

Node initialization happens with [rpi4ptt-init](https://github.com/resiliencetheatre/rpi4ptt-init) script which creates all needed
connection artifacts and uses (insecure) /dev/urandom as sample for key material.

## Building

```
mkdir ~/build-directory
cd ~/build-directory
git clone https://git.buildroot.net/buildroot
git clone https://github.com/resiliencetheatre/rpi4ptt
```

Current build uses master branch of buildroot. Build is tested with 8740387457f4dfccbd211ffaef1cae91db9f232d.

Modify `rpi-firmware` package file and change firmware version tag to
match kernel version (6.1.77) we're using. 

```
# package/rpi-firmware/rpi-firmware.mk
RPI_FIRMWARE_VERSION = 7273369aded28c56937cda2ec8e305f86eaa1203
```

Disable hash check by deleting hash file:

```
cd ~/build-directory/buildroot
rm package/rpi-firmware/rpi-firmware.hash
```

After you're stable with kernel and firmware versions, re-create hash file.

Define _external tree_ location to **BR2_EXTERNAL** variable:

```
export BR2_EXTERNAL=~/build-directory/rpi4ptt
```

Make rpi4ptt configuration (defconfig) and start building:

```
cd ~/build-directory/buildroot
make rpi4ptt_defconfig
make
```

After build is completed, you find image file for MicroSD card at:

```
~/build-directory/buildroot/output/images/sdcard.img
```

## Patching iqaudio driver

You can optionally patch iqaudio-codec.c driver to remove really anoying 
delay on audio opening. Download [this patch](https://gist.github.com/resiliencetheatre/9b9323e37b81a49a5724f68c04ac7dff)
and place it under buildroot/linux/ before build.


