#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo 'Model not specified!'
  exit 1
fi

model=$1

cfg=../cfg/${model}.cfg
weights=../weights/${model}.weights
output=model_data/${model}.h5

python3 convert.py $cfg $weights $output
