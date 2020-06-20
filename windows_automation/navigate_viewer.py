import win32com.client

from win32com.client import Dispatch

autoit = Dispatch("AutoItX3.Control")

autoit.Run("C:\Program Files (x86)\YOKOGAWA\WTViewerFreePlus\WTViewerFreePlus.exe")

# pause execution until Calculator becomes active window
# autoit.WinWaitActive('Calculator')

autoit.WinWaitActive("WTViewerFreePlus", "", 10)

# Get the handle for Calculator
hWnd = autoit.WinGetHandle("WTViewerFreePlus")

autoit.WinActivate("WTViewerFreePlus")

lol = autoit.WinGetTitle(hWnd)

print(hWnd)
print(lol)

# ;Using the `Finder Tool`, you can drag and drop it onto controls to see all information (i.e. Text, Class, Handle, etc.)

# ;`ClassnameNN: Button10` is the number 5
# ;`ClassnameNN: Button23` is the addition operator (+)
# ;`ClassnameNN: Button28` is the equals operator (=)

# ;***** simple operation will perform 5 + 5 = 10 **************

# ;click 5

autoit.Sleep(200)
# autoit.ControlClick(hWnd, "OK", "[CLASSNN:Button1]")
autoit.ControlClick("WTViewerFreePlus", "OK", "[CLASSNN:Button1]")

autoit.ControlClick("WTViewerFreePlus", "OK", "[CLASSNN:Button1]")
# autoit.ControlClick("", "", "[CLASSNN:Button1]")

