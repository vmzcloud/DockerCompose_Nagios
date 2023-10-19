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

# Plugins

## vcsa_montior

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
