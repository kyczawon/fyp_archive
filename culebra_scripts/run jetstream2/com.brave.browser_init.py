#! /usr/bin/env python
# -*- coding: utf-8 -*-
import time

from com.dtmilano.android.viewclient import ViewClient
from com.dtmilano.android.adb import adbclient

import sys, os
sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))
from common import *

device, serialno = ViewClient.connectToDeviceOrExit()
vc = ViewClient(device, serialno)
adb = adbclient.AdbClient(serialno='.*')

component='com.brave.browser/com.google.android.apps.chrome.Main'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'com.brave.browser:id/btn_next')
wait_for_text(vc, 'Brave Shields')
vc.findViewByIdOrRaise('com.brave.browser:id/btn_next').touch()
wait_for_text(vc, 'Brave Rewards')
vc.findViewByIdOrRaise('com.brave.browser:id/btn_skip').touch()
time.sleep(2)