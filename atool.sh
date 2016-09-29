#!/bin/sh

home_dir=${HOME}
echo ${home_dir}

declare -A project_info
project_info[1]="/AOSP_New 0123456789ABCDEF"
project_info[2]="/AOSP_Internal 192.168.100.100:5555"

declare -A component_info

component_info["framework"]="/out/target/product/aus6735_66c_c_m/system/framework/framework.jar /system/framework/:/out/target/product/aus6735_66c_c_m/system/framework/ext.jar /system/framework/"
component_info["service"]="/out/target/product/aus6735_66c_c_m/system/framework/services.jar /system/framework/"
component_info["systemui"]="/out/target/product/aus6735_66c_c_m/system/priv-app/SystemUI/SystemUI.apk /system/priv-app/SystemUI"

check_tools_exists(){
    command -v adb > /dev/null 2>&1 | {echo >&2 "Required tool is not installed, aborting"; exit 1}
}

init(){
    adb connect 192.168.100.100:5555
    adb -s 0123456789ABCDEF remount
    adb -s 192.168.100.100:5555 remount
}

deploy(){
  echo "Deploy is invoked $1"
  init
  COMPONENT=${component_info["$1"]}
  
  PRJ_ROOT=`echo ${project_info[$2]} | cut -d' ' -f1`
  DEVICE_NAME=`echo ${project_info[$2]} | cut -d' ' -f2`
  
  echo "project root $PRJ_ROOT"
  echo "device name $DEVICE_NAME"

  oldIFS=$IFS
  IFS=:
  
  for substr in ${COMPONENT}
  do
      push_source=`echo ${substr} | cut -d' ' -f1`
      push_dist=`echo ${substr} | cut -d' ' -f2`
      
      echo $home_dir$PRJ_ROOT$push_source
      
      adb -s "$DEVICE_NAME" push "$home_dir$PRJ_ROOT$push_source" "$push_dist"
  done

  IFS=$oldIFS
}

log(){
    init
    DEVICE_NAME=`echo ${project_info[$1]} | cut -d' ' -f2`
    adb -s $DEVICE_NAME logcat | tee /tmp/lll &
    p1=$!

    trap '{ echo "Hey, you pressed Ctrl-C.  Time to quit." ; kill $p1; }' INT
    wait $p1
    
    cp /tmp/lll ~/tmp/lll && gedit ~/tmp/lll
}

while getopts d:l:p:n:s: option
do
    case "${option}" in
        d) 
	    #Target of deployment
	    TARGET_NAME=${OPTARG}
	    ;;
        l) 
	    echo "Log start !"
	    LOG_NUMBER=${OPTARG}
	    ;;
        p) 
	    PROJECT_NUMBER=${OPTARG}
	    ;;
        n) 
	    NAME=$OPTARG
	    ;;
	s) 
	    SHOWLOG=$OPTARG
	    ;;
	?)
	    echo "Unknow argument"
	    exit 1
	    ;;
        esac    
done

if [[ $TARGET_NAME != "" ]] && [[ $PROJECT_NUMBER -gt 0 ]]; then
    deploy $TARGET_NAME $PROJECT_NUMBER
    exit 0
fi

if [ $SHOWLOG -gt 0 ]; then
    showlog
fi

if [ $LOG_NUMBER -gt 0 ]; then
    log $LOG_NUMBER
else
    echo "Problem occured: Wrong Argument"
fi
