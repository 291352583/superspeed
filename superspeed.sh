#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE="\033[0;35m"
CYAN='\033[0;36m'
PLAIN='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1

# check python
if  [ ! -e '/usr/bin/python' ]; then
		echo -e
		read -p "${RED}Error:${PLAIN} python is not install. You must be install python command at first.\nDo you want to install? [y/n]" is_install
		if [[ ${is_install} == "y" || ${is_install} == "Y" ]]; then
			if [ "${release}" == "centos" ]; then
						yum -y install python
				else
						apt-get -y install python
				fi
		else
			exit
		fi
		
fi

# check wget
if  [ ! -e '/usr/bin/wget' ]; then
		echo -e
		read -p "${RED}Error:${PLAIN} wget is not install. You must be install wget command at first.\nDo you want to install? [y/n]" is_install
		if [[ ${is_install} == "y" || ${is_install} == "Y" ]]; then
				if [ "${release}" == "centos" ]; then
						yum -y install wget
				else
						apt-get -y install wget
				fi
		else
				exit
		fi
fi


clear

echo "———————————————————————SuperSpeed 全面测速版———————————————————————"
echo "    使用方法:      bash <(curl -Lso- https://git.io/superspeed)"
echo "    查看全部节点:  https://git.io/superspeedList"
echo "    节点更新日期:  2019/07/02"
echo "———————————————————————————————————————————————————————————————————"
echo "是否进行全面测速?  (失效的测速节点会自动跳过)"
echo -ne "    1. 确认测速    2. 取消测速"

while :; do echo
		read -p "请输入数字选择: " telecom
		if [[ ! $telecom =~ ^[1-2]$ ]]; then
				echo "输入错误, 请输入正确的数字!"
		else
				break   
		fi
done

[[ ${telecom} == 2 ]] && exit 1

# install speedtest
if  [ ! -e '/tmp/speedtest.py' ]; then
	wget --no-check-certificate -P /tmp https://raw.github.com/sivel/speedtest-cli/master/speedtest.py > /dev/null 2>&1
fi
chmod a+rx /tmp/speedtest.py

speed_test(){
	temp=$(python /tmp/speedtest.py --server $1 --share 2>&1)
	is_down=$(echo "$temp" | grep 'Download') 
	if [[ ${is_down} ]]; then
		local REDownload=$(echo "$temp" | awk -F ':' '/Download/{print $2}')
		local reupload=$(echo "$temp" | awk -F ':' '/Upload/{print $2}')
		local relatency=$(echo "$temp" | awk -F ':' '/Hosted/{print $2}')
		temp=$(echo "$relatency" | awk -F '.' '{print $1}')
		if [[ ${temp} -gt 1000 ]]; then
			relatency=" > 1 s"
		fi
		local nodeID=$1
		local nodeLocation=$2
		local nodeISP=$3

		printf "${RED}%-8s${YELLOW}%-10s${GREEN}%-10s${CYAN}%-16s${BLUE}%-16s${PURPLE}%-10s${PLAIN}\n" "${nodeID}  " "${nodeISP}  " "${nodeLocation}  " "${reupload}  " "${REDownload}  " "${relatency}"
	else
		local cerror="ERROR"
	fi
}

if [[ ${telecom} == 1 ]]; then
	echo "———————————————————————————————————————————————————————————————————"
	printf "%-8s%-10s%-10s%-16s%-16s%-10s\n" "节点ID  " "运营商  " "位置     " "上传速度        " "下载速度        " "延迟"
	start=$(date +%s) 
	# 电信
	speed_test '4595' '郑州' '电信'
	# 联通
	speed_test '5145' '北京1' '联通'
	speed_test '18462' '北京2' '联通'
	speed_test '5505' '北京3' '联通'
	speed_test '5131' '郑州1' '联通'
	speed_test '6810' '郑州2' '联通'
	# 移动
	speed_test '4713' '北京' '移动'
	speed_test '18970' '郑州1' '移动'
	speed_test '4486' '郑州2' '移动'

	end=$(date +%s)  
	rm -rf /tmp/speedtest.py
	echo "———————————————————————————————————————————————————————————————————"
	time=$(( $end - $start ))
	if [[ $time -gt 60 ]]; then
		min=$(expr $time / 60)
		sec=$(expr $time % 60)
		echo -ne "测试完成, 本次测速耗时: ${min} 分 ${sec} 秒"
	else
		echo -ne "测试完成, 本次测速耗时: ${time} 秒"
	fi
	echo -ne "\n当前时间: "
	echo $(date +%Y-%m-%d" "%H:%M:%S)
fi
