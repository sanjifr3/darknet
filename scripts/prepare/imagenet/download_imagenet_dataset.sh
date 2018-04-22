#!/bin/bash
DIR=${DATABASE_PATH:-$HOME/Database}

# Make directories
mkdir -p $DIR/imagenet
cd $DIR/imagenet
mkdir -p train/ test/ tiny/
cd train/
mkdir -p 8x8/ 16x16/ 32x32/ 64x64/
cd ../test/
mkdir -p 8x8/ 16x16/ 32x32/ 64x64/
cd ..

## Download datasets
for LINK in \
  https://www.image-net.org/image/downsample/Imagenet8_train.zip \
  https://www.image-net.org/image/downsample/Imagenet16_train.zip \
  https://www.image-net.org/image/downsample/Imagenet32_train.zip \
  https://www.image-net.org/image/downsample/Imagenet64_train_part1.zip \
  https://www.image-net.org/image/downsample/Imagenet64_train_part2.zip \
  https://www.image-net.org/image/downsample/Imagenet8_val.zip \
  https://www.image-net.org/image/downsample/Imagenet16_val.zip \
  https://www.image-net.org/image/downsample/Imagenet32_val.zip \
  https://www.image-net.org/image/downsample/Imagenet64_val.zip \
  https://www.image-net.org/image/tiny/tiny-imagenet-200.zip \
; do wget --no-check-certificate $LINK; done

# Extract datasets
unzip Imagenet8_train.zip -d train/8x8
unzip Imagenet16_train.zip -d train/16x16
unzip Imagenet32_train.zip -d train/32x32
unzip Imagenet64_train_part1.zip -d train/64x64
unzip Imagenet64_train_part2.zip -d train/64x64

unzip Imagenet8_val.zip -d test/8x8
unzip Imagenet16_val.zip -d test/16x16
unzip Imagenet32_val.zip -d test/32x32
unzip Imagenet64_val.zip -d test/64x64
unzip Imagenet64_val.zip -d test/64x64

unzip tiny-imagenet-200.zip -d tiny

# Delete zip files
rm -rf Imagenet8_train.zip Imagenet16_train.zip Imagenet32_train.zip \
       Imagenet64_train_part1.zip Imagenet64_train_part2.zip Imagenet8_val.zip \
       Imagenet16_val.zip Imagenet32_val.zip Imagenet64_val.zip Imagenet64_val.zip \
       tiny-imagenet-200.zip
