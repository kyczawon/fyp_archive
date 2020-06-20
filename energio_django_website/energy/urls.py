from django.urls import path

from . import views

app_name = 'energy'

urlpatterns = [
    path('', views.index, name='index'),
    path('otii', views.otii, name='otii'),
    path('benchmark/<int:id>', views.benchmark, name='benchmark'),
    path('benchmark', views.benchmark_home, name='benchmark_home'),
    path('benchmark/<str:category>', views.benchmarks_by_cat, name='benchmarks_by_cat'),
    path('result/<int:id>', views.result, name='result'),
]