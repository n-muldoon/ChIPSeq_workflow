#!/usr/bin/env nextflow
include { FASTQC } from './modules/fastqc'
include { BOWTIE2_BUILD } from './modules/bowtie2_build'
include { TRIM } from './modules/trimmomatic/'
include { BOWTIE2_ALIGN } from './modules/bowtie2_align'
include { SAMTOOLS_SORT } from './modules/samtools_sort'
include { SAMTOOLS_INDEX } from './modules/samtools_index'
include { SAMTOOLS_STATS } from './modules/samtools_stats'
include { MULTIQC } from './modules/multiqc'
include { BAMCOVERAGE } from './modules/deeptools_bamcoverage'
include { MULTIBIGWIG } from './modules/deeptools_multibigwig'
include { PLOTCORR } from './modules/deeptools_plotcorrelation'
include { CALLPEAKS } from './modules/mac3'
include { INTERSECT } from './modules/bedtools_intersect/main.nf'
include { REMOVE } from './modules/bedtools_remove/main.nf'
include { ANNOTATE } from './modules/homer_annotatepeaks/main.nf'
include { COMP_MATRIX } from './modules/deeptools_computeMatrix/main.nf'
include { PLOT_PROF } from './modules/deeptools_plotProfile/main.nf'
include { FIND_MOTIFS } from './modules/homer_findMotifs/main.nf'
workflow {
    //Quality Control, Genome indexing and alignment
    Channel.fromPath(params.samplesheet) |
    splitCsv(header: true) |
    map { row -> tuple(row.name, file(row.path)) } |
    // transpose() |
    // view()
    set { fq_ch }
    //view(params.genome,params.gtf)

    FASTQC(fq_ch)
    // path adapters
    // tuple val(sample_id), path(reads)
    TRIM(params.adapter_fa,fq_ch)

    BOWTIE2_BUILD(params.genome)
    
    BOWTIE2_ALIGN(TRIM.out.trimmed_reads,BOWTIE2_BUILD.out.index,BOWTIE2_BUILD.out.name)

    //Sorting and indexing the alignments
    SAMTOOLS_SORT(BOWTIE2_ALIGN.out.bam)
    SAMTOOLS_INDEX(SAMTOOLS_SORT.out.sorted)
    
    //Calculate alignment statistics using samtools flagstat
    SAMTOOLS_STATS(SAMTOOLS_INDEX.out.index)

    //Aggregating QC results with MultiQC
    // (fastqc zip files, trimmomatic log, and samtools flagstat output)
    
    FASTQC.out.zip.map { it -> [ it ] }
    .mix(TRIM.out.log.map {it -> it[1]})
    .mix(SAMTOOLS_STATS.out.flagstat.map {it -> it[1]})
    .collect()
    .set { multiqc_ch }

    MULTIQC(multiqc_ch)

    //Generating bigWig files from our BAM files
    //input: tuple val(meta), path(bam), path(bai)
    
    BAMCOVERAGE(SAMTOOLS_INDEX.out.index)

    //Generate matrix with info from all big wigs using MultiBigWig Summary
    //input: tuple val(meta), path('*.bw'), emit: bigwig 
    BAMCOVERAGE.out.bigwig.collect { it[1]} |
    set { summary_ch }

    // summary_ch.view { "Debug - Files being passed to MULTIBIGWIG: $it" }
    MULTIBIGWIG(summary_ch)

    //plotCorrelation utility in deeptools to 
    //generate a plot of the distances between correlation coefficients for all of your samples.
    // You will need to choose whether to use a pearson or spearman correlation. 
    
    //input: multibigwig output
    PLOTCORR(MULTIBIGWIG.out.multibwsummary,params.cortype)
    //In a notebook you create, provide a short justification for what you chose
    //pearsono plot: b/c data not ordinal, but linear; is data normally distributed?
    
    //PEAK CALLING: SKIPPED BC GOT RESIZE ARRAY ERROR
        // proceed w/provided narrowpeak files
    // BOWTIE2_ALIGN.out
    // | map { name, path -> tuple(name.split('_')[1], [(path.baseName.split('_')[0]): path]) }
    // | groupTuple(by: 0)
    // | map { rep, maps -> tuple(rep, maps[0] + maps[1])}
    // | map { rep, samples -> tuple(rep, samples.IP, samples.INPUT)}
    // | set { peakcalling_ch }


    // CALLPEAKS(peakcalling_ch,params.macs3_genome)
    //Channel.fromPath(params.peaks) | view()
    Channel.fromPath(params.peaks).collect{it} |
    map { files -> tuple('repr_peaks', files[0],files[1]) } |
    set { intersect_ch}
    // .map { file -> def meta = [id: file.simpleName]
    //     return tuple(meta, file, file)
    // } 
    // .view()
    //set{intersect_ch}

    //INTERSECT: to produce a single set of reproducible peaks from both of your replicate experiments
    INTERSECT(intersect_ch)

    //REMOVE: uses bedtools to remove any peaks that overlap with the blacklist BED 
    //        for the most recent human reference genome.
    REMOVE(INTERSECT.out.intersect, params.blacklist)

    //HOMER: Annotating peaks to their nearest genomic feature using HOMER
    ANNOTATE(REMOVE.out.cleaned,params.genome,params.gtf)

    //collect .bw where "IP" in file name
    BAMCOVERAGE.out.bigwig
    .map { it[1] }         // extract file paths
    .filter { it.name.contains('IP_') }  // filter files whose name includes 'IP_'
    // .view()
    .set { mx_ch }

    // BAMCOVERAGE.out.bigwig.collect { it[1] } |
    // filter(~/.IP_./) |
    // view()

    // basename
    // set { mx_ch }


    //COMP_MATRIX: Generating a signal intensity plot for all human genes using computeMatrix and plotProfile for IP samples
    //input: bigwigfiles, uscs bed file
    COMP_MATRIX(mx_ch,params.ref_bed)
    
    //PLOT_PROF: generate a simple visualization of the read counts from the IP samples across the body of genes from the hg38 reference
    PLOT_PROF(COMP_MATRIX.out.mx)

    // FIND_MOTIFS: perform motif enrichment analysis on your set of reproducible and filtered peaks
    FIND_MOTIFS(REMOVE.out.cleaned,params.genome)
}