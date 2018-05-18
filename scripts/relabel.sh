#!/bin/bash

cd ..

REPLACE_WITH=50obj

for FOLDER in backup my-cfg my-weights results ; do
  cd $FOLDER
  for FILE_NAME in y-obj 3-obj ; do
    for FILE in `ls . | grep $FILE_NAME`; do
      mv $FILE ${FILE/obj/$REPLACE_WITH}
    done
  done
  cd ..
done

