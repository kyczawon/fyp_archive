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

wait_for_id(vc, 'com.brave.browser:id/url_bar')
vc.findViewByIdOrRaise('com.brave.browser:id/url_bar').setText('https://browserbench.org/JetStream/')
adb.shell('input keyevent KEYCODE_ENTER')
wait_for_text_and_touch(vc, 'Start Test', 15)
wait_for_id(vc, 'result-summary', 1320)