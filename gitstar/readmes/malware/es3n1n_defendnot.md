# defendnot

An even funnier way to disable windows defender.

Defendnot is a successor of [no-defender](https://github.com/es3n1n/no-defender).

![](https://i.imgur.com/VGE8g6a.jpeg)

## How it works

There's a WSC (Windows Security Center) service in Windows which is used by antiviruses to let Windows know that there's some other antivirus in the hood and it should disable Windows Defender.  
This WSC API is undocumented and furthermore requires people to sign an NDA with Microsoft to get its documentation.

The initial implementation of [no-defender](https://github.com/es3n1n/no-defender) used thirdparty code provided by other AVs to register itself in the WSC, while defendnot interacts with WSC directly.

## Limitations

Sadly, to keep this WSC stuff even after reboot, defendnot adds itself to the autorun. Thus, you would need to keep the defendnot binaries on your disk :(

## Usage

```commandline
Usage: defendnot-loader [--help] [--version] [--name VAR] [--disable] [--verbose] [--silent] [--autorun-as-user] [--disable-autorun]

Optional arguments:
  -h, --help         prints help message and exits
  --version          shows version and exits
  -n, --name         av display name [default: "https://github.com/es3n1n/defendnot"]
  -d, --disable      disable defendnot
  -v, --verbose      verbose logging
  --silent           do not allocate console
  --autorun-as-user  create autorun task as currently logged in user
  --disable-autorun  disable autorun task creation
```

## Writeup

[How I ruined my vacation by reverse engineering WSC](https://blog.es3n1n.eu/posts/how-i-ruined-my-vacation/)

## Special thanks

* [mrbruh](https://mrbruh.com) for poking me to research this topic
* [pindos](https://github.com/pind0s) for providing their machine for WSC service debugging

## License

Apache-2.0
