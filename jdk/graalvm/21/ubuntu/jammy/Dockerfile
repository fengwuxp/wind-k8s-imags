# ------------------------------------------------------------------------------
# GraalVM Community JDK (JVM + Native Image)
# Ubuntu 22.04 (Jammy)
# ------------------------------------------------------------------------------
FROM ubuntu:22.04

ARG GRAALVM_VERSION=21.0.2
ARG GRAALVM_BUILD=+13.1

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JAVA_HOME=/opt/graalvm \
    PATH=/opt/graalvm/bin:$PATH

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        # curl required for historical reasons, see https://github.com/adoptium/containers/issues/255
        curl \
        wget \
        # gnupg required to verify the signature
        gnupg \
        # java.lang.UnsatisfiedLinkError: libfontmanager.so: libfreetype.so.6: cannot open shared object file: No such file or directory
        # java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11FontManager
        # https://github.com/docker-library/openjdk/pull/235#issuecomment-424466077
        fontconfig \
        # utilities for keeping Ubuntu and OpenJDK CA certificates in sync
        # https://github.com/adoptium/containers/issues/293
        ca-certificates p11-kit \
        # jlink --strip-debug on 13+ needs objcopy: https://github.com/docker-library/openjdk/issues/351
        # Error: java.io.IOException: Cannot run program "objcopy": error=2, No such file or directory
        binutils \
        tzdata \
        # locales ensures proper character encoding and locale-specific behaviors using en_US.UTF-8
        locales \
    ; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    echo "GraalVM version is $GRAALVM_VERSION, build $GRAALVM_BUILD"; \
    ARCH="$(dpkg --print-architecture)"; \
    case "$ARCH" in \
        amd64) GRAALVM_ARCH="linux-x64" ;; \
        arm64) GRAALVM_ARCH="linux-aarch64" ;; \
        *) echo "Unsupported arch: $ARCH"; exit 1 ;; \
    esac; \
    \
    URL="https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-${GRAALVM_VERSION}/graalvm-community-jdk-${GRAALVM_VERSION}_${GRAALVM_ARCH}_bin.tar.gz"; \
    \
    curl -L "$URL" -o /tmp/graalvm.tar.gz; \
    mkdir -p /opt; \
    tar -xzf /tmp/graalvm.tar.gz -C /opt; \
    mv /opt/graalvm-community-openjdk-${GRAALVM_VERSION}${GRAALVM_BUILD} $JAVA_HOME; \
    rm /tmp/graalvm.tar.gz

# 可选：Native Image
#RUN gu install native-image || true

RUN find "$JAVA_HOME/lib" -name '*.so' -exec dirname '{}' ';' | sort -u \
    > /etc/ld.so.conf.d/docker-graalvm.conf && ldconfig

RUN java -version && javac -version

COPY --chmod=755 entrypoint.sh /__cacert_entrypoint.sh
ENTRYPOINT ["/__cacert_entrypoint.sh"]
CMD ["jshell"]