mkdir -p kraken_standard
cd kraken_standard

wget 'https://genome-idx.s3.amazonaws.com/kraken/uniq/krakendb-2022-06-16-STANDARD/kuniq_standard_minus_kdb.20220616.tgz'
wget 'https://genome-idx.s3.amazonaws.com/kraken/uniq/krakendb-2022-06-16-STANDARD/database.kdb'

tar -zxvf kuniq_standard_minus_kdb.20220616.tgz

cd ..