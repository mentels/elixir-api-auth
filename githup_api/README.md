# GithubApi

## Notes

* Github puts signature of the messages in the `X-Hub-Signature` HTTP header
* the signature is HMAC-SHA1 of the request payload
* both parties need to share a secer
* more [here](https://developer.github.com/webhooks/securing/)

## Running example

### Success

* start the mock Github server with:
`make github_server secret=my_secret`
* start the Webhook server with:
`make webhook_server secret=my_secret`
* Run the webhook from the github server:
    ```elixir
    iex(github_server@szm-mac)1> GithubServer.call
    {:ok, 200, "ok"}
     ```
* The webhook server will listen to hooks at `http://localhost:4000/api/webhook` by default and print the following log:
    ```
    15:43:49.063 [debug] Signature valid
    15:43:49.070 [info]  POST /api/webhook Params: %{"key" => "val"}
    15:43:49.070 [info]  POST /api/webhook body: ["{\"key\":\"val\"}"]
    ```
* If the signature is invalid (because secrets differ or the message has been tampered with) the message will look like:
```
15:44:56.595 [error] Invalid signature, sending OK 200 and halting connection
```