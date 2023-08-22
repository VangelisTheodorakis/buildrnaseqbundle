include { GUNZIP as GUNZIP_GENCODE                    } from '../../modules/nf-core/gunzip'
include { UNZIP                                       } from '../../modules/nf-core/unzip'
include { PATCH_ERCC_SPIKES_FASTA                     } from '../../modules/local/patch_ercc_spikes_fasta'
include { PATCH_ERCC_SPIKES_GTF                       } from '../../modules/local/patch_ercc_spikes_gtf'
include { REMOVE_ALT_HLA_DECOY_FROM_GENOME_FASTA      } from '../../modules/local/remove_alt_hla_decoy_from_genome_fasta'

workflow PREPARE_INPUT_FILES {
    
    take:
    gencodeVersion               // string : The gencode annotation version
    
    main:
    
    // Initialize the channels
    ch_patched_ercc_fasta                   = Channel.empty()
    ch_patched_ercc_gtf                     = Channel.empty()
    ch_gencode_gtf                          = Channel.empty()
    ch_cleaned_genome_without_alt_hla_decoy = Channel.empty()
    ch_versions                             = Channel.empty()
    
    //////////////////////////////////////////////////////////////////////////////
    //               Download and prepare the input files
    //////////////////////////////////////////////////////////////////////////////
    
     // Get the GENCODE annotation
    gencode_gtf_gz_url = file("https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_${gencodeVersion}/gencode.v${gencodeVersion}.annotation.gtf.gz")
    
    // Set the gencode metadata
    gencode_meta = [id: "gencode.v${gencodeVersion}.annotation"]
    
    // Get the ERCC spikes zip
    ercc_zip_url = file("https://tools.thermofisher.com/content/sfs/manuals/ERCC92.zip")
    
    // Set the ERCC metadata
    ercc_meta = [id: "ERCC92"]

    // Get the genome
    genome_fasta_url = file("https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta")
    
    // Set the genome metadata
    genome_meta = [id: "Homo_sapiens_assembly38"]
    
    // Unzip the gencode annotation
    ch_gencode_gtf = GUNZIP_GENCODE([gencode_meta, gencode_gtf_gz_url]).gunzip
    ch_versions = ch_versions.mix(GUNZIP_GENCODE.out.versions)
       
    // Update the metadata
    // Get the ERCC results
    ercc_result = UNZIP([ercc_meta, ercc_zip_url]).unzipped_archive.multiMap {
                                                                        fasta: [it[0], "${it[1]}/${it[1].baseName}.fa"] 
                                                                        gtf:   [it[0], "${it[1]}/${it[1].baseName}.gtf"]
                                                                      }
    //Update the metadata for the ERCC fasta file
    ch_versions = ch_versions.mix(UNZIP.out.versions)
    
    // Patch the ERCC fasta file
    ch_patched_ercc_fasta = PATCH_ERCC_SPIKES_FASTA(ercc_result.fasta).patched_ercc_fasta
    
    //Update the metadata for the ERCC fasta file
    ch_patched_ercc_fasta = ch_patched_ercc_fasta
                            .map{meta, file -> [[id:["patched", meta.id].join("_")], file]}
                            
    //Update the versions channel
    ch_versions = ch_versions.mix(PATCH_ERCC_SPIKES_FASTA.out.versions)
    
    // Patch the ERCC gtf file
    ch_patched_ercc_gtf = PATCH_ERCC_SPIKES_GTF(ercc_result.gtf).patched_ercc_gtf
    
    //Update the metadata for the ERCC fasta file
    ch_patched_ercc_gtf = ch_patched_ercc_gtf
                            .map{meta, file -> [[id:["patched", meta.id].join("_")], file]}
    
    //Update the versions channel
    ch_versions = ch_versions.mix(PATCH_ERCC_SPIKES_GTF.out.versions)


    // Remove the ALT, HLA and decoy sequences from the genome fasta files
    ch_cleaned_genome_without_alt_hla_decoy = REMOVE_ALT_HLA_DECOY_FROM_GENOME_FASTA([genome_meta, genome_fasta_url]).cleaned_genome_without_alt_hla_decoy
    
    //Update the metadata for the ERCC fasta file
    ch_cleaned_genome_without_alt_hla_decoy = ch_cleaned_genome_without_alt_hla_decoy
                                             .map{meta, file -> [[id:[meta.id, "noALT_noHLA_noDecoy"].join("_")], file]}

    //Update the versions channel
    ch_versions = ch_versions.mix(REMOVE_ALT_HLA_DECOY_FROM_GENOME_FASTA.out.versions)
    
    emit:
    patched_ercc_fasta_file       = ch_patched_ercc_fasta                      // channel: path(patched_ERCC92.fa)
    patched_ercc_gtf_file         = ch_patched_ercc_gtf                        // channel: path(patched_ERCC92.gtf)
    gencode_gtf_file              = ch_gencode_gtf                             // channel: path(gencode.v44.annotation.gtf)
    cleaned_genome_fasta_file     = ch_cleaned_genome_without_alt_hla_decoy    // channel: path(Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fa)
    versions                      = ch_versions                                // channel: [ versions.yml ]
    
}