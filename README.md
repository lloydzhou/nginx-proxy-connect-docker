
# build
```
sudo docker build -t lloydzhou/nginx-proxy-connect -f Dockerfile .
```

# run 
```
htpasswd -c htpasswd lloyd:lloyd
sudo docker run --rm -it -p 7777:7777 lloydzhou/nginx-proxy-connect:latest
```

# test
```
curl -v -x http://127.0.0.1:7777 https://www.baidu.com
```

# TODO
1. https
2. auth: using openresty + lua

