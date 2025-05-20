# idahost

`idahost` is a hack to allow you to embed/host IDA Pro in your own application. It uses reflective process loading to load `idat64.exe` as a DLL, and then uses the IDA Pro API to interact with it. `idahost` requires a helper plugin to be loaded by IDA Pro.

`idahost` is mentioned and used in this video: [Headless programming in IDA Pro](https://youtu.be/Ioql0TLU0zA?t=914).

## Building

### Setup the `idahost` binaries

1. Take a copy of your IDA installation, say to `c:\work\idahost`

2. Clean up the `plugins` folder and keep it to the minimum; for example:

```
hexx64.dll
idaclang64.dll
pdb64.dll
plugins.cfg
win32_user64.dll
idahostplg64.dll
```

Note that you won't have the `idahostplg64.dll` file yet, until you build as described below.

You may also delete non "64" versions of the files, since `idahost` is 64-bit only.

### Prerequisites

- You need the IDA SDK installed alongside a properly configured [`ida-cmake`](https://github.com/allthingsida/ida-cmake)

- The projects will not work properly in `Debug` builds, instead opt for either `RelWithDebInfo` or `Release` builds.

- Since an IDA host program statically links to the IDA SDK, make sure `ida64.dll` is in the PATH when running the host program.

- It is best if you also set the `IDADIR` environment variable to point to your IDA host folder, so that the client can find the `idat64.exe` automatically.

- The host program should have the '64' suffix in its name, e.g. `myhost64.exe`, so that IDA kernel does not complain

## Build `idahost`

```
cd idahost
cmake -B build64 -DCMAKE_INSTALL_PREFIX=C:\temp\cmake -DEA64=YES -A x64
cmake --build build64 --config Release
cmake --install build64 --config Release
```

(change the install prefix to your liking)

## Build the idahost helper plugin

```
cd idahost_plugin
cmake -B build64 -DEA64=YES -A x64
cmake --build build64 --config Release
```

Copy the `idahostplg64.dll` to your IDA host's plugins directory.

## Build an idahost client

```
cd example
cmake -DCMAKE_PREFIX_PATH=C:\Temp\cmake -A x64 -B build64
cmake --build build64 --config Release
```

If you set up the `IDADIR` environment variable correctly and updated your PATH environment variable, you should be able to run an IDA host client without any issues.
