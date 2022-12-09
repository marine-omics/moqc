process symbiont_plot {

  publishDir "$params.outdir/symbiont_plot", mode: 'copy'

  input:
    path(report)

  output:
    path "*.png"

  script:

  def args = task.ext.args ?: ''

  """
  Rscript /usr/local/bin/plot_symbionts.R .
  """

}