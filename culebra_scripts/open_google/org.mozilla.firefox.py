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

vc.findViewByIdOrRaise('org.mozilla.firefox:id/url_edit_text').setText('http://google.com')
adb.shell('input keyevent KEYCODE_ENTER')
time.sleep(3)