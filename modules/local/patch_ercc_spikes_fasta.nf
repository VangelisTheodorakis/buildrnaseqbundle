process PATCH_ERCC_SPIKES_FASTA {
    tag "$patch_ercc_spikes_fasta"
    label 'process_single'
    
    conda "conda-forge::sed=4.7"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"
        
    input:
    tuple val(meta), path(erccFasta)
 
    output:
    tuple val(meta), path("patched_${erccFasta.baseName}.fa"), emit: patched_ercc_fasta
    path "versions.yml", emit: versions
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    """
    sed 's/ERCC-/ERCC_/g' $erccFasta > patched_${erccFasta.baseName}.fa
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sed: \$(sed --version | head -n 1| sed 's/sed (GNU sed) //g')
    END_VERSIONS
    """
}