#!/bin/bash
DIR=${PROGRAM_PATH:-$HOME/programs}

echo "Installing YOLO in $DIR..."

cd $DIR

git clone https://github.com/sanjifr3/darknet.git

cd darknet
make

cd weights
wget https://pjreddie.com/media/files/yolo.weights
wget https://pjreddie.com/media/files/yolov3.weights
wget https://pjreddie.com/media/files/yolo-voc.weights
wget https://pjreddie.com/media/files/alexnet.weights
wget https://pjreddie.com/media/files/yolov2-tiny.weights
wget https://pjreddie.com/media/files/tiny-yolo.weights
wget https://pjreddie.com/media/files/tiny-yolo-voc.weights
wget https://pjreddie.com/media/files/yolo9000.weights

cd ../conv
wget https://pjreddie.com/media/files/darknet19_448.conv.23
wget https://pjreddie.com/media/files/tiny-yolo-voc.conv.13
wget https://pjreddie.com/media/files/darknet53.conv.74

# Add yolo to bashrc
#grep -q -F "export PYTHONPATH=$PYTHONPATH:$DIR/darknet/python" ~/.bashrc || echo "export PYTHONPATH=$PYTHONPATH:$DIR/darknet/python" >> ~/.bashrc
#source ~/.bashrc
