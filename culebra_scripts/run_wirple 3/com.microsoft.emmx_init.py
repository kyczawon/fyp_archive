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

component='com.microsoft.emmx/com.microsoft.ruby.Main'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'com.microsoft.emmx:id/cancel_button')
wait_for_id_and_touch(vc, 'com.microsoft.emmx:id/not_now')
wait_for_id_and_touch(vc, 'com.microsoft.emmx:id/fre_share_not_now')
wait_for_id_and_touch(vc, 'com.microsoft.emmx:id/no')
wait_for_id(vc, 'com.microsoft.emmx:id/search_box_text')
vc.findViewByIdOrRaise('com.microsoft.emmx:id/search_box_text').touch()
wait_for_id(vc, 'com.microsoft.emmx:id/url_bar')
vc.findViewByIdOrRaise('com.microsoft.emmx:id/url_bar').setText('https://www.wirple.com/bmark/')
adb.shell('input keyevent KEYCODE_ENTER')
time.sleep(2)