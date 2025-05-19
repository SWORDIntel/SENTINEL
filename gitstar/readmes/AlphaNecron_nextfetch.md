### nextfetch

> Simple cross-platform fetch program, written in Go

#### Prerequisites
- True color (24-bit) or 256-color (8-bit) compatible terminals
- `go >= 17` (build only)

#### Building
```sh
git clone https://github.com/AlphaNecron/nextfetch.git
cd nextfetch
# build the program
make
./out/nextfetch
# install it globally
sudo make install
```

#### Installation for Arch Linux
```sh
git clone https://github.com/AlphaNecron/nextfetch.git
cd nextfetch/nextfetch
makepkg -sri
```

#### Configuration
> Do `make install-config` on Linux or copy `nextfetch.default` to `%USERPROFILE%/.nextfetch` on Windows.
```json lines
{
    "noAscii": false, // Whether to disable ASCII art
    "primaryColor": "blue", // Default color, can be either hex without hash, "r,g,b", color name or number (256-color)
    "colorBlock": "▁▁", // Character to be used as color block
    "clearScreen": false // Whether to clear screen on startup
}
```

#### Screenshot
![Nextfetch](https://user-images.githubusercontent.com/57827456/153422522-7c9b7452-ee04-4e75-90c9-dce7ef03432e.png)

#### Credits
- [`gopsutil`](https://github.com/shirou/gopsutil) for their source code
- [`goterm`](https://github.com/buger/goterm) for terminal manipulation
- [`gookit/color`](https://github.com/gookit/color) for color solution
- [`pfetch`](https://github.com/dylanaraps/pfetch) for some ASCII arts