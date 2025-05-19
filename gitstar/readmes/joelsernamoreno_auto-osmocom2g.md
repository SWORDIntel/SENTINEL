# auto-osmocom2g

* System: Ubuntu 18.04: https://releases.ubuntu.com/18.04.5/

* Hardware: LimeSDR, LimeSDR mini or USRP

### Installation

Run with the **root user:**

* apt update && apt upgrade

* git clone https://github.com/joelsernamoreno/auto-osmocom2g

* cd auto-osmocom2g

* ./install.sh

* cp osmo-pcu /usr/local/bin

* Reboot the computer

### Check the versions

* sudo osmo-nitb --version (1.1.0 OK)

* sudo osmo-bts-trx --version (1.2.1 OK)

* sudo osmo-trx-lms --version (1.2.0 OK)

* sudo osmo-trx-uhd --version (1.2.0 OK)

* sudo /usr/local/bin/osmo-pcu --version (0.8.0 OK)

* sudo osmo-ggsn --version (1.6.0 OK)

* sudo osmo-sgsn --version (1.6.2 OK)

* sudo osmo-stp --version (1.3.0 OK)

* sudo osmo-sip-connector --version (1.3.0 OK)

### POC

* Read the documentation for LimeSDR/LimeSDR mini: docs/limesdr.txt

* Read the documentation for USRP: docs/usrp.txt
