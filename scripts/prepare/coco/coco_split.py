#!/usr/bin/python

## Note coco folder structure
# coco > images > train2014
# coco > images > val2014
# coco > labels > .train2014 # original labels moved here
# coco > labels > .test2014 # original labels moved here
# coco > trainvalno5k.txt # File containing training file path
# coco > 5k.txt # File containing testing file paths

import os
import numpy as np

coco_path = "/home/sanjif/Database/coco/"

classes_file = 'all_classes.csv'
training_file = 'trainvalno5k.txt'
testing_file = '5k.txt'
classes = []
training_files = []
testing_files = []

with open(classes_file,'r') as f:
  for line in f:
    classes.append(line.strip('\n'))

with open(coco_path + training_file,'r') as f:
  for line in f:
    line = line.strip('\n').replace('images','labels').split('.')[0].replace('labels/','labels/.') + '.txt'
    training_files.append(line)

with open(coco_path + testing_file,'r') as f:
  for line in f:
    line = line.strip('\n').replace('images','labels').split('.')[0].replace('labels/','labels/.') + '.txt'
    testing_files.append(line)

train_ctr = np.zeros(len(classes))
test_ctr = np.zeros(len(classes))

for ctr, st in zip([train_ctr, test_ctr], [training_files, testing_files]):
  for file in st:
    try:
      with open(file,'r') as f:
        for line in f:
          cls_id = int(line.split(' ')[0])
          ctr[cls_id]+=1
    except IOError:
      print "IOERROR:",file
        
for c,t,v in zip(classes,train_ctr,test_ctr):
  print c,t,v
