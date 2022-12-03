krakenify_fagz(){
	fagz=$1
	taxid=$2
	gunzip -c ${fagz} | bioawk -c fastx -v taxid=${taxid} \
	'{printf(">sequence%s|kraken:taxid|%s %s\n%s\n",NR,taxid,$name,$seq)}'
}

make_taxonmap(){
	fagz=$1
	taxid=$2
	description=$3
	gunzip -c ${fagz} | bioawk -c fastx -v taxid=${taxid} -v desc="$description" \
	'{printf("%s\t%s\t%s\n",$name,taxid,desc)}'
}

do_dustmasker(){
	fasta_file=$1
	dustmasker -infmt fasta -in ${fasta_file} -level 20 -outfmt fasta | \
		sed '/^>/! s/[^AGCT]/N/g' 
}

download_by_accession(){
	accession=$1
	destpath=$2
	type=$3

	tmpdir=${accession}_tmp
	mkdir -p $tmpdir
	cd $tmpdir
	datasets download genome accession ${accession} --filename tmp.zip # --exclude-gff3 --exclude-protein --exclude-genomic-cds --exclude-rna
	unzip tmp.zip
	cd ..

	if [[ $type == "genome" ]]; then
		#statements
		mv $tmpdir/ncbi_dataset/data/${accession}/${accession}*_genomic.fna ${destpath%.gz}
		gzip ${destpath%.gz}
	elif [[ $type == "cds" ]]; then
		mv $tmpdir/ncbi_dataset/data/${accession}/cds_from_genomic.fna ${destpath%.gz}
		gzip ${destpath%.gz}
	else
		echo "Unsupported type $type"
		exit
	fi
	rm -rf $tmpdir
}

prepare_inputs(){
	DLDIR=$1
	DBNAME=$2
	DBTYPE=$3

	mkdir -p $DLDIR

	while IFS=, read -r name abbrv taxid url
	do
		if [[ -f $DLDIR/${abbrv}.fa.gz ]]; then
			echo "Skipping download for ${abbrv}. File exists"
		else
			regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
			if [[ $url =~ $regex ]]; then				
				echo "Downloading ${url} using wget"
				wget "$url" -O $DLDIR/${abbrv}.fa.gz
			else
				echo "Downloading ${url} using ncbi dataset api"
				download_by_accession $url $DLDIR/${abbrv}.fa.gz $DBTYPE
			fi
			if [[ ! -s $DLDIR/${abbrv}.fa.gz ]]; then
				echo "Download failed for $url"
				exit 1
			fi
		fi

		echo "Making taxon map for ${abbrv}"
		make_taxonmap $DLDIR/${abbrv}.fa.gz $taxid ${abbrv} > $DLDIR/${abbrv}_kraken.fa.map
		gunzip -c $DLDIR/${abbrv}.fa.gz > $DLDIR/${abbrv}_kraken.fa
		if [[ ! -s $DLDIR/${abbrv}_kraken.fa ]]; then
			echo "Failed to make taxon.map ${abbrv}"
			exit 1
		fi
		
		echo "Dust Masking ${abbrv}"
		do_dustmasker $DLDIR/${abbrv}_kraken.fa > $DLDIR/${abbrv}_kraken_dust.fa
		if [[ ! -s $DLDIR/${abbrv}_kraken_dust.fa ]]; then
			echo "Dustmasker failed for ${abbrv}"
			exit 1
		fi
		mv $DLDIR/${abbrv}_kraken_dust.fa $DLDIR/${abbrv}_kraken.fa

	done < $DBNAME.csv

}

build_db(){
	DLDIR=$1
	DBNAME=$2
	DBTYPE=${3:genome}
	
	prepare_inputs $DLDIR $DBNAME $DBTYPE

	mkdir -p $DBNAME

	krakenuniq-download --db ${DBNAME} taxonomy

	for f in $(find $DLDIR -name '*kraken.fa');do
		echo $f
		krakenuniq-build --add-to-library $f --db $DBNAME
	done

	for f in $(find $DLDIR -name '*.map');do
		echo $f
		krakenuniq-build --add-to-library $f --db $DBNAME
	done

	krakenuniq-build --build --db $DBNAME $KRAKENBUILDFLAGS

}


export KRAKENBUILDFLAGS="--kmer-len 31 --threads 40"
