#!/bin/bash

DATA=data/obj.data

TYPE=(
  #yolov2-tiny-50obj
  #yolov3-50obj
  yolov3-tiny-30obj
  yolov3-30obj
)

for type in $TYPE; do
  CFG=cfg/${type}.cfg
  MODEL=backup/${type}.backup
  ./darknet detector recall $DATA $CFG $MODEL
done
