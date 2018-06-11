.RECIPEPREFIX +=

# Build the binaries
.PHONY: bin
bin:
  stack build --fast

# Build the RabbitMQ Docker image
.PHONY: build-rabbit
build-rabbit:
  docker build -t rabbitmq .

# Run RabbitMQ and set up an admin/admin user
.PHONY: run-rabbit
run-rabbit:
  docker kill some-rabbit
  docker rm some-rabbit
  docker run -p 5672:5672 -p 1883:1883 -p 61613:61613 -d --hostname my-rabbit --name some-rabbit -e RABBITMQ_ERLANG_COOKIE=secret rabbitmq && sleep 5
  docker run -it --rm --link some-rabbit:my-rabbit -e RABBITMQ_ERLANG_COOKIE=secret -e RABBITMQ_NODENAME=rabbit@my-rabbit rabbitmq sh -c 'rabbitmqctl add_user admin admin && rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" && rabbitmqctl add_vhost localhost && rabbitmqctl set_permissions -p localhost admin ".*" ".*" ".*"'
