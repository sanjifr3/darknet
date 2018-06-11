#!/usr/bin/python

import os
import sys

imagenet_path = '/home/sanjif/Database/imagenet'
classes_file = 'imagenet/classes.csv'
wnib_file = 'imagenet/wnib_classes.csv'

if 'IN_PATH' in os.environ:
  imaganet_path = os.environ('I_PATH')

script_path = os.path.realpath(__file__)
classes_path = script_path.split(os.path.basename(__file__))[0]

if imagenet_path[-1] != '/':
  imagenet_path += '/'

imagenet_classes_file = classes_path + 'classes.csv'
all_classes_file = classes_path + '../obj.names'

in_classes = []
with open(imagenet_classes_file,'r') as f:
  for line in f:
    in_classes.append(line.strip('\n'))

all_classes = []
with open(all_classes_file,'r') as f:
  for line in f:
    all_classes.append(line.strip('\n'))

print in_classes
print all_classes

print 'Relabelling ImageNet'

food = ['banana','apple','sandwich','orange','broccoli','carrot','hot dog','pizza','donut','cake']

remapping = {}
for i in range(len(in_classes)):
  if in_classes[i] in food and 'food' in all_classes:
    in_classes[i] = 'food'
  try:
    remapping[i] = all_classes.index(in_classes[i])
  except ValueError:
    remapping[i] = -1

print remapping

classes = []
with open(classes_file, 'r') as f:
  for line in f:
    classes.append(line.strip('\n'))
print classes

wnib_mapping = {}
with open(wnib_file, 'r') as f:
  for line in f:
    line_split = line.strip('\n').split(',')
    wnib_mapping[line_split[2]] = classes.index(line_split[0])

print wnib_mapping

folders = ['train','test']

for folder in folders:
  if not os.path.exists('%s/labels/%s'%(imagenet_path,folder)):
    os.makedirs('%s/labels/%s'%(imagenet_path,folder))

  for file in os.listdir('%s/my_labels/%s'%(imagenet_path,folder)):
    with open('%s/my_labels/%s/%s'%(imagenet_path,folder,file),'r') as f:
      fout = open('%s/labels/%s/%s'%(imagenet_path,folder,file),'w')
      for line in f:
        line = line.strip('\n').split()
        line[0] = str(remapping[int(line[0])])
        if int(line[0]) != -1:
          #print ' '.join(line)
          fout.write(' '.join(line))
          fout.write('\n')
      fout.close()