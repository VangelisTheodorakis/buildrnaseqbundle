process CONCAT_FILES {
    tag "$patch_ercc_spikes_fasta"
    label 'process_single'
    
    conda "conda-forge::sed=4.7"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"
    
    input:
    tuple val(meta), path(file1), path(file2)
 
    output:
    tuple val(meta), path("${file1.baseName}_${file2.baseName}.${file1.extension}"), emit: concatenated_file
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when
    
    script:
    """
    cat $file1 $file2 > ${file1.baseName}_${file2.baseName}.${file1.extension}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cat: \$(cat --version | head -n 1| sed 's/cat (GNU coreutils) //g')
    END_VERSIONS
    """
}