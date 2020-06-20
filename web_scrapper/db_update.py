import mysql.connector
import time
import pandas as pd

start_time = time.time()

mydb = mysql.connector.connect(
  host="lesz.mariadb.database.azure.com",
  user="leszek@lesz",
  passwd="test",
  database="fyp"
)

mycursor = mydb.cursor()




df = pd.read_csv("results.csv", index_col=0)

for index, row in df.iterrows():
    # print(index)
    # print(row['capacity'])
    # print("UPDATE fyp.devices SET capacity = %s WHERE model ='%s'" % (row['capacity'], index))
    mycursor.execute("UPDATE fyp.devices SET capacity = %s WHERE model ='%s'" % (row['capacity'], index))
#     print(row['c1'], row['c2'])

mydb.commit()

print("--- The script took %s seconds ---" % (time.time() - start_time))

# print(df.head())





