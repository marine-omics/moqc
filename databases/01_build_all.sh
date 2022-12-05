source 00_functions.sh
source 02_symbiont_genomes.sh
source 03_coral_genomes.sh
source 04_euk_genomes.sh
source 05_coral_transcriptomes.sh
source 06_symbiont_transcriptomes.sh
source 07_standard.sh

# Update the (very old) standard taxDB
cp symbiont_transcriptomes/taxDB kraken_standard/taxDB

