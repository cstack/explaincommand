# Import a man page
```
man ls | groff -T html - > man-pages/ls.txt
```

# Run server
```
be ruby main.rb
```
Then visit:
http://localhost:5678/explain?cmd=ls%20-lof