#!/usr/bin/python

import os
import shutil
import random
import argparse
import numpy as np
import pandas as pd
import cv2

database_path = os.environ['HOME'] + '/Database/'
classes = ['microwave','tv','laptop','sink','dish','light','lamp','newspaper','food','oven','book']


ap = argparse.ArgumentParser()
ap.add_argument('-c','--class',required=False,help='Class name to label')
args = vars(ap.parse_args())

if args['class'] is not None:
  if args['class'] not in classes:
    print 'ERROR:', args['class'], "not in", classes  
    exit(1)
  classes = [args['class']]
else:
  classes = ['microwave']

min_size = 3000 #px^2
show_image = False

ctr = 0
def saveImg(im, class_name):
  global ctr
  cv2.imwrite('%s/objects/%s/%s%d.jpg'%(database_path,class_name,class_name,ctr),im)
  ctr+=1

if __name__ == '__main__':
  for class_name in classes:
    images = os.listdir('%s/objects/%s'%(database_path,class_name))
    random.shuffle(images)

    df = pd.DataFrame()
    try:
      df = pd.read_csv('%s/objects/%s.csv'%(database_path,class_name),sep=',')
    except IOError:
      df = pd.DataFrame(columns=['image','state'])

    print 'press 0 for apply state 0'
    print 'press 1 for apply state 1'
    print 'press 2 for apply state 2'
    print 'press z or 7 to delete last applied label'
    print 'press . to skip image'
    print 'press q or 9 to quit'

    i = 0
    while i < len(images):
      im_file = images[i]
      if im_file not in df['image']:
        print '%s/objects/%s/%s'%(database_path,class_name,im_file)
        im = cv2.imread('%s/objects/%s/%s'%(database_path,class_name,im_file))

        if im is None:
          print 'Invalid image file:', im_file
          i+=1
          continue

        im_size = im.shape[0] * im.shape[1]
        if im_size < min_size:
          print im_file, ': size:', im_size, '<', min_size
          i+=1
          continue

        cv2.imshow('im',im)
        key=cv2.waitKey(0) & 0xFF
        state = -1
        if key == ord('q') or key == ord('9'):
          break
        elif key == ord('0'):
          state = 0
        elif key == ord('1'):
          state = 1
        elif key == ord('2'):
          state = 2
        elif key == ord('.'):
          i+=1
          print 'skip'
          continue
        elif key == ord('z') or key == ord('7'):
          if len(df) > 0:
            df.drop(df.index[len(df)-1],inplace=True)
            print 'delete last label'
            i-=1
          continue
        else:
          continue

        print im_file,state
        print 'Labelled:', len(df), '/', len(images), 'images'
        df = df.append({'image':im_file,'state':state}, ignore_index=True)
        df.sort_values('image',inplace=True)
        df.to_csv('%s/objects/%s.csv'%(database_path,class_name),sep=',',index=False)
        i+=1