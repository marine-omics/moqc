# Building kraken databases

The scripts in this directory as designed to semi-automate the process of building appropriate databases for classifying reads from coral sequencing projects. 

Each database has its own shell script for building. To run them all invoke the master script like this.

```bash
bash 01_build_all.sh
```

## Dependencies

- `bioawk`
- `krakenuniq`
- `dustmasker` (Part of ncbi blast+)
- [ncbi cli tools](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/)
- `unzip`
