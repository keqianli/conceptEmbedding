#!/bin/bash

# export OMP_NUM_THREADS=4
# export NUM_KEYPHRASES=40000
# export MIN_PHRASE_SUPPORT=10

export OMP_NUM_THREADS=${OMP_NUM_THREADS:- 4}
# export NUM_KEYPHRASES=40000
export MIN_PHRASE_SUPPORT=${MIN_PHRASE_SUPPORT:- 10}

AUTO_LABEL=1
WORDNET_NOUN=1
DATA_LABEL=data/wiki.label.auto
KNOWLEDGE_BASE=data/wiki_labels_quality.txt
KNOWLEDGE_BASE_LARGE=data/wiki_labels_all.txt

STOPWORD_LIST=../src/tools/stopwords.txt
SUPPORT_THRESHOLD=$MIN_PHRASE_SUPPORT
DISCARD_RATIO=0.00
MAX_ITERATION=5

NEED_UNIGRAM=0
ALPHA=0.85

echo tmp/$DATASET
cd SegPhrase
make
# clearance
rm -rf tmp/$DATASET
rm -rf results/$DATASET

mkdir -p tmp/$DATASET
mkdir -p results/$DATASET

# preprocessing
./bin/from_raw_to_binary_text ${RAW_TEXT} tmp/$DATASET/sentencesWithPunc.buf

# frequent phrase mining for phrase candidates
${PYPY} ./src/frequent_phrase_mining/main.py -thres ${SUPPORT_THRESHOLD} -o ./results/$DATASET/patterns.csv -raw ${RAW_TEXT}
${PYPY} ./src/preprocessing/compute_idf.py -raw ${RAW_TEXT} -o results/$DATASET/wordIDF.txt

# feature extraction
./bin/feature_extraction tmp/$DATASET/sentencesWithPunc.buf results/$DATASET/patterns.csv ${STOPWORD_LIST} results/$DATASET/wordIDF.txt results/$DATASET/feature_table_0.csv

if [ ${AUTO_LABEL} -eq 1 ];
then
    ${PYTHON} src/classification/auto_label_generation.py ${KNOWLEDGE_BASE} ${KNOWLEDGE_BASE_LARGE} results/$DATASET/feature_table_0.csv results/$DATASET/patterns.csv ${DATA_LABEL}
fi

# classifier training
./bin/predict_quality results/$DATASET/feature_table_0.csv ${DATA_LABEL} results/$DATASET/ranking.csv outsideSentence,log_occur_feature,constant,frequency 0 TRAIN results/$DATASET/random_forest_0.model

MAX_ITERATION_1=$(expr $MAX_ITERATION + 1)

# 1-st round
./bin/from_raw_to_binary ${RAW_TEXT} tmp/$DATASET/sentences.buf
./bin/adjust_probability tmp/$DATASET/sentences.buf ${OMP_NUM_THREADS} results/$DATASET/ranking.csv results/$DATASET/patterns.csv ${DISCARD_RATIO} ${MAX_ITERATION} ./results/$DATASET/ ${DATA_LABEL} ./results/$DATASET/penalty.1

# 2-nd round
./bin/recompute_features results/$DATASET/iter${MAX_ITERATION_1}_discard${DISCARD_RATIO}/length results/$DATASET/feature_table_0.csv results/$DATASET/patterns.csv tmp/$DATASET/sentencesWithPunc.buf results/$DATASET/feature_table_1.csv ./results/$DATASET/penalty.1 1
./bin/predict_quality results/$DATASET/feature_table_1.csv ${DATA_LABEL} results/$DATASET/ranking_1.csv outsideSentence,log_occur_feature,constant,frequency 0 TRAIN results/$DATASET/random_forest_1.model
./bin/adjust_probability tmp/$DATASET/sentences.buf ${OMP_NUM_THREADS} results/$DATASET/ranking_1.csv results/$DATASET/patterns.csv ${DISCARD_RATIO} ${MAX_ITERATION} ./results/$DATASET/1. ${DATA_LABEL} ./results/$DATASET/penalty.2

# phrase list & segmentation model
./bin/build_model results/$DATASET/1.iter${MAX_ITERATION_1}_discard${DISCARD_RATIO}/ 6 ./results/$DATASET/penalty.2 results/$DATASET/segmentation.model

# unigrams
normalize_text() {
  awk '{print tolower($0);}' | sed -e "s/’/'/g" -e "s/′/'/g" -e "s/''/ /g" -e "s/'/ ' /g" -e "s/“/\"/g" -e "s/”/\"/g" \
  -e 's/"/ " /g' -e 's/\./ \. /g' -e 's/<br \/>/ /g' -e 's/, / , /g' -e 's/(/ ( /g' -e 's/)/ ) /g' -e 's/\!/ \! /g' \
  -e 's/\?/ \? /g' -e 's/\;/ /g' -e 's/\:/ /g' -e 's/-/ - /g' -e 's/=/ /g' -e 's/=/ /g' -e 's/*/ /g' -e 's/|/ /g' \
  -e 's/«/ /g' | tr 0-9 " "
}
normalize_text < results/$DATASET/1.iter${MAX_ITERATION}_discard${DISCARD_RATIO}/segmented.txt > tmp/$DATASET/normalized.txt





NEED_UNIGRAM=0

if [ ${NEED_UNIGRAM} -eq 1 ];
then
  echo ===Unigram Enable===
  # unigrams
  normalize_text() {
    awk '{print tolower($0);}' | sed -e "s/’/'/g" -e "s/′/'/g" -e "s/''/ /g" -e "s/'/ ' /g" -e "s/“/\"/g" -e "s/”/\"/g" \
    -e 's/"/ " /g' -e 's/\./ \. /g' -e 's/<br \/>/ /g' -e 's/, / , /g' -e 's/(/ ( /g' -e 's/)/ ) /g' -e 's/\!/ \! /g' \
    -e 's/\?/ \? /g' -e 's/\;/ /g' -e 's/\:/ /g' -e 's/-/ - /g' -e 's/=/ /g' -e 's/=/ /g' -e 's/*/ /g' -e 's/|/ /g' \
    -e 's/«/ /g' | tr 0-9 " "
  }
  normalize_text < results/$DATASET/1.iter${MAX_ITERATION}_discard${DISCARD_RATIO}/segmented.txt > tmp/$DATASET/normalized.txt

  cd word2vec_tool
  make
  cd ..
  ./word2vec_tool/word2vec -train tmp/$DATASET/normalized.txt -output ./results/$DATASET/vectors.bin -cbow 2 -size 300 -window 6 -negative 25 -hs 0 -sample 1e-4 -threads ${OMP_NUM_THREADS} -binary 1 -iter 15
  time ./bin/generateNN results/$DATASET/vectors.bin results/$DATASET/1.iter${MAX_ITERATION_1}_discard${DISCARD_RATIO}/ 30 3 results/$DATASET/u2p_nn.txt results/$DATASET/w2w_nn.txt
  ./bin/qualify_unigrams results/$DATASET/vectors.bin results/$DATASET/1.iter${MAX_ITERATION_1}_discard${DISCARD_RATIO}/ results/$DATASET/u2p_nn.txt results/$DATASET/w2w_nn.txt ${ALPHA} results/$DATASET/unified.csv 100 ${STOPWORD_LIST}
else
  echo ===Unigram Disable===
  ./bin/combine_phrases results/$DATASET/1.iter${MAX_ITERATION_1}_discard${DISCARD_RATIO}/ results/$DATASET/unified.csv
fi

${PYPY} src/postprocessing/filter_by_support.py results/$DATASET/unified.csv results/$DATASET/1.iter${MAX_ITERATION}_discard${DISCARD_RATIO}/segmented.txt ${SUPPORT_THRESHOLD} results/$DATASET/salient.csv

if [ ${WORDNET_NOUN} -eq 1 ];
then
    ${PYPY} src/postprocessing/clean_list_with_wordnet.py -input results/$DATASET/salient.csv -output results/$DATASET/salient.csv
fi

cd ..

