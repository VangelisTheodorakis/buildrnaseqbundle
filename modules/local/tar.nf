process TAR {
    tag "$archive"
    label 'process_low'

    conda "conda-forge::sed=4.7 conda-forge::grep=3.11 conda-forge::tar=1.34"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    val archive
    path files

    output:
    path "${archive}.tar.gz", emit: tar
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args  = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    //prefix    = task.ext.prefix ?: ( meta.id ? "${meta.id}" : archive.baseName.toString().join(".tar.gz"))

    """
    tar \\
        -zcvf \\
        ${archive}.tar.gz \\
        $files \\
        $args 
        
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        untar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """

    stub:
    //prefix    = task.ext.prefix ?: ( meta.id ? "${meta.id}" : archive.toString().replaceFirst(/\.[^\.]+(.gz)?$/, ""))
    """
    mkdir $prefix
    touch ${prefix}/file.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        untar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """
}
