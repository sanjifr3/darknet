#!/usr/bin/python


## Do the following remapping to the imagenet dataset:
  # 47 - 27
  # 48 - 28
  # 49 - 29

import os
import numpy as np

classes_file = 'obj.names'
training_file = 'train.txt'
testing_file = 'test.txt'
classes = []
training_files = []
testing_files = []


with open(classes_file,'r') as f:
  for line in f:
    classes.append(line.strip('\n'))

with open(training_file,'r') as f:
  for line in f:
    line = line.strip('\n').replace('images','labels').split('.')[0] + '.txt'
    training_files.append(line)

with open(testing_file,'r') as f:
  for line in f:
    line = line.strip('\n').replace('images','labels').split('.')[0] + '.txt'
    testing_files.append(line)


train_ctr = np.zeros(len(classes))
test_ctr = np.zeros(len(classes))

for ctr, st in zip([train_ctr, test_ctr], [training_files, testing_files]):
  for file in st:
    with open(file,'r') as f:
      for line in f:
        cls_id = int(line.split(' ')[0])
        ctr[cls_id]+=1
        
for c,t,v in zip(classes,train_ctr,test_ctr):
  print c,t,v
