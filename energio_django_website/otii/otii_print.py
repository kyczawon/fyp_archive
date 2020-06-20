#!/usr/bin/env python
import time
import sys, os
from rq import get_current_job
import pandas as pd
import numpy as np

sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))
from otii_tcp_client import otii_connection, otii_exception, otii
from . import config as cfg


def _start(my_arc, voltage, max_current):
    try:
        print(my_arc.name + " supply voltage: " + str(my_arc.get_main_voltage()))
        my_arc.enable_channel("mc", True)
        print(my_arc.name + " enabled channel Main Current")
        my_arc.enable_channel("mv", True)
        print(my_arc.name + " enabled channel Main Voltage")
        my_arc.enable_channel("me", True)
        print(my_arc.name + " enabled channel Main Power")
        my_arc.set_max_current(max_current)
        print(my_arc.name + " set max current to "+str(max_current)+"A")
        my_arc.set_main_voltage(voltage)
        print(my_arc.name + " set max current to "+str(voltage)+"V")
        my_arc.set_main(True)
        print("Set main on")
    except otii_exception.Otii_Exception as e:
            print("Error message: " + e.message)

def _connect():
    try:
        connection = otii_connection.OtiiConnection(cfg.HOST["IP"], cfg.HOST["PORT"])
        connect_response = connection.connect_to_server()
        if connect_response["type"] == "error":
            print("Exit! Error code: " + connect_response["errorcode"] + ", Description: " + connect_response["data"]["message"])
            sys.exit()
        try:
            return otii.Otii(connection)
        except otii_exception.Otii_Exception as e:
            print("Error message: " + e.message)
    except ConnectionRefusedError as e:
        print('exceptions!!!')
        print(e)

def _get_my_arc(otii_object):
    try:
        devices = otii_object.get_devices()
        if len(devices) == 0:
            print("No Arc connected!")
            sys.exit()
        return devices[0]
    except otii_exception.Otii_Exception as e:
            print("Error message: " + e.message)

def _check_create_project(otii_object):
    proj = otii_object.get_active_project()
    if proj:
        print("Project already active")
    else:
        proj = otii_object.create_project()
        print("Project created")
    return proj


def start_otii():
    job = get_current_job()
    otii_object = _connect()
    my_arc = _get_my_arc(otii_object)
    _start(my_arc, 3.85, 3)

def stop_otii():
    job = get_current_job()
    otii_object = _connect()
    my_arc = _get_my_arc(otii_object)
    my_arc.set_main(False)

def start_otii_and_start_recording():
    job = get_current_job()
    otii_object = _connect()
    my_arc = _get_my_arc(otii_object)
    _start(my_arc, 3.85, 3)

    proj = _check_create_project(otii_object)
    proj.start_recording()
    print("Recording started")

def start_recording():
    job = get_current_job()
    otii_object = _connect()
    proj = _check_create_project(otii_object)
    proj.start_recording()
    print("Recording started")

def stop_recording():
    job = get_current_job()
    otii_object = _connect()
    proj = _check_create_project(otii_object)
    proj.stop_recording()
    print("Recording stopped")

def stop_and_get_latest_data():
    job = get_current_job()
    otii_object = _connect()
    my_arc = _get_my_arc(otii_object)
    proj = _check_create_project(otii_object)
    proj.stop_recording()
    print("Recording stopped")

    recording = proj.get_last_recording()
    if recording:
        count_mc = recording.get_channel_data_count(my_arc.id, "mc")
        count_mv = recording.get_channel_data_count(my_arc.id, "mv")
        count_me = recording.get_channel_data_count(my_arc.id, "me")

        mc_data = recording.get_channel_data(my_arc.id, "mc", 0, count_mc)
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

        my_arc.set_main(False)
        print('Otii Stopped')
        
        return df

    else:
        print("No recording in project")
        return pd.DataFrame()
    

# returns the data in a pandas dataframe
def get_latest_data():
    job = get_current_job()
    otii_object = _connect()
    my_arc = _get_my_arc(otii_object)
    proj = _check_create_project(otii_object)
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
        
        return df

    else:
        print("No recording in project")
        return pd.DataFrame()