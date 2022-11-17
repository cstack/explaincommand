# Explaincommand

A tool to match command-line arguments to their help text.

Live version: https://shielded-basin-58652.herokuapp.com/

Inspired by https://github.com/idank/explainshell

## Import a man page
```
man ls | groff -T html - > data/manpages/ls.html
```

## Import a help page
```
docker run --help > data/helppages/docker-run.txt
```

## Run server locally
```
bundle exec rails s
```
Then visit:
http://localhost:3000/explain?cmd=ls%20-lof

Or request json results:
```
curl -H "Accept: application/json" "http://localhost:3000/explain?cmd=ls+-l"
```

## Run server in Docker
```
make build
make run
```

Then visit:
http://localhost:3000/explain?cmd=ls%20-lof

Or request json results:
```
curl -H "Accept: application/json" "http://localhost:3000/explain?cmd=ls+-l"
```

## Deploy to Heroku

```
git push heroku main
```

Visit https://shielded-basin-58652.herokuapp.com/