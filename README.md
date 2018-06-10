# mq-experiment

## Instructions for running with RabbitMQ

In one terminal, do:

    $ docker build -t rabbitmq .
    $ docker run -p 5672:5672 -p 1883:1883 -p 61613:61613 -d --hostname my-rabbit --name some-rabbit -e RABBITMQ_ERLANG_COOKIE=secret rabbitmq
    $ docker run -it --rm --link some-rabbit:my-rabbit -e RABBITMQ_ERLANG_COOKIE=secret -e RABBITMQ_NODENAME=rabbit@my-rabbit rabbitmq bash
    # rabbitmqctl add_user admin admin && rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
    # rabbitmqctl add_vhost localhost rabbitmqctl set_permissions -p localhost admin ".*" ".*" ".*"

In another terminal, do either of these:

    $ stack build --fast && stack exec -- mqtt-bin
    $ stack build --fast && stack exec -- stomp-bin

If all goes well, you should see messages being sent and received. For MQTT
it will look like this:

```
Client server-demo sending CONNECT
Client server-demo sending PUBLISH (d0, q1, r1, m1, 'sometopic', ... (7 bytes))
Client server-demo received CONNACK (0)
0
Client server-demo sending SUBSCRIBE (Mid: 2, Topic: #, QoS: 0)
Client server-demo received SUBACK
(2,[0])
Client server-demo received PUBACK (Mid: 1)
Client server-demo sending PUBLISH (d0, q1, r1, m3, 'sometopic', ... (7 bytes))
Client server-demo received PUBACK (Mid: 3)
Client server-demo received PUBLISH (d0, q0, r0, m0, 'sometopic', ... (7 bytes))
Message {mid = 0, topic = "sometopic", payload = "krendel", qos = 0, retain = False}
```

## Instructions for running with ActiveMQ

    $ docker run -p 1883:1883 -p 8161:8161 --name activemq rmohr/activemq:5.15.4-alpine

After that it's the same.

TODO: STOMP
