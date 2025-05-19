# rpi-edgemap (initramfs)

External tree for [buildroot](https://buildroot.org) to build RaspberryPi4 based [Edgemap](https://resilience-theatre.com/edgemap/) firmware image. 

## Latest version

Latest development happens currently in [meshtastic-maplibre4 branch](https://github.com/resiliencetheatre/rpiedgemap/tree/meshtastic-maplibre4) and until that is merged, you most
probably want to keep eye and use that branch. It contains Meshtastic radio support and latest maplibre-gl-js.

## Features

This branch contains edgeUI for browser based mapping with [Protomaps](https://protomaps.com/). 

Branch is stripped down version of [Edgemap](https://resilience-theatre.com/edgemap/) firmware image for
[Raspberry Pi4](https://en.wikipedia.org/wiki/Raspberry_Pi) and does not need tileserver-gl to serve 
mbtiles. All maps are pmtiles handled by [maplibre-gl-js](https://github.com/maplibre/maplibre-gl-js) library.

Image contains [taky](https://github.com/tkuester/taky) a simple [COT](https://www.mitre.org/sites/default/files/pdf/09_4937.pdf) server 
for [ATAK](https://tak.gov/products). CoT server is mainly targeted to read CoT targets in network and illustrate them on Web user interface.
This functionality was tested with [AN/PRC-169](https://silvustechnologies.com/) radios.

Buildroot is used to build [initramfs](https://en.wikipedia.org/wiki/Initial_ramdisk) image and it contains kernel and rootfs on single file
on MicroSD card boot partition. This makes system total ephemeral and updating OS (including rootfs) does not require full MicroSD copying. Instead
you can drop new 'Image' file to boot partition and update is done. 

For [operations security](https://en.wikipedia.org/wiki/Operations_security) we use Linux Unified Key Setup (LUKS) to encrypt data partition on same MicroSD card (or external USB drive).
Since we aim to use RPi4 in headless configuration we use [systemd-cryptsetup](https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptsetup@.service.html)
with [FIDO2](https://shop.nitrokey.com/shop/product/nkfi2-nitrokey-fido2-55) key. With this approach we can start unit to fully operational state with FIDO2
key plugged in to USB port and after unit is booted (and LUKS partitions are opened) - we can remove FIDO2 key. 

Browser usable user interface allows wide range of end user devices (EUD's) without any additional software installs. 

This version does NOT have high rate target, simulations, CoT reading and [AN/PRC-169](https://silvustechnologies.com/) support. 

If you choose to use browser based geolocation, configure installation to use TLS connection.

## Building

To build edgemap firmware, you need to install Buildroot environment and clone this repository 
as 'external tree' to buildroot. Make sure you check buildroot manual for required packages 
for your host, before building.

```
mkdir ~/build-directory
cd ~/build-directory
git clone https://git.buildroot.net/buildroot
git clone https://github.com/resiliencetheatre/rpiedgemap
```

Checkout '2023.08.3' for buildroot:

```
cd ~/build-directory/buildroot
git checkout 2023.08.3
```

Modify `rpi-firmware` package file and change firmware version tag to
match kernel version (6.7.0-rc3-v8) we're using. 

```
# package/rpi-firmware/rpi-firmware.mk
RPI_FIRMWARE_VERSION = 5ffb2e29c0e14dede001447a6977e126e950cf3e
```

Disable hash check by deleting hash file:

```
cd ~/build-directory/buildroot
rm package/rpi-firmware/rpi-firmware.hash
```

After you're stable with kernel and firmware versions, re-create hash file.

Define _external tree_ location to **BR2_EXTERNAL** variable:

```
export BR2_EXTERNAL=~/build-directory/rpiedgemap
```

Make edgemap configuration (defconfig) and start building:

```
cd ~/build-directory/buildroot
make rpi4_edgemap_defconfig
make
```

After build is completed, you find image file for MicroSD card at:

```
~/build-directory/buildroot/output/images/sdcard.img
```

Use 'dd' to copy this image to your MicroSD card.

## Configuration

After you initial boot completes insert your FIDO2 key and run `create-partition.sh` script to partition remaining space on your MicroSD card. 

Place pmtiles to your MicroSD second partition and link them under /opt/edgemap/edgeui/ on running instance. Modify also styles/style.json to 
match amount of sources available.

## Map data

You need to have full [planet OSM](https://maps.protomaps.com/builds/) pmtiles and A global terrain RGB dataset from [Mapzen Joerd](https://github.com/tilezen/joerd) project.



