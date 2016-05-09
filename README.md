## What is this?
This is a benchmark tool to measure trend of pub/sub processing throughput at AMQP,STOMP and Kafka server.

## Installation
You can install mqbench with RubyGems:
```
gem install mqbench
```

## Usage
```
Usage: benchmark [options]
    -m, --mode m                     specify benchmark mode ('amqp' or 'stomp')
    -s, --size s                     specify message size
    -c, --count c                    specify message counts
    -u, --user p                     specify user-id to login broker
    -w, --pass w                     specify password to login broker
    -h, --host h                     specify host of server
    -p, --port p                     specify TCP port-number which is listened
```
