process krakenuniq {

  publishDir "$params.outdir/krakenuniq", mode: 'copy', pattern: '*.kraken.report'

  input:
    tuple val(meta), path(reads)
    path(krakendbs)

  output:
    path "*.kraken", emit: kraken
    path "*.kraken.report", emit: krakenreport

  script:

  def args = task.ext.args ?: ''

  outfile = "${meta.sample}.kraken"
  reportfile = "${meta.sample}.kraken.report"

  krakendb_args = params.krakendbs.split(",").collect { db -> "--db ${db}"}.join(" ")

  if (meta.single_end) {
  """
  krakenuniq ${krakendb_args} --report-file ${reportfile} --threads ${task.cpus} ${args} ${reads[0]} ${reads[1]} > ${outfile}
  """
    } else {
  """
  gunzip -c ${reads[0]} > ${reads[0].baseName} && gunzip -c ${reads[1]} > ${reads[1].baseName} && \
  krakenuniq ${krakendb_args} --report-file ${reportfile} --threads ${task.cpus} ${args} --paired ${reads[0].baseName} ${reads[1].baseName} > ${outfile}
  rm ${reads[0].baseName} ${reads[1].baseName}
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
