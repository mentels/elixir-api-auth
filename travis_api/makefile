# public key can be read from the local filesystem ("local") or fetch from Travis endpoint ("travis")
pk_method ?= "local"

.PHONY: travis_server
travis_server:
	iex --sname travis_server -S mix run --no-start \
	 --eval "{:ok, _} = Application.ensure_all_started :travis_server"

.PHONY: webhook_server
webhook_server:
	PUBLIC_KEY_METHOD=$(pk_method) iex --sname webhook_server -S mix run --no-start \
	 --eval "{:ok, _} = Application.ensure_all_started :webhook_server"