process krakenuniq {

  publishDir "$params.outdir/krakenuniq", mode: 'copy'

  input:
    tuple val(meta), path(reads)
    path(krakendbs)

  output:
    path "*.kraken"

  script:

  def args = task.ext.args ?: ''

  outfile = "${meta.sample}.kraken"

  krakendb_args = params.krakendbs.split(",").collect { db -> "--db ${db}"}.join(" ")

  if (meta.single_end) {
  """
  krakenuniq ${krakendb_args} ${args} ${reads[0]} ${reads[1]} > ${outfile}
  """
    } else {
  """
  gunzip -c ${reads[0]} > ${reads[0].baseName} && gunzip -c ${reads[1]} > ${reads[1].baseName} && \
  krakenuniq ${krakendb_args} ${args} --paired ${reads[0].baseName} ${reads[1].baseName} > ${outfile}
  """
  }

}


process krakenuniq_mpa {

  publishDir "$params.outdir/krakenuniq", mode: 'copy'

  input:
    path(kraken)
    path(krakendbs)

  output:
    path "*.mpa"

  script:

  def args = task.ext.args ?: ''

  outfile = "${kraken.baseName}.mpa"

  krakendb_args = params.krakendbs.split(",").collect { db -> "--db ${db}"}.join(" ")

  """
  krakenuniq-mpa-report ${krakendb_args} ${args} ${kraken} > ${outfile}
  """

}
