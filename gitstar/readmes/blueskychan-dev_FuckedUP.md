# FuckedUP
![thumbnail](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/thumbnail.png)
FuckedUP - Best way to fuck up windows without UAC (.NET way)
# Preview for FuckedUP
<details>
<summary>Windows 7 with FuckedUP (GUI)</summary>
<br>
  
![bandicam 2023-07-09 00-48-15-481](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/bandicam%202023-07-09%2000-48-15-481.gif)

</details>
<details>
<summary>Windows 10 with FuckedUP (GUI)</summary>
<br>
  
![bandicam 2023-07-09 16-35-21-362](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/bandicam%202023-07-09%2016-35-21-362.gif)

</details>
<details>
<summary>Windows XP SP4 with FuckedUP (CLI)</summary>
<br>

![bandicam 2023-07-09 16-28-07-155](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/bandicam%202023-07-09%2016-28-07-155.gif)

</details>
<details>
<summary>Windows 2000 SP4 ExKernel with FuckedUP (CLI)</summary>
<br>
  
![bandicam 2023-07-09 16-31-13-471](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/bandicam%202023-07-09%2016-31-13-471.gif)

</details>

# About FuckedUP
* What is FuckedUP?

FuckedUP is software that allows you to BSOD windows without admin
Which is very helpful for Windows YTPMVs/Crazy Error/Development/Testing and more!

FuckedUP will work perfectly in Windows 8 or higher!

* How FuckedUP Work?

FuckedUP will use ntdll.dll to crash windows without admins!
By generate a hard system error in NtRaiseHardError() object.

We use same methods with MEMZ, but we don't overwrite MBR! (stay safe!)
<details>
<summary>More information from ChatGPT</summary>
<br>
  
The NtRaiseHardError function is an API function in the Windows operating system that is part of the native API provided by the "ntdll.dll" library. It is used to generate a hard system error, which can potentially result in a system crash (Blue Screen of Death or BSOD) or trigger other system-level error handling mechanisms.

The function takes several parameters, including the error status code, the number of parameters, a Unicode string parameter mask, a pointer to the parameters, a valid response option, and an output parameter for the response.

The primary purpose of NtRaiseHardError is to allow system-level components, such as drivers or system services, to report critical errors to the operating system. It provides a mechanism for signaling unrecoverable or severe errors that require immediate attention or system-wide notification.

It's worth noting that invoking NtRaiseHardError directly from user-mode applications is typically not recommended and should be done with caution. Generating hard errors intentionally can disrupt the normal operation of the system, potentially leading to system instability, data loss, or other undesirable consequences. Therefore, it should only be used for specific testing, debugging, or diagnostic purposes in controlled environments.

</details>

* Does fuckedup is safe?

Yes, FuckedUP is safe for your computer and data, we never tracking any data from you, FuckedUP is only crash your computer! Stay safe :3

* FuckedUP will work on MS-DOS based? (like Windows 95, 98, ME)

No, FuckedUP will working on Windows NT Kernel only.

* FuckedUP will be port to C++ or other language?

I don't have enough time for do it :(


# Minimum Requirements
</details>
<details>
<summary>FuckedUP (CLI)</summary>
<br>

  * Windows 2000 SP4 or higher (NT Kernel based)
  * .NET 2.0
  * 256 MB of ram, 512 MHz Processors
  * x86 (32-Bit) Architectures

</details>

</details>
<details>
<summary>FuckedUP (GUI)</summary>
<br>

  * Windows 2000 SP4 or higher (NT Kernel-based) is supported. However, it is recommended to use Windows Vista or a higher version when not in safe mode.
  * .NET 2.0
  * 256 MB of ram, 512 MHz Processors
  * x86 (32-Bit) Architectures

</details>

# How to use FuckedUP?
</details>
<details>
<summary>FuckedUP (GUI)</summary>
<br>

![image](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/GUI.PNG)

* Stop code
You can select stop code from lists, stop code will show in BSOD Screen
![image](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/StopLists.PNG)

* Use custom stop code

Please use if you know about stop code ONLY!

This will work with stopcode are start with (0xC only!)

Be careful about Unknown Hard Error messagebox!

![image](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/customgui.PNG)

* Immediately trigger the FuckedUP action without confirmation

If you checked this box, FuckedUP will bsod without asking!

![image](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/ursure.PNG)


This message will gone after checked this box!

* Accelerate the FuckedUP process by spamming NtRaiseHardError

If you checked this box, FuckedUP will spam NtRaiseHardError process to make BSOD will happen faster!

Please Note Enabling this option may result in high CPU usage due to the creation of multiple threads by the process.

* Debug

This option will debug about your software like Windows OS, Current .NET Framework and few more!

Please Note this option will won't sending to me, that just only show to you!

![image](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/debug.PNG)

</details>

<details>
<summary>FuckedUP (CLI)</summary>
<br>
  
![image](https://github.com/blueskychan-dev/FuckedUP/raw/main/github/cli.PNG)

If you run without console args, that will look like normal but try learn about console args!

* `-help`

This command will show all Available commands from 

Output:

```
Available commands:
-stop <stop code>     : Customize the stop code for NtRaiseHardError
                        (Example: 0xc000021a, start with 0xc ONLY!) *Experiment
-now                  : Immediately trigger the FuckedUP action without confirmation
-fuckedup             : Accelerate the FuckedUP process by spamming NtRaiseHardError
-help                 : Show available commands and examples
Copyright to blueskychan-dev 2023 (https://fusemeow.me)
```

* `-stop <stop code>`

This command will allow you can use custom stop code, this stop code will show in BSOD screen!

Please use if you know about stop code ONLY!

This will work with stopcode are start with (0xC only!)

Be careful about Unknown Hard Error messagebox!

* `-now`

This command will make, FuckedUP just bsod away without asking!

* `-fuckedup`

This command will make FuckedUP will spam NtRaiseHardError process to make BSOD will happen faster!

Please Note Enabling this option may result in high CPU usage due to the creation of multiple threads by the process.


</details>

# Credit

Thanks MEMZ creator and [peewpw](https://github.com/peewpw/) for this [Simple Code!](https://github.com/peewpw/Invoke-BSOD/blob/master/Program.cs)

# Copyright Protection 
* This code is protect by [Apache License 2.0](https://github.com/blueskychan-dev/FuckedUP/blob/main/LICENSE)

# Donate this project!
* I don't know to make donate (global one), sadly!
