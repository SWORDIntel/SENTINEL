# Discord Router

A simple router decorator for [discord.py](https://github.com/Rapptz/discord.py) chat bots.

## Installation

`pip3 install discordrouter`

## Usage

```py
from discordrouter import Router, message

class ChatBot(discord.Client):
  router = Router('!test')

  async def on_ready(self):
    print(f'Logged in as {self.user.name}')
  
  async on_message(self, message):
    await self.router(self, message)

  @message(router, "new <name>")
  async _test1(self, items, message):
    name = items['name']
    await message.channel.send('{name}')
```

`items` is a dict of keys. Using the example above, if called with `!test new swag money`, `items` would contain `{'name': 'swag money'}`

`send` is a link to `message.channel.send`

`message` is the `discord.Message` object passed in from `on_message`


Another example for fun
```py
@message(router, "list", "List all things")
async def _list(self, message, send, **kwargs):
  ...
```
