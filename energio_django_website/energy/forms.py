from django import forms
 
from .models import Benchmark
 
 
class BenchmarkForm(forms.ModelForm):
    class Meta:
        model = Benchmark
        fields = ['file','category']