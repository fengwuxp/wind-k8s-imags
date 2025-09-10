# === Stage 0: 设置 ARG 和环境变量 ===
ARG GRAALVM_VERSION=21.0.2
ARG GRAALVM_BUILD=+13.1
ARG TARGETPLATFORM=linux/amd64
ARG ARTHAS_VERSION=4.0.5

# === Stage 1: 下载并解压 GraalVM ===
FROM ubuntu:jammy AS graalvm

ARG GRAALVM_VERSION
ARG GRAALVM_BUILD
ARG TARGETPLATFORM

ENV JAVA_DIR=graalvm-community-java${GRAALVM_VERSION}
ENV JAVA_HOME=/opt/${JAVA_DIR}
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tar ca-certificates && \
    set -eux; \
    case "$TARGETPLATFORM" in \
        "linux/amd64") GRAALVM_ARCH=linux-x64 ;; \
        "linux/arm64") GRAALVM_ARCH=linux-aarch64 ;; \
        *) echo "Unsupported TARGETPLATFORM=$TARGETPLATFORM" && exit 1 ;; \
    esac; \
    GRAALVM_PKG="https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${GRAALVM_VERSION}/graalvm-community-jdk-${GRAALVM_VERSION}_${GRAALVM_ARCH}_bin.tar.gz"; \
    curl -L "$GRAALVM_PKG" | tar -xz -C /opt/; \
    mv /opt/graalvm-community-openjdk-${GRAALVM_VERSION}${GRAALVM_BUILD} "$JAVA_HOME"; \
    mkdir -p /usr/java && \
    ln -sfT "$JAVA_HOME" /usr/java/default && \
    ln -sfT "$JAVA_HOME" /usr/java/latest && \
    for bin in "$JAVA_HOME/bin/"*; do \
      base="$(basename "$bin")"; \
      if [ ! -e "/usr/bin/$base" ]; then \
        update-alternatives --install "/usr/bin/$base" "$base" "$bin" 20000; \
      fi; \
    done && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# === Stage 2: 下载并解压 Arthas ===
FROM ubuntu:jammy AS downloader

ARG ARTHAS_VERSION
ENV ARTHAS_URL=https://github.com/alibaba/arthas/releases/download/arthas-all-${ARTHAS_VERSION}/arthas-bin.zip

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip ca-certificates && \
    curl -L "${ARTHAS_URL}" -o /tmp/arthas-bin.zip && \
    mkdir -p /opt/arthas && \
    unzip /tmp/arthas-bin.zip -d /opt/arthas && \
    rm -f /tmp/arthas-bin.zip && \
    apt-get remove -y curl wget unzip && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# === Stage 3: 最小运行镜像 ===
FROM ubuntu:jammy

ARG GRAALVM_VERSION
ARG GRAALVM_BUILD
ARG JAVA_DIR=graalvm-community-java${GRAALVM_VERSION}
ENV TZ="Asia/Shanghai"
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要依赖、设置时区、创建用户与目录
RUN apt-get update && \
    apt-get install -y --no-install-recommends fontconfig locales tzdata && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    useradd -u 1001 -m -s /bin/bash admin && \
    mkdir -p /home/admin/run /home/admin/nas /home/admin/logs && \
    apt-get purge -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# 拷贝 GraalVM 和 Arthas
COPY --from=graalvm --chown=admin:admin /opt/${JAVA_DIR} /opt/graalvm
COPY --from=downloader --chown=admin:admin /opt/arthas /opt/arthas

# 拷贝启动脚本与环境配置
COPY --chown=admin:admin ../startup.sh ./prestop.sh /home/admin/run/
COPY --chown=admin:admin ../jdk.sh /etc/profile.d/

# 设置权限
RUN chown -R admin:admin /home/admin /opt && \
    chmod +x /home/admin/run/startup.sh \
             /home/admin/run/prestop.sh \
             /etc/profile.d/jdk.sh

# 切换为非 root 用户
USER admin

# 设置默认工作目录
WORKDIR /home/admin/run

# 设置 GraalVM 环境变量
ENV JAVA_HOME=/opt/graalvm
ENV PATH="$JAVA_HOME/bin:$PATH"
