#!/usr/bin/env python
import os
import argparse
import pandas as pd

results_path = '/home/sanjif/programs/darknet/results'

columns = list(range(0,50))
columns += ['precision','recall','F1-score','TP','FP','FN','average IOU','mAP']

df = pd.DataFrame(columns=columns)
df.index.name = 'model'

for file in os.listdir(results_path):  
  if file in ['YOLO_model_results.csv','data_split.txt','old','old_v2']:
    continue
  with open (results_path + '/' + file) as f:
    results = pd.Series(index=columns)
    results.name = file.split('.')[0]
    for line in f:
      if 'class_id' in line:
        data = line.strip('\n').replace('\t','').replace('\r','').split(',')
        cls_id = data[0].split(' = ')[-1]
        cls_name = data[1].split(' = ' )[-1]
        cls_ap = data[2].split(' = ')[-1].split(' % ')[0]
        results[int(cls_id)] = float(cls_ap)

      elif 'thresh' in line and 'precision' in line:
        data = line.strip('\n').split(',')
        precision = data[1].split(' = ')[-1]
        recall = data[2].split(' = ')[-1]
        F1 = data[3].split(' = ')[-1][:-1]

        results['precision'] = precision
        results['recall'] = recall
        results['F1-score'] = F1
      elif 'thresh' in line and 'TP' in line:
        data = line.strip('\n').split(',')
        TP = data[1].split(' = ')[-1]
        FP = data[2].split(' = ')[-1]
        FN = data[3].split(' = ')[-1]
        IOU = data[4].split(' = ')[-1].split(' % ')[0]
        
        results['TP'] = float(TP)
        results['FP'] = float(FP)
        results['FN'] = float(FN)
        results['average IOU'] = IOU
      elif 'mean average' in line:
        mAP = line.strip('\n').split(',')[0].split(' = ')[-1]
        
        results['mAP'] = float(mAP)*100
    df = df.append(results)

df.sort_values(0)
df.to_csv(results_path + '/YOLO_model_results.csv')