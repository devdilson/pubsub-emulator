# pubsub emulator with script

This docker image is not optimized, but it allows to initialize pubsub and run scripts to create topics.


## How to build:

```bash
docker build -t pubsub .
```

## With compose:

```bash
docker-compose up --build
```


## Run:

```bash
docker container run -it pubsub /bin/bash
docker run pubsub -p 8500:8500
```