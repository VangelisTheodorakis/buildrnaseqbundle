process CONCAT_FILES {
    tag "$patch_ercc_spikes_fasta"
    label 'process_single'
    
    input:
    tuple val(meta), path(file1), path(file2)
 
    output:
    tuple val(meta), path("${file1.baseName}_${file2.baseName}.${file1.extension}"), emit: concatenated_file
    path "versions.yml", emit: versions

    script:
    """
    cat $file1 $file2 > ${file1.baseName}_${file2.baseName}.${file1.extension}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cat: \$(cat --version | head -n 1| sed 's/cat (GNU coreutils) //g')
    END_VERSIONS
    """
}