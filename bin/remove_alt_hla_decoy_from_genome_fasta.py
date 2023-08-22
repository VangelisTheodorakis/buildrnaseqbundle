#!/usr/bin/env python3

import sys
import argparse

def main(argv):
	inputFasta = ''
	outputFasta = ''

	argParser = argparse.ArgumentParser(description = "Remove ALT, HLA and decoy contiges from fasta file")
	argParser.add_argument(	"-i", "--inputFasta",
				required = True,
				help="The input Fasta file path")
	argParser.add_argument( "-o", "--outputFasta",
				required = True,
                                help = "The output Fasta file path")
	args = argParser.parse_args(argv)

	inputFasta = args.inputFasta
	outputFasta = args.outputFasta

	with open(inputFasta, 'r') as fasta:
		contigs = fasta.read()

	contigs = contigs.split('>')
	contig_ids = [i.split(' ', 1)[0] for i in contigs]

	# exclude ALT, HLA and decoy contigs
	filtered_fasta = '>'.join([c for i,c in zip(contig_ids, contigs)
		if not (i[-4:]=='_alt' or i[:3]=='HLA' or i[-6:]=='_decoy')])

	with open(outputFasta, 'w') as fasta:
		fasta.write(filtered_fasta)


if __name__ == "__main__":
	main(sys.argv[1:])
