#!/usr/bin/python

import os
import shutil
import random
import numpy as np
import pandas as pd
import cv2

database_path = os.environ['HOME'] + '/Database/'
classes = ['microwave','tv','laptop','sink','dish','light','lamp','newspaper','food','oven','book']
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

    for im_file in images:
      if im_file not in df['image']:
        im = cv2.imread('%s/objects/%s/%s'%(database_path,class_name,im_file))
        cv2.imshow('im',im)
        key=cv2.waitKey(0) & 0xFF
        state = -1
        if key == ord('q'):
          break
        elif key == ord('0'):
          state = 0
        elif key == ord('1'):
          state = 1
        elif key == ord('2'):
          state = 2
        elif key == ord('n'):
          continue
        elif key == ord('z'):
          if len(df) > 0:
            df.drop(df.index[len(df)-1],inplace=True)
          continue
        else:
          continue

        df = df.append({'image':im_file,'state':state}, ignore_index=True)

    df.sort_values('image',inplace=True)
    df.to_csv('%s/objects/%s.csv'%(database_path,class_name),sep=',',index=False)