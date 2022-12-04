process krona_import_taxonomy {

  publishDir "$params.outdir/krona", mode: 'copy'

  input:
    path(kraken)

  output:
    path "*.html"

  script:

  def args = task.ext.args ?: ''

  outfile = "krakenuniq.krona.html"


  """
  ktImportTaxonomy -q 2 -t 3 ${kraken} ${args} -o ${outfile}
  """

}