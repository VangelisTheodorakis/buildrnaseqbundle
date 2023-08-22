process MERGE_FOLDERS {
    tag "$merge_folders"
    label 'process_single'

    conda "conda-forge::sed=4.7 conda-forge::grep=3.11 "
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    val folders_to_merge

    output:
    path "star_rsem_index/", emit: destination_folder
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    
    """
    mkdir star_rsem_index
    
    cp -t star_rsem_index/ $folders_to_merge 
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cp: \$(echo \$(cp --version 2>&1 | head -n 1 |sed 's/cp (GNU coreutils) //g'))
    END_VERSIONS
    """
}
