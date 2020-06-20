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

wait_for_id(vc, 'com.microsoft.emmx:id/search_box_text')
vc.findViewByIdOrRaise('com.microsoft.emmx:id/search_box_text').touch()
wait_for_id(vc, 'com.microsoft.emmx:id/url_bar')
vc.findViewByIdOrRaise('com.microsoft.emmx:id/url_bar').setText('https://browserbench.org/JetStream/')
adb.shell('input keyevent KEYCODE_ENTER')
wait_for_text(vc, 'Start Test')
device.touch(579,1203,'DOWN_AND_UP')
wait_for_id(vc, 'result-summary', 1320)