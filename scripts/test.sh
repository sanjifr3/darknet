#!/bin/bash

DATA=data/obj.data

TYPE=(
  yolov2-tiny-obj
  yolov3-obj
)

for type in $TYPE; do
  CFG=cfg/${type}.cfg
  MODEL=backup/${type}.backup
  ./darknet detector recall $DATA $CFG $MODEL
done
