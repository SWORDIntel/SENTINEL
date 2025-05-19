# LsassReflectDumping
This tool leverages the Process Forking technique using the RtlCreateProcessReflection API to clone the lsass.exe process. Once the clone is created, it utilizes MINIDUMP_CALLBACK_INFORMATION callbacks to generate a memory dump of the cloned process.

## Steps
* Getting the handle of Lsass.exe process
* Cloning Lsass.exe process using RtlCreateProcessReflection (Process Forking)
* Using MINIDUMP_CALLBACK_INFORMATION callbacks to create cloned process minidump
* Confirming the dump content and size.
* Terminating the cloned process.

## Usage
Simply execute the compiled file.
```cpp
ReflectDump.exe 
```

## Offline Dumping
Use Mimikatz or Pypykatz to parse the dump file offline.
```cpp
sekurlsa::minidump [filename] sekurlsa::logonpasswords
pypykatz lsa minidump [filename]
```
## Upcoming Features
```cpp
* Encrypt dump before writing on disk to bypass static detection.
* Exfiltrate on C2 Server
```

## Disclaimer
The content provided on this repository is for educational and informational purposes only.

### Reference 
https://www.deepinstinct.com/blog/dirty-vanity-a-new-approach-to-code-injection-edr-bypass
