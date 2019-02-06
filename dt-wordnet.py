#!/usr/bin/env python3

import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument('-w', '--wordnet-super-senses', type=argparse.FileType('r', encoding='UTF-8'), required=True)
parser.add_argument('-t', type=float, default=0.01)
parser.add_argument('dt', type=argparse.FileType('r', encoding='UTF-8'))
parser.add_argument('-o', '--output', default=sys.stdout, type=argparse.FileType('w', encoding='UTF-8'))
args = parser.parse_args()

def read_super_senses_wordnet(f, operation=None):
    lexicon = set()

    for line in f:
        _, _, word_pos_sid = line.partition('\t')
        word_pos, _, _ = word_pos_sid.rpartition('.')
        word, _, pos = word_pos.rpartition('.')

        if 'n' == pos:
            if operation is None:
                lexicon.add(word)
            else:
                lexicon.add(operation(word))

    return lexicon

lexicon = read_super_senses_wordnet(args.wordnet_super_senses)

for line in args.dt:
    word1, word2, weight = line.rstrip().split('\t', 2)
    word1, word2, weight = word1.lower(), word2.lower(), float(weight)

    if word1 in lexicon and word2 in lexicon and weight > args.t:
        print('%s\t%s\t%f' % (word1, word2, weight), file=args.output)
