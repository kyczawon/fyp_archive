# Imports the monkeyrunner modules used by this program
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

# Connects to the current device, returning a MonkeyDevice object
device = MonkeyRunner.waitForConnection()

device.press('KEYCODE_WAKEUP','DOWN_AND_UP')

device.press('KEYCODE_APP_SWITCH','DOWN_AND_UP')
device.drag((448,1368),(1000,1368),0.1,3)
device.drag((448,1368),(1000,1368),0.1,3)
device.drag((448,1368),(1000,1368),0.1,3)
device.drag((448,1368),(1000,1368),0.1,3)
device.drag((448,1368),(1000,1368),0.1,3)
device.drag((448,1368),(1000,1368),0.1,3)
device.drag((448,1368),(1000,1368),0.1,3)
device.drag((448,1368),(1000,1368),0.1,3)
device.drag((448,1368),(1000,1368),0.1,3)

device.drag((110,1368),(727,1368),0.1,3)
MonkeyRunner.sleep(1)
device.touch(224,695,'DOWN_AND_UP')
