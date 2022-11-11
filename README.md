# Import a man page
```
man ls | groff -T html - > data/manpages/ls.html
```

# Run server
```
bundle exec rails s
```
Then visit:
http://localhost:3000/explain?cmd=ls%20-lof