#!/usr/bin/env python
import time
import sys, os
sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))

from otii_tcp_client import otii_connection, otii_exception, otii
import config as cfg

connection = otii_connection.OtiiConnection(cfg.HOST["IP"], cfg.HOST["PORT"])
connect_response = connection.connect_to_server()
if connect_response["type"] == "error":
    print("Exit! Error code: " + connect_response["errorcode"] + ", Description: " + connect_response["data"]["message"])
    sys.exit()
try:
    otii_object = otii.Otii(connection)
    devices = otii_object.get_devices()
    if len(devices) == 0:
        print("No Arc connected!")
        sys.exit()
    my_arc = devices[0]
    my_arc.set_main(False)
    print("Set main off")

except otii_exception.Otii_Exception as e:
    print("Error message: " + e.message)

print("Done!")
