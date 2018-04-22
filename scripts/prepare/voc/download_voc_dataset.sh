#!/bin/bash
DIR=${DATABASE_PATH:-$HOME/Database}

mkdir -p $DIR/voc

#VOC
cd $DIR/voc

wget https://pjreddie.com/media/files/VOCtrainval_11-May-2012.tar
wget https://pjreddie.com/media/files/VOCtrainval_06-Nov-2007.tar
wget https://pjreddie.com/media/files/VOCtest_06-Nov-2007.tar
wget https://pjreddie.com/media/files/voc_label.py
wget https://pjreddie.com/media/files/darknet19_448.conv.23
tar xf VOCtrainval_11-May-2012.tar
tar xf VOCtrainval_06-Nov-2007.tar
tar xf VOCtest_06-Nov-2007.tar

python voc_label.py
cat 2007_train.txt 2007_val.txt 2012_*.txt > train.txt
