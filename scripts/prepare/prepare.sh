#!/bin/bash
export C_PATH=${COCO_PATH:-$HOME/Database/coco}
export I_PATH=${IMAGENET_PATH:-$HOME/Database/imagenet}
export TOOLS_PATH=${TOOLS_PATH:-$HOME/programs/darknet/tools}
export DN_PATH=${DARKNET_PATH:-$HOME/programs/darknet/}

########################  Control Parameters  ########################

            ################## COCO #################
UPDATE_COCO=0 # Pull all data from annotations - really no reason to run this again
  
            ################ ImageNet ###############
DOWNLOAD_DATA=0 # Download data from imagenet
LABEL_DATA=0 # Label objects using bbox-labeling-tool
DISTRIBUTE_FILES=1 # Distribute into training and testing data files

# Parameters
TRAIN_SIZE=70 # /100: Ratio for training/testing split
            ################ Combined ###############
RELABEL_CLASSES=1 # Relabel the COCO and IMAGENET classes so they follow obj.names
MAKE_TRAINING_FILES=1 # Make train.list, test.list, and put them in the correct directories
START_TRAINING=1 # Start Training

######################################################################                                                

echo 'Download coco using their site or using `scripts/orignal/get_coco_dataset`'
echo 'Set classes to keep from coco in coco/classes.csv'
echo 'Set classes to add from imagenet in imagenet/wnib_classes.csv'

read -p "Press enter to continue"

################################ COCO ################################

# Update labels files
if [ $UPDATE_COCO -eq 1 ]; then
  echo "Generating labels from annotation files for COCO"
  rm -rf $C_PATH/my_labels/*
  mkdir -p $C_PATH/my_labels/
  python coco/coco_label.py -a
fi 

######################################################################

############################ ImageNet ################################

mkdir -p $I_PATH/images/train $I_PATH/images/test \
         $I_PATH/labels/train $I_PATH/labels/test $I_PATH/results \
         $I_PATH/my_labels/train $I_PATH/my_labels/test \
         $I_PATH/raw/images $I_PATH/raw/annotations $I_PATH/raw/labels \
         $I_PATH/raw/my_labels

## Download Data ##
if [ $DOWNLOAD_DATA -eq 1 ]; then
  CLS_CTR=0
  PREV_CLS=0
  
  # Change working directory
  CWD=$PWD
  cd $TOOLS_PATH/imagenet/

  while read -r line; do 
   
    IFS=',' read -r -a array <<< $line
    CLS=${array[0]}
    WNID=${array[2]}   
    if [ $CLS != $PREV_CLS ]; then CLS_CTR=$(($CLS_CTR+1)); fi
    
    echo "$CLS($CLS_CTR): $WNID"
    PREV_CLS=$CLS
        
    # Download Images
    ./downloadutils.py -i -b --wnid $WNID
       
    # Move images to imagenet Database folder
    FLDER=0${CLS_CTR}
    if [ $CLS_CTR -lt 10 ]; then FLDER=00${CLS_CTR}; fi
    
    mkdir -p $I_PATH/raw/images/$FLDER $I_PATH/raw/annotations/$FLDER/
    mkdir -p $I_PATH/raw/labels/$FLDER $I_PATH/raw/my_labels/$FLDER
    mv $WNID/${WNID}_original_images/* $I_PATH/raw/images/$FLDER/
    mv $WNID/Annotation/$WNID/* $I_PATH/raw/annotations/$FLDER/
    
    # Remove download directory
    rm -rf $WNID
  done < $CWD/imagenet/wnib_classes.csv
  
  # Change back to original working directory
  cd $CWD
  
  # Convert annotations to labels
  python imagenet/imagenet_label.py
fi

## Label Data ##
if [ $LABEL_DATA -eq 1 ]; then
  # Clear existing folders
  rm -rf $TOOLS_PATH/bbox-label-tool/Images/* 
  rm -rf $TOOLS_PATH/bbox-label-tool/labels/*  
  for FOLDER in `ls $I_PATH/raw/images`; do
    mkdir -p $TOOLS_PATH/bbox-label-tool/Images/$FOLDER
    mkdir -p $TOOLS_PATH/bbox-label-tool/labels/$FOLDER    
    for IM in `ls -1 $I_PATH/raw/images/$FOLDER | sed 's/\.JPEG$//'`; do
      if [ ! -f $I_PATH/raw/labels/$FOLDER/${IM}.txt ] && [ ! -f $I_PATH/raw/my_labels/$FOLDER/${IM}.txt ]; then
        ln -s $I_PATH/raw/images/$FOLDER/${IM}.JPEG $TOOLS_PATH/bbox-label-tool/Images/$FOLDER/${IM}.JPEG
      fi
    done
  done
  
  # Relabel classes
  CWD=$PWD
  cd $TOOLS_PATH/bbox-label-tool
  python main.py
  
  # Convert labels back to imagenet directory
  cd $CWD
  python imagenet/bbox_label.py
  
  rm -rf $TOOLS_PATH/bbox-label-tool/Images/* 
  rm -rf $TOOLS_PATH/bbox-label-tool/labels/*  
fi

# Distribute labelled files into training and testing set
if [ $DISTRIBUTE_FILES -eq 1 ]; then

  # Remove previous distribution
  rm $I_PATH/my_labels/train/* $I_PATH/my_labels/test/*
  rm $I_PATH/images/train/* $I_PATH/images/test/*

  for FOLDER in `ls $I_PATH/raw/images/`; do
  
    NUM_ANNOT=`ls $I_PATH/raw/labels/$FOLDER/ | wc -l`
    NUM_ANNOT=$(($NUM_ANNOT + `ls $I_PATH/raw/my_labels/$FOLDER/ | wc -l`))
    echo "${FOLDER} Total Labelled Images: ${NUM_ANNOT}"
  
    NUM_ANNOT=`ls $I_PATH/raw/labels/$FOLDER/ | wc -l`    
    NUM_TRAIN=$(($NUM_ANNOT * $TRAIN_SIZE / 100 ))
    NUM_TEST=$(($NUM_ANNOT-$NUM_TRAIN))
    CTR=0
    
    echo "  ImageNet Labels: ${NUM_ANNOT} (train/test): $NUM_TRAIN/$NUM_TEST"
       
    for FILE in `ls $I_PATH/raw/labels/$FOLDER/ | sed -e 's/\.txt$//'`; do
      CTR=$(($CTR+1))
      
      if [ $CTR -lt $NUM_TRAIN ]; then
        ln -s $I_PATH/raw/labels/$FOLDER/$FILE.txt $I_PATH/my_labels/train/
        ln -s $I_PATH/raw/images/$FOLDER/$FILE.JPEG $I_PATH/images/train/
      else
        ln -s $I_PATH/raw/labels/$FOLDER/$FILE.txt $I_PATH/my_labels/test/
        ln -s $I_PATH/raw/images/$FOLDER/$FILE.JPEG $I_PATH/images/test/
      fi
    done
    
    NUM_ANNOT=`ls $I_PATH/raw/my_labels/$FOLDER/ | wc -l`
    NUM_TRAIN=$(($NUM_ANNOT * $TRAIN_SIZE / 100 ))
    NUM_TEST=$(($NUM_ANNOT-$NUM_TRAIN))
    CTR=0
    
    echo "  My Labels: ${NUM_ANNOT} (train/test): $NUM_TRAIN/$NUM_TEST"  
    
    for FILE in `ls $I_PATH/raw/my_labels/$FOLDER/ | sed -e 's/\.txt$//'`; do
      CTR=$(($CTR+1))
      
      if [ $CTR -lt $NUM_TRAIN ]; then
        ln -s $I_PATH/raw/my_labels/$FOLDER/$FILE.txt $I_PATH/my_labels/train/
        ln -s $I_PATH/raw/images/$FOLDER/$FILE.JPEG $I_PATH/images/train/
      else
        ln -s $I_PATH/raw/my_labels/$FOLDER/$FILE.txt $I_PATH/my_labels/test/
        ln -s $I_PATH/raw/images/$FOLDER/$FILE.JPEG $I_PATH/images/test/
      fi
    done
  done
fi

######################################################################

############################ Combined ################################

## Relabel Classes ##
if [ $RELABEL_CLASSES -eq 1 ]; then
  python merge_classes.py
  
  echo "Removing existing remapping for COCO"
  rm -rf $C_PATH/labels/val* $C_PATH/labels/train*
  python coco/coco_relabel.py
  
  echo "Removing empty label files for COCO"
  ./delete_empty_files.sh $C_PATH/labels/
  
  echo "Removing existing remapping for Imagenet"
  rm -rf $I_PATH/labels/test* $I_PATH/labels/train*
  python imagenet/imagenet_relabel.py 
  
  echo "Removing empty label files for Imagenet"
  ./delete_empty_files.sh $I_PATH/labels/
fi

if [ $SEE_SPLIT -eq 1 ]; then
  python see_split.py
fi

if [ $MAKE_TRAINING_FILES -eq 1 ]; then
  TRAIN_FILE='coco_train.txt'
  TEST_FILE='coco_test.txt'
  VAL_FOLDER='val2014'
  
  rm coco/$TRAIN_FILE coco/$TEST_FILE
  
  # Parse folder structure and populate training/testing files
  for FOLDER in `ls $C_PATH/labels`; do
    for FILE in `ls $C_PATH/labels/$FOLDER | sed -e 's/\.txt$//'`; do
      if [ $FOLDER == $VAL_FOLDER ]; then
        echo "$C_PATH/images/$FOLDER/$FILE.jpg" >> coco/$TEST_FILE
      else
        echo "$C_PATH/images/$FOLDER/$FILE.jpg" >> coco/$TRAIN_FILE
      fi
    done
  done
  
  TRAIN_FILE='imagenet_train.txt'
  TEST_FILE='imagenet_test.txt'
  
  rm imagenet/$TRAIN_FILE imagenet/$TEST_FILE
  
  # Parse folder structure and populate training/testing files
  for FOLDER in 'train' 'test'; do
    for FILE in `ls $I_PATH/labels/$FOLDER | sed -e 's/\.txt$//'`; do
      if [ $FOLDER == 'train' ]; then
        echo "$I_PATH/images/$FOLDER/$FILE.JPEG" >> imagenet/$TRAIN_FILE
      else
        echo "$I_PATH/images/$FOLDER/$FILE.JPEG" >> imagenet/$TEST_FILE
      fi
    done
  done
  
  rm train.txt test.txt
  cat coco/coco_train.txt >> train.txt
  cat imagenet/imagenet_train.txt >> train.txt
  cat coco/coco_test.txt >> test.txt
  cat imagenet/imagenet_test.txt >> test.txt
  
  CWD=$PWD
  
  # Update data files in my darknet data path
  cd $DN_PATH/data
  rm obj.names train.list test.list coco_val_5k.list
  ln -s $CWD/train.txt train.list
  ln -s $CWD/test.txt test.list
  ln -s $CWD/test.txt coco_val_5k.list
  ln -s $CWD/obj.names obj.names
  
  # Update data files in pj_darknet's data path
  cd $DN_PATH/../pj_darknet/data
  rm obj.names train.list test.list coco_val_5k.list
  ln -s $CWD/train.txt train.list
  ln -s $CWD/test.txt test.list
  ln -s $CWD/test.txt coco_val_5k.list
  ln -s $CWD/obj.names obj.names
fi

######################################################################

if [ $START_TRAINING -eq 1 ]; then
  cd $DN_PATH/../pj_darknet/scripts
  export CONTINUE_TRAINING=0
  ./train.sh
fi
