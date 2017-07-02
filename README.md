# Concept Embedding


## Notes

This software require [SegPhrase](https://github.com/shangjingbo1226/SegPhrase) to extract domain keyphrases. It has been included in this repository but users should check the SegPhrase related documentations for proper instruction.

## Requirements

We will take Ubuntu for example.

* g++ 4.8
```
$ sudo apt-get install g++-4.8
```
* python 2.7
```
$ sudo apt-get install python
```
* other python packages
```
$ sudo pip install -r requirements.txt
```



## Run

```
$ ./segmentating_embedding.sh  #run the concept extraction, segmentation and embedding pipeline
```

## Parameters
The running parameters are located in segmentating_embedding.sh
```
DATASET="signal_processing"
```
DATASET refers to the name you assign to the dataset
```
DATADIR_oneDocPerFile=`pwd`/data/signal_processin_oneDocPerFile
```
DATADIR_oneDocPerFile refers to the directory where the input is stored in one-document-per-file format. Set this value to be non-emtpy if your file are in this format.
```
DATADIR=`pwd`/data/signal_processing
```
DATADIR refers to the directory the input lies in
```
RAW_TEXT=$DATADIR/input.txt
```
RAW_TEXT refers to the input text file



```
OMP_NUM_THREADS=36
```
Number of threads.

```
RETAIN_PHRASES_RATIO=0.5
```
Ratio of domain keyphrases in generated keyphrases.csv used to parse the corpus by SegPhrase

```
MIN_PHRASE_SUPPORT=10
```
Number of occurrences for a valid domain keyphrase in the corpus.

## Input Format
The input can be either one document per line or one document per file. Depending on whether you want to set the paramter $DATADIR_oneDocPerFile.
Since Segphrase parser uses square brackets to identify phrases in the segmented text, these brackets should be cleaned from input files to avoid misidentification.

## Output Format
There output consists of 
* ```segmented_text.txt_phraseAsWord```
The segmented text, each phrase is represented as words joined by underscore.
* ```segmented_text.txt_phraseAsWord.concept_embedding*.json```
The concept/phrase embedding, each term follows the structure of ```concept : list form of concept embedding array```.
* ```segmented_text.txt_phraseAsWord.model*```
The dump of gensim word2vec model.
