#!/bin/bash

TYPE=(
  yolov2-tiny-obj
  yolov3-obj
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
  CFG=my-cfg/${type}.cfg
  MODEL=backup/${type}.backup
    
  echo "Calculating recall for $type with $DATA"
  ./darknet detector recall $DATA $CFG $MODEL    
done
