# === Stage 1: 下载并解压 Arthas ===
FROM eclipse-temurin:21-jdk AS downloader

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
FROM eclipse-temurin:21-jdk

ENV TZ="Asia/Shanghai"

# 安装必要依赖、设置时区、创建用户与目录
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends fontconfig locales tzdata && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    useradd -u 1001 -m -s /bin/bash admin && \
    mkdir -p /home/admin/run /home/admin/nas /home/admin/logs && \
    apt-get remove -y curl wget unzip && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# 拷贝文件并设定权限
COPY --chown=admin:admin ./startup.sh ./prestop.sh /home/admin/run/
COPY --chown=admin:admin ./jdk.sh /etc/profile.d/
COPY --from=downloader --chown=admin:admin /opt/arthas /opt/arthas

RUN chown -R admin:admin /home/admin /opt && \
    chmod +x /home/admin/run/startup.sh \
             /home/admin/run/prestop.sh \
             /etc/profile.d/jdk.sh

# 切换为非 root 用户
USER admin

# 设置默认工作目录
WORKDIR /home/admin/run