#!/usr/bin/env bash


#####################################################
#
#
#
#
#
#####################################################

#!/bin/bash

Zabbix_Server = $(yum install zabbix-server-mysql mariadb mariadb-server -y)


echo "Welcome to Zabbix-Server installation script"

Checkroot()
{
if [ $(id -u) != "0" ]; then
		echo "You are not root , Exiting"
		exit 1;
	fi
}

Menu()
{
echo "Would you like to install Zabbix Server now? "
select yesno in
  do
    case $yesno in
      yes)
      ZabIns
      ;;
      no)
      echo "Are you sure? "
      ;;
      *)
      echo "Please enter a valid selection"
    esac
  done
}

ZabIns()
{
echo "Would you like to add rule to SELinux or to shut it down? "
select selinux in "Add-Rule" "Shut-Down"
  do
    case $selinux in
      Add-Rule)
      SELinuxRule
      ;;
      Shut-Down)
      SELinuxShut
      ;;
      *)
      echo "Please enter a valid Selection"
    esac
  done
}

SELinuxRule()
{
  setsebool -P httpd_can_connect_zabbix on
  if [ $? -eq 0 ]; then
    echo "Rule has been added successfully"
  else
    echo "Rule didn't added to the SELinux rules ."
  ZabIns
}
SELinuxShut()
{
setenforce 0
  if [ $? -eq 0 ]; then
    echo "SELinux has been disabled successfully."
  FirewallRule
  else
    echo "SELinu still active for some reason."
  getenforce
  ZabIns
}

FirewallRule()
{
  echo "Let's add some Firewall rules"
    firewall-cmd --permanent --add-port=10051/tcp
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=10050/tcp
  if [ $? -eq 0 ]; then
    echo "Rules has been successfully added"
    Prerequisites
  else
    read -p "Something went wrong would you like to try again [Y|N]?" ans
    if [ $ans = N ]; then
      FirewallRule
}

Prerequisites()
{
  echo "Adds Zabbix repository for RHEL7"
  rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm

  echo "Instaling Zabbix Server/MariaDB"
  yum install yum-utils -y
  yum-config-manager --enable rhel-7-server-optional-rpms
  yum install zabbix-server-mysql mariadb mariadb-server -y
    if [ $? -ne 0 ]; then
      read -p "Something went wrong would you like to try again?" good
      if [ $good = N ]; then
        $Zabbix_Server
        Prerequisites
  systemctl enable mariadb --now
}
mysql_secure_installation <<_EOF_

y
password
password
y
y
y
y
_EOF_


echo ""
echo "Enter root SQL password"
echo ""
mysql -u root -ppassword -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -u root -ppassword -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"

echo ""
echo "Enter zabbix SQL password"
echo ""
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -pzabbix zabbix
sed -i -e 's/# DBHost=localhost/DBHost=localhost/g' /etc/zabbix/zabbix_server.conf
sed -i -e 's/# DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf
systemctl enable zabbix-server --now

Httpd()
{
  echo "Need to install httpd to configure zabbix access"
  select httpd in "Yes" "No"
    do
      case $httpd in
        Yes)
        Httpd1
        ;;
        No)
        echo "Okay , I guess you have already apache server. "
        Httpd2
        ;;
        *)
        echo "Please enter a valid Selection"
      esac
    done
}
Httpd1()
{
  yum install httpd -y
  systemctl enable httpd --now
  yum install zabbix-web-mysql -y
  sed -i -e 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Asia\/Jerusalem/g' /etc/httpd/conf.d/zabbix.conf
  systemctl restart httpd
}

Httpd2()
{
  yum install zabbix-web-mysql -y
  sed -i -e 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Asia\/Jerusalem/g' /etc/httpd/conf.d/zabbix.conf
}

Checkroot
Menu
