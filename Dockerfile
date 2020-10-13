FROM debian:buster-slim AS builder

RUN apt-get update && \ 
    apt-get install -y \
        apt-utils autoconf automake build-essential \
        git libcurl4-openssl-dev libgeoip-dev liblmdb-dev \
        libpcre++-dev libtool libxml2-dev libyajl-dev \
        pkgconf wget zlib1g-dev
WORKDIR /root
RUN git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
RUN cd ModSecurity && git submodule init && git submodule update
WORKDIR /root/ModSecurity
RUN ./build.sh
RUN ./configure
RUN make && make install

# NginxコネクタのダウンロードとModSecurityの
# Dynamicモジュールとしてのコンパイル
RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
RUN wget http://nginx.org/download/nginx-1.19.3.tar.gz
RUN tar zxvf nginx-1.19.3.tar.gz
WORKDIR /root/ModSecurity/nginx-1.19.3
RUN ./configure --with-compat --add-dynamic-module=../ModSecurity-nginx && make modules
# 
FROM nginx:1.19.3 AS nginx-modsecurity
COPY --from=builder /root/ModSecurity/nginx-1.19.3/objs/ngx_http_modsecurity_module.so /etc/nginx/modules
RUN mkdir -p /usr/local/modsecurity/lib
COPY --from=builder /usr/local/modsecurity/lib/libmodsecurity.so.3.0.4 /usr/local/modsecurity/lib/libmodsecurity.so.3
COPY --from=builder /usr/lib/x86_64-linux-gnu/liblmdb.so.0.0.0 /usr/lib/x86_64-linux-gnu/liblmdb.so.0
COPY --from=builder /usr/lib/x86_64-linux-gnu/libyajl.so.2.1.0 /usr/lib/x86_64-linux-gnu/libyajl.so.2
COPY conf.d/nginx.conf /etc/nginx/nginx.conf

# ModSecurityの推奨設定を取得する。
COPY --from=builder /root/ModSecurity/modsecurity.conf-recommended ./modsecurity.conf
RUN sed -i -e "s/SecRuleEngine DetectionOnly/SecRuleEngine On/g" modsecurity.conf && \
    mkdir -p /etc/nginx/modsecurity && \
    mv modsecurity.conf /etc/nginx/modsecurity/
RUN ln -s /dev/stdout /var/log/modsec_audit.log
COPY conf.d/main.conf /etc/nginx/modsecurity
COPY conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY conf.d/ruleset.conf /etc/nginx/modsecurity/ruleset.conf
COPY --from=builder /root/ModSecurity/unicode.mapping /etc/nginx/modsecurity


RUN curl -OL https://github.com/coreruleset/coreruleset/archive/v3.3.0.tar.gz && \
    tar -xvzf v3.3.0.tar.gz && \
    mv coreruleset-3.3.0 coreruleset && \
    mv coreruleset /usr/local && \
    cp /usr/local/coreruleset/crs-setup.conf.example \ 
       /usr/local/coreruleset/crs-setup.conf

RUN nginx -t
