# mq-experiment

## Instructions for running with RabbitMQ

Start up RabbitMQ:

    $ make build-rabbit run-rabbit

Then do either of these:

    $ stack build --fast && stack exec -- mqtt-bin
    $ stack build --fast && stack exec -- stomp-bin

If all goes well, you should see messages being sent and received. With
STOMP, you can add `--message "whatever"` and run several agents who are
sending out different messages.

## Instructions for running with ActiveMQ

    $ make run-active

After that it's the same.
