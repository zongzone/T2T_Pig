#graph pangenome

vg autoindex --workflow giraffe -R XG \
	--ref-fasta genome.fa \
	--vcf vcf.gz \
	--tmp-dir tmp --prefix pig \
	--threads 20
	
vg snarls --threads 10 --include-trivial pig.xg > pig.snarls

./vg giraffe --gbz-name pig.giraffe.gbz --minimizer-name pig.min --dist-name pig.dist --fastq-in $i_1.clean.fastq.gz --fastq-in $i_2.clean.fastq.gz --sample $i -b default --rescue-algorithm dozeu --threads 15 --output-format gam > $i.mapped.gam

./vg pack --xg pig.xg --gam $i.mapped.gam --packs-out $i.pack --threads 15 --min-mapq 5 		

./vg call pig.xg --snarls pig.snarls --pack $i.pack --sample $i --threads 15 --genotype-snarls > $i.genotypes.vcf 
