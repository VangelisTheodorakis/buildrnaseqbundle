#!/usr/bin/env python3

import sys
import argparse

def main(argv):
    ercc_gtf_file = ''
    patched_ercc_gtf_file = ''
    parser = argparse.ArgumentParser(description='Add gene- and transcript-level attributes to the ERCC GTF files (original and patched)')
    parser.add_argument('--ercc_gtf_file', help='The ERCC spike gtf file')
    parser.add_argument('--patched_ercc_gtf_file', help='The patched ERCC spike gtf file')
    args = parser.parse_args(argv)
    
    ercc_gtf_file = args.ercc_gtf_file
    patched_ercc_gtf_file = args.patched_ercc_gtf_file
    
    with open(ercc_gtf_file) as exon_gtf, open(patched_ercc_gtf_file, 'w') as gene_gtf:
        for line in exon_gtf:
            f = line.strip().split('\t')
            f[0] = f[0].replace('-', '_')  # required for RNA-SeQC/GATK (no '-' in contig name)
            f[5] = '.'

            attr = f[8]
            if attr[-1] == ';':
                attr = attr[:-1]
            attr = dict([i.split(' ') for i in attr.replace('"', '').split('; ')])
            # add gene_name, gene_type
            attr['gene_name'] = attr['gene_id']
            attr['gene_type'] = 'ercc_control'
            attr['gene_status'] = 'KNOWN'
            attr['level'] = 2
            for k in ['id', 'type', 'name', 'status']:
                attr[f'transcript_{k}'] = attr[f'gene_{k}']

            attr_str = []
            for k in ['gene_id', 'transcript_id', 'gene_type', 'gene_status', 'gene_name',
                'transcript_type', 'transcript_status', 'transcript_name']:
                attr_str.append(f'{k} "{attr[k]}";')
            attr_str.append(f"level {attr['level']};")
            f[8] = ' '.join(attr_str)

            # write gene, transcript, exon
            gene_gtf.write('\t'.join(f[:2] + ['gene'] + f[3:]) + '\n')
            gene_gtf.write('\t'.join(f[:2] + ['transcript'] + f[3:]) + '\n')
            f[8] = ' '.join(attr_str[:2])
            gene_gtf.write('\t'.join(f[:2] + ['exon'] + f[3:]) + '\n')

        
if __name__ == '__main__':
    main(sys.argv[1:])