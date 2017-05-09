import os 
import logging
import re
import random
import numpy as np
import collections
from gensim.models import word2vec
import gensim

file = './data/input.txt_phraseAsWord.txt'

import sys
if len(sys.argv) > 1:
  file = sys.argv[1]
  
def trim_rule(word, count, min_count):
  return gensim.utils.RULE_KEEP if '_' in word else gensim.utils.RULE_DEFAULT 

def displayString(w):
 return re.sub(r'</?phrase>','',w)

dictionary = {}

for size in [50,128,200]:
  for sg in [0,1]:
    for max_vocab_size in [60000,None]:
      model = word2vec.Word2Vec(word2vec.LineSentence(file), size=size,  workers=120, max_vocab_size=max_vocab_size, 
        trim_rule = trim_rule, sg=sg)

      max_vocab_size = -1 if max_vocab_size == None else max_vocab_size
      model.save(file + '.model_wordPruning_dimension%d_sg%d_max_vocab_size%d' % (size, sg, max_vocab_size))