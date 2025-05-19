# t2bot.io
Website for [t2bot.io](https://t2bot.io).

Building/running:
```bash
npm install
npm run watch    # For development
npm run build    # For production. Outputs to ./site/
```

Windows users: it is recommended to use WSL with the watcher as cuttlebelle currently does not
properly work with Windows directly.

Docker:
```
docker run -it -p 80:80 t2bot/t2bot.io
```
