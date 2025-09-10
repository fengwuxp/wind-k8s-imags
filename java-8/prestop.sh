#!/bin/bash
timestamp=`date +%s`
datetime=`date +%F`
[ ! -d /data/oss/$JVM_DUMP_DIR/$SPRING_APPLICATION_NAME/$datetime ] && mkdir -p /data/oss/$JVM_DUMP_DIR/$SPRING_APPLICATION_NAME/$datetime
java_pid=`jps | awk '/jar/{print $1}'`
jstack -l $java_pid > /data/oss/$JVM_DUMP_DIR/$SPRING_APPLICATION_NAME/$datetime/thread-$POD_NAME-$timestamp.log
sleep 15
echo "exec graceful shutdown"
kill -15 $java_pid
[ $? -eq 0 ] && echo "springboot 优雅关闭"
sleep 10