import time, socks, socket
from urllib.request import urlopen
from stem import Signal
from stem.control import Controller

nbrOfIpAddresses=3

with Controller.from_port(port = 9051) as controller:
   controller.authenticate(password = '872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C')
   socks.setdefaultproxy(socks.PROXY_TYPE_SOCKS5, "127.0.0.1", 9050)
   socket.socket = socks.socksocket   

   for i in range(0, nbrOfIpAddresses):
       newIP=urlopen("https://www.gsmarena.com/yu_yureka-6987.php").read()
       print("NewIP Address: %s" % newIP)
       controller.signal(Signal.NEWNYM)
       if controller.is_newnym_available() == False:
        print("Waitting time for Tor to change IP: "+ str(controller.get_newnym_wait()) +" seconds")
        time.sleep(controller.get_newnym_wait())
   controller.close()