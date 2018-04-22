#!/bin/bash
DIR=${DATABASE_PATH:-$HOME/Database}

# Make directories
mkdir -p $DIR
cd $DIR

wget https://pjreddie.com/media/files/cifar.tgz
tar xzf cifar.tgz
rm cifar.tgz

cd cifar
find `pwd`/train -name \*.png > train.list
find `pwd`/test -name \*.png > test.list

