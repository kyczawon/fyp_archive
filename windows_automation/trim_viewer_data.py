import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('sites', delimiter = ',')

# remove rows that are not needed
df = df.iloc[:, :-3]
df.drop(columns=['WT1:S-1','WT1:PF-1','WT1:FreqU-1'], inplace=True)

df.columns = ['id','date','time','mill','v','i','p','q','phi','freq_i']

# filter failed rows
df = df[df.p != 'Error    ']

# pad milliseconds to be 3 digits long
df['mill'] = df['mill'].astype(str)
df['mill'] = df['mill'].str.zfill(3)
# merge time and milliseconds
df['time'] = df[['time','mill']].agg(':'.join, axis=1)

df['datetime'] =df[['date','time']].agg(' '.join, axis=1)
df['datetime'] = pd.to_datetime(df['datetime'], format="%Y/%m/%d %H:%M:%S:%f")

df['p'] = df['p'].astype(float)

# df.sort_values('datetime')

fig = plt.figure(figsize=(9,5),dpi=100)
ax = plt.axes()
ax.plot(df['datetime'], df['p'])
fig.suptitle('Power over time', fontsize=20)
plt.xlabel('time', fontsize=18)
plt.ylabel('Power (W)', fontsize=16)
plt.grid(True)
plt.show() # Depending on whether you use IPython or interactive mode, etc.

df.drop(columns=['datetime','mill'], inplace=True)

df.to_csv('result.csv', index=False)