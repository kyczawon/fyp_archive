#! /usr/bin/env python
# -*- coding: utf-8 -*-
import time, re

from com.dtmilano.android.viewclient import ViewClient
from com.dtmilano.android.adb import adbclient

import sys, os
sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))
from common import *

device, serialno = ViewClient.connectToDeviceOrExit()
vc = ViewClient(device, serialno)
adb = adbclient.AdbClient(serialno='.*')

adb.shell('input keyevent KEYCODE_ENTER')
wait_for_text(vc, re.compile('.*Energio Logo!.*'))
wait_for_text_scroll(vc, adb, re.compile(".*It's a dog!.*"), 20, 2)