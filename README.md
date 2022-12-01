# Marine Omics QC Pipeline


The `moqc` pipeline is intended as an initial step in the analysis of data from marine organisms, particularly those with endosymbionts (corals/giant clams), but also other marine taxa.  In addition to standard short-read QC steps `moqc` aligns reads to a user-provided reference genome (eg a coral host) combined with reference sequences for Symbiodinaceae in order to report relative proportions of host and symbiont reads.  In marine samples (especially sessile organisms such as corals and sponges) it is common to encounter a range of associated eukaryotic taxa as well as bacteria.  The pipeline assesses reads for the presence of these diverse taxa using kraken. 

TODO: Relationship matrix between samples to find clones?

## Quick Start

1. Install [nextflow](https://www.nextflow.io/)
2. Run a test to make sure everything is installed properly. The command below should work on a linux machine with singularity installed (eg JCU HPC). 
```bash
nextflow run marine-omics/moqc -latest -profile singularity,test -r main
```
If you are working from a mac or windows machine you will need to use docker. 
```bash
nextflow run marine-omics/moqc -latest -profile docker,test -r main
```
3. Create the sample csv file (example below)
```
sample,fastq_1,fastq_2
1,sample1_r1.fastq.gz,sample1_r2.fastq.gz
2,sample2_r1.fastq.gz,sample2_r2.fastq.gz
```

Paths should either be given as absolute paths or relative to the launch directory (where you invoked the nextflow command)

4. Choose a profile for your execution environment. This depends on where you are running your code. `moqc` comes with preconfigured profiles that should work on JCU infrastructure. These are
	- *HPC* (ie zodiac) : Use `-profile zodiac`
	- *genomics12* (HPC nodes without pbs): Use `-profile genomics`

If you need to customise further you can create your own `custom.config` file and invoke with option `-c custom.config`. See [nextflow.config](nextflow.config) for ideas on what parameters can be set.

5. Run the workflow with your reference and samples file
```bash
nextflow run marine-omics/moqc -profile singularity,zodiac -r main --host <hostref> --samples <samples.csv> --outdir myoutputs
```


## Symbiont mapping

As a minimum `moqc` requires a host reference file which can be either a genome or transcriptome. To include a symbiont mapping step specify the `--map-symb` at the command-line.  In most cases you will just want to use the default symbiont reference databases which include representatives from all major coral symbiont genera (see databases section below). If you have a custom database you can specify this instead as `--map-symb customdb.fasta`.  Note that custom databases need to comply with a special format (see below).

```bash
nextflow run marine-omics/moqc -profile singularity,zodiac -r main --host <hostref> --samples <samples.csv> --map-symb 'default' --outdir myoutputs
```

## Broad taxonomic classification

For host and symbiont mapping (above) we classify reads by mapping them to a reference genome or transcriptome using a short-read mapping program.  This is highly sensitive and accurate but cannot classify reads from unknown taxa.  In most samples a proportion of reads will come from bacteria and sometimes unknown taxa will be present via contamination during sequencing or the presence of cryptic commensals. To identify these reads we use [krakenuniq](https://github.com/fbreitwieser/krakenuniq)

```bash
nextflow run marine-omics/moqc -profile singularity,zodiac -r main --host <hostref> --samples <samples.csv> --map-symb --outdir myoutputs
```

# Building databases

See the databases folder


