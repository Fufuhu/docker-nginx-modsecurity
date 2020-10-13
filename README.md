# docker-nginx-modsecurity
Nginx + modsecurity 3 + OWASP ModSecurity core rule set

I checked this works with the following environment.

+ Ubuntu 18.04
+ Docker CE 19.03.13

## What's this?

This repository includes Dockerfile and the related files to create docker image with
**Nginx + ModSecurity 3.x + OWASP ModeSecurity Core Rule Set**.

## What version of components is used?

+ Nginx 1.19.3
+ ModSecurity 3.0.4
+ OWASP ModSecurity Core Rule Set 3.3.0

Currently, these are hard-coded in Dockerfile, so
I'd like to make it flexible to follow new versions through refactoring.


## How to build

```console
$ git@github.com:teapod418/docker-nginx-modsecurity.git # Ofcourse https is also OK.
$ cd docker-nginx-modsecurity
$ docker build -t docker-nginx-modsecurity `pwd`
$ docker run --it --rm -p 80:80 docker-nginx-modsecurity
```

Nginx access log and ModSecurity log, ModSecurity audit logs are logged to stdout(/dev/stdout).

## Hey, I want image only.

Perhaps, automatically built image might be useful for you.

[fufuhu/docker-nginx-modescurity](https://hub.docker.com/r/fufuhu/docker-nginx-modsecurity)


## Reference
+ [ModSecurity: Open Source Web Application Firewall](https://www.modsecurity.org/)
+ [OWASP ModSecuirty Core Rule Set](https://owasp.org/www-project-modsecurity-core-rule-set/)
+ [SpiderLabs/ModSecurity](https://github.com/SpiderLabs/ModSecurity)
+ [ModSecurity 3.0 and NGINX: Quick Start Guide](https://www.nginx.com/resources/library/modsecurity-3-nginx-quick-start-guide/)
