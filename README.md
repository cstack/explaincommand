# Explaincommand

A tool to match command-line arguments to their help text.

Inspired by https://github.com/idank/explainshell

## Import a man page
```
man ls | groff -T html - > data/manpages/ls.html
```

## Import a help page
```
docker run --help > data/helppages/docker-run.txt
```

## Run server
```
bundle exec rails s
```
Then visit:
http://localhost:3000/explain?cmd=ls%20-lof

Or request json results:
```
curl -H "Accept: application/json" "http://localhost:3000/explain?cmd=ls+-l"
```