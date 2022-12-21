# Marine Omics QC Pipeline


The `moqc` pipeline is intended as an initial step in the analysis of data from marine organisms, particularly those with endosymbionts (corals/giant clams), but also other marine taxa.  In addition to standard short-read QC steps `moqc` uses [krakenuniq](https://github.com/fbreitwieser/krakenuniq) to perform a quick taxonomic classification of reads.  This can help to identify instances of contamination (eg with lab bacteria or human DNA), or potentially identify unexpected reads from commensal eukaryotes such as cryptic barnacles (eg [as in this study](https://github.com/iracooke/Porites_competition/blob/master/07_kraken.md)). 

```mermaid
graph TD;
	fastq-->fastqc;
	fastqc-->multiqc;
	fastq-->krakenuniq;
	krakenuniq-->krona;
	krakenuniq-->Rplot;
```

## Getting Started

0. Build the krakenuniq databases. If you are working on our JCU server, genomics2 this is already done. Otherwise see section below on building the databases.
1. Install and configure [nextflow](https://www.nextflow.io/). See [here](https://gist.github.com/iracooke/bec2b24a86eb682f7d3055eea15e61aa) for instructions specific to JCU machines (zodiac, genomics1, genomics2)
2. Create the sample csv file (example below). Note that the header line is mandatory and must be identical to that shown in the example.
```
sample,fastq_1,fastq_2
1,sample1_r1.fastq.gz,sample1_r2.fastq.gz
2,sample2_r1.fastq.gz,sample2_r2.fastq.gz
```

or for single-end data

```
sample,fastq_1
1,sample1_r1.fastq.gz
2,sample2_r1.fastq.gz
```

Paths should either be given as absolute paths or relative to the launch directory (where you invoked the nextflow command).  Also note that for `moqc` the items in the sample column must be unique.  So if you have multiple files per sample you will need to give them separate IDs in the first column. 

3. Choose a profile for your execution environment. This depends on where you are running your code. `moqc` comes with preconfigured profiles that should work on JCU infrastructure. These are
	- *genomics2* (HPC nodes without pbs): Use `-profile genomics2`. This is the preferred profile because databases are already installed
	- *HPC* (ie zodiac) : Use `-profile zodiac` (you will need to install databases if you choose this option)

If you need to customise further you can create your own `custom.config` file and invoke with option `-c custom.config`. See [nextflow.config](nextflow.config) for ideas on what parameters can be set.

4. Run the workflow with your samples file
```bash
nextflow run marine-omics/moqc -latest -profile genomics2 -r main --samples <samples.csv> --outdir myoutputs
```

## Outputs

Once the pipeline has finished running you should find the following useful outputs

	- Report files ('*.report') from krakenuniq
	- krona (An interactive html page showing the taxonomic breakdown of all classified reads)
	- multiqc (Standard read QC metrics from fastqc)

The report files can be used to make simple summaries of taxonomic composition. For example this code should produce a bar plot of symbiont composition
```R
library(tidyverse)

report_dir="outputs/krakenuniq" # Adapt this to your own output directory

report_files <- list.files(report_dir,pattern = "*.report",full.names = TRUE)

read_report <- function(path){
  s <- basename(path) %>% str_extract("[^\\.]+")
  sample_group <- s %>% str_extract("[^\\-]+")
  read_tsv(path,show_col_types = FALSE,skip=2) %>% 
    add_column(sample=s)
}

report_data <- do.call(rbind,lapply(report_files,read_report))

symbiont_report_data <- report_data %>% 
  filter(taxName %in% c("Symbiodinium microadriaticum","Breviolum minutum","Cladocopium goreaui","Durusdinium trenchii","Fugacium kawagutii")) %>% 
  extract(taxName,into = "Genus",regex = "([^ ]*)")

symbiont_report_data %>% 
  ggplot(aes(x=sample)) + geom_col(aes(y=taxReads,fill=Genus)) + xlab("") + ylab("Number of Classified Reads") + theme(axis.text.x = element_text(angle=90), legend.position = "bottom")

```

## Note about disk usage

The `moqc` pipeline creates some fairly large temporary files.  The default behaviour is to keep these around in the `work` directory because their presence can speed up reruns of the pipeline if you use the `-resume` option. Once you have finished your run however it is probably a good idea to delete the `work` directory entirely as this will take a lot of disk space and be of little lasting value.  

## Building databases

The krakenuniq databases required for this pipeline are very large and take a lot of compute power to build. We recommend you build these in a central location on a shared computer so that they can be used by multiple users. 

See [databases](databases) for details.


