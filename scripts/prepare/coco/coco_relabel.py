#!/bin/python
import os
import sys

coco_path = '/home/sanjif/Database/coco' # Path to coco database
if 'C_PATH' in os.environ:
  coco_path = os.environ['C_PATH']

script_path = os.path.realpath(__file__)
tools_path = script_path.split('scripts/prepare')[0] + 'tools/coco/PythonAPI/'
classes_path = script_path.split(os.path.basename(__file__))[0]

if coco_path[-1] != '/':
  coco_path += '/'

original_classes_file = classes_path + 'all_classes.csv'
classes_file = classes_path + 'classes.csv'

sys.path.insert(0,tools_path)

import xml.etree.ElementTree as ET
from pycocotools.coco import COCO

sets=[('2014', 'train'), ('2014', 'val')]

# remap the following set as food
food = ['banana','apple','sandwich','orange','broccoli','carrot','hot dog','pizza','donut','cake']

original_classes = []
with open(original_classes_file,'r') as f:
  for line in f:
    original_classes.append(line.strip('\n'))

classes = []
with open(classes_file,'r') as f:
  for line in f:
    classes.append(line.strip('\n'))

print 'Relabelling COCO'
        
remapping = {}
for i in range(len(original_classes)):
  if original_classes[i] in food and 'food' in classes:
    original_classes[i] = 'food'
  try: 
    remapping[i] = classes.index(original_classes[i])
  except ValueError:
    remapping[i] = -1

for year, image_set in sets:
  if not os.path.exists(coco_path + 'labels/.' + image_set + year):
    if os.path.exists(coco_path + 'labels/' + image_set + year):
      os.rename(coco_path + 'labels/' + image_set + year, coco_path + 'labels/.' + image_set + year)

  if not os.path.exists('%s/labels/%s%s'%(coco_path,image_set,year)):
    os.makedirs('%s/labels/%s%s'%(coco_path,image_set,year))
    
  original_label_files = os.listdir('%s/labels/.%s%s'%(coco_path,image_set,year))

  for file in original_label_files:
    with open(coco_path + '/labels/.' + image_set + year + '/' + file,'r') as f:
      fout = open(coco_path + '/labels/' + image_set + year + '/' + file,'w')
      for line in f:
        line = line.strip('\n').split()
        line[0] = str(remapping[int(line[0])])
        if int(line[0]) != -1:
          fout.write(' '.join(line))
          fout.write('\n')
      fout.close()