mkdir zabbix
cd zabbix
hostname > myFile1.txt
set /p hn= < myFile1.txt
cd C:\
copy "zabbix_agentd.exe" "C:\zabbix"
copy "zabbix_agentd.win.conf" "C:\zabbix"
cd zabbix
powershell -Command "(gc zabbix_agentd.win.conf) -replace 'ServerActive=127.0.0.1', 'ServerActive=82.166.70.94' | sc zabbix_agentd.win.conf
powershell -Command "(gc zabbix_agentd.win.conf) -replace 'Hostname=Windows host', 'Hostname=%hn%' | sc zabbix_agentd.win.conf
C:\zabbix\zabbix_agentd.exe --config C:\zabbix\zabbix_agentd.win.conf --install
netsh advfirewall firewall add rule name="Allow Zabbix" dir=in action=allow program="C:\zabbix\zabbix_agentd.exe"
netsh advfirewall firewall add rule name="Allow Zabbix" dir=out action=allow program="C:\zabbix\zabbix_agentd.exe"
C:\zabbix\zabbix_agentd.exe --start
echo "This script was created by DorShamay"
