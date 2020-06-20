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
vc.findViewByIdOrRaise('com.android.chrome:id/url_bar').setText('https://web.basemark.com/')
adb.shell('input keyevent KEYCODE_ENTER')
time.sleep(2)