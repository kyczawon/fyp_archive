#! /usr/bin/env python
# -*- coding: utf-8 -*-
import time
import sys, os
sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))

from com.dtmilano.android.viewclient import ViewClient
from com.dtmilano.android.adb import adbclient

import sys, os
sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))
from common import *

device, serialno = ViewClient.connectToDeviceOrExit()
vc = ViewClient(device, serialno)
adb = adbclient.AdbClient(serialno='.*')

wait_for_id_and_touch(vc, 'org.mozilla.firefox:id/url_bar_title')
wait_for_id(vc, 'org.mozilla.firefox:id/url_edit_text')
vc.findViewByIdOrRaise('org.mozilla.firefox:id/url_edit_text').setText('https://browserbench.org/Speedometer2.0/')
adb.shell('input keyevent KEYCODE_ENTER')
wait_for_text_and_touch(vc, 'Start Test')
wait_for_text_and_touch(vc, 'Details', 420)