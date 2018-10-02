#!/bin/bash

if [[ -z ${RUNNING_ENVIRONMENT} ]]; then
  echo "Predix Machine container not started properly. No host OS environment found in environment variables."
  echo "Please include the host OS environment (RUNNING_ENVIRONMENT) in the environment variables or use the bootstrap container to start the Predix Machine container."
  exit 1
elif [[ ${RUNNING_ENVIRONMENT} == "Darwin" ]]; then
  # Check if docker group already exists
  getent group docker &>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "docker group found."
  else
    echo "No Docker group found... adding docker group."
    addgroup docker
  fi

  # Check if predixmachine user already exists
  id predixmachine &>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "predixmachine user found."
  else
    echo "No predixmachine user found... adding predixmachine user."
    adduser -D predixmachine
  fi

  # Check if the predixmachine user is part of the docker group
  getent group docker | grep predixmachine &>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "The predixmachine user is already part of the docker group."
  else
    echo "The predixmachine user is not part of the docker group... adding to the group."
    adduser predixmachine docker
  fi

  # Need to change ownership of docker.sock when using Docker for Mac
  chown predixmachine:docker /var/run/docker.sock
else
  # Check for Host UID and Docker GID in env variables
  if [[ -z ${HOST_UID} ]]; then
    echo "Predix Machine container not started properly. No host UID found in environment variables."
    echo "Please include the host user's UID (HOST_UID) and the docker group's GID (DOCKER_GID) in the environment variables or use the bootstrap container to start the Predix Machine container."
    exit 1
  elif [[ -z ${DOCKER_GID} ]]; then
    echo "Predix Machine container not started properly. No Docker GID found in environment variables."
    echo "Please include the docker group's GID (DOCKER_GID) in the environment variables or use the bootstrap container to start the Predix Machine container."
    exit 1
  fi

  # Check if docker group already exists
  getent group docker &>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "docker group found."
  else
    echo "No Docker group found... adding with GID=${DOCKER_GID}."
    addgroup -g ${DOCKER_GID} docker
  fi

  # Check if predixmachine user already exists
  id predixmachine &>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "predixmachine user found."
  else
    echo "No predixmachine user found... adding with UID=${HOST_UID}."
    adduser -u ${HOST_UID} -D predixmachine
  fi

  # Check if the predixmachine user is part of the docker group
  getent group docker | grep predixmachine &>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "The predixmachine user is already part of the docker group."
  else
    echo "The predixmachine user is not part of the docker group... adding to the group."
    adduser predixmachine docker
  fi
fi

# Prepare for openvpn container if start_openvpn script exists
if [[ -f /PredixMachine/bin/start_openvpn.sh ]]; then
    # If configuration directory hasnt been moved
    #   Modify predix-connectivity config and create openvpn dir within
    if [[ -d /PredixMachine/configuration ]]; then
        pm_config_dir=/PredixMachine/configuration/machine
        connectivity_config_file=com.ge.dspmicro.predix.connectivity.openvpn.config
        sed -i "s/^\(com.ge.dspmicro.predix.connectivity.openvpn.conf.dir=\).*/\1\"\/data\/configuration\/openvpn\"/g" ${pm_config_dir}/${connectivity_config_file}
        sed -i "s/^\(com.ge.dspmicro.predix.connectivity.openvpn.logs.directory=\).*/\1\"\/data\/openvpn\"/g" ${pm_config_dir}/${connectivity_config_file}
        sed -i "s/^\(com.ge.dspmicro.predix.connectivity.openvpn.certificate.directory=\).*/\1\"\/data\/openvpn\"/g" ${pm_config_dir}/${connectivity_config_file}

        ovpn_config_dir=/PredixMachine/configuration/openvpn
        mkdir ${ovpn_config_dir}
        mv /PredixMachine/openvpn/predix-client.conf ${ovpn_config_dir}
    fi

    # Start OpenVPN as root.
    /bin/bash /PredixMachine/bin/start_openvpn.sh &
else
  # If no openvpn found and predix connectivity configuration is found, disable connectivity so predix machine doesnt complain since there is no openvpn
  if [[ -f /data/configuration/machine/com.ge.dspmicro.predix.connectivity.openvpn.config ]]; then
    data_config_dir=/data/configuration/machine
    connectivity_config_file=com.ge.dspmicro.predix.connectivity.openvpn.config
    sed -i "s/^\(com.ge.dspmicro.predix.connectivity.openvpn.management.enabled=\).*/\1\"false\"/g" ${data_config_dir}/${connectivity_config_file}
  fi
fi

# Change file permissions and ownership
chown -R predixmachine:docker /PredixMachine
chown -R predixmachine:docker /data
chmod -R g=u /PredixMachine
chmod -R g=u /data

# Run predix machine
su -m -s /bin/sh -c '/PredixMachine/bin/docker_start_predixmachine.sh' predixmachine
