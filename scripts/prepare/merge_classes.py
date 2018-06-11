#!/bin/python

coco_file = 'coco/classes.csv'
imagenet_file = 'imagenet/classes.csv'
target_file = 'obj.names'

classes = []
with open(coco_file,'r') as f:
    for line in f:
        classes.append(line.strip('\n'))

classes2 = []
with open(imagenet_file,'r') as f:
  for line in f:
    classes2.append(line.strip('\n').split(',') [0])
    
classes += classes2

print 'Classes:', classes
  
with open(target_file,'w') as f:
  for cls in classes:
    f.write(cls + '\n')  