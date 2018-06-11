import xml.etree.ElementTree as ET
import pickle
import os
from os import listdir, getcwd
from os.path import join
import os
import sys
import argparse

imagenet_path = '/home/sanjif/Database/imagenet' # Path to imagenet database
if 'I_PATH' in os.environ:
  imagenet_path = os.environ['I_PATH']
  
imagenet_path += '/raw'

classes_file = 'obj.names'
wnib_mapping_file = 'imagenet/wnib_classes.csv'

cleaned_classes_file = 'imagenet/classes.csv'

classes = []
with open(classes_file,'r') as f:
    for line in f:
        classes.append(line.strip('\n'))

mapping = {}
cls_id = -1
prev_cls = ''
out_classes_file = open(cleaned_classes_file, 'w')
with open(wnib_mapping_file,'r') as f:
  for line in f:
    line_split = line.strip('\n').split(',')
    cls = line_split[0]
    if cls != prev_cls:
        cls_id+=1
        out_classes_file.write(cls + '\n')
    prev_cls = cls
    mapping[line_split[2]] = cls_id

    print cls, "(", cls_id, "):", line_split[2]

out_classes_file.close()
    
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

folders = os.listdir(imagenet_path + '/annotations')

def convert_annotation(folder,image_id):
    try:
      in_file = open(imagenet_path + '/annotations/' + folder + '/' + image_id + '.xml')
    except IOError:
      return
    out_file = open(imagenet_path + '/labels/' + folder + '/' + image_id + '.txt', 'w')
    tree=ET.parse(in_file)
    root = tree.getroot()
    size = root.find('size')
    w = int(size.find('width').text)
    h = int(size.find('height').text)

    for obj in root.iter('object'):
        difficult = obj.find('difficult').text
        wnid = obj.find('name').text
        if wnid not in mapping.keys():
          continue
        cls_id = mapping[wnid]
        if int(difficult) == 1:
            continue
        #cls_id = classes.index(cls)
        xmlbox = obj.find('bndbox')
        b = (float(xmlbox.find('xmin').text), float(xmlbox.find('xmax').text), float(xmlbox.find('ymin').text), float(xmlbox.find('ymax').text))
        bb = convert((w,h), b)
        out_file.write(str(cls_id) + " " + " ".join([str(a) for a in bb]) + '\n')
       
for folder in folders:
  
  im_paths = os.listdir(imagenet_path + '/images/' + folder)
  
  if not os.path.exists('%s/labels/%s'%(imagenet_path,folder)):
    os.makedirs('%s/labels/%s'%(imagenet_path,folder))
  
  for im_path in im_paths:
    image_id = im_path.split('.')[0]
    convert_annotation(folder,image_id)
