#!/bin/sh

get_external_device(){
    devices_list=`adb devices`
    external_device=`echo $devices_list | cut -d ' ' -f 5`
    
    if [ "$external_device"x == ""x ];then
	echo "can not find any devices, please try to restart the adb server"
	return 1
    fi
    
    echo $external_device
}

get_internal_device(){
    devices_list=`adb devices`
    internal_device=`echo $devices_list | cut -d ' ' -f 7`
    
    if [ "$internal_device"x == ""x ];then
	#try kill-server & start-server
	echo "can not find any devices, please try to restart the adb server"
	return 1
    fi
    
    echo $internal_device
}

gain_device_id(){
    adb connect 192.168.100.100:5555
    ext_device=`get_external_device`
    #[ $? != "0" ] && return 1

    int_device=`get_internal_device`
    #[ $? != "0" ] && return 1

    echo "the devices list will be wrote to $1"
    rm $1
    echo "$ext_device" > $1
    echo "$int_device" >> $1
    
    if [ "$ext_device"x == ""x ];then
	echo "Problem occured during obtain external device identification"
	return 1
    fi
    
    if [ "$int_device"x == ""x ];then
	echo "Problem occured during obtain internal device identification"
	return 1
    fi
}






