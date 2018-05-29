#!/usr/bin/env python
import os
import argparse
import pandas as pd

results_path = '/home/sanjif/programs/darknet/results'

columns = list(range(0,30))
columns += ['precision','recall','F1-score','TP','FP','FN','average IOU','mAP']

df = pd.DataFrame(columns=columns)

for file in os.listdir(results_path):
  if file in ['YOLO_model_results.xlsx','data_split.txt']:
    continue
  if '50' in file:
    continue
  print file.split('.')[0]
  
  with open(results_path + '/' + file,'r') as f:
    for line in f:
      if 'class_id' in line:
        for l in line.strip('\n').split(', '):
          print l.split(' = ')[-1]
        
      
