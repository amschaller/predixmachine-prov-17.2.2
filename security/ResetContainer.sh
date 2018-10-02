#!/bin/sh
# Copyright (c) 2012-2017 General Electric Company. All rights reserved.
# The copyright to the computer software herein is the property of
# General Electric Company. The software may be used and/or copied only
# with the written permission of General Electric Company or in accordance
# with the terms and conditions stipulated in the agreement/contract
# under which the software has been supplied.

# Sets a property value in the provided config file
# Arguments:
#  $1 the full path to the property file
#  $2 the key of the property to replace
#  $3 the value of the property
set_property()
{
    if [ -f "$1" ]; then
        if test `uname` = 'Darwin'; then
            # Mac needs the blank backup specified. Linux issue warnings if specified.
            sed -i '' -e "s;\($2 *= *\).*;\1$3;g" "$1"
        else
            sed -i -e "s;\($2 *= *\).*;\1$3;g" "$1"
        fi
    fi
    sync
}

rm_keystore()
{
    rm -f "$PREDIX_MACHINE_DATA/$KEYSTORE_PATH"
    set_property "$SECURITYADMIN_CFG_PATH" "$KEYSTORE_PATH_PROP" ""
    set_property "$SECURITYADMIN_CFG_PATH" "$KEYSTORE_TYPE_PROP" ""
    set_property "$SECURITYADMIN_CFG_PATH" "$KEYSTORE_PW_PROP" ""
    set_property "$SECURITYADMIN_CFG_PATH" "$KEYSTORE_PW_ENCRYPT_PROP" ""
    set_property "$SECURITYADMIN_CFG_PATH" "$KEYSTORE_KEY_PW_PROP" ""
    set_property "$SECURITYADMIN_CFG_PATH" "$KEYSTORE_KEY_PW_ENCRYPT_PROP" ""
    set_property "$SECURITYADMIN_CFG_PATH" "$KEYSTORE_KEY_ALIAS_PROP" ""
    sync
}


START_ORIGIN="$(pwd)"
cd "$(dirname "$0")/.."
PREDIX_MACHINE_HOME=$(pwd)
PREDIX_MACHINE_DATA=${PREDIX_MACHINE_DATA_DIR-$PREDIX_MACHINE_HOME}
SECURITYADMIN_CFG_PATH="$PREDIX_MACHINE_DATA"/security/com.ge.dspmicro.securityadmin.cfg

if [ ! -e "$SECURITYADMIN_CFG_PATH" ]; then 
    echo "The parent installation is not a Predix Machine. Run this script from the PredixMachine/security."
    exit 1
fi

if [ -f "$PREDIX_MACHINE_DATA/security/lock" ]; then
    # stop any running machine.
    sh "$PREDIX_MACHINE_HOME/bin/stop_predixmachine.sh"
fi

# remove the keystores.
KEYSTORE_PATH=security/tls_client_keystore.jks
KEYSTORE_PATH_PROP=com.ge.dspmicro.securityadmin.sslcontext.client.keystore.path
KEYSTORE_TYPE_PROP=com.ge.dspmicro.securityadmin.sslcontext.client.keystore.type
KEYSTORE_PW_PROP=com.ge.dspmicro.securityadmin.sslcontext.client.keystore.password
KEYSTORE_PW_ENCRYPT_PROP=com.ge.dspmicro.securityadmin.sslcontext.client.keystore.password.encrypted
KEYSTORE_KEY_PW_PROP=com.ge.dspmicro.securityadmin.sslcontext.client.keymanager.password
KEYSTORE_KEY_PW_ENCRYPT_PROP=com.ge.dspmicro.securityadmin.sslcontext.client.keymanager.password.encrypted
KEYSTORE_KEY_ALIAS_PROP=com.ge.dspmicro.securityadmin.sslcontext.client.keymanager.alias
rm_keystore

KEYSTORE_PATH=security/tls_server_keystore.jks
KEYSTORE_PATH_PROP=com.ge.dspmicro.securityadmin.sslcontext.server.keystore.path
KEYSTORE_TYPE_PROP=com.ge.dspmicro.securityadmin.sslcontext.server.keystore.type
KEYSTORE_PW_PROP=com.ge.dspmicro.securityadmin.sslcontext.server.keystore.password
KEYSTORE_PW_ENCRYPT_PROP=com.ge.dspmicro.securityadmin.sslcontext.server.keystore.password.encrypted
KEYSTORE_KEY_PW_PROP=com.ge.dspmicro.securityadmin.sslcontext.server.keymanager.password
KEYSTORE_KEY_PW_ENCRYPT_PROP=com.ge.dspmicro.securityadmin.sslcontext.server.keymanager.password.encrypted
KEYSTORE_KEY_ALIAS_PROP=com.ge.dspmicro.securityadmin.sslcontext.server.keymanager.alias
rm_keystore

KEYSTORE_PATH=security/misc_keystore.jks
KEYSTORE_PATH_PROP=com.ge.dspmicro.securityadmin.default.keystore.path
KEYSTORE_TYPE_PROP=com.ge.dspmicro.securityadmin.default.keystore.type
KEYSTORE_PW_PROP=com.ge.dspmicro.securityadmin.default.keystore.password
KEYSTORE_PW_ENCRYPT_PROP=com.ge.dspmicro.securityadmin.default.keystore.password.encrypted
KEYSTORE_KEY_PW_PROP=com.ge.dspmicro.securityadmin.default.keystore.aliasPassword
KEYSTORE_KEY_PW_ENCRYPT_PROP=com.ge.dspmicro.securityadmin.default.keystore.aliasPassword.encrypted
KEYSTORE_KEY_ALIAS_PROP=com.ge.dspmicro.securityadmin.default.keystore.alias
rm_keystore

KEYSTORE_PATH=security/secretkey_keystore.jceks
KEYSTORE_PATH_PROP=com.ge.dspmicro.securityadmin.encryption.keystore.path
KEYSTORE_TYPE_PROP=com.ge.dspmicro.securityadmin.encryption.keystore.type
KEYSTORE_PW_PROP=com.ge.dspmicro.securityadmin.encryption.keystore.password
KEYSTORE_PW_ENCRYPT_PROP=com.ge.dspmicro.securityadmin.encryption.keystore.password.encrypted
KEYSTORE_KEY_PW_PROP=com.ge.dspmicro.securityadmin.encryption.alias.password
KEYSTORE_KEY_PW_ENCRYPT_PROP=com.ge.dspmicro.securityadmin.encryption.alias.password.encrypted
KEY_ALIAS_PROP=com.ge.dspmicro.securityadmin.encryption.alias
rm_keystore

# no props setting with opcua files.
KEYSTORE_PATH=security/opcua_keystore.jks
rm -f "$PREDIX_MACHINE_DATA/$KEYSTORE_PATH"

KEYSTORE_PATH=security/opcuaserver_keystore.jks
rm -f "$PREDIX_MACHINE_DATA/$KEYSTORE_PATH"

# cleanup truststores - hash is the same so dont do this.

# cleanup security extra files.
rm -f "$PREDIX_MACHINE_DATA/security/users.store"
rm -f "$PREDIX_MACHINE_DATA/security/lock"
sync

# clean up tmp storage.
rm -f "$PREDIX_MACHINE_HOME/machine/bin/predix/predix.home.prs"
rm -rf "$PREDIX_MACHINE_HOME/machine/bin/vms/jdk/storage"
sync

# clean up logs
cd "$PREDIX_MACHINE_DATA/logs/machine"
rm -f *.log
rm -f *.log.gz
cd "$PREDIX_MACHINE_DATA/logs/installations"
rm -f *.log
cd $PREDIX_MACHINE_HOME
rm -f "$PREDIX_MACHINE_DATA/security/prosyst/8.1/domain.crp.old"
sync

# remove appdata file folders
rm -rf "$PREDIX_MACHINE_DATA/appdata/cloudgateway"
rm -rf "$PREDIX_MACHINE_DATA/appdata/packageframework"
rm -rf "$PREDIX_MACHINE_DATA/appdata/statusdir"
rm -rf "$PREDIX_MACHINE_DATA/appdata/storeforward"
sync

# remove old installations
rm -rf "$PREDIX_MACHINE_HOME/configuration.old"
rm -rf "$PREDIX_MACHINE_HOME/machine.old"
rm -rf "$PREDIX_MACHINE_HOME/yeti.old"

cd "$PREDIX_MACHINE_DATA/installations"
rm -f *.zip
rm -f *.zip.sig
sync

#
# configuration folder
#
cd "$PREDIX_MACHINE_DATA/configuration/machine"

# Client Indentity
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.oauth.authorize.url" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.uaa.enroll.url" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.uaa.token.url" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.uaa.clientid" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.uaa.clientsecret" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.uaa.clientsecret.encrypted" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.deviceid" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.deviceuuid" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.tenantid" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.mac" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.cloud.upload.url" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.yeti.signature.url" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.enroll.sharedSecret" "\"\""
set_property "com.ge.dspmicro.predixcloud.identity.config" "com.ge.dspmicro.predixcloud.identity.enroll.sharedSecret.encrypted" "\"\""

# Git
set_property "com.ge.dspmicro.gitrepository.config" "com.ge.dspmicro.gitrepository.credentials.password.encrypted" "\"\""

# OPCUA adapter - assumes 1
set_property "com.ge.dspmicro.machineadapter.opcua-0.config" "com.ge.dspmicro.machineadapter.opcua.keystore.password.encrypted" "\"\""
set_property "com.ge.dspmicro.machineadapter.opcua-0.config" "com.ge.dspmicro.machineadapter.opcua.key.password.encrypted" "\"\""
set_property "com.ge.dspmicro.machineadapter.opcua-0.config" "com.ge.dspmicro.machineadapter.opcua.truststore.password.encrypted" "\"\""
set_property "com.ge.dspmicro.machineadapter.opcua-0.config" "com.ge.dspmicro.machineadapter.opcua.server.password.encrypted" "\"\""

# MQTT adapter - assumes 1
set_property "com.ge.dspmicro.machineadapter.mqtt-0.config" "com.ge.dspmicro.machineadapter.mqtt.password.encrypted" "\"\""

# MQTT river - assumes 1
set_property "com.ge.dspmicro.mqttriver.send-0.config" "com.ge.dspmicro.mqttriver.send.password.encrypted" "\"\""

# store and forward - assumes 1
set_property "com.ge.dspmicro.storeforward-0.config" "com.ge.dspmicro.storeforward.databasePassword.encrypted" "\"\""
set_property "com.ge.dspmicro.storeforward-0.config" "com.ge.dspmicro.storeforward.encryptionPassword.encrypted" "\"\""

# Gatway store and forward
set_property "com.ge.dspmicro.storeforward-taskstatus.config" "com.ge.dspmicro.storeforward.databasePassword.encrypted" "\"\""
set_property "com.ge.dspmicro.storeforward-taskstatus.config" "com.ge.dspmicro.storeforward.encryptionPassword.encrypted" "\"\""

# Re-enable tech console for enrollment.
set_property "com.ge.dspmicro.device.techconsole.config" "com.ge.dspmicro.device.techconsole.console.enabled" "B\"true\""

# Re-set open vpn to disabled
set_property "com.ge.dspmicro.predix.connectivity.openvpn.config" "com.ge.dspmicro.predix.connectivity.openvpn.management.enabled" "B\"false\""

echo "Predix Machine reset complete."
cd $PREDIX_MACHINE_HOME
