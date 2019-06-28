.PHONY: dockerhub_server
dockerhub_server:
	iex --sname dockerhub_server -S mix run --no-start \
	 --eval "{:ok, _} = Application.ensure_all_started :dockerhub_server"

.PHONY: webhook_server
webhook_server:
	PUBLIC_KEY_METHOD=$(pk_method) iex --sname webhook_server -S mix run --no-start \
	 --eval "{:ok, _} = Application.ensure_all_started :webhook_server"