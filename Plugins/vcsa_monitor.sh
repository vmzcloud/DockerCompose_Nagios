#!/bin/bash


##########################################
# VTO
# Health Monitoring of VMWARE VCSA via rest API
#
# Changelog :
# 17/11/2017 : V0
##########################################

##########################################
# Variables setup
##########################################
RETURN_CODE=0
RETURN_MESSAGE=""
let API_HEALTH_COUNTER_COUNT=0
let API_HEALTH_COUNTER_OK=0


# Test if we have only one parameter
if [[ "$#" -ne 1 ]]; then echo "A parameter is required : 'vcenter fqdn or IP'"; exit 2; fi
if [[ "$1" =~ "help" ]] || [[ "$1" =~ "?" ]]; then echo "A parameter is required : 'vcenter fqdn or IP'"; exit 2; fi




##########################################
# Source variables from config file
##########################################

# CONFIG_FOLDER=$(dirname $0) to source config file from script dir
# CONFIG_FOLDER=/foo/bar to source from /foo/bar folder
CONFIG_FOLDER=/opt/Custom-Nagios-Plugins/vcsa_cfg

# Source variable from config file or die
if [[ -f $CONFIG_FOLDER/vcsa_monitor_config_$1.ini ]];then
        . $CONFIG_FOLDER/vcsa_monitor_config_$1.ini
else
        echo "Unable to find config file: $CONFIG_FOLDER/vcsa_monitor_config_$1.ini";exit 3 ;
fi

# Test if all expected variables have been found in config file
if [[ -z $VCENTER ]]; then echo "Unable to find variable VCENTER from config file"; exit 3; fi
if [[ -z $USERNAME ]]; then echo "Unable to find variable USERNAME from config file"; exit 3; fi
if [[ -z $PASSWORD ]]; then echo "Unable to find variable PASSWORD from config file"; exit 3; fi




##########################################
# Functions declarations
##########################################
function api_login()
{
# Login to VCSA api and get http SESSION_ID to resuse later
SESSION_ID=$(curl -ks -X POST -H 'Accept: application/json' --basic -u $USERNAME:$PASSWORD $VCENTER/rest/com/vmware/cis/session| python -c 'import json,sys;obj=json.load(sys.stdin);print obj["'value'"]';)
# Test if session is successfull (HTTP code 200) , exit if KO
SESSION_SUCCES_TEST=$(curl -o /dev/null -w "%{http_code}" -ks -X POST --header 'Content-Type: application/json' --header "Accept: application/json" --header "vmware-api-session-id: $SESSION_ID" $VCENTER/rest/com/vmware/cis/session?~action=get)
if [[ $SESSION_SUCCES_TEST != "200" ]];then echo "Unable to login to VCSA API, please check credentials and firewall. Please visit $VCENTER:5480/ ";exit 2 ;fi
}

function get_api_appliance_health ()
{
# Get api "color"
STATUS=$(curl -ks -X GET --header "Accept: application/json" --header "vmware-api-session-id: $SESSION_ID" $VCENTER/rest/appliance/health/$1 2>/dev/null| python -c 'import json,sys;obj=json.load(sys.stdin);print obj["'value'"]';)
# Test if "color" is in range (orange|gray|green|red|yellow)
if  ! [[ "$STATUS" =~ ^(orange|gray|green|red|yellow)$ ]]; then STATUS="n/a" ;fi
#Increment counter of "ok" check if color is green
if    [[ $STATUS = "green" ]];then let API_HEALTH_COUNTER_OK+=1 ;fi
#Increment counter of check executed
let API_HEALTH_COUNTER_COUNT+=1
#add status to output message
RETURN_MESSAGE+="$1 ($STATUS),"
}


##########################################
# Functions execution
##########################################

#Login to api, exit if it fails
api_login

#Get health status of applmgmt services.
get_api_appliance_health applmgmt
#Get database storage health.
get_api_appliance_health database-storage
#Get load health.
get_api_appliance_health load
#Get memory health.
get_api_appliance_health mem
#Get information on available software updates available in remote VUM repository.
#red indicates that security updates are available.
#orange indicates that non security updates are available.
#green indicates that there are no updates available.
#gray indicates that there was an error retreiving information on software updates.
get_api_appliance_health software-packages
#Get storage health.
get_api_appliance_health storage
#Get swap health.
get_api_appliance_health swap
#Get overall health of system.
get_api_appliance_health system


##########################################
# Output and exit code
##########################################
if [[ $API_HEALTH_COUNTER_OK -lt $API_HEALTH_COUNTER_COUNT ]];then
        echo "One or more health checks are not green ($API_HEALTH_COUNTER_OK/$API_HEALTH_COUNTER_COUNT) : $RETURN_MESSAGE Please visit $VCENTER:5480/ "
        exit 2
else
        echo "All ($API_HEALTH_COUNTER_OK/$API_HEALTH_COUNTER_COUNT) VCSA health checks are green : $RETURN_MESSAGE"
        exit 0
fi
