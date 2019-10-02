# Derivcotest

## About

This application exposes two endpoints which can filter and group entries from `data/matches.csv` file, based on query params from URL.

- JSON api: `GET /api/games?division=&season=&group_by=`
- Protobuffer api: `GET /proto/games?division=&season=&group_by=`

> 'division' and 'season' parameters do filters data based on value,
> ex.: division=SP1&season=201617 return only games from Spania Primeria in 2016-2017 season 
>
> 'group_by' can group rows only by these fields
>
> - group_by=season
> - group_by=division
> - group_by=season,division
> - group_by=division,season

## Setup

Make sure you have latest Elixir (1.9) and Docker installed, then clone this repo.


```bash
$ git clone git@github.com:hpaul/derivcotest
$ cd derivcotest
$ mix deps.get
```

Data folder contain the file with games received for test. You can change it's content for different response.

Application can be started with iex which will start a server on port :8000.

```bash
$ iex -S mix
```

Or you start the server with docker.

```bash
$ docker build -t derivcotest .
$ docker run --publish 8000:8000 derivcotest:latest
```

Or you can stresstest it, on the three instance container with HAproxy as load balancer.

```
$ docker-compose up --scale webapp=3
```
