#!/bin/bash
export C_PATH=${COCO_PATH:-$HOME/Database/coco}
export I_PATH=${IMAGENET_PATH:-$HOME/Database/imagenet}
export TOOLS_PATH=${TOOLS_PATH:-$HOME/programs/darknet/tools}
export DN_PATH=${DARKNET_PATH:-$HOME/programs/darknet/}

########################  Control Parameters  ########################

MERGE_CLASSES=0

            ################## COCO #################
UPDATE_COCO=0 # Update COCO classes
  LABEL_ALL_COCO=0 # Get 2017 COCO labels as well
  RELABEL_COCO=0 # Relabel using the existing dataset or fresh using COCO api
CREATE_COCO_TRAINTEST_FILES=0 # Create COCO training and testing files again
  REMOVE_COCO_EMPTY=0 # Delete label files that contain no labels
 
            ################ ImageNet ###############
TRAIN_SIZE=75 # /100: Ratio for training/testing split
DOWNLOAD_DATA=0 # Download data from imagenet
LABEL_DATA=0 # Label bounding boxes using bbox-labeling-tool
RELABEL_IMAGENET=1 # Relabel imagenet dataset 
#  -- works only if old_obj.names exists 
#  -- can only run once
DISTRIBUTE_FILES=1 # Distribute into training and testing data files
REMOVE_IMAGENET_EMPTY=0 # Delete label files that contain no labels

            ############# General ##############
MERGE_TRAINTEST_FILES=1 # Merging training and testing sets for coco and imagenet
SEE_SPLIT=0 # See split of classes
SET_TRAINING_SYM_LINK=1 # Set sym link for YOLO training

######################################################################                                                

echo 'Download coco using their site or using `scripts/orignal/get_coco_dataset`'
echo 'Set classes to keep from coco in coco/classes.csv'
echo 'Set classes to add from imagenet in imagenet/classes.csv'

read -p "Press enter to continue"

## Merge Classes ##
if [ $MERGE_CLASSES -eq 1 ]; then
  python merge_classes.py
fi

################################ COCO ################################
# Update labels files
if [ $UPDATE_COCO -eq 1 ]; then
  # Update label files for all classes in COCO 2014 & COCO 2017 and then relabel
  # required classes
  if [ $RELABEL_COCO -eq 1 ] && [ $LABEL_ALL_COCO -eq 1 ]; then
    echo 'Relabeling COCO 2014 & 2017'
    python coco/coco_label.py -a
    rm -rf $C_PATH/labels/val* $C_PATH/labels/train*
    cp -r $C_PATH/all_labels/* $C_PATH/labels
    python coco/coco_relabel.py -a
  # Relabel all required classes in COCO 2014
  elif [ $RELABEL_COCO -eq 1 ]; then
    echo 'Relabeling COCO 2014'
    python coco/coco_relabel.py
  # Label all required classes in COCO 2014 & COCO 2017
  else
    echo 'Labeling COCO w/ custom set'
    python coco/coco_label.py
    rm -rf $C_PATH/labels/val* $C_PATH/labels/train*
    cp -r $C_PATH/my_labels/* $C_PATH/labels
  fi
fi

# Create training and testing files for COCO
if [ $CREATE_COCO_TRAINTEST_FILES -eq 1 ]; then
  echo 'Creating COCO Training and Testing Files'

  # Delete label files that have no content
  if [ $REMOVE_COCO_EMPTY -eq 1 ]; then
    echo '  Removing empty files from labels path'
    ./delete_empty_files.sh $C_PATH/labels/
  fi

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
fi
######################################################################
############################ ImageNet ################################

# Make directories
mkdir -p $I_PATH/images/train $I_PATH/images/test \
         $I_PATH/labels/train $I_PATH/labels/test $I_PATH/results \
         $I_PATH/raw/images $I_PATH/raw/annotations $I_PATH/raw/labels \
         $I_PATH/raw/my_labels
        
# Download required classes from imagenet

if [ $DOWNLOAD_DATA -eq 1 ]; then
  CLS_CTR=0
  PREV_CLS=0
  
  # Change working directory
  CWD=$PWD
  cd $TOOLS_PATH/imagenet/

  while read -r line; do 
    CTR=$(($CTR+1))
    
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
  done < $CWD/imagenet/classes.csv
  
  # Change back to original working directory
  cd $CWD
  
  # Convert annotations to labels
  python imagenet/imagenet_label.py
fi

# Label data
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
  
  # Remove empty labels
  echo '  Removing empty files from labels path'
  ./delete_empty_files.sh $I_PATH/raw/my_labels  
fi

if [ $RELABEL_IMAGENET -eq 1 ]; then
  if [ -f $PWD/old_obj.names ]; then
    mv $I_PATH/raw/labels/ $I_PATH/raw/.labels
    mv $I_PATH/raw/my_labels/ $I_PATH/raw/.my_labels
    python imagenet/imagenet_relabel.py
  else 
    echo "$PWD/old_obj.names does not exist! Cannot relabel imagenet classes"
  fi
fi

# Distribute labelled files into training and testing set
if [ $DISTRIBUTE_FILES -eq 1 ]; then

  # Remove previous distribution
  rm $I_PATH/labels/train/* $I_PATH/labels/test/*
  rm $I_PATH/images/train/* $I_PATH/images/test/*

  for FOLDER in `ls $I_PATH/raw/images/`; do
    NUM_ANNOT=`ls $I_PATH/raw/labels/$FOLDER/ | wc -l`
    NUM_ANNOT=$(($NUM_ANNOT + `ls $I_PATH/raw/my_labels/$FOLDER/ | wc -l`))
    
    NUM_TRAIN=$(($NUM_ANNOT * $TRAIN_SIZE / 100 ))
    NUM_TEST=$(($NUM_ANNOT-$NUM_TRAIN))
    
    echo "${FOLDER}: ${NUM_ANNOT} (train/test): $NUM_TRAIN/$NUM_TEST"
    
    CTR=0
    
    for FILE in `ls $I_PATH/raw/labels/$FOLDER/ | sed -e 's/\.txt$//'`; do
      CTR=$(($CTR+1))
      
      if [ $CTR -lt $NUM_TRAIN ]; then
        ln -s $I_PATH/raw/labels/$FOLDER/$FILE.txt $I_PATH/labels/train/
        ln -s $I_PATH/raw/images/$FOLDER/$FILE.JPEG $I_PATH/images/train/
      else
        ln -s $I_PATH/raw/labels/$FOLDER/$FILE.txt $I_PATH/labels/test/
        ln -s $I_PATH/raw/images/$FOLDER/$FILE.JPEG $I_PATH/images/test/
      fi
    done
    
    for FILE in `ls $I_PATH/raw/my_labels/$FOLDER/ | sed -e 's/\.txt$//'`; do
      CTR=$(($CTR+1))
      
      if [ $CTR -lt $NUM_TRAIN ]; then
        ln -s $I_PATH/raw/my_labels/$FOLDER/$FILE.txt $I_PATH/labels/train/
        ln -s $I_PATH/raw/images/$FOLDER/$FILE.JPEG $I_PATH/images/train/
      else
        ln -s $I_PATH/raw/my_labels/$FOLDER/$FILE.txt $I_PATH/labels/test/
        ln -s $I_PATH/raw/images/$FOLDER/$FILE.JPEG $I_PATH/images/test/
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
fi

if [ $MERGE_TRAINTEST_FILES -eq 1 ]; then
  rm train.txt test.txt
  cat coco/coco_train.txt >> train.txt
  cat imagenet/imagenet_train.txt >> train.txt
  cat coco/coco_test.txt >> test.txt
  cat imagenet/imagenet_test.txt >> test.txt
fi

if [ $SEE_SPLIT -eq 1 ]; then
  python see_split.py
fi

if [ $SET_TRAINING_SYM_LINK -eq 1 ]; then
  CWD=$PWD
  cd $DN_PATH/data
  rm obj.names train.list test.list coco_val_5k.list
  ln -s $CWD/train.txt train.list
  ln -s $CWD/test.txt test.list
  ln -s $CWD/test.txt coco_val_5k.list
  ln -s $CWD/obj.names obj.names
fi
