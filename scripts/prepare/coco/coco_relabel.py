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

coco_classes_file = classes_path + 'all_classes.csv'
all_classes_file = classes_path + '../obj.names'

coco_classes = []
with open(coco_classes_file,'r') as f:
  for line in f:
    coco_classes.append(line.strip('\n'))

all_classes = []
with open(all_classes_file,'r') as f:
  for line in f:
    all_classes.append(line.strip('\n'))

print coco_classes
print all_classes

print 'Relabelling COCO'

food = ['banana','apple','sandwich','orange','broccoli','carrot','hot dog','pizza','donut','cake']

remapping = {}
for i in range(len(coco_classes)):
  if coco_classes[i] in food and 'food' in all_classes:
    coco_classes[i] = 'food'
  try:
    remapping[i] = all_classes.index(coco_classes[i])
  except ValueError:
    remapping[i] = -1

sys.path.insert(0,tools_path)

import xml.etree.ElementTree as ET
from pycocotools.coco import COCO

sets=[('2014', 'val'), ('2014', 'train'), ('2017', 'train'), ('2017', 'val')]

for year, image_set in sets:
  if not os.path.exists('%s/labels/%s%s'%(coco_path,image_set,year)):
    os.makedirs('%s/labels/%s%s'%(coco_path,image_set,year))

  for file in os.listdir('%s/my_labels/%s%s'%(coco_path,image_set,year)):
    with open(coco_path + '/my_labels/' + image_set + year + '/' + file,'r') as f:
      fout = open(coco_path + '/labels/' + image_set + year + '/' + file,'w')
      for line in f:
        line = line.strip('\n').split()
        line[0] = str(remapping[int(line[0])])
        if int(line[0]) != -1:
          fout.write(' '.join(line))
          fout.write('\n')
      fout.close()