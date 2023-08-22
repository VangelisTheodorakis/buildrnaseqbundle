include { SAMTOOLS_FAIDX                              } from '../../modules/nf-core/samtools/faidx'
include { PICARD_CREATESEQUENCEDICTIONARY             } from '../../modules/nf-core/picard/createsequencedictionary'

workflow CREATE_FASTA_INDEX_AND_DICT {
    
    take:
    genome_patched_ercc_fasta                // channel: path(Homo_sapiens_assembly38_noALT_noHLA_noDecoy_patched_ERCC92.fa)
    
    main:
    
    // Initialize the channels
    ch_genome_patched_ercc_fai              = Channel.empty()
    ch_genome_patched_ercc_dict             = Channel.empty()
    ch_versions                             = Channel.empty()
    
    //////////////////////////////////////////////////////////////////////////////
    //               Index the combined genome and patched ERCC fasta file
    //////////////////////////////////////////////////////////////////////////////
    
    // Create a dummy variable the points to the current working directory
    dummy_genome_patched_ercc_fasta = genome_patched_ercc_fasta
                                        .map{meta, file -> [[:], System.getProperty("user.dir")]}
                                        
    // Combine the cleaned genome and patched ERCC Fasta files
    ch_genome_patched_ercc_fai = SAMTOOLS_FAIDX(genome_patched_ercc_fasta, dummy_genome_patched_ercc_fasta).fai
    
    //Update the versions channel
    ch_versions = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)    
    
    
    //////////////////////////////////////////////////////////////////////////////
    //               Create the dictionary for the combined genome and patched 
    //               ERCC fasta file
    //////////////////////////////////////////////////////////////////////////////
    
    // Combine the cleaned genome and patched ERCC Fasta files
    ch_genome_patched_ercc_dict = PICARD_CREATESEQUENCEDICTIONARY(genome_patched_ercc_fasta).reference_dict
    
    //Update the versions channel
    ch_versions = ch_versions.mix(PICARD_CREATESEQUENCEDICTIONARY.out.versions)
    
    emit:
    genome_patched_ercc_fai    = ch_genome_patched_ercc_fai      // channel: path(Homo_sapiens_assembly38_noALT_noHLA_noDecoy_patched_ERCC92.fasta.fai)
    genome_patched_ercc_dict   = ch_genome_patched_ercc_dict     // channel: path(Homo_sapiens_assembly38_noALT_noHLA_noDecoy_patched_ERCC92.dict)
    versions                   = ch_versions                     // channel: [ versions.yml ]
    
}