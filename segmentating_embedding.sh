#!/bin/bash

export DATASET="signal_processing"
#export DATADIR_oneDocPerFile=`pwd`/data/signal_processin_oneDocPerFile
export DATADIR=`pwd`/data/signal_processing
export RAW_TEXT=$DATADIR/input.txt

export OMP_NUM_THREADS=36
export RETAIN_PHRASES_RATIO=.5
export MIN_PHRASE_SUPPORT=10

if [ ! -z "$DATADIR_oneDocPerFile" ]; then
  echo 'using one document per file format'
  find $DATADIR_oneDocPerFile -type f -exec sh -c 'tr "\n\t" "  "< "{}"' >> $RAW_TEXT \;  -exec printf '\n' >> $RAW_TEXT \;
fi

./segPhrase.sh

python convertSegphraseToPhraseAsWord.py $DATADIR/segmented_text.txt

echo "Learning embedding of concepts"
python learnEmbedding.py $DATADIR/segmented_text.txt_phraseAsWord.txt

echo "Done"
