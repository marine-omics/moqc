source 00_functions.sh

DLDIR=kraken2dl

DBNAME=kraken_coral_symbionts3

#prepare_inputs $DLDIR coral_genomes genome
#prepare_inputs $DLDIR symbiont_genomes genome
#prepare_inputs $DLDIR euk_genomes genome

kraken2-build --download-taxonomy --db $DBNAME --use-ftp

kraken2-build --download-library bacteria --db $DBNAME --use-ftp
kraken2-build --download-library viral --db $DBNAME --use-ftp
kraken2-build --download-library human --db $DBNAME --use-ftp

for f in $(find $DLDIR -name '*kraken_dust.fa');do
	echo $f
	kraken2-build --add-to-library $f --db $DBNAME
done

kraken2-build --build --kmer-len 31 --threads 32 --db $DBNAME