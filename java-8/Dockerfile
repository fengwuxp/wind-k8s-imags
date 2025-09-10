# === Stage 1: 下载并解压 Arthas ===
FROM eclipse-temurin:8-jdk AS downloader

ARG ARTHAS_VERSION=4.0.5
ENV ARTHAS_URL=https://github.com/alibaba/arthas/releases/download/arthas-all-${ARTHAS_VERSION}/arthas-bin.zip

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip && \
    curl -L "${ARTHAS_URL}" -o /tmp/arthas-bin.zip && \
    mkdir -p /opt/arthas && \
    unzip /tmp/arthas-bin.zip -d /opt/arthas && \
    rm -f /tmp/arthas-bin.zip && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# === Stage 2: 最小运行镜像 ===
FROM eclipse-temurin:8-jdk

ENV TZ="Asia/Shanghai"

# 安装依赖（无 curl/wget/unzip）
RUN apt-get update && \
    apt-get remove -y wget curl unzip && \
    apt-get install -y --no-install-recommends \
        fontconfig locales tzdata unzip && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone

# 添加 admin 用户（UID 1001）
RUN useradd -u 1001 -m -s /bin/bash admin

# 确保目录存在并提前授权
RUN mkdir -p /home/admin/run /home/admin/nas /home/admin/logs

# 将文件拷贝给 admin
COPY --chown=admin:admin ./startup.sh ./prestop.sh /home/admin/run/
COPY --chown=admin:admin ./jdk.sh /etc/profile.d/
COPY --from=downloader --chown=admin:admin /opt/arthas /opt/arthas

# 确保所有目录归属 admin
RUN chown -R admin:admin /home/admin /opt && \
    chmod +x /home/admin/run/startup.sh \
             /home/admin/run/prestop.sh \
             /etc/profile.d/jdk.sh

# 切换为非 root 用户
USER admin

# 设置默认工作目录
WORKDIR /home/admin/run
