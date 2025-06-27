#!/bin/bash

read_property(){
    grep "^$2=" "$1" | cut -d'=' -f2
}

if [ -z "$JAVA_HOME" ] ; then
  JAVACMD=`which java`
else
  JAVACMD="$JAVA_HOME/bin/java"
fi

if [ ! -x "$JAVACMD" ] ; then
  echo "The JAVA_HOME environment variable is not defined correctly" >&2
  echo "This environment variable is needed to run this program" >&2
  echo "NB: JAVA_HOME should point to a JDK not a JRE" >&2
  exit 1
fi

# JAVA_OPTS、$SPRING_CLOUD_OPTS、$SPRING_APPLICATION_OPTS 从环境变量中来
exec "$JAVACMD" \
  -Dpod.name=$POD_NAME $JAVA_OPTS -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:/home/admin/nas/gc-$POD_NAME.log \
  -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/admin/nas/dump-$POD_NAME.hprof \
  $SPRING_CLOUD_OPTS \
  $SPRING_APPLICATION_OPTS \
  -Dfile.encoding=UTF8 \
  -Dsun.jnu.encoding=UTF8 \
  -Duser.timezone=$TZ \
  -jar bootstrap.jar $@