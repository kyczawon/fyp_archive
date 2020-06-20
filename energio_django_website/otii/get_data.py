#!/usr/bin/env python
#encoding: utf-8
import sys, os
sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))

from otii_tcp_client import otii_connection, otii_exception, otii
import config as cfg
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

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
    proj = otii_object.get_active_project()
    recording = proj.get_last_recording()
    if recording:
        count_mc = recording.get_channel_data_count(my_arc.id, "mc")
        count_mv = recording.get_channel_data_count(my_arc.id, "mv")
        count_me = recording.get_channel_data_count(my_arc.id, "me")

        mc_data = recording.get_channel_data( my_arc.id, "mc", 0, count_mc)
        mv_data = recording.get_channel_data(my_arc.id, "mv", 0, count_mv)
        me_data = recording.get_channel_data(my_arc.id, "me", 0, count_me)

        index_mc = np.round(np.arange(mc_data['timestamp'], mc_data['interval']*count_mc+mc_data['timestamp'], mc_data['interval']), 5)
        index_mv = np.round(np.arange(mv_data['timestamp'], mv_data['interval']*count_mv+mv_data['timestamp'], mv_data['interval']), 5)
        index_me = np.round(np.arange(me_data['timestamp'], me_data['interval']*count_me+me_data['timestamp'], me_data['interval']), 5)

        # Intialise data to Dicts of series. 
        d = {'current (A)': pd.Series(mc_data['values'], index=index_mc), 
            'voltage (V)': pd.Series(mv_data['values'], index=index_mv),
            'Energy (J)': pd.Series(me_data['values'], index=index_me)} 
        
        # creates Dataframe. 
        df = pd.DataFrame(d)
        df.index.name = 'timestamp'
        df.to_csv('test.csv')

        # df.plot()
        # plt.show()



    else:
        print("No recording in project")
except otii_exception.Otii_Exception as e:
    print("Error message: " + e.message)

print("Done!")
