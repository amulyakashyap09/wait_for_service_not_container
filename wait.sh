#!/bin/bash

declare -a HOSTS=("localhost:27017" "localhost:9200" "localhost:5601" "localhost:15672")

pingNow(){

    VAL=${HOSTS[$1]}
    SERVER=$(echo $VAL | awk -F: '{print $1}')
    PORT=$(echo $VAL | awk -F: '{print $2}')

    echo "$1, $2, $VAL"

    if [ $1 -lt `expr $2 - 1` ]; then

        $(nc -w 2 -v $SERVER $PORT </dev/null)
        
        if [ "$?" -ne 0 ]; then
            echo "Connection to $SERVER on port $PORT failed"
            testing $1 $2
            # exit 1
        else
            echo "Connection to $SERVER on port $PORT succeeded"
            testing `expr $1 + 1` $2
            # exit 0
        fi
    else
        echo "DONE!!! All services are UP"
    fi
}

pingNow 0 ${#HOSTS[@]}
