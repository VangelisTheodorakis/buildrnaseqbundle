# ![nf-core/buildrnaseqbundle](docs/images/nf-core-buildrnaseqbundle_logo_light.png#gh-light-mode-only) ![nf-core/buildrnaseqbundle](docs/images/nf-core-buildrnaseqbundle_logo_dark.png#gh-dark-mode-only)

[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://nf-co.re/buildrnaseqbundle/results)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Nextflow Tower](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Nextflow%20Tower-%234256e7)](https://tower.nf/launch?pipeline=https://github.com/nf-core/buildrnaseqbundle)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23buildrnaseqbundle-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/buildrnaseqbundle)[![Follow on Twitter](http://img.shields.io/badge/twitter-%40nf__core-1DA1F2?labelColor=000000&logo=twitter)](https://twitter.com/nf_core)[![Follow on Mastodon](https://img.shields.io/badge/mastodon-nf__core-6364ff?labelColor=FFFFFF&logo=mastodon)](https://mstdn.science/@nf_core)[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

**buildrnaseqbundle** is a bioinformatics pipeline that can be used to create bundles of input data (genome files, annotations, indexes etc) for RNA sequencing analyses with **nf-core/rnaseq**, using the [guidelines for GTEx v10](https://github.com/broadinstitute/gtex-pipeline/blob/master/TOPMed_RNAseq_pipeline.md). 

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->

1. Get the input fasta and gtf files 
    1. Prepre the reference genome file
        1. Get the GRCh38 reference genome FASTA from Broad Institute ([`GRCh38`](https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta))
        2. Remove the ALT, HLA, and Decoy contigs from the reference genome FASTA 
   2. Prepre the gene annotation file ([`gunzip`](https://www.gnu.org/software/gzip/manual/gzip.html))
        1. Get the Gencode v.XX annotation of choice ([`Gencode`](https://www.gencodegenes.org/human/))
   3. Prepare the ERCC92 spike-in data ([`7za`](https://linux.die.net/man/1/7za), [`sed`](https://linux.die.net/man/1/sed))
        1. Get the Thermofisher ERCC spike-in data ([ERCC92 spike-in](https://tools.thermofisher.com/content/sfs/manuals/ERCC92.zip))
        2. Patch the ERCC92 fasta file for compatibility with RNA-SeQC/GATK
2. Combine the Gencode and ERCC GTF annotation files ([`cat`](https://linux.die.net/man/1/cat))
3. Create the STAR index ([`STAR`](https://github.com/alexdobin/STAR), [`tar`](https://www.linfo.org/tar.html))
4. Create the RSEM index ([`RSEM`](https://github.com/deweylab/RSEM), [`tar`](https://www.linfo.org/tar.html))
5. Create the combined fasta fai and dict files for GATK/Picard ([`samtools`](https://github.com/samtools/samtools), [`gatk4`](https://github.com/broadinstitute/gatk))

## Usage

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
> to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
> with `-profile test` before running the workflow on actual data.

You can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->

```bash
nextflow run nf-core/buildrnaseqbundle \
   -profile <docker/singularity/.../institute> \
   --gencodeVersion           "44" \
   --spliceJunctionOverhang    100 \
   --star_output_zip           <STAR_OUTPUT_ZIP> \
   --rsem_output_zip           <RSEM_OUTPUT_ZIP> \
   --executor                  <slurm/local>
   --publish_intermediate_data <true/false>
   --outdir                    <OUTDIR>
```

> **Warning:**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those
> provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/buildrnaseqbundle/usage) and the [parameter documentation](https://nf-co.re/buildrnaseqbundle/parameters).

## Pipeline output

The pipeline creates an output folder with the same output as the GTEx v10 analysis, as well as the input for the rnaseq pipeline input.
```bash

nf-test-rnaseq-hg38-gencode.v44-bundle/
├── gencode.v44.annotation_genes_collapsed_only_patched_ERCC92.gtf
├── Homo_sapiens_assembly38_noALT_noHLA_noDecoy_patched_ERCC92.dict
├── Homo_sapiens_assembly38_noALT_noHLA_noDecoy_patched_ERCC92.fasta
├── Homo_sapiens_assembly38_noALT_noHLA_noDecoy_patched_ERCC92.fasta.fai
├── pipeline_info/
├── rsem_reference_GRCh38_gencode44_ercc.tar.gz
├── star_rsem_index/
└── STARv2710a_genome_GRCh38_noALT_noHLA_noDecoy_ERCC_v44_oh100.tar.gz
```

## Current versions

|         | Version | 
| ------- | ------- | 
| Genome  | GRCh38  | 
| GENCODE | [v44](https://www.gencodegenes.org/human/release_44.html)|
| python  | 3.10.2  |
| samtools| 1.17    |
| gatk4   | 4.4.0.0 |
| STAR    | 2.7.10a | 
| RSEM    | 1.3.3   | 

## Credits

nf-core/buildrnaseqbundle was originally written by Evangelos (Vangelis) Theodorakis.

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#buildrnaseqbundle` channel](https://nfcore.slack.com/channels/buildrnaseqbundle) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

