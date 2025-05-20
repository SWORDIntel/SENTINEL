# KrakenMask

Sleep mask using APC with gadget-based evasion to bypass current detection methods.

It’s possible to detect a VirtualProtect call using APC if it returns to NtTestAlert. In this sleep mask, the return address of VirtualProtect is the address of a call NtTestAlert gadget.

Query example :
```
query = '''
api where 
 process.Ext.api.name : "VirtualProtect" and 
 process.thread.Ext.call_stack_summary : "ntdll.dll*" and 
 _arraysearch(process.thread.Ext.call_stack, $entry, $entry.symbol_info : ("*NtTestAlert*", "*ZwTestAlert*")) and 
 _arraysearch(process.thread.Ext.call_stack, $entry, $entry.symbol_info : "*ProtectVirtualMemory*") and 
 process.thread.Ext.call_stack_summary : ("ntdll.dll", "ntdll.dll|kernelbase.dll|ntdll.dll|Unknown", "ntdll.dll|Unbacked", "ntdll.dll|Unknown")
```

stackframe without gadget :

```
00 000000b7`619ff7d8 00007ffd`0dcb66db     ntdll!NtProtectVirtualMemory
01 000000b7`619ff7e0 00007ffd`106c306f     KERNELBASE!VirtualProtect+0x3b
02 000000b7`619ff820 00000000`00009000     ntdll!NtTerminateJobObject+0x1f
03 000000b7`619ff828 00007ff6`7f710000     0x9000
04 000000b7`619ff830 00000000`00000000     KrakenMask!__ImageBase
```
stackframe with gadget :

```
 # Child-SP          RetAddr               Call Site
00 0000026d`14e416e0 00007ffd`0dcb66db     ntdll!NtProtectVirtualMemory
01 0000026d`14e416e8 00007ffd`106c349d     KERNELBASE!VirtualProtect+0x3b
02 0000026d`14e41728 00000000`00000000     ntdll!KiUserApcHandler+0xd
```

Detection rules for VirtualProtect :

https://github.com/elastic/protections-artifacts/blob/cb45629514acefc68a9d08111b3a76bc90e52238/behavior/rules/defense_evasion_virtualprotect_call_via_nttestalert.toml

# Update

Update 2.2 :
- Add callstack masking during delay to evade HuntBeaconSleep-NG

Update 2.1:
- Modified CONTEXT.RIP to point to a ```jmp RDI``` gadget. CONTEXT.RDI now contains the address of the targeted function.
