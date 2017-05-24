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
* scikit-learn
```
$ sudo apt-get install pip
$ sudo pip install sklearn
```
* gensim
```
$ sudo pip install gensim
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
NUM_KEYPHRASES=40000
```
Number of domain keyphrases extracted by SegPhrase

```
MIN_PHRASE_SUPPORT=10
```
Number of occurrences for a valid domain keyphrase in the corpus.

## Input Format
The input can be either one document per line or one document per file. Depending on whether you want to set the paramter $DATADIR_oneDocPerFile.