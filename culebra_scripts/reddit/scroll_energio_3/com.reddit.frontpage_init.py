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

component='com.reddit.frontpage/.main.MainActivity'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'com.reddit.frontpage:id/search_view')
wait_for_id(vc, 'com.reddit.frontpage:id/search')
vc.findViewByIdOrRaise('com.reddit.frontpage:id/search').setText('energio')
# press search
device.touch(1033, 1730, 'DOWN_AND_UP')
wait_for_text_and_touch(vc, 'Communities')
time.sleep(2)