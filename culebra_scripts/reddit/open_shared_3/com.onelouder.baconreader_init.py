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

component='com.onelouder.baconreader/.FrontPage'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'android:id/button1')
wait_for_id_and_touch(vc, 'com.onelouder.baconreader:id/action_search')
wait_for_id(vc, 'com.onelouder.baconreader:id/toolbarEdit')
vc.findViewByIdOrRaise('com.onelouder.baconreader:id/toolbarEdit').setText('r/energio')
wait_for_text_and_touch(vc, 'ALL SUBREDDITS')
wait_for_text_and_touch(vc, 'energio', 10, 2)
wait_for_text(vc, 'Energio Logo!', 10, 2)
adb.shell('input touchscreen swipe 100 700 300 300 90')
wait_for_text(vc, re.compile('.*How to share a reddit post:.*'))
time.sleep(2)