#!/bin/bash

MODEL=${1:-yolov3-30obj}
TYPE=${2:-final}

cd ../my-weights
rm $MODEL.weights
ln -s ../backup/${MODEL}_${TYPE}.weights ${MODEL}.weights
