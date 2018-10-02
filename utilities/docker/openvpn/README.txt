
*************************** Openvpn ****************************

This folder contains the openvpn related configurations, scripts, and certificates needed to run.

client-down.sh                 - Script called when TUN device is opened

client-up.sh                   - Script called when TUN device is closed

predix-ca.crt                  - Predix root certificate

client.crt                     - A Predix Machine signed certificate (Placed here by Predix Machine
                                 once it is enrolled with edge manager and predix-connectivity is properly
                                 configured)

predix-client.conf              - Configuration properties for the OpenVPN application.


NOTE: The following directories do not exist, but could be added to run GE owned scripts

ge-client-up.d/                - Any GE owned scripts that will run when called by client-up.sh

ge-client-down.d/              - Any GE owned scripts that will run when called by client-down.sh
