include { RSEM_PREPAREREFERENCE                       } from '../../modules/nf-core/rsem/preparereference'
include { TAR as TAR_RSEM_RESULTS                     } from '../../modules/local/tar'

workflow CREATE_RSEM_INDEX {
    
    take:
    genome_patched_ercc_fasta                // channel: path(Homo_sapiens_assembly38_noALT_noHLA_noDecoy_patched_ERCC92.fa)
    gencode_patched_ercc_gtf                 // channel: path(gencode.v44.annotation_patched_ERCC92.gtf)

    main:
    
    // Initialize the channels
    ch_rsem_index_dir                       = Channel.empty()
    ch_rsem_transcript_fasta                = Channel.empty()
    ch_tar_rsem_results                     = Channel.empty()
    ch_versions                             = Channel.empty()
    
    //////////////////////////////////////////////////////////////////////////////
    //               Get the RSEM reference index
    //////////////////////////////////////////////////////////////////////////////
    
    // Get the patched ercc fasta file path only
    genome_patched_ercc_fasta_path_only = genome_patched_ercc_fasta
                                        .map{meta, file -> [file]}
    
    // Get the combined gtf file path only
    gencode_patched_ercc_gtf_path_only = gencode_patched_ercc_gtf
                                        .map{meta, file -> [file]}
                      
    // Combine the cleaned genome and patched ERCC Fasta files
    RSEM_PREPAREREFERENCE(genome_patched_ercc_fasta_path_only, gencode_patched_ercc_gtf_path_only)
    
    // Get the index folder
    ch_rsem_index_dir = RSEM_PREPAREREFERENCE.out.index
    
    // Get the transcript fasta 
    ch_rsem_transcript_fasta = RSEM_PREPAREREFERENCE.out.transcript_fasta
    
    
    //Update the versions channel
    ch_versions = ch_versions.mix(RSEM_PREPAREREFERENCE.out.versions)    
    
    //////////////////////////////////////////////////////////////////////////////
    //               Zip the resulting folder
    //////////////////////////////////////////////////////////////////////////////
    
    // Prepare channels for combination
    ch_rsem_index_files_to_tar = ch_rsem_index_dir
                                .map{file -> [[file, ""].join("/")]}
    
    // Zip the resulting folder
    ch_tar_rsem_results = TAR_RSEM_RESULTS(params.rsem_output_zip, ch_rsem_index_files_to_tar).tar
    ch_versions = ch_versions.mix(TAR_RSEM_RESULTS.out.versions)
    
    emit:
    rsem_index_dir             = ch_rsem_index_dir             // channel: path(rsem/)
    versions                   = ch_versions                   // channel: [ versions.yml ]
    
}