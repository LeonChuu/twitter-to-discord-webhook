# Twitter to Discord Webhook Listener

A simple Tweet listener that sends recent tweets to a Discord Webhook.

You can run the project building it directly with Mix, or use Docker to build an image. But before running it, you must configure the application.

## Configuration:

The configuration is done by environment variables. 

### Mandatory Variables
You must specify the following variables. 

TWITTER_IDS: List of Twitter ids of the users whose tweets will be sent to Discord, separated by commas.

Example: TWITTER_IDS=123456,564523

WEBHOOK_URLS: List of Discord webhooks where the tweets will be sent to, separated by commas.

Example: https://discord.com/api/webhooks/1234/abcde,https://discord.com/api/webhooks/1234/ghji

TWITTER_BEARER_TOKEN: Authentication token for the Twitter API. You can get one at https://developer.twitter.com/en .

Example: TWITTER_BEARER_TOKEN=AAAAAAAAAAAAAAAAAAAAAMLheAAAAAAA0%2BuSeid%2BULvsea4JtiGRiSDSJSI%3DEUifiRBkKG5E2XzMDjRfl76ZC9Ub0wnz4XsNiRVBChTYbJcE3F

The following variables are optional and can be used to change program behavior.

### Optional Variables
POLL_TIME_MS: Time between checks for the newest tweets for the profiles specified in TWITTER_IDS ,in miliseconds . Default is 1800000 (30 minutes.)

LOG_LEVEL: Elixir logging level for the application. "info" will display info and more critical levels (warn, error, critical), "debug" will display debug messages and all of the former. Default is "info".

BASE_TWITTER_QUERY: By default, the listener will only fetch media that isn't a retweet. You can edit the base query using the specification from Twitter's API in https://developer.twitter.com/en/docs/twitter-api/tweets/search/api-reference/get-tweets-search-recent . \
The default value is  "has:media -is:retweet -is:quote &tweet.fields=entities"
## Mix:

### Compiling
`mix deps.get`
`mix compile`
### Running:

`mix run --no-halt`

### Testing:

`mix test`

## Docker

If you have docker-compose installed, you can just use 
`docker-compose up -d`

