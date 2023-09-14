
# build
```
sudo docker build -t lloydzhou/nginx-proxy-connect -f Dockerfile .
```

# run 
```
sudo docker run --rm -it -p 7777:7777 lloydzhou/nginx-proxy-connect:latest
```

# test
```
curl -v -x http://127.0.0.1:7777 https://www.baidu.com
```
