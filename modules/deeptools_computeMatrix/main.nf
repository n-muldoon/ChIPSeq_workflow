#!/usr/bin/env nextflow

process COMP_MATRIX {
    label 'process_high'
    conda 'envs/deeptools_env.yml'
    container 'ghcr.io/bf528/deeptools:latest'

    input:
    path(big_wig)
    path(ucsd_bed)

    output:
    path('*.gz'), emit: mx

    shell:
    """
    computeMatrix scale-regions -S $big_wig -R $ucsd_bed -b 2000 -a 2000 -p $task.cpus -o comp_matrix.gz
    """
    //only for the IP samples

    //--scoreFileName, -S: bigWig file(s) containing the scores to be plotted.
    // Multiple files should be separated by spaced.
}
