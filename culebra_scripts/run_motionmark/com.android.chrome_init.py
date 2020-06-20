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

component='com.android.chrome/com.google.android.apps.chrome.Main'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'com.android.chrome:id/send_report_checkbox')
vc.findViewByIdOrRaise('com.android.chrome:id/terms_accept').touch()
wait_for_id_and_touch(vc, 'com.android.chrome:id/negative_button')
wait_for_id_and_touch(vc, 'com.android.chrome:id/search_box_text')
wait_for_id(vc, 'com.android.chrome:id/url_bar')
vc.findViewByIdOrRaise('com.android.chrome:id/url_bar').setText('https://browserbench.org/MotionMark1.1/')
adb.shell('input keyevent KEYCODE_ENTER')
adb.shell('settings put system accelerometer_rotation 0')
adb.shell('settings put system user_rotation 1')
wait_for_text(vc, u'MotionMark is a graphics benchmark that measures a browser’s capability to animate complex scenes at a target frame rate.', 15)
# device.drag(448,1368),(1000,1368),0.1,3)

adb.shell('input swipe 448 1368 1000 1368')
time.sleep(2)