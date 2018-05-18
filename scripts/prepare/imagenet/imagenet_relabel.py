#!/usr/bin/python

import os
import sys

imagenet_path = '/home/sanjif/Database/imagenet'

if 'IN_PATH' in os.environ:
  imaganet_path = os.environ('C_PATH')

script_path = os.path.realpath(__file__)

classes_path = script_path.split(os.path.basename(__file__))[0]

if imagenet_path[-1] != '/':
  imagenet_path += '/'

original_classes_file = 'old_obj.names'
classes_file = 'obj.names'

old_classes = []
with open (classes_path + '../' + original_classes_file, 'r') as f:
  for line in f:
    old_classes.append(line.strip('\n'))

classes = []
with open (classes_path + '../' + classes_file, 'r') as f:
  for line in f:
    classes.append(line.strip('\n'))

print old_classes
print '\n'
print classes

remapping = {}
for i in range(len(old_classes)):
  try:
    remapping[i] = classes.index(old_classes[i])
  except ValueError:
    remapping[i] = -1

print remapping

for label_folder in ['labels','my_labels']:
  for set in os.listdir(imagenet_path + 'raw/.' + label_folder):
    for file in os.listdir(imagenet_path + 'raw/.' + label_folder + '/' + set):
      print imagenet_path + 'raw/.' + label_folder + '/' + set + '/' + file
      with open(imagenet_path + 'raw/.' + label_folder + '/' + set + '/' + file, 'r') as f:
        if not os.path.exists(imagenet_path + 'raw/' + label_folder + '/' + set + '/'):
          os.makedirs(imagenet_path + 'raw/' + label_folder + '/' + set + '/')

        fout = open(imagenet_path + 'raw/' + label_folder + '/' + set + '/' + file, 'w')
        for line in f:
          line = line.strip('\n').split()
          line[0] = str(remapping[int(line[0])])
          if int(line[0]) != -1:
            # print ' '.join(line)
            fout.write(' '.join(line))
            fout.write('\n')
        fout.close()