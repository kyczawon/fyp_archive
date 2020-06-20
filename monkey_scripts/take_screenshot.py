# Imports the monkeyrunner modules used by this program
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

# Connects to the current device, returning a MonkeyDevice object
device = MonkeyRunner.waitForConnection()
result = device.takeSnapshot()
file = "C:\\Workspace\\"+now.strftime("%d%m%Y-%H%M%S")+".png"
result.writeToFile(file,'png')
