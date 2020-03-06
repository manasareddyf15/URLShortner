# URL shortener with Ruby, Sinatra and SQLite
=================================================
by Manasa Reddy <manasa.f15@gmail.com>

This app works as a REST API and to shorten an URL:

## Requirements:

* sinatra
* json
* sqlite3
* securerandom
* uri



## Run the app:
    ./run.sh

# APIs

## Visit short link

`GET /:short_url`
    curl -H 'Accept: application/json' http://localhost:4567/short_link/

### Respone
    Redirects to full url

## Create short link

`POST /shorten_url`
    curl -X POST -H 'Accept: application/json' http://localhost:4567/shorten_url/ -d '{{"url":"http://www.google.com"}}'

### Respone
    http://127.0.0.1:4567/74cea5d2

## Create custome short link

`POST /shorten_url`
    curl -X POST -H 'Accept: application/json' http://localhost:4567/shorten_url/ -d '{{"url":"http://www.google.com", "custom":"goog"}}'

### Respone
    http://127.0.0.1:4567/goog

## Get stats for the short link

`GET /stats/:short_url`
    curl -H 'Accept: application/json' http://localhost:4567/stats/goog

### Respone
    {
        "short_url": "goog",
        "original_url": "http://www.google.com",
        "created_at": "2020-03-06",
        "total_visits": 3
    }
