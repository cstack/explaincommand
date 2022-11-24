# Explaincommand

A tool to match command-line arguments to their help text.

Live version: https://shielded-basin-58652.herokuapp.com/

Inspired by https://github.com/idank/explainshell

## Import a man page
```
rails manpage:import\[cat\]
```

## Import a man page for a subcommand
```
rails manpage:import\[docker,build\]
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