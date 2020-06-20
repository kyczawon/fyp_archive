#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys, os
from com.dtmilano.android.viewclient import ViewClient
device, serialno = ViewClient.connectToDeviceOrExit(serialno=os.environ['ANDROID_SERIAL'] if os.environ.has_key('ANDROID_SERIAL') else '.*')
device.takeSnapshot().save(str(sys.argv[1]), 'PNG')