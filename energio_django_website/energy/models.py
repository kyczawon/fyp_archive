from django.db import models
from django.core.exceptions import ValidationError
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

def validate_file_extension(value):
    if value.file.content_type != 'application/zip':
        raise ValidationError(u'Uploaded file is not a zip file')

class Benchmark(models.Model):
    file = models.FileField(upload_to='files/%Y/%m/%d', validators=[validate_file_extension])
    name = models.CharField(max_length=200)
    date = models.DateTimeField(default=timezone.now, blank=True)
    category = models.CharField(max_length=200)
    clear_cache = models.BooleanField(default=True)
    close_apps = models.BooleanField(default=True)
    init = models.BooleanField(default=True)

    class ExecProg(models.TextChoices):
        MONKEYRUNNER = 'monkeyrunner', _('monkeyrunner')
        JAVA = 'java', _('Java 1.8.0_241-b07 (UI Automator)')
        PYTHON = 'python', _('python 2.7.16 (androidViewClient)')
        PYTHON3 = 'python3', _('python 3.7.4')

    exec_prog = models.CharField(
        max_length=12,
        choices=ExecProg.choices,
        default=ExecProg.MONKEYRUNNER,
    )

class App(models.Model):
    benchmark = models.ForeignKey(Benchmark, on_delete=models.CASCADE)
    name = models.CharField(max_length=200)

class Task(models.Model):
    benchmark = models.ForeignKey(Benchmark, on_delete=models.CASCADE)
    name = models.CharField(max_length=200)

class Result(models.Model):
    benchmark = models.ForeignKey(Benchmark, on_delete=models.CASCADE)
    app = models.ForeignKey(App, on_delete=models.CASCADE)
    task = models.ForeignKey(Task, on_delete=models.CASCADE)
    result = models.FloatField(default=None, null=True, blank=True)
    graph = models.FilePathField(default='', blank=True)
    csv = models.FilePathField(default='', blank=True)
    screenshot_path = models.FilePathField(default='', blank=True)

    message = models.CharField(max_length=2000, blank=True)

    class ResultStatus(models.TextChoices):
        QUEUED = 'QU', _('QUEUED')
        STARTED = 'ST', _('STARTED')
        CLEARING_CACHE = 'CC', _('CLEARING CACHE')
        CLOSING_APPS= 'CA', _('CLOSING APPS')
        RUNNING_INIT = 'RI', _('RUNNING INIT SCRIPT')
        RUNNING_SCRIPT = 'RS', _('RUNNING SCRIPT')
        SCREENSHOT= 'TS', _('TAKING SCREENSHOT')
        SAVING= 'SD', _('SAVING DATA')
        FAILED = 'FA', _('FAILED')
        FINISHED = 'FI', _('FINISHED')


    status = models.CharField(
        max_length=2,
        choices=ResultStatus.choices,
        default=ResultStatus.QUEUED,
    )

class Measurement(models.Model):
    result = models.ForeignKey(Result, on_delete=models.CASCADE)
    time = models.FloatField()
    current = models.FloatField()
    voltage = models.FloatField()
    energy = models.FloatField()