<!--
category: network
subcategory: telecom-protocol
origin: moiji-mobile
risk_level: low
possible_abuse: telecom protocol fuzzing, network mapping
hardening_tips: restrict access, monitor protocol usage
related: GSM, UMTS, MAP, GSUP, OpenBSC, Osmocom
opsec: low

tags: [gsm, umts, map, gsup, telecom, protocol, network]
-->
SGSN MAPProxy [![Build Status](https://travis-ci.org/moiji-mobile/sgsn-mapproxy?branch=master)](https://travis-ci.org/moiji-mobile/sgsn-mapproxy) [![Test Status](https://api.bob-bench.org/v1/badgeByUrl?branch=master&hosting=github&ci=travis-ci&repo=moiji-mobile%2Fsgsn-mapproxy)](https://bob-bench.org/r/gh/moiji-mobile/sgsn-mapproxy)
=====

Connect the OsmoSGSN to the GSM/UMTS core network. It is implementing
GSUP of OpenBSC/Osmocom and converts the requests to GSM MAP. GSM MAP
requests like cancelLocation will be converted to GSUP.

The code is used in production.
