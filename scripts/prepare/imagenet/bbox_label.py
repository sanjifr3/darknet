#!/bin/python2.7
# -*- coding: utf-8 -*-

import os
from os import walk, getcwd
from PIL import Image

imagenet_path = '/home/sanjif/Database/imagenet' # Path to imagenet database
if 'I_PATH' in os.environ:
  imagenet_path = os.environ['I_PATH']
imagenet_path += '/raw/'


bbox_path = '/home/sanjif/programs/darknet/tools' # Path to tools
if 'TOOLS_PATH' in os.environ:
  bbox_path = os.environ['TOOLS_PATH']
bbox_path += '/bbox-label-tool/'

classes_file = 'obj.names'
wnib_mapping_file = 'imagenet/classes.csv'

classes = []
with open(classes_file,'r') as f:
    for line in f:
        classes.append(line.strip('\n'))

mapping = {}
with open(wnib_mapping_file,'r') as f:
  for line in f:
    line_split = line.strip('\n').split(',')
    mapping[line_split[2]] = line_split[0]

print classes
print mapping
print bbox_path

print imagenet_path

def convert(size, box):
    dw = 1./size[0]
    dh = 1./size[1]
    x = (box[0] + box[1])/2.0
    y = (box[2] + box[3])/2.0
    w = box[1] - box[0]
    h = box[3] - box[2]
    x = x*dw
    w = w*dw
    y = y*dh
    h = h*dh
    return (x,y,w,h)

# Source folder
folders = os.listdir(bbox_path + 'labels')

outDir = imagenet_path + 'my_labels'

for folder in folders:
  
  # Make target folder if it doesn't exist
  if not os.path.exists(outDir + '/' + folder):
    os.mkdir(outDir + '/' + folder)

  for f in os.listdir(bbox_path + 'labels/' + folder):
    wnid = f.split('_')[0]
       
    if wnid in mapping.keys():
      cls = mapping[wnid]
      cls_i = classes.index(cls)
      im_path = bbox_path + 'Images/' + folder + '/' + f.split('.')[0] + '.JPEG'
      inp = bbox_path + 'labels/' + folder + '/' + f
      outp = outDir + '/' + folder + '/' + f
      # print inp + ' > ' + outp

      ''' Open input file '''
      txt_file = open(inp, 'r')
      lines = txt_file.read().split('\n')
      # print lines
    
      ''' Open output file '''
      txt_outfile = open(outp, "w")
    
      ''' Convert data to yolo format'''
      ct = 0
      for line in lines:
        if(len(line) >= 3):
          ct = ct+1
          #print(line + "\n")
          elems = line.split(' ')
          #print(elems)
          xmin = elems[0]
          xmax = elems[2]
          ymin = elems[1]
          ymax = elems[3]
          
          im = Image.open(im_path)
          w= int(im.size[0])
          h= int(im.size[1])
          
          b = (float(xmin), float(xmax), float(ymin), float(ymax))
          bb = convert((w,h), b)
          print(bb)
          txt_outfile.write(str(cls_i) + " " + " ".join([str(a) for a in bb]) + '\n')
