Embed a file in HTML and have it autodownload using JavaScript
============

Revision Author: RedTeamRonin

- I took what Arno0x0x created and got it working with Python3. I also removed some of the items I didn't find useful but a link to the original repository is [here](https://github.com/Arno0x/EmbedInHTML) as the drag and drop site could be useful to others.

Original Author: Arno0x0x - [@Arno0x0x](http://twitter.com/Arno0x0x)

My revised verion of the readme:

What this tool does is taking a file (*any type of file*), encrypt it, and embed it into an HTML file as ressource, along with an automatic download routine simulating a user clicking on the embedded ressource.

Then, when the user browses the HTML file, the embedded file is decrypted on the fly, saved in a temporary folder, and the file is then presented to the user as if it was being downloaded from the remote site. Depending on the user's browser and the file type presented, the file can be automatically opened by the browser.

This tool comes in one flavor:

  1. An **python script** which generates the output HTML file based on a template, using **RC4 encryption** routines, and embedding the decryption key within the output file. The resulting HTML can either be browsed by the targeted user or sent as an attachement.

Side notes:
- This tool was inspired and derived from the great 'demiguise' tool : [https://github.com/nccgroup/demiguise](https://github.com/nccgroup/demiguise)

- The b64AndRC4 function used on the binary input (from the XLL file) is a mix of:
[https://gist.github.com/borismus/1032746](https://gist.github.com/borismus/1032746) and [https://gist.github.com/farhadi/2185197](https://gist.github.com/farhadi/2185197)

- In the HTML template (*html.tpl file*) it is advised to insert your own key environmental derivation function below in place
of the 'keyFunction'. You should derive your key from the environment so that it only works on your intended target (*and not in a sandbox*).

Usage
----------------------

**Using the python script**

1/ Generate the malicious html file from the XLL file, along with a secret key:
`python embedInHTML.py -k mysecretkey -f example_calc.xll -o index.html`

DISCLAIMER
----------------
This tool is intended to be used in a legal and legitimate way only:
  - either on your own systems as a means of learning, of demonstrating what can be done and how, or testing your defense and detection mechanisms
  - on systems you've been officially and legitimately entitled to perform some security assessments (pentest, security audits)

Quoting Empire's authors:
*There is no way to build offensive tools useful to the legitimate infosec industry while simultaneously preventing malicious actors from abusing them.*
