<img src="https://img.shields.io/badge/language-DockerCompose-blue.svg"/> <img src="https://img.shields.io/github/last-commit/vmzcloud/DockerCompose_Nagios.svg"/>

# Nagios

![alt text](nagios_image.png "Nagios")

[DockerHub](https://hub.docker.com/r/jasonrivers/nagios)

## docker-compose.yml

<pre>
services:
  nagios:
    image: jasonrivers/nagios:4.4.8
    container_name: nagios
    restart: always
    environment:
      TZ: 'Asia/Hong_Kong'
    volumes:
      - ./cgi.cfg:/opt/nagios/etc/cgi.cfg
      - ./nagios.cfg:/opt/nagios/etc/nagios.cfg
      - ./conf.d:/opt/nagios/etc/conf.d
      - ./nagiosgraph_var:/opt/nagiosgraph/var
      - ./Plugins:/opt/Custom-Nagios-Plugins
      - ./SNMPv2-PDU:/usr/share/snmp/mibs/ietf/SNMPv2-PDU
    ports:
      - 8080:80
    ulimits:
      nofile:
        soft: 32768
        hard: 32768
</pre>

## cgi.cfg
Default refresh rate is 90 seconds
<pre>
  refresh_rate=30
</pre>

# conf.d

## objects/servicegroup.cfg
<pre>
define servicegroup{
        servicegroup_name  UPS
        alias              UPS
        }

define servicegroup{
        servicegroup_name  NAS
        alias              NAS
        }
</pre>

# Plugins

## vcsa_montior

[Reference](https://exchange.nagios.org/directory/Plugins/Operating-Systems/%2A-Virtual-Environments/VMWare/vcsa_monitor-2Esh/details?__hstc=53274167.81f04695664b9dc054b5f524eb53b5a4.1510963200069.1510963200070.1510963200071.1&__hssc=53274167.1.1510963200072&__hsfp=528229161)

You need to create a config file - vcsa_monitor_config_{VCSA_URL_ip_address}.ini
<pre>
#------------------#
#    properties    #
#------------------#
VCENTER=https://{VCSA_URL_ip_address}
USERNAME="username" #create a specific monitoring user instead
PASSWORD="password"
</pre>

### command
<pre>
  define command {
    command_name   vcsa_monitor
    command_line   /opt/Custom-Nagios-Plugins/vcsa_monitor.sh $HOSTADDRESS$
    register 1
}
</pre>

### Example
<pre>
  /opt/Custom-Nagios-Plugins/vcsa_monitor.sh 10.23.34.45
</pre>
<pre>
  One or more health checks are not green (6/8) : applmgmt (green),database-storage (green),load (green),mem (orange),software-packages (green),storage (green),swap (green),system (orange), Please visit https://10.23.34.45:5480/
</pre>
