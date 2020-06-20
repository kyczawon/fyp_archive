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
time.sleep(2)