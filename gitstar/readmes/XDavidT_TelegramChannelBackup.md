# Telegram Channel Backup

## About
This is a small program in Python3 that download channel massages and save it in your local machine. It can be used for mirroring or backup when you afraid to lose data or information.

## Installation

Use the package manager [pip3](https://pip.pypa.io/en/stable/) to install telethon.

```bash
pip3 install telethon
```

Before starting, update API id & hash, in *setting/config.json* , get it from [https://my.telegram.org/](https://my.telegram.org/) -> 'API development tools'-> App api_id & App api_hash .
Or You can use your bot API id&hash, you can create a bout using [BotFather](https://t.me/botfather)
Here is example, how 'config.json' should look like:
```
{
    "api_id":123456,
    "api_hash":"abcdefghikzjfwqer1234567890"
}
```

## Usage

Using `-i` is short of `--id`, provide an ID of the channel, for example, t.me/*test* provide only *test*. By the way.. It's MUST parameter.

Using `-l` is short of `--limit`, set a limit of history, how long you want to search back, if you didn't use it, will take the whole chat (take some time..). INT ONLY

Using `-o` is short of `--override`, is *true* or *false* in lower case sensitive. True(Default) will re-create the folder, False - Will continue and fix what missing.

Using `-m` is short of `--mirror`, to forward the selected messages to other chat (empty bot I created).

Using `-u` or `--upload`, to upload your data to external website. You can use only sites that have driver. Currently options: *anonymousfiles* - anonymousfiles.io


Examples: (ChannelID = Chat ID)
```
python3 main.py -i ChannelID -l 5 -o false -u anonymousfiles -m #get only 5 back, do not override, mirror to bot, upload to anonymousfiles

python3 main.py -i ChannelID -o true #Override all the exists data and backup all the chat to local
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
Use at your own risk !
