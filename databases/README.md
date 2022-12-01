# Building kraken databases

Kraken and krakenuniq run very fast, however, one downside is that building the requisite databases takes a long time. 

The scripts in this directory as designed to semi-automate the process of building appropriate databases for classifying reads from coral sequencing projects. 

Each database has its own shell script for building. For example

```bash
bash 02_symbiont_genomes.sh
```

Will build the `symbiont_genomes` database

## Dependencies

- `bioawk`
- `krakenuniq`
- `dustmasker` (Part of ncbi blast+)
- [ncbi cli tools](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/)
- `unzip`
