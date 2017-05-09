# !/bin/bash

# DATASET="yelp"
export DATASET="signal_processing"
export DATADIR=${DATADIR:- /local/home/klee/workspace/data/data_oneFilePerLine/signal_processing}
# /home/keqian/coderepo/data/fullpaper_oneFilePerLine
export RAW_TEXT=${RAW_TEXT:- $DATADIR/output.txt_pureText.txt}
# segmentatorInline.txt_sectionPerLine_pureText.txt


Green='\033[0;32m'
NC='\033[0m'


mkdir -p tmp/$DATASET

export PYTHON=python
export PYPY=python
if type "pypy" > /dev/null; then
      export PYPY=pypy
fi



echo -e "${Green}Training SegPhrase${NC}"
./domain_keyphrase_extraction.sh

cp SegPhrase/results/$DATASET/salient.csv tmp/$DATASET/keyphrases.csv
cp SegPhrase/results/$DATASET/segmentation.model tmp/$DATASET/segmentation.model

echo -e "${Green}Identifying Phrases in Input File${NC}"
./SegPhrase/bin/segphrase_parser tmp/$DATASET/segmentation.model \
  tmp/$DATASET/keyphrases.csv $NUM_KEYPHRASES $RAW_TEXT ./tmp/$DATASET/segmented_text.txt 1

cp tmp/$DATASET/keyphrases.csv $DATADIR
cp ./tmp/$DATASET/segmented_text.txt $DATADIR
cp tmp/$DATASET/segmentation.model $DATADIR
