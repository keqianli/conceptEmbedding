import os 
import logging
import re
import random
import numpy as np
import collections
from gensim.models import word2vec
import gensim
import json, codecs

# file = 'data/segmented_text.txt_phraseAsWord'
file = 'data/signal_processing/segmented_text.txt_phraseAsWord.txt'

logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

import sys
if len(sys.argv) > 1:
  file = sys.argv[1]
  
def trim_rule(word, count, min_count):
  return gensim.utils.RULE_KEEP if '_' in word else gensim.utils.RULE_DEFAULT 

def displayString(w):
 return re.sub(r'</?phrase>','',w)


dictionary = {}
concept_embeddings = {}

# sg : defines the training algorithm. (sg = 0 : CBOW, sg = 1 : skip-gram).
# size : dimensionality of the feature vectors.

for size in [50,128,200]:
  for sg in [0,1]:
# for size in [50]:
#   for sg in [0]:
    for max_vocab_size in [60000,None]:
      model = word2vec.Word2Vec(word2vec.LineSentence(file), size=size,  workers=120, max_vocab_size=max_vocab_size, 
        trim_rule = trim_rule, sg=sg)

      max_vocab_size = -1 if max_vocab_size == None else max_vocab_size

      # concept_embeddings = [(w,model.wv[w]) for w in model.wv.index2word if '_' in w]
      concept_embeddings = {w:model.wv[w].tolist() for w in model.wv.index2word if '_' in w}

      model.save(file + '.model_dimension%d_sg%d_max_vocab_size%d' % (size, sg, max_vocab_size))
      with open(file+'.concept_embedding_dimension%d_sg%d_max_vocab_size%d.json' % (size, sg, max_vocab_size), 'w') as f_out:
        # for w,norm in concept_embeddings:
        #   f_out.write(w+'\t'+','.join([str(d) for d in norm])+'\n')
        json.dump(concept_embeddings, f_out)

