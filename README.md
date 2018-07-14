# Docker Compose Wait For Services Script
> A tutorial on how to wait for services within docker containers.

## Explanation
> Instead of putting your `wait-script` in `docker-compose.yaml` (as shown in docker-compose docs).
> You should put your `wait-script` within your source(src) folder
> And execute `wait.sh` from Dockerfile. 

> Whenever your `docker-compose.yaml` file executes it builds from `Dockerfile` and your script executes.
> Now, execute your binary (`golang binary`) / main file `(main.js)` from `wait.sh`

## Contributing [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues) ![Chrome Web Store](https://img.shields.io/chrome-web-store/price/nimelepbpejjlbmoobocpfnjhihnpked.svg) ![license](https://img.shields.io/github/license/mashape/apistatus.svg)

* All pull requests are **welcomed**
* Mail me at `amulyakashyap09@gmail.com`

## Usage
1. Add your services in your **docker-compose.yaml** file (`vi docker-compose.yaml`)
```
zookeeper:
    image: wurstmeister/zookeeper
    ports:
      - "2181:2181"
  kafka:
    build: .
    ports:
      - "9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 192.168.99.100
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

2. Now, Kafka will be accessible via [http://localhost:9092](http://localhost:9092)
3. Add this command `localhost:9200` to **wait.sh** file (`vi wait.sh`)

```
declare -a HOSTS=("localhost:27017" "localhost:9200" "localhost:5601" "localhost:15672", "localhost:9092")
```
4. Run Command `docker-compose up`
