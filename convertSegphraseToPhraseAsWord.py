import os
import sys
import logging
import random
import re

file = '../data/input.txt'

if len(sys.argv) > 1:
    file = sys.argv[1]

lineSeparater = '     '

square_brackets_enclosed = re.compile(
    r"\[(?P<phrase>[\w\s]+)\]"
)

def brackets2UnderScoreNotation(l):
    return square_brackets_enclosed.sub(lambda x: re.sub('\s', '_', x.group('phrase')), l)

def singleFileClean(file, file_output):
    f_forrnn = open(file_output, "w")
    with open(file) as f:
        for l in f:
            l = l.replace('$', lineSeparater)
            l = l.lower()
            l = brackets2UnderScoreNotation(l)
            try:
                f_forrnn.write(l.strip() + '\n')
            except Exception, e:
                logging.debug(e)
            else:
                pass

    f_forrnn.close()



if __name__ == '__main__':
    singleFileClean(file, file+'_phraseAsWord.txt')