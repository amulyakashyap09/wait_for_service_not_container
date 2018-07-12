#!/bin/bash

declare -a HOSTS=("ping -c 5 -p 27017 localhost" "ping -c 5 -p 9200 localhost" "ping -c 5 -p 5601 localhost" "ping -c 5 -p 15672 localhost")

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
