FROM nginx:1.25.3-perl

# 镜像默认识别此环境变量控制时区
ENV TZ="Asia/Shanghai"

WORKDIR /etc/nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources; \
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources; \
    apt-get update; \
    apt-get install -y vim busybox \
    && ln -s /bin/busybox /usr/local/bin/ip \
    && ln -s /bin/busybox /usr/local/bin/telnet \
    && ln -s /bin/busybox /usr/local/bin/ping \
    && ln -s /bin/busybox /usr/local/bin/nslookup \
    && chmod +x /entrypoint.sh
