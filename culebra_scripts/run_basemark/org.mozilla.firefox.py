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

wait_for_text_and_touch(vc, 'Start')
wait_for_text(vc, 'breakdown', 600, 5)