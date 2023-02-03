process sample_reads {
  input:
  tuple val(meta), path(reads)
  val(maxreads)

  output:
  tuple val(meta), path('*sample.fastq.gz') , emit: reads

  script:
  if (meta.single_end) {
  """
  gunzip -c $reads | head $maxreads | gzip > ${reads.baseName}.sample.fastq.gz
  """
  } else {
  """
  gunzip -c ${reads[0]} | head -n $maxreads | gzip > ${reads[0].baseName}.sample.fastq.gz
  gunzip -c ${reads[1]} | head -n $maxreads | gzip > ${reads[1].baseName}.sample.fastq.gz
  """
  }

}