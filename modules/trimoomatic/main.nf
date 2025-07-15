#!/usr/bin/env nextflow

process TRIM {
    conda 'envs/trimmomatic_env.yml'
    container 'ghcr.io/bf528/trimmomatic:latest'
    publishDir params.outdir, mode: 'copy'
    
    input:
    path adapters
    tuple val(sample_id), path(reads)


    output:
    tuple val(sample_id), path("*_trimmed.fastq.gz"), emit: trimmed_reads
    tuple val(sample_id), path("*.log"), emit: log

    shell:
    """
    trimmomatic SE \\
    ${reads} \\
    ${sample_id}_trimmed.fastq.gz \\
    ILLUMINACLIP:${adapters}:2:30:10 \\
    LEADING:3 \\
    TRAILING:3 \\
    SLIDINGWINDOW:4:15 \\
    2> ${sample_id}_trim.log
    """
    //java -jar trimmomatic-0.35.jar SE -phred33 input.fq.gz output.fq.gz ILLUMINACLIP:TruSeq3-SE:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    //    ${sample_id}.fastq.gz \\
}
