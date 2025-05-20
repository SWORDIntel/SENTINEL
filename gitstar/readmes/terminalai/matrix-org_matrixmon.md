# matrixmon

A small end-to-end prober and Prometheus stats exporter for a Matrix homeserver.

## Running

Make a copy of the configuration template:

```bash
cp mon.yaml.example mon.yaml
```
    
Edit `mon.yaml` with the correct details regarding your homeserver, monitor user, access token and room ID.

Optionally edit the port and other values, if needed.

By default, Matrixmon expects the config file to be found in the same path where it runs. A custom config file 
location (full path to file including file name) can be set with the environment variable `MATRIXMON_CONFIG_PATH`. 

### Using Docker

```bash
docker run -ti matrixdotorg/matrixmon -v $PWD/mon.yaml:/app/mon.yaml -p 9091:9091
```

### Manually

On Debian/Ubuntu, example:

To build:

```bash
sudo apt-get install perl cpanminus build-essential libssl-dev zlib1g-dev
./install-deps.pl
``` 

To run:

```bash
perl mon.pl
```

## Metrics

Prometheus metrics are by default exposed at `http://localhost:9091/metrics`.

## License

Apache 2.0
