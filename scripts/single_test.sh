#!/bin/bash

DATA=data/obj.data

TYPE=(
  tiny-yolo-voc-obj
  yolo-voc-obj
)

for type in $TYPE; do
  CFG=cfg/${type}.cfg
  MODEL=backup/${type}.backup
  mkdir -p test/$type
  for image in `ls test/images/`; do
    img=test/images/$image
    ./darknet detector test $DATA $CFG $MODEL $img
    mv predictions.jpg test/$type/$image
  done
done
