#!/usr/bin/python2.7
from pycocotools.coco import COCO
import numpy as np
import cv2
import skimage.io as io
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import pylab

pylab.rcParams['figure.figsize'] = (8.0, 10.0)

from_net = False
categories_of_interest = ['dining table','bed','couch','sink','refrigerator','oven','microwave','tv','book','laptop','cell phone']#['person','dog','skateboard']
year = 2017
dir = '/home/sanjif/Database/coco'
set_id = 0
font = cv2.FONT_HERSHEY_DUPLEX

typ_set = ['val','train']
typ = typ_set[set_id]
file = typ + str(year)

class coco:
  def __init__(self,file_name):
    self.ann_path = dir + '/annotations/instances_' + file_name + '.json'
    # self.keypts_path = dir + '/annotations/person_keypoints_' + file_name + '.json'
    # self.caps_path = dir + '/annotations/captions_' + file_name + '.json'
    # self.im_path = dir + '/images/' + file_name + '/'
    self.coco = COCO(self.ann_path)
    # try:
    #   self.coco_kps = COCO(self.keypts_path)
    # except IOError:
    #   self.coco_kps = ''
    # try:
    #   self.coco_caps = COCO(self.caps_path)
    # except IOError:
    #   self.coco_caps = ''

  def getFullCategories(self):
    self.fullCategories = self.coco.loadCats(self.coco.getCatIds())
    return self.fullCategories

  def getCategories(self):
    if hasattr(self, 'categories'):
      return self.categories

    if not hasattr(self, 'fullCategories'):
      self.fullCategories = self.getFullCategories()

    self.categories = [cat['name'] for cat in self.fullCategories]
    return self.categories

  def getSuperCategories(self):
    if hasattr(self, 'superCategories'):
      return self.superCategories

    if not hasattr(self, 'fullCategories'):
      fullCategories = self.getFullCategories()

    self.superCatergories = set([cat['supercategory'] for cat in self.fullCategories])
    return self.superCatergories

  def getImgIds(self, cat):
    catIds = self.coco.getCatIds(catNms=cat)
    imgIds = self.coco.getImgIds(catIds=catIds)
    return imgIds

  def getImgInfo(self, im_id):
    return self.coco.loadImgs(im_id)[0]

  def getCatIds(self, cat):
    return self.coco.getCatIds(catNms=cat)

  def getAnnIds(self, im_id, cat):
    cat_ids = self.getCatIds(cat)
    return self.coco.getAnnIds(im_id, catIds=cat_ids, iscrowd=False)

  def getAnns(self, im_id, cat):
    ann_ids = self.getAnnIds(im_id, cat)
    return self.coco.loadAnns(ann_ids)

  def getBoundRect(self, im_id, cat):
    anns = self.getAnns(im_id,cat)

    cat_ids = self.getCatIds(cat)

    cat_dict = {}
    for ct,cid in zip(cat,cat_ids):
      cat_dict[cid] = ct

    bb = {}
    for ann in anns:
      l = int(ann['bbox'][0])
      t = int(ann['bbox'][1])
      r = int(ann['bbox'][0] + ann['bbox'][2])
      b = int(ann['bbox'][1] + ann['bbox'][3])

      bb[cat_dict[ann['category_id']]] = [l,t,r,b]

    return bb, anns


  ## Keypoint functions
  def getKPAnnIds(self, im_id, cat):
    cat_ids = self.getCatIds(cat)
    return self.coco_kps.getAnnIds(im_id, catIds=cat_ids, iscrowd=False)

  def getKPAnns(self, im_id, cat):
    ann_ids = self.getKPAnnIds(im_id, cat)
    return self.coco_kps.loadAnns(ann_ids)


  ## Caption functions
  def getCapAnnIds(self, im_id):
    return self.coco_caps.getAnnIds(im_id)

  def getCapAnns(self, im_id):
    ann_ids = self.getCapAnnIds(im_id)
    return self.coco_caps.loadAnns(ann_ids)

  def getImgPath(self,im_id):
    im_info = self.getImgInfo(im_id)
    return im_info['file_name']

  ## Show
  def getImg(self, im_id):
    im_info = self.getImgInfo(im_id)

    if from_net:
      im = io.imread(im_info['coco_url'])
    else:
      im = cv2.imread(self.im_path + im_info['file_name'])
      im = cv2.cvtColor(im, cv2.COLOR_BGR2RGB)
    return im

  def showImgWAnn(self,im, ann=[]):
    #plt.figure()
    plt.axis('off')
    plt.imshow(im)
    if len(ann) > 0:
      self.coco.showAnns(ann)
    plt.show()

  def showImgWKP(self,im, ann=[]):
    #plt.figure()
    plt.axis('off')
    plt.imshow(im)
    if len(ann) > 0:
      self.coco_kps.showAnns(ann)
    plt.show()

  def drawRect(self,c_bb_):
    for cat,bb in c_bb.items():
      cv2.rectangle(im,(bb[0],bb[1]),(bb[2],bb[3]),(0,255,0),3)
      text = "{}".format(cat)
      cv2.putText(im, text, (bb[0],bb[1]-10), font, 0.6, (0,255,0),1)

  def showCaptions(self, im_id):
    anns = self.getCapAnns(im_id)
    print ''
    return self.coco_caps.showAnns(anns)

  def showImg2(self,im, wait=1):
    im = cv2.cvtColor(im, cv2.COLOR_RGB2BGR)
    cv2.imshow('im',im)
    cv2.waitKey(wait)


if __name__ == '__main__':

  for year in [2017,2014]:
    for typ in typ_set:
      file = typ + str(year)
      data = coco(file)

      for category in data.getCategories():
        f = open(dir + "/sorted/"  + category + '_' + typ + '_' + str(year) + '.csv','w')
        f.write('im_file,l,t,r,b\n')
        im_ids = data.getImgIds(category)

        print '{} {} relevant images found!'.format(len(im_ids),category)

        for im_id in im_ids:
          im = data.getImg(im_id)
          c_bb, anns = data.getBoundRect(im_id, category)
          imPath = data.getImgPath(im_id)

          for cat, bb in c_bb.items():
            f.write(imPath 
                     + ',' + str(bb[0]) 
                     + ',' + str(bb[1])
                     + ',' + str(bb[2])
                     + ',' + str(bb[3])
                     + '\n')

        f.close()
        
  exit(1)

  im_ids = data.getImgIds(categories_of_interest)

  for im_id in im_ids:
    im = data.getImg(im_id)

    c_bb, anns = data.getBoundRect(im_id, categories_of_interest)

    data.drawRect(c_bb)

    data.showImg2(im,0)
    continue

    data.showImgWAnn(im, anns)
    
    # kp_anns = data.getKPAnns(im_id, categories_of_interest)
    # data.showImgWKP(im, kp_anns)

    # data.showCaptions(im_id)
