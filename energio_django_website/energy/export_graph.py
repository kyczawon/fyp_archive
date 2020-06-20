import pandas as pd
import matplotlib.pyplot as plt

import matplotlib.gridspec as gridspec

csv_path = "/Users/leszek/Desktop/Desktop/Imperial/FYP/app/uploads/files/2020/05/14/browsing_top_5_jwqgGVq/browsing_top_5/134_335.csv"


df = pd.read_csv(csv_path, index_col=0)

# average energy
print((df.tail(1)['Energy (J)'].values[0] / (df.tail(1).index.values[0] *60*60))*1000000)

task_name = "1"

app_name = "1"
# Create 2x2 sub plots
gs = gridspec.GridSpec(6, 5)

plt.figure(figsize=(20,10))
ax = plt.subplot(gs[0:3, 0:2]) # row 0, col 0
df['current (A)'].plot(title='Voltage plot for '+task_name+': '+app_name, ax=ax, color="darkorange",grid=True)
ax.set_xlabel("time (s)")
ax.set_ylabel("current (A)")

ax = plt.subplot(gs[3:6, 0:2]) # row 0, col 1
df['voltage (V)'].plot(title='Current plot for '+task_name+': '+app_name, ax=ax,grid=True)
ax.set_xlabel("time (s)")
ax.set_ylabel("voltage (V)")

ax = plt.subplot(gs[1:5, 2:5]) # row 1, span all columns
df['Energy (J)'].plot(title='Cummulative Energy plot for '+task_name+': '+app_name, ax=ax, color="tab:green",grid=True)
ax.set_xlabel("time (s)")
ax.set_ylabel("energy (J)")

plt.tight_layout()
# plt.show()

# # when storing the paths have to be relative to the root of the project
# export_path = export_path.replace(settings.BASE_DIR,'')
# csv_path = export_path+'.csv'
# graph_path = export_path+'.png'