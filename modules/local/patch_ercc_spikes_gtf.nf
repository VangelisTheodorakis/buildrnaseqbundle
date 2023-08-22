process PATCH_ERCC_SPIKES_GTF {

    tag "$patch_ercc_spikes_gtf"
    label 'process_single'
    
    conda "conda-forge::python=3.10.2 "
    container "${    workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
                    'https://depot.galaxyproject.org/singularity/python:3.10.2' :
                    'biocontainers/python:3.10.2'}"
                   
    input:
    tuple val(meta), path(erccGtfFile)
 
    output:
    tuple val(meta), path("patched_${erccGtfFile.baseName}.gtf"), emit: patched_ercc_gtf
    path "versions.yml", emit: versions

    script:
    """
    
    # Get the GRCh38 data

    patch_ercc_spikes_gtf.py \
    --ercc_gtf_file $erccGtfFile \
    --patched_ercc_gtf_file patched_${erccGtfFile.baseName}.gtf
    
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
        
    """

}