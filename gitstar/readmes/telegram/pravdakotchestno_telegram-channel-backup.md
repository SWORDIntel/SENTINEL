# telegram-channel-backup
Tool for public/private telegram channel backup.

Want to save some stuff from channel which is about to be removed, but manual forwarding takes too long?
Well, here is a tool for you.

## Retrieving channels

```
python3 tcb.py retrieve_channels --api_key 888888:0123456789abcdef0123456789abcdef --session sessionfile
```

*api_key* argument is simply *api_id:api_hash*, if you don't know what is it and how to get it, read [this](https://core.telegram.org/api/obtaining_api_id)

Output will look something like this:

```
Connecting to the Telegram...
Logged in successfuly as @nickname
Retrieving dialogs...
+--------------+----------------------------------+-----------------------------------+
|      ID      |          Channel title           |             Username              |
+==============+==================================+===================================+
| 1999999999   | Initial channel backup           | @initialchannelbackup             |
+--------------+----------------------------------+-----------------------------------+
| 1555555555   | Initial channel                  | @initialchannel                   |
+--------------+----------------------------------+-----------------------------------+
```

## Forwarding

```
python3 tcb.py forward_posts --api_key 888888:0123456789abcdef0123456789abcdef --session sessionfile --from_channel 1555555555 --to_channel 1999999999
```

```
Connecting to the Telegram...
Logged in successfuly as @nickname
Forwarding posts...
About 100.00% have been forwarded
=============================================
2 posts have been forwarded in 0.53 seconds
=============================================
```

## TODO

* proxy support
