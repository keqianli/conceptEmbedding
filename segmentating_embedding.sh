export DATASET="signal_processing"
export DATADIR=`pwd`/data/signal_processing
export RAW_TEXT=$DATADIR/input.txt

export OMP_NUM_THREADS=36
export NUM_KEYPHRASES=40000
export MIN_PHRASE_SUPPORT=10

./segPhrase.sh

python convertSegphraseToPhraseAsWord.py $DATADIR/segmented_text.txt

echo "Learning embedding of concepts"
python learnEmbedding.py $DATADIR/segmented_text.txt_phraseAsWord.txt

echo "Done"