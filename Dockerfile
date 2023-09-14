FROM alpine:3.17.4 as builder

RUN mkdir /data && cd /data
WORKDIR /data
RUN wget http://nginx.org/download/nginx-1.25.0.tar.gz

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk add git && git clone https://github.com/chobits/ngx_http_proxy_connect_module.git nginx_proxy 
RUN tar -zxvf nginx-1.25.0.tar.gz && rm -f nginx-1.25.0.tar.gz

WORKDIR /data/nginx-1.25.0
RUN apk add patch && patch -p1 < /data/nginx_proxy/patch/proxy_connect_rewrite_102101.patch \
  && apk add gcc g++ linux-headers pcre-dev openssl-dev zlib-dev make \
  && mkdir -p /var/cache/nginx && ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules \
  --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --with-compat --with-file-aio --with-threads --with-http_addition_module \
  --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module \
  --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module \
  --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module \
  --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream \
  --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module \
  --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
  --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' --add-module=/data/nginx_proxy \
  && make -j2 && make install && rm -rf /data/nginx_proxy

# TODO
RUN strip /usr/sbin/nginx

FROM alpine:3.17.4

COPY --from=builder /usr/lib/libpcre.so.1 /usr/lib/libpcre.so.1
COPY --from=builder /usr/lib/libpcre.so.1.2.13 /usr/lib/libpcre.so.1.2.13
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx

# default config
ADD proxy.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/log/nginx && mkdir -p /var/cache/nginx

CMD ["nginx", "-g", "daemon off;"]
