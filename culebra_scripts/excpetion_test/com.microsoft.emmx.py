#! /usr/bin/env python
# -*- coding: utf-8 -*-
import time

from com.dtmilano.android.viewclient import ViewClient
from com.dtmilano.android.adb import adbclient

device, serialno = ViewClient.connectToDeviceOrExit()
vc = ViewClient(device, serialno)
adb = adbclient.AdbClient(serialno='.*')

def wait_for_id(vc, 'id):
    while True:
        vc.dump(window=-1)
        if vc.findViewById(id) is None:
            time.sleep(0.5)
        else:
            return

def wait_for_id_and_touch(id):
    while True:
        vc.dump(window=-1)
        if vc.findViewById(id) is None:
            time.sleep(0.5)
        else:
            vc.findViewByIdOrRaise(id).touch()
            return

def wait_for_text(vc, 'text):
    while True:
        vc.dump(window=-1)
        if vc.findViewWithText(text) is None:
            time.sleep(0.5)
        else:
            return

def wait_for_text_and_touch(vc, 'text):
    while True:
        vc.dump(window=-1)
        if vc.findViewWithText(text) is None:
            time.sleep(0.5)
        else:
            vc.findViewWithText(text).touch()
            return

vc.dump(window=-1)

wait_for_id(vc, 'com.microsoft.emmx:id/search_box_text')
vc.findViewByIdOrRaise('com.microsoft.emmx:id/search_box_text').touch()
wait_for_id(vc, 'com.microsoft.emmx:id/url_bar')
vc.findViewByIdOrRaise('com.microsoft.emmx:id/url_bar').setText('https://browserbench.org/Speedometer2.0/')
adb.shell('input keyevent KEYCODE_ENTER')
wait_for_text_and_touch(vc, 'Start Test')
wait_for_text_and_touch(vc, 'Details', 420)