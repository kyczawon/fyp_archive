import mysql.connector
import requests
from bs4 import BeautifulSoup
import re
import pandas as pd
import time, socks, socket, sys, os
from urllib.request import urlopen
from stem import Signal
from stem.control import Controller
from stem.util.log import get_logger
import logging

# configure loggin to print to console and save to file
logger = get_logger()
logger.propagate = False
logging.basicConfig(filename='./db.log', format='%(levelname)s: %(message)s')
logging.getLogger().addHandler(logging.StreamHandler(sys.stdout))

def save_data():
    logging.warning("Total time: %s seconds. Completed %s devices, %s failed and changed IP adress %s times.\nFailed models: %s" % (time.time() - start_time_global, completed, len(failed_models), total_ip_changes, failed_models))

    df = pd.DataFrame.from_dict(results, orient='index')
    df.columns = ['capacity']
    df.to_csv('results.csv')

    df = pd.DataFrame({'mod':failed_models})
    df.to_csv('failed_models.csv')

start_time_global = time.time()

mydb = mysql.connector.connect(
  host="lesz.mariadb.database.azure.com",
  user="leszek@lesz",
  passwd="test",
  database="fyp"
)

mycursor = mydb.cursor()

mycursor.execute("SELECT DISTINCT model FROM fyp.devices")

models= [models[0] for models in mycursor.fetchall()]

print("--- db time: %s seconds ---" % (time.time() - start_time_global))

results = {}
completed = 0
total_ip_changes = 0
failed_models = []

try:
    # connect to tor service controller
    with Controller.from_port(port = 9051) as controller:
        controller.authenticate(password = '872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C')

        for model in models:
            try:
                # revert to local IP
                socks.setdefaultproxy()

                start_time = time.time()
                goog_search = "https://www.google.co.uk/search?&q=gsmarena+" + model
                page = requests.get(goog_search)
                if page.status_code != 200:
                    logging.error('google failed at %s' % completed)
                    save_data()
                    sys.exit()

                soup = BeautifulSoup(page.text, 'html.parser')

                test = soup.select_one("a[href*='www.gsmarena.com']")
                sep = '&'
                link = test['href'][7:].split(sep, 1)[0]
                
                # connect to TOR
                socks.setdefaultproxy(socks.PROXY_TYPE_SOCKS5, "127.0.0.1", 9050)
                socket.socket = socks.socksocket   

                done = False
                while (not done):
                    page = requests.get(link)

                    # if too many requests retry with a new ip address
                    if page.status_code == 429:
                        total_ip_changes += 1
                        controller.signal(Signal.NEWNYM)
                        if controller.is_newnym_available() == False:
                            print("Waiting %s seconds for Tor to change IP: " % controller.get_newnym_wait())
                            time.sleep(controller.get_newnym_wait())
                        
                        newIP=urlopen("http://icanhazip.com").read()
                        print("Changed IP adress %s times, NewIP Address: %s" % (total_ip_changes,newIP))
                    elif page.status_code == 200:
                        done = True
                    else:
                        raise Exception('When loading GSM page, error status code: %s' % (page.status_code))
            
                soup = BeautifulSoup(page.text, 'html.parser')

                # try to find the battery capacity on the page, if it's not there we fail and move on
                try:
                    battery_string = soup.find("th", string="Battery").find_next('td').find_next('td').getText()
                    capacity = int(re.search(r'\d+', battery_string).group(0))
                    results[model] = capacity

                except AttributeError:
                    logging.warning('model %s does not have battery stats' % (model))
                    failed_models.append(model)

                completed+=1
                print("--- device number %s %s seconds ---" % (completed, time.time() - start_time))

            # catch any other exceptions and move one
            except Exception as e:
                logging.warning('model %s failed due to the following exception:' % (model))
                logging.warning(e)

        controller.close()
    save_data()

# save the date on interrupt
except KeyboardInterrupt:
        print('Interrupted')
        save_data()
        try:
            sys.exit(0)
        except SystemExit:
            os._exit(0)


