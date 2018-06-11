.RECIPEPREFIX +=

# Build the binaries
.PHONY: bin
bin:
  stack build --fast


############################################################
# RabbitMQ

# Build the RabbitMQ Docker image
.PHONY: build-rabbit
build-rabbit:
  docker build -t rabbitmq .

# Stop RabbitMQ
.PHONY: stop-rabbit
stop-rabbit:
  docker kill some-rabbit || true
  docker rm some-rabbit || true

# Run RabbitMQ and set up an admin/admin user
.PHONY: run-rabbit
run-rabbit: stop-rabbit
  docker run -p 5672:5672 -p 1883:1883 -p 61613:61613 -d --hostname my-rabbit --name some-rabbit -e RABBITMQ_ERLANG_COOKIE=secret rabbitmq && sleep 5
  docker run -it --rm --link some-rabbit:my-rabbit -e RABBITMQ_ERLANG_COOKIE=secret -e RABBITMQ_NODENAME=rabbit@my-rabbit rabbitmq sh -c 'rabbitmqctl add_user admin admin && rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" && rabbitmqctl add_vhost localhost && rabbitmqctl set_permissions -p localhost admin ".*" ".*" ".*"'


############################################################
# ActiveMQ

# Stop ActiveMQ
.PHONY: stop-active
stop-active:
  docker kill some-active || true
  docker rm some-active || true

# Run ActiveMQ (the admin/admin user is already set up)
.PHONY: run-active
run-active:
  docker run -p 1883:1883 -p 8161:8161 -p 61613:61613 -d --name some-active rmohr/activemq:5.15.4-alpine
