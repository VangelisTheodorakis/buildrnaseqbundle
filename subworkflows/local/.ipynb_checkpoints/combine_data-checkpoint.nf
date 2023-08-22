include { CAT_CAT as CAT_GENCODE_PATCHED_ERCC_GTF     } from '../../modules/nf-core/cat/cat'
include { CAT_CAT as CAT_GENOME_PATCHED_ERCC_FASTA    } from '../../modules/nf-core/cat/cat'

workflow COMBINE_DATA {
    
    take:
    patched_ercc_fasta_file                  // channel: path(patched_ERCC92.fa)
    patched_ercc_gtf_file                    // channel: path(patched_ERCC92.gtf)
    gencode_gtf_file                         // channel: path(gencode.v44.annotation.gtf)
    cleaned_genome_fasta_file                // channel: path(Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fa)
    
    main:
    
    // Initialize the channels
    ch_gencode_patched_ercc_gtf             = Channel.empty()
    ch_genome_patched_ercc_fasta            = Channel.empty()
    ch_versions                             = Channel.empty()
    
    //////////////////////////////////////////////////////////////////////////////
    //               Combine  Gencode vXX and patheced ERCC92 spikes GTFs
    //////////////////////////////////////////////////////////////////////////////

    // Prepare the gencode channel to be combined
    gencode_gtf_file = gencode_gtf_file
                        .map{meta, file -> [meta, file, "to_combine"]}
   
    // Prepare the patched ERCC channel to be combined
    patched_ercc_gtf_file = patched_ercc_gtf_file
                            .map{meta, file -> [meta, file, "to_combine"]}
                            
    // Combine the gencode and patched ERCC gtfs                        
    gencode_patched_ercc_gtf = gencode_gtf_file
            .join(patched_ercc_gtf_file, by: 2)
            .map{flag, meta1, file1, meta2, file2 -> [flag, [id:[meta1.id, meta2.id].join("_")], [file1, file2]]}
            .map{flag, meta, files -> [meta, files]}
            
    // Combine the Gencode and patched ERCC annotations
    ch_gencode_patched_ercc_gtf = CAT_GENCODE_PATCHED_ERCC_GTF(gencode_patched_ercc_gtf).file_out
    
    //Update the versions channel
    ch_versions = ch_versions.mix(CAT_GENCODE_PATCHED_ERCC_GTF.out.versions)
    
    //////////////////////////////////////////////////////////////////////////////
    //               Combine cleaned genome and patched ERCC92 spikes FASTAs
    //////////////////////////////////////////////////////////////////////////////
    
    // Prepare the gencode channel to be combined
    cleaned_genome_fasta_file = cleaned_genome_fasta_file
                                .map{meta, file -> [meta, file, "to_combine"]}
   
    // Prepare the patched ERCC channel to be combined
    patched_ercc_fasta_file = patched_ercc_fasta_file
                                .map{meta, file -> [meta, file, "to_combine"]}
                            
    // Combine the gencode and patched ERCC gtfs                        
    genome_patched_ercc_fasta = cleaned_genome_fasta_file
                                .join(patched_ercc_fasta_file, by: 2)
                                .map{flag, meta1, file1, meta2, file2 -> [flag, [id:[meta1.id, meta2.id].join("_")], [file1, file2]]}
                                .map{flag, meta, files -> [meta, files]}
                                
    // Combine the cleaned genome and patched ERCC Fasta files
    ch_genome_patched_ercc_fasta = CAT_GENOME_PATCHED_ERCC_FASTA(genome_patched_ercc_fasta).file_out
    
    //Update the versions channel
    ch_versions = ch_versions.mix(CAT_GENOME_PATCHED_ERCC_FASTA.out.versions)    
    
    emit:
    gencode_patched_ercc_gtf      = ch_gencode_patched_ercc_gtf     // channel: path(gencode.v44.annotation_patched_ERCC92.gtf)
    genome_patched_ercc_fasta     = ch_genome_patched_ercc_fasta    // channel: path(Homo_sapiens_assembly38_noALT_noHLA_noDecoy_patched_ERCC92.fa)
    versions                      = ch_versions                     // channel: [ versions.yml ]
    
}