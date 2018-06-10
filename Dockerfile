FROM rabbitmq:3.7.5-management

RUN rabbitmq-plugins enable --offline rabbitmq_mqtt \
 && rabbitmq-plugins enable --offline rabbitmq_stomp

EXPOSE 15671 15672 1883 61613
