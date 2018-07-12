# Docker Compose Wait For Services Script
> A tutorial on how to wait for services within docker containers.

## Contributing [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues) ![Chrome Web Store](https://img.shields.io/chrome-web-store/price/nimelepbpejjlbmoobocpfnjhihnpked.svg) ![license](https://img.shields.io/github/license/mashape/apistatus.svg)

* All pull requests are **welcome**
* Mail me at `amulyakashyap09@gmail.com`

### Usage
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
3. Add this command `ping -c 5 -p 9092 localhost` to **wait.sh** file (`vi wait.sh`)

```
declare -a HOSTS=("ping -c 5 -p 27017 localhost" "ping -c 5 -p 9200 localhost" "ping -c 5 -p 5601 localhost" "ping -c 5 -p 15672 localhost", "ping -c 5 -p 9092 localhost")
```
4. Run Command `docker-compose up`

#### Final Code looks like

> docker-compose.yaml
```
version: '3.1'

services:

  zookeeper:
    image: wurstmeister/zookeeper
    ports:
      - "2181:2181"
  kafka:
    build: .
    ports:
      - "9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 0.0.0.0
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181

  elk:
    image: "sebp/elk"
    hostname: "elk"
    ports:
      - "5601:5601"
      - "9200:9200"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9200"]
      interval: 30s
      timeout: 10s
      retries: 5
  
  rmq:
    image: "rabbitmq:3-management"
    hostname: "rmq"
    # environment:
    #   RABBITMQ_ERLANG_COOKIE: "SWQOKODSQALRPCLNMEQG"
    #   RABBITMQ_DEFAULT_USER: "rabbitmq"
    #   RABBITMQ_DEFAULT_PASS: "rabbitmq"
    #   RABBITMQ_DEFAULT_VHOST: "/"
    ports:
      - "15672:15672"
      - "5672:5672"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:15672"]
      interval: 30s
      timeout: 10s
      retries: 5
    depends_on:
    - elk
  
  mongo:
    image: "mongo"
    hostname: "mongo"
    restart: "always"
    ports:
      - 27017:27017
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:27017"]
      interval: 30s
      timeout: 10s
      retries: 5
    depends_on:
      - rmq
    #environment:
      #MONGO_INITDB_ROOT_USERNAME: admin
      #MONGO_INITDB_ROOT_PASSWORD: admin_password
    
  hm-services:
    build:
      context: ./src
      dockerfile: ../docker/Dockerfile
    ports:
      - 8009:80
    depends_on:
      - elk
      - mongo
      - rmq
    command: ["sh", "./wait.sh"]
```
___

> wait.sh
```
#!/bin/bash

declare -a HOSTS=("ping -c 5 -p 27017 localhost" "ping -c 5 -p 9200 localhost" "ping -c 5 -p 5601 localhost" "ping -c 5 -p 15672 localhost", "ping -c 5 -p 9092 localhost")

pingFunc() {

    LIMIT=`expr $2 - 1`
    LOSS="0.0%"

    if [ $1 -lt $LIMIT ]; then
        HOST=${HOSTS[$1]}
        output=$($HOST | grep 'loss'| awk -F, '{print $3}' | awk '{print $1;}')

        if [ $output != $LOSS ]; then
            echo "Oops! ${HOST} is down. Please wait re-checking"
            pingFunc $1 ${#HOSTS[@]}
        else
            pingFunc `expr $1 + 1` ${#HOSTS[@]}
        fi
        
    else
        echo "DONE!!! All services are UP"
    fi
}

pingFunc 0 ${#HOSTS[@]}
```
