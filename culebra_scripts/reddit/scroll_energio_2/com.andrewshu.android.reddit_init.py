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

component='com.andrewshu.android.reddit/.MainActivity'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'content-denyLabel')
wait_for_id(vc, 'content-closeWindowLabel')
# close overlay
device.touch(575, 1719,'DOWN_AND_UP')
wait_for_id_and_touch(vc, 'android:id/button1')
# open drawer
device.touch(100, 108,'DOWN_AND_UP')
wait_for_id(vc, 'com.andrewshu.android.reddit:id/subreddit_input')
vc.findViewByIdOrRaise('com.andrewshu.android.reddit:id/subreddit_input').setText('energio')
time.sleep(2)