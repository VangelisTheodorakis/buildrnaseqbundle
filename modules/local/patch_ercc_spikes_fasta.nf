process PATCH_ERCC_SPIKES_FASTA {
    tag "$patch_ercc_spikes_fasta"
    label 'process_single'
    
    input:
    tuple val(meta), path(erccFasta)
 
    output:
    tuple val(meta), path("patched_${erccFasta.baseName}.fa"), emit: patched_ercc_fasta
    path "versions.yml", emit: versions

    script:
    """
    sed 's/ERCC-/ERCC_/g' $erccFasta > patched_${erccFasta.baseName}.fa
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sed: \$(sed --version | head -n 1| sed 's/sed (GNU sed) //g')
    END_VERSIONS
    """
}