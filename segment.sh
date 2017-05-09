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
export NUM_KEYPHRASES=400000

cp -n tmp/$DATASET/keyphrases.csv $DATADIR
cp -n tmp/$DATASET/segmentation.model $DATADIR

echo -e "${Green}Identifying Phrases in Input File${NC}"
./SegPhrase/bin/segphrase_parser tmp/$DATASET/segmentation.model \
  tmp/$DATASET/keyphrases.csv $NUM_KEYPHRASES $RAW_TEXT $RAW_TEXT._segmented_$NUM_KEYPHRASES.txt 1


