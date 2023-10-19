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
