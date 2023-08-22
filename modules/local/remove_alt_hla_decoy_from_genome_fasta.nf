process REMOVE_ALT_HLA_DECOY_FROM_GENOME_FASTA {
    tag "$remove_alt_hla_decoy_from_genome_fasta"
    label 'process_low'
    
    conda "conda-forge::python=3.10.2"
    container "${    workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
                    'https://depot.galaxyproject.org/singularity/python:3.10.2' :
                    'biocontainers/python:3.10.2'}"
                    
    input:
    tuple val(meta), path(genomeFasta)
    
    output:
    tuple val(meta), path("${genomeFasta.baseName}_noALT_noHLA_noDecoy.fasta"), emit: cleaned_genome_without_alt_hla_decoy
    path "versions.yml", emit: versions

    script:
    """
    
    remove_alt_hla_decoy_from_genome_fasta.py --inputFasta $genomeFasta --outputFasta ${genomeFasta.baseName}_noALT_noHLA_noDecoy.fasta
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
        
    """
}