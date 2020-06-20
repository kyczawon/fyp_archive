#!/usr/bin/env python
import time
import sys, os
from rq import get_current_job
import pandas as pd
import numpy as np

sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))
from otii_tcp_client import otii_connection, otii_exception, otii
from . import config as cfg

def _append_string(job, message):
    if 'message' in  job.meta:
        job.meta['message'] += (message + "\n")
    else:
         job.meta['message'] = (message + "\n")
    job.save_meta()

def _start(job, my_arc, voltage, max_current):
    try:
        _append_string(job, my_arc.name + " supply voltage: " + str(my_arc.get_main_voltage()))
        my_arc.enable_channel("mc", True)
        _append_string(job, my_arc.name + " enabled channel Main Current")
        my_arc.enable_channel("mv", True)
        _append_string(job, my_arc.name + " enabled channel Main Voltage")
        my_arc.enable_channel("me", True)
        _append_string(job, my_arc.name + " enabled channel Main Power")
        my_arc.set_max_current(max_current)
        _append_string(job, my_arc.name + " set max current to "+str(max_current)+"A")
        my_arc.set_main_voltage(voltage)
        _append_string(job, my_arc.name + " set max current to "+str(voltage)+"V")
        my_arc.set_main(True)
        _append_string(job, "Set main on")
    except otii_exception.Otii_Exception as e:
        _append_string(job, 'Otii Exception while starting')

def _connect(job):
    try:
        connection = otii_connection.OtiiConnection(cfg.HOST["IP"], cfg.HOST["PORT"])
        connect_response = connection.connect_to_server()
        if connect_response["type"] == "error":
            _append_string(job, "Exit! Error code: " + connect_response["errorcode"] + ", Description: " + connect_response["data"]["message"])
            sys.exit()
        try:
            return otii.Otii(connection)
        except otii_exception.Otii_Exception as e:
            _append_string(job, "Error connecting to Otii TCP server")
    except ConnectionRefusedError as e:
        _append_string(job, 'Otii ConnectionRefusedError')

def _get_my_arc(job, otii_object):
    try:
        devices = otii_object.get_devices()
        if len(devices) == 0:
            _append_string(job, "No Arc connected!")
            sys.exit()
        return devices[0]
    except otii_exception.Otii_Exception as e:
            _append_string(job, "Error connecting to Otii TCP server")

def _check_create_project(job, otii_object):
    proj = otii_object.get_active_project()
    if proj:
        _append_string(job, "Project already active")
    else:
        proj = otii_object.create_project()
        _append_string(job, "Project created")
    return proj

# calibrate on start
def start_otii():
    job = get_current_job()
    otii_object = _connect(job)
    my_arc = _get_my_arc(job, otii_object)
    my_arc.calibrate()
    _start(job, my_arc, 3.87, 3)

def stop_otii():
    job = get_current_job()
    otii_object = _connect(job)
    my_arc = _get_my_arc(job, otii_object)
    my_arc.set_main(False)

def start_otii_and_start_recording():
    job = get_current_job()
    otii_object = _connect(job)
    my_arc = _get_my_arc(job, otii_object)
    _start(job, my_arc, 3.87, 3)
    proj = _check_create_project(job, otii_object)
    proj.start_recording()
    _append_string(job, "Recording started")

# calibrate before each recording
def start_recording():
    job = get_current_job()
    otii_object = _connect(job)
    proj = _check_create_project(job, otii_object)
    proj.start_recording()
    _append_string(job, "Recording started")

def stop_recording():
    job = get_current_job()
    otii_object = _connect(job)
    proj = _check_create_project(job, otii_object)
    proj.stop_recording()
    _append_string(job, "Recording stopped")

def stop_and_get_latest_data():
    job = get_current_job()
    otii_object = _connect(job)
    my_arc = _get_my_arc(job, otii_object)
    proj = _check_create_project(job, otii_object)
    proj.stop_recording()
    _append_string(job, "Recording stopped")

    recording = proj.get_last_recording()
    if recording:
        # downsample to 100Hz
        recording.downsample_channel(my_arc.id, "mc",5)
        recording.downsample_channel(my_arc.id, "mv",5)
        recording.downsample_channel(my_arc.id, "me",5)

        count_mc = recording.get_channel_data_count(my_arc.id, "mc")
        count_mv = recording.get_channel_data_count(my_arc.id, "mv")
        count_me = recording.get_channel_data_count(my_arc.id, "me")

        mc_data = recording.get_channel_data(my_arc.id, "mc", 0, count_mc)
        mv_data = recording.get_channel_data(my_arc.id, "mv", 0, count_mv)
        me_data = recording.get_channel_data(my_arc.id, "me", 0, count_me)

        index_mc = np.round(np.arange(mc_data['timestamp'], mc_data['interval']*count_mc+mc_data['timestamp'], mc_data['interval']), 5)
        index_mv = np.round(np.arange(mv_data['timestamp'], mv_data['interval']*count_mv+mv_data['timestamp'], mv_data['interval']), 5)
        index_me = np.round(np.arange(me_data['timestamp'], me_data['interval']*count_me+me_data['timestamp'], me_data['interval']), 5)

        # I don't understand, but sometimes the arrays are of different size (by 1), so just take the first ones required
        len_mc= len(mc_data['values'])
        len_mv= len(mv_data['values'])
        len_me= len(me_data['values'])
        index_mc = index_mc[:len_mc]
        index_mv = index_mv[:len_mv]
        index_me = index_me[:len_me]

        # Intialise data to Dicts of series. 
        d = {'current (A)': pd.Series(mc_data['values'], index=index_mc), 
            'voltage (V)': pd.Series(mv_data['values'], index=index_mv),
            'Energy (J)': pd.Series(me_data['values'], index=index_me)}

        print()
        
        # creates Dataframe. 
        df = pd.DataFrame(d)
        df.index.name = 'timestamp'

        df.dropna(inplace=True)
        
        return df

    else:
        _append_string(job, "No recording in project")
        return pd.DataFrame()
    

# returns the data in a pandas dataframe
def get_latest_data():
    job = get_current_job()
    otii_object = _connect(job)
    my_arc = _get_my_arc(job, otii_object)
    proj = _check_create_project(job, otii_object)
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
        _append_string(job, "No recording in project")
        return pd.DataFrame()