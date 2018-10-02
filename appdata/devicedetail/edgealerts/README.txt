Place edge alerts JSON files here.

JSON Requirement:
- EdgeManager uses alertType, sourceType, and source as key. When more than one alert has the same values for these 3 fields, 
  only the latest alert will be displayed on EdgeManager UI.
- Timestamp field must be in RFC3399 format (https://www.ietf.org/rfc/rfc3339.txt) and default to the epoch time if not specified. See examples below.
- Refer to Device Detail documentation for a complete list of supported alertType, sourceType, severity and status levels.

Example edge alerts (one file with multiple alerts):

{
    "edgeAlert": [
        {
            "alertType": "SIM_USAGE",
            "deviceId": "device1",
            "sourceType": "ALERT_SOURCE_SIM",
            "source": "8991101200003111111",
            "severity": "ALERT_SEVERITY_ERROR",
            "timestamp": "2017-02-09T02:47:57.178Z",
            "description": "SIM usage exceeded 100% of usage plan",
            "status": "ALERT_STATUS_OPEN"
        },
        {
            "alertType": "CELLULAR_STRENGTH",
            "deviceId": "device2",
            "sourceType": "ALERT_SOURCE_DEVICE",
            "source": "Device12345",
            "severity": "ALERT_SEVERITY_WARNING",
            "timestamp": "2017-02-09T02:47:57.181Z",
            "description": "Cellular signal week",
            "status": "ALERT_STATUS_ACKNOWLEDGED"
        }
    ]
}

Example edge alert (one file with a single alert):

{
    "alertType": "OPENVPN_STATUS",
    "deviceId": "device3",
    "sourceType": "ALERT_SOURCE_DEVICE",
    "source": "Cube224",
    "severity": "ALERT_SEVERITY_CRITICAL",
    "timestamp": "2016-02-09T02:32:57.181Z",
    "description": "OpenVPN disconnected",
    "status": "ALERT_STATUS_CLOSED"
}
