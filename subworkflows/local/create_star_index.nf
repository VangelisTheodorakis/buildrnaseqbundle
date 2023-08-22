include { STAR_GENOMEGENERATE                         } from '../../modules/nf-core/star/genomegenerate'
include { TAR as TAR_STAR_RESULTS                     } from '../../modules/local/tar'

workflow CREATE_STAR_INDEX {
    
    take:
    genome_patched_ercc_fasta                // channel: path(Homo_sapiens_assembly38_noALT_noHLA_noDecoy_patched_ERCC92.fa)
    gencode_patched_ercc_gtf                 // channel: path(gencode.v44.annotation_patched_ERCC92.gtf)

    main:
    
    // Initialize the channels
    ch_star_results                         = Channel.empty()
    ch_versions                             = Channel.empty()
    
    //////////////////////////////////////////////////////////////////////////////
    //               Generate the STAR index for the fasta files
    //////////////////////////////////////////////////////////////////////////////
    
    // Get the patched ercc fasta file path only
    genome_patched_ercc_fasta_path_only = genome_patched_ercc_fasta
                                        .map{meta, file -> [file]}
    
    // Get the combined gtf file path only
    gencode_patched_ercc_gtf_path_only = gencode_patched_ercc_gtf
                                        .map{meta, file -> [file]}
    
    // Create the star index
    ch_star_results = STAR_GENOMEGENERATE(genome_patched_ercc_fasta_path_only, gencode_patched_ercc_gtf_path_only).index
    ch_versions = ch_versions.mix(STAR_GENOMEGENERATE.out.versions)
    
    //////////////////////////////////////////////////////////////////////////////
    //               Zip the resulting folder
    //////////////////////////////////////////////////////////////////////////////
    
    // Prepare channels for combination
    ch_star_index_files_to_tar = ch_star_results
                        .map{file -> [[file,""].join("/")]}                        
    
    // Zip the resulting folder
    ch_tar_star_results = TAR_STAR_RESULTS(params.star_output_zip, ch_star_index_files_to_tar).tar
    ch_versions = ch_versions.mix(TAR_STAR_RESULTS.out.versions)
    
    emit:
    star_results                  = ch_star_results                // channel: path(star/)
    versions                      = ch_versions                    // channel: [ versions.yml ]
    
}