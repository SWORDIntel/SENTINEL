Palioxis - Linux "kill-switch" utility
========
Palioxis was the Greek personification of the backrush or retreat from battle.
It seems fitting in the scenarios that would surround the needed use of this script.
For use by freedom fighters as needed for self-preservation. 
Do not operate while under the influence of drugs or alcohol. You might lose data and stuff.<br><br>
 
Running in 'Server' mode:<br>
usage: ./palioxis.py --mode server --host 127.0.0.1 --port 44524 --key OHSNAP<br>
This will start Palioxis as a server, meaning it will listen on
the given host and port for the 'destroy key'. Once received, it
will proceed to shred the specified files and truecrypt drives.
Once the server starts, it will run in the background as a daemon
process until you either reboot or kill the process.
**It's good idea to run the Palioxis server as system service**<br><br>

Running in 'Client' mode:<br>
usage: ./palioxis.py --mode client --list /etc/palioxis/nodes.txt<br>
This will start Palioxis as the master client. It will read server hosts
from the file specified with the --list argument and attempt to send the 
kill signal to each of these hosts. <br><br>
 
Example server list file:<br>
192.168.56.102 44524 OHSNAP
192.168.56.104 44524 FREEDOM
192.168.56.105 44524 L33T

