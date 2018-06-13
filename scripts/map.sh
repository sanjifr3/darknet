#!/bin/bash

TYPE=(
  #yolov2-tiny-50obj
  #yolov3-50obj
  #yolov3-tiny-30obj
  #yolov3-30obj
  #yolov3-tiny-30obj-labelfixed
  #yolov3-tiny-30obj-labelfixed2
  yolov3-tiny-30obj-labelfixed3
  #yolov3-30obj-labelfixed
)

SUFFIXS=(
  _10000.weights
  #_50000.weights
  #_55000.weights
  #_60000.weights
  #_65000.weights
  #_70000.weights
  #_75000.weights
  #_80000.weights
  #_85000.weights
  #_90000.weights
  #_95000.weights
  #_100000.weights
  #_final.weights
)

cd ..

# Place cfg file in cfg/

# yolov2: (classes+5)*5
# yolov3: (classes+5)*3

# Takes 5.6 days to fully train yolo v2 on 49 classes with 5 secs/iteration
#5*((2000*49))/60/60/24 = 5.6 days

# Takes 2.25 days to fully train tiny yolo on 49 classes with 2 secs/iteration
#2*((2000*49))/60/60/24 = 2.26 days

DATA=data/obj.data
for type in ${TYPE[@]}; do
  for suffix in ${SUFFIXS[@]}; do
    CFG=my-cfg/${type}.cfg
    MODEL=backup/${type}${suffix}
    
    echo "Validating $type with $DATA"
    ./darknet detector map $DATA $CFG $MODEL > results/${type}${suffix}.txt
  done
done
