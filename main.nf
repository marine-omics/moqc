nextflow.enable.dsl=2

include { fastqc } from './modules/fastqc.nf'
include { multiqc_fastqc; multiqc_fastp; multiqc_bams } from './modules/multiqc.nf'
include { fastp } from './modules/fastp.nf'
include { sidx; faidx; flagstat; stat; idxstat } from './modules/samtools.nf'
include { krakenuniq;krakenuniq_mpa } from './modules/krakenuniq.nf'
include { krona_import_taxonomy } from './modules/krona.nf'

if(!params.outdir){
  log.error "No outdir provided"
  exit 1
}

workflow qc {
  take:
    fastqin
  main:
    fastqin | fastqc | collect | multiqc_fastqc
}

workflow {
  kraken_dbs = Channel.from(params.krakendbs).splitCsv() | collect

// Preprocess data
  ch_input_sample = extract_csv(file(params.samples, checkIfExists: true))

  ch_input_sample.view()


  krakenuniq(ch_input_sample,kraken_dbs)

  ch_krakenouts = krakenuniq.out.kraken

  krakenuniq_mpa(ch_krakenouts,kraken_dbs)

  ch_krakenouts | collect | krona_import_taxonomy

  ch_input_sample | qc
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def resolve_path(pathstring){
  if(pathstring =~ /^\//){
    pathstring
  } else {
    "${params.base_path}/${pathstring}"
  }
}

def extract_csv(csv_file) {
    Channel.from(csv_file).splitCsv(header: true)
    .map{ row -> 
      def meta = [:]
      meta.sample = row.sample

      if (! meta.sample) exit 1, "Encountered a row with a null sample. All samples must have names. Offending row is ${row}"

      def fastq_1     = file(resolve_path(row.fastq_1), checkIfExists: true)
      def fastq_2     = row.fastq_2 ? file(resolve_path(row.fastq_2), checkIfExists: true) : null
      meta.single_end = row.fastq_2 ? false : true

      reads = [fastq_1,fastq_2]
      reads.removeAll([null])

      [meta,reads]
    }
}
