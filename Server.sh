#!/usr/bin/env bash


#####################################################
#
#
#
#
#
#####################################################

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
select yesno in "Yes" "No"
  do
    case $yesno in
      Yes)
      ZabIns
      ;;
      No)
      echo "Are you sure? "
      ;;
      *)
      echo "Please enter a valid selection"
    esac
  done
}

ZabIns()
{
  echo "Lets shut down this fking SELinux first "
  setenforce 0
  firewall-cmd --add-port=10051/tcp --permanent
  firewall-cmd --add-port=80/tcp --permanent
  echo "Let's add some Zabbix repositories "
  rpm -ivh https://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
  echo "Frontend Installation prerequisties"
  yum install yum-utils --noconfirm
  yum-config-manager --enable rhel-7-server-optional-rpms
  yum install zabbix-server-mysql
  yum install zabbix-server-mysql mariadb mariadb-server --noconfirm
  systemctl enable mariadb
  systemctl start mariadb
  yum install zabbix-proxy-mysql --noconfirm
  yum install zabbix-web-mysql --noconfirm
  echo "|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|"
  echo "Enter root SQL password"
  echo "|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|"
  mysql -u root -ppassword -e "create database zabbix character set utf8 collate utf8_bin;"
  mysql -u root -ppassword -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"
  echo "|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|"
  echo "Enter zabbix SQL password"
  echo "|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|"
  zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -pzabbix zabbix
  sed -i -e 's/# DBHost=localhost/DBHost=localhost/g' /etc/zabbix/zabbix_server.conf

  sed -i -e 's/# DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf

  yum insatll httpd --noconfirm
  systemctl enable httpd
  systemctl enable zabbix-server
  systemctl restart zabbix-server
  systemctl restart httpd
}

Checkroot
Menu
