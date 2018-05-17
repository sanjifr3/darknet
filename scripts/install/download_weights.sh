#!/bin/bash

cd ../weights/
wget https://pjreddie.com/media/files/yolo.weights
wget https://pjreddie.com/media/files/yolov3.weights
wget https://pjreddie.com/media/files/yolo-voc.weights
wget https://pjreddie.com/media/files/alexnet.weights
wget https://pjreddie.com/media/files/yolov2-tiny.weights
wget https://pjreddie.com/media/files/tiny-yolo.weights
wget https://pjreddie.com/media/files/tiny-yolo-voc.weights
wget https://pjreddie.com/media/files/yolo9000.weights
wget https://pjreddie.com/media/files/yolov3-tiny.weights

cd ../conv/
wget https://pjreddie.com/media/files/darknet19_448.conv.23
wget https://pjreddie.com/media/files/tiny-yolo-voc.conv.13
wget https://pjreddie.com/media/files/darknet53.conv.74
