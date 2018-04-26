#!/bin/python
import os
import sys
import argparse

coco_path = os.environ['HOME'] + '/Database/coco' # Path to coco database
if 'C_PATH' in os.environ:
  coco_path = os.environ['C_PATH']
  
script_path = os.path.realpath(__file__)
tools_path = script_path.split('scripts/prepare')[0] + 'tools/coco/PythonAPI/'
classes_path = script_path.split(os.path.basename(__file__))[0]

if coco_path[-1] == '/':
  coco_path = coco_path[0:-1]

original_classes_file = classes_path + 'all_classes.csv'
classes_file = classes_path + 'classes.csv'

labels_path = 'my_labels'

# Set threshold from command line
ap = argparse.ArgumentParser()
ap.add_argument("-a","--all", required=False, action='store_true', help="Create labels for all possible classes")
args = vars(ap.parse_args())

if args['all']:
  classes_file = original_classes_file
  labels_path = 'all_labels'

sets=[('2014', 'val'), ('2014', 'train'), ('2017', 'train'), ('2017', 'val')]

classes = []
with open(classes_file,'r') as f:
  for line in f:
    classes.append(line.strip('\n'))

if 'food' in classes:
  classes.remove('food')
  classes += ['banana','apple','sandwich','orange','broccoli','carrot','hot dog','pizza','donut','cake']
  
sys.path.insert(0,tools_path)

import xml.etree.ElementTree as ET
from pycocotools.coco import COCO
import cv2
import shutil

for year, image_set in sets:
  if not os.path.exists('%s/%s/%s%s'%(coco_path,labels_path,image_set,year)):
    os.makedirs('%s/%s/%s%s'%(coco_path,labels_path,image_set,year))
  else:
    shutil.rmtree('%s/%s/%s%s/'%(coco_path,labels_path,image_set,year))
    os.makedirs('%s/%s/%s%s'%(coco_path,labels_path,image_set,year))
    
  coco = COCO('%s/annotations/instances_%s%s.json'%(coco_path,image_set,year))
  
  for category in classes:
    print classes.index(category)

    catIds = coco.getCatIds(catNms=category)
    imgIds = coco.getImgIds(catIds=catIds)

    for im_id in imgIds:
      im_path = coco.loadImgs(im_id)[0]['file_name']

      f = open("%s/%s/%s%s/%s.txt"%(coco_path,labels_path,image_set,year,im_path.split('.')[0]),'a+')
      
      annIds = coco.getAnnIds(im_id, catIds=catIds, iscrowd=False)
      anns = coco.loadAnns(annIds)

      im = cv2.imread(coco_path + '/images/' + image_set + year + '/' + im_path,0)

      for ann in anns:
        l = ann['bbox'][0] 
        t = ann['bbox'][1]
        r = ann['bbox'][0] + ann['bbox'][2]
        b = ann['bbox'][1] + ann['bbox'][3]

        x = (l+r)/2.0/im.shape[1]
        y = (t+b)/2.0/im.shape[0]
        w = (r-l)/im.shape[1]
        h = (b-t)/im.shape[0]
        
        f.write('%d %.6f %.6f %.6f %.6f\n'%(classes.index(category),x,y,w,h))
      f.close()
