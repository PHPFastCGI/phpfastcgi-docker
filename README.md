
Build docker image with:
```bash
docker build -t phpfastcgi .
```

Run docker image with:
```bash
docker run -it --rm -p :2015:2015 --name phpfastcgi phpfastcgi
```
or detached with:
```bash
docker run -d -p :2015:2015 --name phpfastcgi phpfastcgi
```
