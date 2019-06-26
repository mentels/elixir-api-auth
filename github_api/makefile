secret ?= "my_secret"

.PHONY: github_server
github_server:
	GITHUB_API_SECRET=$(secret) iex --sname github_server \
	 -S mix run --no-start --eval "{:ok, _} = Application.ensure_all_started :github_server"

.PHONY: webhook_server
webhook_server:
	GITHUB_API_SECRET=$(secret) iex --sname webhook_server \
	 -S mix run --no-start --eval "{:ok, _} = Application.ensure_all_started :webhook_server"