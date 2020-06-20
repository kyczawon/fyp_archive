#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys, os

from com.dtmilano.android.viewclient import ViewClient

from common import *

def wirple():
    device, serialno = ViewClient.connectToDeviceOrExit()
    vc = ViewClient(device, serialno)

    wait_for_text_and_touch(vc, 'Start test')
    wait_for_text(vc, re.compile('Total score:.*'), 300, 5)