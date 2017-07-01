# !/bin/bash

export DATASET="nips"

if [ -z "$1" ]
  then
    echo "No arguments supplied for dataset"
  else 
    DATASET=$1
fi

if [ -z "$2" ]
  then
    echo "No arguments supplied for raw text"
  else 
    RAW_TEXT=$2
fi


export DATADIR=/local/home/klee/workspace/data/data_oneFilePerLineBySection/$DATASET
export RAW_TEXT=$DATADIR/out_queue.txt_abstract

export OMP_NUM_THREADS=36

echo -e "${Green}Identifying Phrases in Input File${NC}"
./SegPhrase/bin/segphrase_parser tmp/$DATASET/segmentation.model \
  tmp/$DATASET/keyphrases.csv $RETAIN_PHRASES_RATIO $RAW_TEXT $RAW_TEXT._segmented_$RETAIN_PHRASES_RATIO.txt 1


