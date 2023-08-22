include { COLLAPSE_GTF_ANNOTATIONS_ON_GENE_LEVEL             } from '../../modules/local/collapse_gtf_annotations_on_gene_level'
include { CAT_CAT as CAT_GENE_LEVEL_GENCODE_PATCHED_ERCC_GTF } from '../../modules/nf-core/cat/cat'

workflow COLLAPSE_GTF_ANNOTATIONS {
    
    take:
    gencode_gtf_file             // channel: path(gencode.v44.annotation.gtf)
    patched_ercc_gtf_file        // channel: path(patched_ERCC92.gtf)
    
    main:

    // Initialize the channels
    ch_gene_level_gencode_gtf_file          = Channel.empty()
    ch_patched_ercc_gtf_file                = Channel.empty()
    ch_versions                             = Channel.empty()
    
    //////////////////////////////////////////////////////////////////////////////
    //               Collapse the transcript into genes using the gene annotation
    //////////////////////////////////////////////////////////////////////////////
    
    // Collapse the transcripts in the gencode annotation into gene level
    ch_gene_level_gencode_gtf_file = COLLAPSE_GTF_ANNOTATIONS_ON_GENE_LEVEL(gencode_gtf_file).gene_level_gencode_gtf
    ch_versions = ch_versions.mix(COLLAPSE_GTF_ANNOTATIONS_ON_GENE_LEVEL.out.versions)

    // Prepare the gencode channel to be combined
    ch_gene_level_gencode_gtf_file = ch_gene_level_gencode_gtf_file
                                    .map{meta, file -> [[id: [meta.id, "genes_collapsed_only"].join("_")], file]}
                                    .map{meta, file -> [meta, file, "to_combine"]}
                                    
    // Prepare the patched ERCC channel to be combined
    patched_ercc_gtf_file = patched_ercc_gtf_file
                            .map{meta, file -> [meta, file, "to_combine"]}
                            
    // Combine the gencode and patched ERCC gtfs                        
    ch_gene_level_gencode_gtf_file = ch_gene_level_gencode_gtf_file
                            .join(patched_ercc_gtf_file, by: 2)
                            .map{flag, meta1, file1, meta2, file2 -> [flag, [id:[meta1.id, meta2.id].join("_")], [file1, file2]]}
                            .map{flag, meta, files -> [meta, files]}
                            
    // Combine the Gencode and patched ERCC annotations
    ch_gene_level_gencode_gtf_file = CAT_GENE_LEVEL_GENCODE_PATCHED_ERCC_GTF(ch_gene_level_gencode_gtf_file).file_out
    
    //Update the versions channel
    ch_versions = ch_versions.mix(CAT_GENE_LEVEL_GENCODE_PATCHED_ERCC_GTF.out.versions)
    
    emit:   
    gene_level_gencode_gtf_file   = ch_gene_level_gencode_gtf_file // channel: path(gencode.v44.annotation_genes_collapsed_only_patched_ERCC92.gtf)
    versions                      = ch_versions                    // channel: [ versions.yml ]
    
}