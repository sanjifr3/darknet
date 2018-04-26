#!/usr/bin/python

import os
import shutil
import argparse
import numpy as np
import cv2

database_path = os.environ['HOME'] + '/Database/'
classes = ['microwave','tv','laptop','sink','dish','light','lamp','newspaper','food','oven','book']
min_size = 3000 #px^2
show_image = False

def getClasses(file):
  classes = []
  with open(file,'r') as f:
    for line in f:
      classes.append(line.strip('\n').split(',')[0])
  return classes

def getClsId(cls,all_classes):
  if cls in all_classes:
    return all_classes.index(cls)
  return -1

def parseTrainingFiles(files_path):
  files = []
  with open(files_path + '_train.txt','r') as f:
    for line in f:
      line = line.strip('\n')#.replace('images','labels').split('.')[0] + '.txt'
      files.append(line)

  with open(files_path + '_test.txt','r') as f:
    for line in f:
      line = line.strip('\n')#.replace('images','labels').split('.')[0] + '.txt'
      files.append(line)
  return files

def getImagePaths(class_name, coco_classes, imagenet_classes, script_path):
  files = []
  if class_name in coco_classes:
    files = parseTrainingFiles(script_path + 'coco/coco')
  elif class_name in imagenet_classes:
    files = parseTrainingFiles(script_path + 'imagenet/imagenet')
  return files

def getBBs(file, id):
  bb = []
  file = file.replace('images','labels').split('.')[0] + '.txt'
  with open(file,'r') as f:
    for line in f:
      line = line.strip('\n').split(' ')
      cls_id = int(line[0])
      if cls_id == id:
        bb.append((float(line[1]),float(line[2]),float(line[3]),float(line[4])))
  return bb

def showImage(im,pt1,pt2):
  im2 = im.copy()
  cv2.rectangle(im2, pt1, pt2, (0,255,0), 3)
  cv2.imshow('im',im2)
  cv2.waitKey(0)
  return

def cropImage(im_path,bb):
  global min_size, show_image
  im = cv2.imread(im_path)

  x = int(bb[0]*im.shape[1])
  y = int(bb[1]*im.shape[0])
  w = int(bb[2]*im.shape[1])
  h = int(bb[3]*im.shape[0])

  if w*h < min_size:
    return

  pt1 = (x-w/2,y-h/2)
  pt2 = (x+w/2,y+h/2)

  if show_image:
    showImage(im,pt1,pt2)
  
  im = im[pt1[1]:pt2[1], pt1[0]:pt2[0]]

  return im

ctr = 0
def saveImg(im, class_name):
  global ctr
  cv2.imwrite('%s/objects/%s/%s%d.jpg'%(database_path,class_name,class_name,ctr),im)
  ctr+=1

if __name__ == '__main__':
  script_path = os.path.realpath(__file__).split(__file__)[0]

  # Get classes
  coco_classes = getClasses(script_path + 'coco/classes.csv')
  imagenet_classes = getClasses(script_path  + 'imagenet/classes.csv')
  all_classes = getClasses(script_path + 'obj.names')

  for class_name in classes:
    print 'Creating %s dataset' %(class_name)
    # Get class id
    class_id = getClsId(class_name, all_classes)
    if class_id == -1:
      print '%s not in dataset!' % (class_name)
      continue

    # Get image_paths
    files = getImagePaths(class_name, coco_classes, imagenet_classes, script_path)
    if len(files) == 0:
      print '%s not in dataset!' % (class_name)
      continue

    # Make save directory or clear existing directory
    if not os.path.exists('%s/objects/%s'%(database_path,class_name)):
      os.makedirs('%s/objects/%s'%(database_path,class_name))
    else:
      shutil.rmtree('%s/objects/%s'%(database_path,class_name))
      os.makedirs('%s/objects/%s'%(database_path,class_name))

    for file in files:
      try:
        bbs = getBBs(file, class_id)
      except IOError:
        continue
      if len(bbs) > 0:
        for bb in bbs: 
          im = cropImage(file, bb)
          if im is not None:
            saveImg(im, class_name)