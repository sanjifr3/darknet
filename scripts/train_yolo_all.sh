#!/bin/bash

BACKUP_DIR=$HOME/programs/darknet/backup

for VAR in {0..100}
do
  export LOOP=$var
  if [ ! -f $BACKUP_DIR/tiny-yolo8-voc_final.weights ]; then ./yolo.sh train tiny voc; fi
  if [ ! -f $BACKUP_DIR/tiny-yolo40-train_final.weights ]; then ./yolo.sh train tiny coco; fi
  if [ ! -f $BACKUP_DIR/yolo8-voc-train_final.weights ]; then ./yolo.sh train full voc; fi
  if [ ! -f $BACKUP_DIR/yolo40-train_final.weights ]; then ./yolo.sh train full coco; fi
done

