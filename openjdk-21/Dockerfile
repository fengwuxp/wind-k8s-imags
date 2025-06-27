# === Stage 1: 下载并解压 Arthas（有 curl + unzip）===
FROM eclipse-temurin:21-jdk AS downloader

ARG ARTHAS_VERSION=4.0.5
ENV ARTHAS_URL=https://github.com/alibaba/arthas/releases/download/arthas-${ARTHAS_VERSION}/arthas-bin.zip

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip && \
    curl -L ${ARTHAS_URL} -o /tmp/arthas-bin.zip && \
    mkdir -p /opt/arthas && \
    unzip /tmp/arthas-bin.zip -d /opt/arthas && \
    rm -f /tmp/arthas-bin.zip

# === Stage 2: 最小运行时镜像 ===
FROM eclipse-temurin:21-jdk

ENV TZ="Asia/Shanghai"

# 安装基础依赖（无 curl）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        locales tzdata fontconfig && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone

# 添加 admin 用户，固定 UID=1001（用于挂载兼容）
RUN useradd -u 1001 -m -s /bin/bash admin

# 创建目录结构并设置权限
RUN mkdir -p /home/admin/run /home/admin/nas /home/admin/logs && \
    chown -R admin:admin /home/admin && \
    chmod 755 /home/admin/nas

# 拷贝启动脚本和 profile 配置
COPY ./startup.sh ./prestop.sh /home/admin/run/
COPY ./jdk.sh /etc/profile.d/

# 从 downloader 拷贝 arthas 解压目录
COPY --from=downloader /opt/arthas /opt/arthas

# 权限设置
RUN chmod +x /home/admin/run/startup.sh /home/admin/run/prestop.sh && \
    chmod +x /etc/profile.d/jdk.sh && \
    chown -R admin:admin /opt

# 切换用户
USER admin

# 默认工作目录
WORKDIR /home/admin/run
