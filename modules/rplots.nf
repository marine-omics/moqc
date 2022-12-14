process symbiont_plot {

  label 'tidyverse'

  publishDir "$params.outdir/symbiont_plot", mode: 'copy'

  input:
    path(report)
    path 'plot_symbionts.R'

  output:
    path "*.png"

  script:

  def args = task.ext.args ?: ''

  """
  Rscript plot_symbionts.R .
  """

}