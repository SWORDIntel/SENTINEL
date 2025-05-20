<!--
category: network
subcategory: telecom-protocol
origin: sigscale
risk_level: low
possible_abuse: telecom protocol fuzzing, network mapping
hardening_tips: restrict access, monitor protocol usage
related: SS7, TCAP, ITU-T Q.771-Q.774
opsec: low

tags: [ss7, tcap, telecom, protocol, network]
-->
# ITU-T Q.771-Q.774 Transaction Capabilities Application Part (TCAP) of SS7

The `tcap` protocol stack application implements the encoding/decoding
of network protocol data units and the procedures for the transaction (TSL)
and component sublayers (CSL). It is a distributed application used by
TC-Users such as Mobile Application Part (MAP) and CAMEL Application
Part (CAP) in mobile operator networks.

![distribution](https://raw.githubusercontent.com/sigscale/tcap/master/doc/tcap_distribution.png)

