# Leakscripts
Work on your leaks like dbs were never invented.

## What
A range of thrown-together scripts I use to work on the recent password leaks (bigDB, Antipubli, Collection#1-5, etc.) for python3

## What exactly
Most scripts assume input (mainly e-mails or the output of the tool before) as utf-8 text files.
These are the scripts (use them in roughly this order):

### 1. Unpackallthethings
The `./unpackallthethings/unpack.py` script in unpackallthethings unpacks excel and sqlite .db files to csvs.
I just don't like the idea to open Excel Sheets from random strangers.
This one is optional and you'll need to `pip3 install -r ./unpackallthethings/requirements.txt` first.  
Wishlist: make it unpack 7zip/tar/rar/... too.

### 2. Gmail Export
Google allows to export your contacts, but I prefer to have mails only. 
`./gmail_export_to_linesep.py` should output the mails only.

Outputs to commandline - redirect to a file.

### 3. Search All Mails MP
Search through all mails provided via text.
It goes through each individual line, parses the mail with a (inprecise - since email addresses suck) regex, then compares the mail against all input e-mails.

On top, it duplicates gmail and googlemail addresses (that used to be a thing and the leaks is old.)
so
```
tet@gmail.com
```
will actually output
```
tet@googlemail.com
```
and print results for both addresses.

To use it, simply run `./search_all_mails_mp.py [input file] [path{s} to travese] > all_results.txt`

input file format:
```
fun@mail.de
test@gmail.com
```
output format:
```
fun@mail.com|file where this has been found|the line from this file
```
The filename is kept as some files contain additional info, like an origin or sql layouts.

Outputs to commandline - redirect to a file.

#### Note:
This is multiprocessed, so it'll use all your cores - but if you have an ssd it'll still be slower than necessary as it's python.
(Should probably reimplement that in rust or something (?))

In case you don't have too many mails, a good alternative is `grep`/`rg` 
with a regex per mail, like `rg (mail1@mail\.com|mail2@mail\.xyz|mail3@mail3\.de)`, 
however this script should handle far larger mail dbs.


### 4. Dedupe
"Search all Mails MP" may output a lot of data (up to a gigabyte).
Most of it is useless if you just want a passwordlist. For this reason, run the output through `./dedupe.py`.

It'll try to figure out which parts of the file are passwords and only keep those.
The heuristic is based on what I've seen so far. Keep an eye on the error msgs if you want.

_I recommend to read thorugh the comments in [./dedupe.py](./dedupe.py). 
That's the actual interesting part of this all._
If you want to only get the password from a grep result, use `cleaned(line: str) -> str`.
Based on this, one could probably build an importer to a proper db.

Usage: `./dedupe.py [search_all_mails_mp.outfile] > deduped.txt`

### 5. Wordlistify
That's a fun one: create your very own wordlist from the prior results.
Will take a file with `mail:password` lines, sort them, then output a toplist.

```
999:123456
888:123456789
777:12345678
654:123qaz
321:password
...
```
Think `sort` but slower.
## Why
I needed something that works.

## Stuff is broken
Works for me. Feel free to fix it.
