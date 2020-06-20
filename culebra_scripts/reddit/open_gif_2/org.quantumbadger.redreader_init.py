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

component='org.quantumbadger.redreader/.activities.MainActivity'
device.startActivity(component=component)
wait_for_id_and_touch(vc, 'android:id/button2')
wait_for_text_and_touch(vc, 'Custom Location', 12)
wait_for_id(vc, 'org.quantumbadger.redreader:id/dialog_mainmenu_custom_value')
vc.findViewByIdOrRaise('org.quantumbadger.redreader:id/dialog_mainmenu_custom_value').setText('energio')
wait_for_id_and_touch(vc, 'android:id/button1')
wait_for_text(vc, 'Energio Logo!', 15)
time.sleep(2)