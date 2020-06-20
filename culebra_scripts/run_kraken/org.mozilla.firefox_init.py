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

component='org.mozilla.firefox/.App'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'org.mozilla.firefox:id/firstrun_link')
wait_for_text(vc, 'Sync your bookmarks, history, and passwords to your phone.')
vc.findViewByIdOrRaise('org.mozilla.firefox:id/firstrun_link').touch()
wait_for_id_and_touch(vc, 'org.mozilla.firefox:id/firstrun_browse')
try:
    wait_for_id_and_touch(vc,'close-button')
except:
    pass
wait_for_id_and_touch(vc, 'org.mozilla.firefox:id/url_bar_title')
wait_for_id(vc, 'org.mozilla.firefox:id/url_edit_text')
vc.findViewByIdOrRaise('org.mozilla.firefox:id/url_edit_text').setText('https://krakenbenchmark.mozilla.org/')
adb.shell('input keyevent KEYCODE_ENTER')
time.sleep(2)