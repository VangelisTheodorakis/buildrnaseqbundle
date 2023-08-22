include { MERGE_FOLDERS                               } from '../../modules/local/merge_folders'

workflow CREATE_RNASEQ_INDEX_DIR {
    
    take:
    rsem_index_dir                         // channel: path(rsem/)
    star_index_dir                         // channel: path(star/)
    
    main:
    ch_star_rsem_idex                       = Channel.empty()
    ch_versions                             = Channel.empty()
    
    //////////////////////////////////////////////////////////////////////////////
    //               Publish results to rnaseq dir
    //////////////////////////////////////////////////////////////////////////////
    
    
    // Prepare the files from the rsem folder
    rsem_index_files = rsem_index_dir
                        .map{ folder -> [folder, "genome.*"]. join("/")}
    
    // Prepare the files from the star folder
    star_index_files = star_index_dir
                        .map{ folder -> [folder, "*"]. join("/")}
    
    // Prepare the combined files to include
    star_rsem_index_files = star_index_files
                            .concat(rsem_index_files)
                            .reduce{ star_files, rsem_files -> [star_files, rsem_files]. join(" ")}
                            
    // Zip the resulting folder
    ch_star_rsem_idex = MERGE_FOLDERS(star_rsem_index_files)
    ch_versions = ch_versions.mix(MERGE_FOLDERS.out.versions)

    emit:
    versions                   = ch_versions                   // channel: [ versions.yml ]
    
}