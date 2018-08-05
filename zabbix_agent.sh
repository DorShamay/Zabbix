#!/usr/bin/env bash

###############################################
#                                             #
# Porpuse : Installing and configuring Agent  #
# Version : 0.0.1                             #
# Creator : DorShamay                         #
#                                             #
###############################################


echo "Welcome to Zabbix-Agent installation script"
sleep 3



Checkroot()
{
if [ $(id -u) != "0" ]; then
		echo "You are not root , Exiting"
		exit 1;
	fi
}

read -p "Please enter your Zabbix-Server IP. " Serv

yum -y update
rpm -ivh http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm
yum -y install zabbix-agent
  if [ $? -ne 0 ]; then
    echo "Zabbix Agent didn't installed successfully please try again"
  yum -y install zabbix-agent
sed -i 's/Server=127.0.0.1/Server=$Serv/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=$Serv/' /etc/zabbix/zabbix_agentd.conf
HOSTNAME=`hostname` && sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf
service zabbix-agent restart
