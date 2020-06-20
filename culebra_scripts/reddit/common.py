#! /usr/bin/env python
# -*- coding: utf-8 -*-
import time, sys
import signal
import traceback as trace
import re

retype = type(re.compile('hello, world'))

def handler(signum, frame):
    print('vs dump failed!')
    raise Exception("vc dump timed out")

signal.signal(signal.SIGALRM, handler)

def wait_for_id(vc, id, timeout = 10, refresh_time = 0.5):
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            print('vc dump for id: ' + id)
            signal.alarm(5)
            vc.dump(window=-1, sleep=0)
            signal.alarm(0)
            print('finished: ' + id)
            if vc.findViewById(id) is None:
                time.sleep(refresh_time)
            else:
                return
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            exc_type, exc_value, exc_tb = sys.exc_info()
            print(''.join(trace.format_exception(exc_type, exc_value, exc_tb)))
            time.sleep(refresh_time)
    raise RuntimeError('Failed waiting '+str(timeout)+'s for id: ' + id)

def wait_for_id_and_touch(vc, id, timeout = 10, refresh_time = 0.5):
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            print('vc dump for id: ' + id)
            signal.alarm(5)
            vc.dump(window=-1, sleep=0)
            signal.alarm(0)
            print('finished: ' + id)
            if vc.findViewById(id) is None:
                time.sleep(refresh_time)
            else:
                vc.findViewById(id).touch()
                return
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            exc_type, exc_value, exc_tb = sys.exc_info()
            print(''.join(trace.format_exception(exc_type, exc_value, exc_tb)))
            time.sleep(refresh_time)
    raise RuntimeError('Failed waiting '+str(timeout)+'s for id: ' + id)

def wait_for_text(vc, text, timeout = 10, refresh_time = 0.5):
    if (isinstance(text, retype)):
        string = str(text)
    else:
        string = text.encode('utf-8')
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            print('vc dump for text: ' + string)
            signal.alarm(5)
            vc.dump(window=-1, sleep=0)
            signal.alarm(0)
            print('finished: ' + string)
            if vc.findViewWithText(text) is None:
                time.sleep(refresh_time)
            else:
                return
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            exc_type, exc_value, exc_tb = sys.exc_info()
            print(''.join(trace.format_exception(exc_type, exc_value, exc_tb)))
            time.sleep(refresh_time)
    raise RuntimeError('Failed waiting '+str(timeout)+'s for text: ' + string)

def wait_for_text_and_touch(vc, text, timeout = 10, refresh_time = 0.5):
    if (isinstance(text, retype)):
        string = str(text)
    else:
        string = text.encode('utf-8')
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            print('vc dump for text: ' + string)
            signal.alarm(5)
            vc.dump(window=-1, sleep=0)
            signal.alarm(0)
            print('finished: ' + string)
            if vc.findViewWithText(text) is None:
                time.sleep(refresh_time)
            else:
                vc.findViewWithText(text).touch()
                return
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            exc_type, exc_value, exc_tb = sys.exc_info()
            print(''.join(trace.format_exception(exc_type, exc_value, exc_tb)))
            time.sleep(refresh_time)
    raise RuntimeError('Failed waiting '+str(timeout)+'s for text: ' + string)

def wait_for_text_scroll(vc, adb, text, timeout = 10, swipe_count = 1, refresh_time = 0.5,):
    if (isinstance(text, retype)):
        string = str(text)
    else:
        string = text.encode('utf-8')
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            print('vc dump for text: ' + string)
            signal.alarm(5)
            vc.dump(window=-1, sleep=0)
            signal.alarm(0)
            print('finished: ' + string)
            if vc.findViewWithText(text) is None:
                for n in range(swipe_count):
                    adb.shell('input touchscreen swipe 100 1900 300 300 50')
                time.sleep(refresh_time)
            else:
                return
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            exc_type, exc_value, exc_tb = sys.exc_info()
            print(''.join(trace.format_exception(exc_type, exc_value, exc_tb)))
            time.sleep(refresh_time)
    raise RuntimeError('Failed waiting '+str(timeout)+'s for text: ' + string)