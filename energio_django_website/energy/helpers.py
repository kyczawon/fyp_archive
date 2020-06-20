import django_rq
import os, subprocess, sys
import shutil
import time

import zipfile
import django_rq
from rq import get_current_job
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from django.conf import settings
import traceback as trace

sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))
from otii import otii

from .models import Benchmark, App, Task, Measurement, Result

import signal

SMARTPHONE_IP = "192.168.1.12"

def handler(signum, frame):
    print('Failed taking a screenshot!')
    raise Exception("Failed taking a screenshot!")

signal.signal(signal.SIGALRM, handler)

def _append_string(job, message):
    if 'message' in  job.meta:
        job.meta['message'] += (message + "\n")
    else:
         job.meta['message'] = (message + "\n")
    job.save_meta()

def rq_exception_handler(job, exc_type, exc_value, traceback):
    if 'message' in  job.meta:
        message = job.meta['message']+ '\n' + ''.join(trace.format_exception(exc_type, exc_value, traceback))
    else:
        message = ''.join(trace.format_exception(exc_type, exc_value, traceback))
    # only jobs with integers values are results
    if (job.id.isdigit()):
        if 'screenshot_path' in  job.meta:
            Result.objects.filter(id=int(job.id)).update(status=Result.ResultStatus.SCREENSHOT, screenshot_path=job.meta['screenshot_path'])
            try:
                # try taking a screenshot for 15 seconds if it fails move on
                signal.alarm(15)
                res = subprocess.check_output(["python", "/Users/leszek/Desktop/Desktop/Imperial/FYP/culebra/take_screenshot.py", job.meta['screenshot_path_save']], stderr=subprocess.STDOUT)
                signal.alarm(0)
                for line in res.splitlines():
                    _append_string(job, line.decode())
            except:
                message += '\n Failed taking a failure screenshot'

        Result.objects.filter(id=int(job.id)).update(status=Result.ResultStatus.FAILED, message=message)

# def exception_handler(job, exc_type, exc_value, traceback):
#     if 'message' in  job.meta:
#         message = job.meta['message']+ '\n' + ''.join(trace.format_exception(exc_type, exc_value, traceback))
#     else:
#         message = ''.join(trace.format_exception(exc_type, exc_value, traceback))
#     # only jobs with integers values are results
#     if (isinstance(job.id,int)):
#         Result.objects.filter(id=int(job.id)).update(status=Result.ResultStatus.FAILED, message=message)

# try to clear cache and if it fails try to reconnect to device and try again (up to 60 seconds)
def clear_cache(job, result, app_name):
    result.status = Result.ResultStatus.CLEARING_CACHE
    result.save()

    timeout = 60
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            res = subprocess.check_output(["adb","shell","pm","clear",app_name], stderr=subprocess.STDOUT)

            for line in res.splitlines():
                text = line.decode()
                if (text == 'Success'):
                    _append_string(job, 'Sucesfully cleared cache of '+app_name)
                else:
                    _append_string(job, line.decode())
                return
        except:
            res = subprocess.check_output(["adb","kill-server"], stderr=subprocess.STDOUT)

            for line in res.splitlines():
                _append_string(job, line.decode())

            time.sleep(2)

            res = subprocess.check_output(["adb","connect",SMARTPHONE_IP+":5555"], stderr=subprocess.STDOUT)

            for line in res.splitlines():
                _append_string(job, line.decode())

def run_app_task(path, benchmark, result, task_name, app_name):
    try:
        result.status = Result.ResultStatus.STARTED
        result.save()

        job = get_current_job()
        screenshot_path_save = os.path.dirname(path)+'/'+str(result.task_id)+'_'+str(result.app_id)+'_screenshot.png'
        screenshot_path = screenshot_path_save.replace(settings.BASE_DIR,'')
        job.meta['screenshot_path']=screenshot_path
        job.meta['screenshot_path_save']=screenshot_path_save

        # monkey requires java 8    
        res = subprocess.check_output(["/usr/libexec/java_home","-v","1.8"], stderr=subprocess.STDOUT)
        os.environ['JAVA_HOME'] = str(res.splitlines()[0],'utf-8')

        # clear_cache if needed
        if (benchmark.clear_cache):
            clear_cache(job, result, app_name)

        # wake up and clear all to reset a test if needed else only wake up
        if (benchmark.close_apps):
            result.status = Result.ResultStatus.CLOSING_APPS
            result.save()
            res = subprocess.check_output(["monkeyrunner", "/Users/leszek/Desktop/Desktop/Imperial/FYP/monkey/wake_and_clear_all.py"], stderr=subprocess.STDOUT)
        else:
            res = subprocess.check_output(["monkeyrunner", "/Users/leszek/Desktop/Desktop/Imperial/FYP/monkey/wake.py"], stderr=subprocess.STDOUT)

        for line in res.splitlines():
                _append_string(job, line.decode())

        exec_prog = benchmark.exec_prog

        # run init scripts before measurements if they exist
        if (benchmark.init):
            result.status = Result.ResultStatus.RUNNING_INIT
            result.save()
            # run the test given by user
            res = subprocess.check_output([exec_prog, os.path.splitext(path)[0] + '_init' + os.path.splitext(path)[1]], stderr=subprocess.STDOUT)

        # start otii recording
        otii.start_otii_and_start_recording()

        # run the test given by user
        result.status = Result.ResultStatus.RUNNING_SCRIPT
        result.save()
        res = subprocess.check_output([exec_prog, path], stderr=subprocess.STDOUT)

        for line in res.splitlines():
            _append_string(job, line.decode())

        # stop otii recording and get the results
        df = otii.stop_and_get_latest_data()

        export_path = os.path.dirname(path)+'/'+str(result.task_id)+'_'+str(result.app_id)
        # paths to save the files have to be full
        csv_path = export_path+'.csv'
        graph_path = export_path+'.png'
        screenshot_path = export_path+'_screenshot.png'

        # take screenshot of the device at end
        result.status = Result.ResultStatus.SCREENSHOT
        result.save()
        res = subprocess.check_output(["python", "/Users/leszek/Desktop/Desktop/Imperial/FYP/culebra/take_screenshot.py", screenshot_path], stderr=subprocess.STDOUT)
        for line in res.splitlines():
            _append_string(job, line.decode())

        # clear_cache if needed
        if (benchmark.clear_cache):
            clear_cache(job, result, app_name)

        # save results
        result.status = Result.ResultStatus.SAVING
        result.save()
        for index, row in df.iterrows():
            Measurement.objects.create(result_id=result.id, time=index,
            current=row['current (A)'], voltage=row['voltage (V)'], energy=row['Energy (J)'])

        df.to_csv(csv_path)

        # Create 2x2 sub plots
        gs = gridspec.GridSpec(6, 5)

        plt.figure(figsize=(20,10))
        ax = plt.subplot(gs[0:3, 0:2]) # row 0, col 0
        df['current (A)'].plot(title='Current plot for '+task_name+': '+app_name, ax=ax, color="darkorange",grid=True)
        ax.set_xlabel("time (s)")
        ax.set_ylabel("current (A)")

        ax = plt.subplot(gs[3:6, 0:2]) # row 0, col 1
        df['voltage (V)'].plot(title='Voltage plot for '+task_name+': '+app_name, ax=ax,grid=True)
        ax.set_xlabel("time (s)")
        ax.set_ylabel("voltage (V)")

        ax = plt.subplot(gs[1:5, 2:5]) # row 1, span all columns
        df['Energy (J)'].plot(title='Cummulative Energy plot for '+task_name+': '+app_name, ax=ax, color="tab:green",grid=True)
        ax.set_xlabel("time (s)")
        ax.set_ylabel("energy (J)")

        plt.tight_layout()
        plt.savefig(graph_path)

        # when storing the paths have to be relative to the root of the project
        export_path = export_path.replace(settings.BASE_DIR,'')
        csv_path = export_path+'.csv'
        graph_path = export_path+'.png'
        screenshot_path = export_path+'_screenshot.png'

        result.status = Result.ResultStatus.FINISHED
        # result is the average power in micro Watts
        result.result = (df.tail(1)['Energy (J)'].values[0] / (df.tail(1).index.values[0]))
        result.graph = graph_path
        result.csv=csv_path 
        result.screenshot_path=screenshot_path 
        result.message=job.meta['message']
        result.save()

    except subprocess.CalledProcessError as e:
        exc_type, exc_value, exc_tb = sys.exc_info()
        _append_string(job, e.output.decode("utf-8"))
        rq_exception_handler(job, exc_type, exc_value, exc_tb)
        return

def execute_benchmark(benchmark_id):
    benchmark = Benchmark.objects.get(id=benchmark_id)

    directory = unzip(benchmark.file.path)

    current = [x for x in os.walk(directory)][0]

    if len(current[1]) == 0:
        print('Top level does not have nested folders - wrong file structure')

    # go through the folder and make tasks named after the name of the folder
    # current[1] are the folder names
    for task in current[1]:
        new_task = Task.objects.create(benchmark_id=benchmark_id, name = task)

        current2 = [x for x in os.walk(directory+'/'+task)][0]

        filenames = current2[2]

        # don't consider .DS_Store
        if '.DS_Store' in filenames: filenames.remove('.DS_Store')

        if len(filenames) == 0:
            print('Folders do not have files for execution - wrong file structure')

        # filter init files
        if benchmark.init:
            filenames = filter(lambda x: '_init' not in x, filenames)

        # go through each folder and make app named after the file name without the extension
        # current2[2] are the filenames
        for filename in filenames:
            app, _ = os.path.splitext(filename)

            exisitng_apps = App.objects.filter(benchmark_id=benchmark_id).values_list('name', flat=True)
            
            # avoid creating duplicate apps
            if app not in exisitng_apps:
                new_app = App(benchmark_id=benchmark_id, name=app)
                new_app.save()

            # app_id needs to be queried
            app_id = App.objects.get(benchmark_id=benchmark_id, name=app).id

            # full path to the file to be executed
            path = '/'.join([directory,task,filename])

            result = Result.objects.create(benchmark_id=benchmark_id, app_id=app_id, task_id=new_task.id)

            job = django_rq.enqueue(run_app_task, job_id=str(result.id), path=path, benchmark=benchmark, result=result, task_name=task, app_name=app)

def remove_dir_if_exists(dirpath):
    if os.path.exists(dirpath) and os.path.isdir(dirpath):
        shutil.rmtree(dirpath)

def unzip(path):
    
    dir_name = os.path.splitext(path)[0]
    with zipfile.ZipFile(path, 'r') as zip_ref:
        zip_ref.extractall(dir_name)

    remove_dir_if_exists(dir_name+'/__MACOSX')

    return dir_name