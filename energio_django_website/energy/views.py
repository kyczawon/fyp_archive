from django.shortcuts import render, redirect, reverse, get_object_or_404
import django_rq
import sys, os, time
from django.http import HttpResponseRedirect, JsonResponse
import numpy as np
from django.utils.translation import gettext_lazy as _
from django.db.models import Q

sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '..')))
from otii.otii import stop_otii, start_otii

from .forms import BenchmarkForm
from .models import Benchmark, App, Task, Result, Measurement
from .helpers import execute_benchmark

from django.utils.translation import ugettext_noop

from django.utils import translation

def _(str):
    t = translation.ugettext_lazy(str)
    t.message = str
    return t


def index(request):
    
    if request.method == 'POST':
        form = BenchmarkForm(request.POST, request.FILES)
        if form.is_valid():

            clear_cache = True if request.POST['clear_cache'] == "true" else False
            close_apps = True if request.POST['close_apps'] == "true" else False
            init = True if request.POST['init'] == "true" else False

            print(request.POST['exec_prog'])

            benchmark_id = Benchmark.objects.create(name = os.path.splitext(request.FILES['file'].name)[0], file=request.FILES['file'], category=request.POST['category'], clear_cache=clear_cache, close_apps=close_apps, init=init, exec_prog=request.POST['exec_prog']).id

            link = reverse('energy:benchmark',kwargs={'id':benchmark_id})

            response = {'url':link} 

            execute_benchmark(benchmark_id)

            return JsonResponse(response)

    # get unique categories
    categories = set(Benchmark.objects.values_list('category', flat=True))

    exec_progs = {}

    for exec_prog in Benchmark.ExecProg:
        exec_progs[exec_prog.value] = exec_prog.label

    print(categories)

    context = {'categories':categories, 'exec_progs':exec_progs}
    return render(request, 'energy/index.html', context)

def benchmark(request, id):
    message = ''
    
    app_names = App.objects.filter(benchmark_id=id).values_list('name', flat=True)
    task_names = Task.objects.filter(benchmark_id=id).values_list('name', flat=True)
    tasks = Task.objects.filter(benchmark_id=id)
    apps = App.objects.filter(benchmark_id=id)

    results = {}
    result_ids = []

    started = 0
    failed = 0
    finished = 0
    total = 0

    for app in apps:
        for task in tasks:
            try:
                result = Result.objects.get(task_id=task.id, app_id=app.id)
                link = reverse('energy:result',kwargs={'id':result.id})
                result_ids.append(result.id)
                status = str(Result.ResultStatus(result.status).label)
                result_result = None
                if (result.result):
                    result_result = np.round(result.result,3)
                results[(app.name, task.name)] = (result_result, result.id, link, status)

                message += 'status of '+str(id)+'_'+task.name+'_'+app.name+': '+status+'\n'
                message += result.message + '\n'

                total+=1
                if result.status == Result.ResultStatus.FAILED:
                    failed+=1
                elif result.status == Result.ResultStatus.FINISHED:
                    finished+=1
                elif result.status == Result.ResultStatus.QUEUED:
                    pass
                else:
                    started+=1

            except Result.DoesNotExist:
                pass

    context = {'message': message, 'apps': app_names, 'tasks': task_names, 'results': results, 'result_ids':result_ids, 'total':total, 'failed':failed, 'finished':finished, 'started':started}
    return render(request, 'energy/benchmark.html', context)

def benchmark_home(request):

    benchmarks = Benchmark.objects.all()

    progress = {}

    for benchmark in benchmarks:
        total = Result.objects.filter(benchmark_id=benchmark.id).count()
        started = Result.objects.filter(
            Q(benchmark_id=benchmark.id, status=Result.ResultStatus.STARTED)
            | Q(benchmark_id=benchmark.id, status=Result.ResultStatus.CLEARING_CACHE)
            | Q(benchmark_id=benchmark.id, status=Result.ResultStatus.CLOSING_APPS)
            | Q(benchmark_id=benchmark.id, status=Result.ResultStatus.RUNNING_INIT)
            | Q(benchmark_id=benchmark.id, status=Result.ResultStatus.RUNNING_SCRIPT)
            | Q(benchmark_id=benchmark.id, status=Result.ResultStatus.SCREENSHOT)
            | Q(benchmark_id=benchmark.id, status=Result.ResultStatus.SAVING)
            ).count()
        failed = Result.objects.filter(benchmark_id=benchmark.id, status=Result.ResultStatus.FAILED).count()
        finished = Result.objects.filter(benchmark_id=benchmark.id, status=Result.ResultStatus.FINISHED).count()
        if total == 0:
            started_progress = 0
            finished_progress = 0
            failed_progress = 0
        else:
            started_progress = started/total*100
            finished_progress = finished/total*100
            failed_progress = failed/total*100

        print(benchmark.date)
        print(benchmark.date.strftime("%Y-%m-%d %H:%M"))

        progress[benchmark.id] = (total, started, finished, failed, started_progress, finished_progress, failed_progress)

    
            
    context = {'benchmarks': benchmarks, 'progress': progress}
    return render(request, 'energy/benchmark_home.html', context)

def benchmarks_by_cat(request,category):
    # categories = set(Benchmark.objects.values_list('category', flat=True))
    message = ''

    app_names = set(App.objects.filter(benchmark__category=category).values_list('name', flat=True))
    task_names = set(Task.objects.filter(benchmark__category=category).values_list('name', flat=True))
    tasks = Task.objects.filter(benchmark__category=category)
    apps = App.objects.filter(benchmark__category=category)

    print(app_names)

    results = {}
    result_ids = []

    started = 0
    failed = 0
    finished = 0
    total = 0

    for app in apps:
        for task in tasks:
            try:
                result = Result.objects.get(task_id=task.id, app_id=app.id)
                link = reverse('energy:result',kwargs={'id':result.id})
                result_ids.append(result.id)
                status = Result.ResultStatus(result.status).name
                results[(app.name, task.name)] = (result.result, result.id, link, status)

                message += 'status of '+str(id)+'_'+task.name+'_'+app.name+': '+status+'\n'
                message += result.message + '\n'

                total+=1
                if result.status == Result.ResultStatus.STARTED:
                    started+=1
                elif result.status == Result.ResultStatus.FAILED:
                    failed+=1
                elif result.status == Result.ResultStatus.FINISHED:
                    finished+=1

            except Result.DoesNotExist:
                pass

    context = {'message': message, 'apps': app_names, 'tasks': task_names, 'results': results, 'result_ids':result_ids, 'total':total, 'failed':failed, 'finished':finished, 'started':started}
    return render(request, 'energy/benchmark.html', context)

def result(request, id):

    result = get_object_or_404(Result, pk=id)

    src = result.graph
    csv = result.csv
    screenshot = result.screenshot_path
    result_result = result.result
    message = result.message
    measurements = Measurement.objects.filter(result_id=id)

    context = {'graph_src': src, 'csv':csv, 'result':result_result, 'screenshot': screenshot, 'measurements': measurements, 'benchmark_id':result.benchmark_id, 'message':message}
    return render(request, 'energy/result.html', context)


def otii(request):
    job_id = 'otti_control'
    message = ''

    try:

        q = django_rq.get_queue('default')


        if 'stop_otii' in request.POST:
            # queue job only if not in queue already
            if job_id not in q.job_ids:
                job = django_rq.enqueue(stop_otii, job_id=job_id)
                job.meta['message'] = ''
                job.save_meta()
                time.sleep(0.1)

        if 'start_otii' in request.POST:
            # queue job only if not in queue already
            if job_id not in q.job_ids:
                job = django_rq.enqueue(start_otii, job_id=job_id)
                job.meta['message'] = ''
                job.save_meta()
                time.sleep(0.1)
        

        job = q.fetch_job(job_id) #fetch Job from redis
        if job:
            if job.is_queued:
                message = 'status: in-queue'
            elif job.is_failed:
                message = 'FAILED:\n' + job.exc_info
            elif (job.is_finished or job.is_started): #job is started or finished
                message = job.meta['message']
    except Exception:
        message = 'Redis server not connected'

    context = {'message': message}
    return render(request, 'energy/otii.html', context)