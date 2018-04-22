#!/bin/bash
DIR=$1
READ_FILE=$2

if [ $# -eq 0 ]; then 
  echo 'No path passed to script'
  exit
elif [ $# -eq 1 ]; then
  READ_FILE=0
fi

for FOLDER in `ls $DIR`; do
  COUNT=`ls -1 $DIR/$FOLDER | wc -l`
  echo ORIGINAL COUNT: $FOLDER: $COUNT
  for FILE in `ls $DIR/$FOLDER`; do
    ## Remove empty files
    if [[ ! -s $DIR/$FOLDER/$FILE ]]; then
      rm $DIR/$FOLDER/$FILE
      continue
    fi
    
    ## Read first line from each file (contains number of objects)
    if [ $READ_FILE -eq 1 ]; then
      OBJS=''
      while read -r line
      do
        OBJS="$line"
        break
      done < $DIR/$FOLDER/$FILE
  
      ## Remove any file with no objects
      if [[ $OBJS == 0 ]]; then
        rm $DIR/$FOLDER/$FILE
      fi
    fi
  done
  COUNT=`ls -1 $DIR/$FOLDER | wc -l`
  echo NEW COUNT: $FOLDER: $COUNT  
done
