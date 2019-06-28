# DockerhubApi

## Notes

* DockerHub doesen't provide any means to validate its webhooks
* Thus any possible sanity check over the payload is a MUST: like `repo_url`
  * maybe there's a way to query DockerHub that the hook was validates which would
  be the proof that it was sent by DockerHub

## Running example

* start the mock Github server with:
`make dockerhub_server`
* start the Webhook server with:
`make webhook_server`
* Run the webhook from the dockerhub server:
**TODO**