Place device properties JSON file here.

Device properties include any application-specific information of the device.

JSON Requirement:
- File must contain the full set of properties. Edge Manager services replace the old information with the new list.
- Timestamp field must be in RFC3399 format (https://www.ietf.org/rfc/rfc3339.txt) and default to the epoch time if not specified. See examples below.
- Only one file is expected. If more than one file is found, the first valid file will be used. Extra files will be renamed to <filename>.extra.<timestamp>.
- Device properties are arbitrary key-values. Keys (like "location" in the example) are strings. Value structure contains a string representation of 
  the value and the data type of the value. Refer to Device Detail documentation for a complete list of supported data type.

Format:
{
    "attributes": {
        "key": {
            "value": "some value",
            "dataType": "DATATYPE_STRING"
        },
        ...
    }
}

Example device properties:
{
    "attributes": {
        "location": {
            "value": "4 World Trade Center, New York, NY",
            "dataType": "DATATYPE_STRING"
        },
        "building_type": {
            "value": "high-rise",
            "dataType": "DATATYPE_STRING"
        },
        "elevator_number": {
            "value": "37",
            "dataType": "DATATYPE_INT"
        },        
        "capacity (lbs)": {
            "value": "8000",
            "dataType": "DATATYPE_INT"
        },
        "speed (fpm)": {
            "value": "2000",
            "dataType": "DATATYPE_INT"
        },
        "in_service": {
            "value": "true",
            "dataType": "DATATYPE_BOOLEAN"
        },
        "install_timestamp": {
            "value": "2016-10-25T03:54:43.230Z",
            "dataType": "DATATYPE_TIMESTAMP"
        },        
        "some_prop": {
            "value": "9223372036854775807",
            "dataType": "DATATYPE_LONG"
        },
        "another_prop": {
            "value": "1.7976931348623157E308",
            "dataType": "DATATYPE_DOUBLE"
        },
        "more_prop": {
            "value": "3.4028235E38",
            "dataType": "DATATYPE_FLOAT"
        },
        "log": {
            "value": "XDFDSLKFIERTW*EGJ$%($%*HFKDF",
            "dataType": "DATATYPE_BINARY"
        }
    }
}
