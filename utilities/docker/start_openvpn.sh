#!/bin/bash

# Assumptions:
#    When container is first started, this script will exit since configs wont be copied in /data mount right away.
#        Thats ok, since container wont be enrolled yet
#    When container updates, configs will already be there, this script will procede if both config files are configured properly.

configuration_dir=/data/configuration
machine_config_dir=${configuration_dir}/machine
openvpn_config_dir=${configuration_dir}/openvpn

connectivity_config_file=com.ge.dspmicro.predix.connectivity.openvpn.config
openvpn_config_file=predix-client.conf

connectivity_enabled_property=com.ge.dspmicro.predix.connectivity.openvpn.management.enabled

openvpn_dir=/data/openvpn

# Exit if either predix.connectivity files is missing.
if [[ ! -f ${machine_config_dir}/${connectivity_config_file} ]]; then
    echo "Connectivity configuration has not been moved to data mount"
    exit
fi

# Exit if predix-client.conf files is missing.
if [[ ! -f ${openvpn_config_dir}/${openvpn_config_file} ]]; then
    echo "OpenVPN Configuration does not exist."
    exit
fi

# Exit if connectivity management property is not enabled
connectivity_enabled_value=$(grep -F "${connectivity_enabled_property}" ${machine_config_dir}/${connectivity_config_file} | cut -d "=" -f 2)
if [[ ${connectivity_enabled_value} != *"true"* ]]; then
    echo "OpenVPN management is not enabled."
    exit
fi

# Find host openvpn is configured to talk to
remote_host=
while IFS='' read -r line || [[ -n "${line}" ]]; do
    if [[ ${line} == "remote "* ]]; then
        remote_host=${line}
        echo "OpenVPN host property found: ${line}"
        break
    fi
done < "${openvpn_config_dir}/${openvpn_config_file}"

# Exit if there is no host configured in openvpn configuration file
if [[ -z ${remote_host} ]]; then
    echo "OpenVPN Host not found in openvpn configuration file."
    exit
fi

openvpn_log_file="openvpn.log"

# Start the openvpn client.
echo "Starting OpenVPN"
while [ 1 ];do
    ps -ef | grep "openvpn --config" | grep -v grep > /dev/null
    if [ $? = 1 ]; then
        /usr/sbin/openvpn --config ${openvpn_config_dir}/${openvpn_config_file} --log-append ${openvpn_dir}/${openvpn_log_file} &
    fi
    sleep 30
done
