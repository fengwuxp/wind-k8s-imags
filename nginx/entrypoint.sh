#!/bin/bash

env=${ENV}
app_name=${APP_NAME}
dist_dir=/usr/share/nginx/html
tenant_basepath=/data/oss/${env}/${app_name}

Info() {
  echo "-m: Mode (update|rollback|start)"
  echo "-t: Timestamp "
  echo "-d: Tenant Name"
  echo "-h: Help"
  echo "Example(modify): bash entrypoint.sh -m update|rollback|start -t Timestamp -d Tenant "
  exit -1
}

while getopts ':m:t:d:h:' OPT; do
  case $OPT in
    m)
      mode="$OPTARG"
      ;;
    t)
      timestamp="$OPTARG"
      ;;
    d)
      tenant_dir="${OPTARG:-wind}"
      ;;
    h) Info;;
    *) Info;;
  esac
done

#[ $OPTIND -lt 6 ] && Info

Start(){
  for i in `ls -d ${tenant_basepath}/*`; do
    ls ${i}/*.tar.gz &> /dev/null
    if [ $? -eq 0 ];then
      uncompress_path=`ls -t ${i}/*.tar.gz | head -n 1`
      tar -xf ${uncompress_path} -C ${dist_dir}
    fi
  done
}

Rollback(){
  if [ "last" == "$timestamp" ];then
    uncompress_path=`ls -t ${tenant_basepath}/${tenant_dir}/*.tar.gz | head -n 2 | tail -n 1`
    tar -xf ${uncompress_path} -C ${dist_dir}
  else
    uncompress_path=${tenant_basepath}/${tenant_dir}/${app_name}-${timestamp}.tar.gz
    tar -xf ${uncompress_path} -C ${dist_dir}
  fi
}

Update(){
  uncompress_path=${tenant_basepath}/${tenant_dir}/${app_name}-${timestamp}.tar.gz
  tar -xf ${uncompress_path} -C ${dist_dir}
}

case "$mode" in
  "update")
  Update
  ;;
  "start")
  Start
  ;;
  "rollback")
  Rollback
  ;;
  *) Info;;
esac