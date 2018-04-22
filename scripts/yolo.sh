#!/bin/bash

# for training, in the layer above 
# region ; set filter to: 5*(classes+5)

MODE=${1:-demo}
YOLO=${2:-tiny}
DATASET=${3:-coco}
CAMERA=${4:-0}

############# Training #############
NET=darknet19_448.conv.23

if [ $MODE == 'train' ]; then 
	if [ $DATASET == 'coco' ] && [ $YOLO == 'full' ]; then
		echo 'Training Full YOLO w/ Partial COCO Dataset'
		DATA=coco40.data
		CFG=yolo40-train.cfg
		MODE=resume-training
		BACKUP=yolo40-train.backup

	elif [ $DATASET == 'coco' ] && [ $YOLO == 'tiny' ]; then
		echo 'Training Tiny YOLO w/ Partial COCO Dataset'
		DATA=coco40.data
		CFG=tiny-yolo40-train.cfg
		MODE=resume-training
		BACKUP=tiny-yolo40-train.backup

	elif [ $DATASET == 'voc' ] && [ $YOLO == 'full' ]; then
		echo 'Training Full YOLO w/ Partial VOC Dataset'
		DATA=voc8.data
		MODE=resume-training		
		CFG=yolo8-voc-train.cfg
		BACKUP=yolo8-voc-train.backup

	elif [ $DATASET == 'voc' ] && [ $YOLO == 'tiny' ]; then	
		echo 'Training Tiny YOLO w/ Partial VOC Dataset'
		DATA=voc8.data
		CFG=tiny-yolo8-voc.cfg
		MODE=resume-training
		BACKUP=tiny-yolo8-voc.backup
	fi
else
	if [ $DATASET == 'coco' ] && [ $YOLO == 'full' ]; then
		# XPS: 3.2 fps
		echo 'Running Full YOLO w/ COCO Dataset'
		DATA=coco.data
		CFG=yolo.cfg
		WEIGHTS=yolo.weights

	elif [ $DATASET == 'coco' ] && [ $YOLO == 'tiny' ]; then
		# XPS: 23 fps
		echo 'Running Tiny YOLO w/ COCO Dataset'
		DATA=coco.data
		CFG=tiny-yolo.cfg
		WEIGHTS=tiny-yolo.weights

	elif [ $DATASET == 'voc' ] && [ $YOLO == 'full' ]; then
		# XPS: 7fps
		echo 'Running Full YOLO w/ VOC Dataset'
		DATA=voc.data
		CFG=yolo-voc.cfg
		WEIGHTS=yolo-voc.weights

	elif [ $DATASET == 'voc' ] && [ $YOLO == 'tiny' ]; then	
		# XPS: 21 fps
		echo 'Running Tiny YOLO w/ VOC Dataset'
		DATA=voc.data
		CFG=tiny-yolo-voc.cfg
		WEIGHTS=tiny-yolo-voc.weights
	elif [ $DATASET == 'voc8' ] && [ $YOLO == 'tiny' ]; then
    echo 'Running Tiny YOLO w/ small VOC Dataset'	
	  DATA=voc8.data
	  CFG=tiny-yolo8-voc.cfg
	  WEIGHTS=tiny-yolo8-voc.weights
	elif [ $DATASET == '9k' ] && [ $YOLO == '9000' ]; then
	  echo 'Running YOLO 9000!'
	  DATA=combine9k.data
	  CFG=yolo9000.cfg
	  WEIGHTS=yolo9000.weights
  fi
fi

####################################

sleep 2

cd ~/programs/darknet

if [ $MODE == 'train' ]; then
	./darknet detector train \
		data/$DATA \
		cfg/$CFG \
		conv/$NET
elif [ $MODE == "resume-training" ]; then
  ./darknet detector train \
    data/$DATA \
    cfg/$CFG \
    backup/$BACKUP
else
	./darknet detector demo \
		data/$DATA \
		cfg/$CFG \
		weights/$WEIGHTS \
		-c $CAMERA

fi		
