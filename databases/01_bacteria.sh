source 00_functions.sh

DBDIR=bacteria_archaea

krakenuniq-download --db $DBDIR --threads 10 --dust refseq/bacteria refseq/archaea

krakenuniq-build --db $DBDIR $KRAKENBUILDFLAGS