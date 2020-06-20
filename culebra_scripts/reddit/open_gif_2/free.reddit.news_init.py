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

component='free.reddit.news/reddit.news.RedditNavigation'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'free.reddit.news:id/subreddits')
try:
    wait_for_id_and_touch(vc, 'free.reddit.news:id/subreddits',6)
except:
    pass
wait_for_id(vc, 'free.reddit.news:id/edittext')
vc.findViewByIdOrRaise('free.reddit.news:id/edittext').setText('energio')
# press search
device.touch(1033, 1730, 'DOWN_AND_UP')
wait_for_text_and_touch(vc, 'energio')
wait_for_text(vc, 'Energio Logo!', 15)
time.sleep(2)