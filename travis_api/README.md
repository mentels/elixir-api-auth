# TravisApi

## Notes

* Travis puts signature of the messages in the `Signature` HTTP header
* the signature the SHA1-ed payloed signed with a private key and then base64 encoded 
* to verify signature it has to be base64 deoced and then verified using the corresponding public key and SHA1 digest
* more [here](https://docs.travis-ci.com/user/notifications/#verifying-webhook-requests)
* the example used RSA key pair in PEM format generated with:

```shell
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -out public.pem -outform PEM -pubout
```
* the examples keys are stored in `apps/travis_server/priv`

## Running example

* start the mock Github server with:
`make travis_server`
* start the Webhook server with:
`make webhook_server`
* Run the webhook from the github server:
    ```elixir
    iex(travis_server@szm-mac)1> TravisServer.call
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