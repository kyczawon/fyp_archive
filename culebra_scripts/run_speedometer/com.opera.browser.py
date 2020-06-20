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

wait_for_id_and_touch(vc, 'com.opera.browser:id/url_field')
vc.findViewByIdOrRaise('com.opera.browser:id/url_field').setText('https://browserbench.org/Speedometer2.0/')
adb.shell('input keyevent KEYCODE_ENTER')
# if can't press start test, there is a night mode overlay
try:
    wait_for_text_and_touch(vc, 'Start Test', 5)
except:
    wait_for_text(vc, 'Try night mode')
    device.touch(529,975,'DOWN_AND_UP')
    wait_for_text_and_touch(vc, 'Start Test', 5)

wait_for_text_and_touch(vc, 'Details', 420)