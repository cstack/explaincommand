# Import a man page
```
man ls | groff -T html - > man-pages/ls.html
```

# Run server
```
make serve
```
Then visit:
http://localhost:5678/explain?cmd=ls%20-lof