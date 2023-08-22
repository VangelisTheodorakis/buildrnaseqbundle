process COLLAPSE_GTF_ANNOTATIONS_ON_GENE_LEVEL {
    tag "$collapse_gtf_annotations_on_gene_level"
    label 'process_single'

    conda " conda-forge::python=3.10.2 conda-forge::numpy=1.15.4 conda-forge::pandas=1.5.2 bioconda::intervals=0.6.0 conda-forge::gzip=1.12"
    container "${    workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
                    'https://depot.galaxyproject.org/singularity/mulled-v2-d78a4ea4843c2384982f3da8150b6909abf8fd2f:f51f8060fd2430e7c2d03d6c30f2c12009b10d00-0' :
                    'biocontainers/mulled-v2-d78a4ea4843c2384982f3da8150b6909abf8fd2f'}"
                    
    input:
    tuple val(meta), path(gencodeAnnotation)
 
    output:
    tuple val(meta), path("${gencodeAnnotation.baseName}_genes_collapsed_only.gtf"), emit: gene_level_gencode_gtf
    path "versions.yml", emit: versions
    
    script:
    
    """
    
    # Get the GRCh38 data

    collapse_annotation.py \
    --collapse_only $gencodeAnnotation \
    ${gencodeAnnotation.baseName}_genes_collapsed_only.gtf
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
        
    """

}