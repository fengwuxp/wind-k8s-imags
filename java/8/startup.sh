#!/bin/bash
set -e

# 自动检测 Java 命令
if [ -z "$JAVA_HOME" ] ; then
  JAVACMD=$(which java)
else
  JAVACMD="$JAVA_HOME/bin/java"
fi

if [ ! -x "$JAVACMD" ]; then
  echo "The JAVA_HOME environment variable is not defined correctly" >&2
  exit 1
fi

# 定义日志和 dump 目录，优先使用 nas，如果无权限则 fallback 到 /tmp
LOG_DIR="/home/admin/nas"

# 启动应用 JAVA_OPTS、$SPRING_CLOUD_OPTS、$SPRING_APPLICATION_OPTS 从环境变量中来
exec "$JAVACMD" \
  -Dpod.name=$POD_NAME $JAVA_OPTS -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:${LOG_DIR}/gc-$POD_NAME.log \
  -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/admin/nas/dump-$POD_NAME.hprof \
  $SPRING_CLOUD_OPTS \
  $SPRING_APPLICATION_OPTS \
  -Dfile.encoding=UTF8 \
  -Dsun.jnu.encoding=UTF8 \
  -Duser.timezone=$TZ \
  -jar /home/admin/run/bootstrap.jar "$@"