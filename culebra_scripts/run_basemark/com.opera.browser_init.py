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

component='com.opera.browser/com.opera.Opera'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'com.opera.browser:id/continue_button', 15)
wait_for_id_and_touch(vc, 'com.opera.browser:id/allow_button')
wait_for_id_and_touch(vc, 'com.opera.browser:id/positive_button')
wait_for_id(vc, 'com.opera.browser:id/url_field')
wait_for_id_and_touch(vc, 'com.opera.browser:id/url_field')
vc.findViewByIdOrRaise('com.opera.browser:id/url_field').setText('https://web.basemark.com/')
adb.shell('input keyevent KEYCODE_ENTER')
try:
    wait_for_text(vc, 'Try night mode')
    device.touch(529,975,'DOWN_AND_UP')
except:
    pass
time.sleep(2)
