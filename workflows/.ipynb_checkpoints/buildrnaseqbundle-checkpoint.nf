/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

WorkflowBuildrnaseqbundle.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { PREPARE_INPUT_FILES                    } from '../subworkflows/local/prepare_input_files'
include { COMBINE_DATA                           } from '../subworkflows/local/combine_data'
include { CREATE_FASTA_INDEX_AND_DICT            } from '../subworkflows/local/create_fasta_index_and_dict'
include { COLLAPSE_GTF_ANNOTATIONS               } from '../subworkflows/local/collapse_gtf_annotations'
include { CREATE_RSEM_INDEX                      } from '../subworkflows/local/create_rsem_index'
include { CREATE_STAR_INDEX                      } from '../subworkflows/local/create_star_index'
include { CREATE_RNASEQ_INDEX_DIR                } from '../subworkflows/local/create_rnaseq_index_dir'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BUILDRNASEQBUNDLE {

    ch_versions = Channel.empty()

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    
    //////////////////////////////////////////////////////////////////////////////
    // Get the initial input files
    //////////////////////////////////////////////////////////////////////////////
    
    PREPARE_INPUT_FILES(params.gencodeVersion)
    
    // Append the software versions
    ch_versions = ch_versions.mix(PREPARE_INPUT_FILES.out.versions)
    
    //////////////////////////////////////////////////////////////////////////////
    // Get the combined FASTAs and GTFs
    //////////////////////////////////////////////////////////////////////////////
    
    COMBINE_DATA(   PREPARE_INPUT_FILES.out.patched_ercc_fasta_file,
                    PREPARE_INPUT_FILES.out.patched_ercc_gtf_file,
                    PREPARE_INPUT_FILES.out.gencode_gtf_file,
                    PREPARE_INPUT_FILES.out.cleaned_genome_fasta_file)
                    
    // Append the software versions
    ch_versions = ch_versions.mix(PREPARE_INPUT_FILES.out.versions)
    
    //////////////////////////////////////////////////////////////////////////////
    // Create the RSEM indexes
    //////////////////////////////////////////////////////////////////////////////
    
    CREATE_RSEM_INDEX(  COMBINE_DATA.out.genome_patched_ercc_fasta,
                        COMBINE_DATA.out.gencode_patched_ercc_gtf)
    
    // Append the software versions
    ch_versions = ch_versions.mix(CREATE_RSEM_INDEX.out.versions)
    
    //////////////////////////////////////////////////////////////////////////////
    // Create the fasta index and dict
    //////////////////////////////////////////////////////////////////////////////
    
    CREATE_FASTA_INDEX_AND_DICT(COMBINE_DATA.out.genome_patched_ercc_fasta)
    
    // Append the software versions
    ch_versions = ch_versions.mix(CREATE_RSEM_INDEX.out.versions)
    
    
    //////////////////////////////////////////////////////////////////////////////
    // Collapse the transcripts in the annotation gtf into genes
    //////////////////////////////////////////////////////////////////////////////
    
    COLLAPSE_GTF_ANNOTATIONS( PREPARE_INPUT_FILES.out.gencode_gtf_file,
                                            PREPARE_INPUT_FILES.out.patched_ercc_gtf_file)
    
    // Append the software versions
    ch_versions = ch_versions.mix(COLLAPSE_GTF_ANNOTATIONS.out.versions)
    
    //////////////////////////////////////////////////////////////////////////////
    // Create the STAR indexes
    //////////////////////////////////////////////////////////////////////////////
    
    CREATE_STAR_INDEX(  COMBINE_DATA.out.genome_patched_ercc_fasta,
                        COMBINE_DATA.out.gencode_patched_ercc_gtf)
    
    ch_versions = ch_versions.mix(CREATE_STAR_INDEX.out.versions)
    
    
    //////////////////////////////////////////////////////////////////////////////
    // Export all the indexes in one file
    //////////////////////////////////////////////////////////////////////////////
    
    CREATE_RNASEQ_INDEX_DIR(CREATE_RSEM_INDEX.out.rsem_index_dir,
                            CREATE_STAR_INDEX.out.star_results)
    
    ch_versions = ch_versions.mix(CREATE_RNASEQ_INDEX_DIR.out.versions)
    
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
