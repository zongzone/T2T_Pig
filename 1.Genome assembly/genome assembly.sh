#Contig assembly

hifiasm -o minzhu -t 30 --ul ONT.reads --h1 hic.reads1 --h2 hic.reads2 HiFi.reads

Note: Removing the Hi-C reads typically yields the smallest number of contigs (i.e., a less fragmented contig set), whereas including Hi-C reads often increases the contig N50 and produces longer contigs overall.

nextDenovo nextdenovo.cfg

nextPolish run.cfg

#Chromosome mounting 

allhic extract group.clean.bam group.fasta --RE GATC
partition --pairsfile group.clean.pairs.txt --contigfile group.clean.counts_GATC.txt -K 19 --minREs 50 --maxlinkdensity 3 --NonInformativeRabio 2
allhic build group.fasta
allhic optimize group1.txt group.clean.clm

Note: Although the commands below are functional, we now generally recommend using **YaHS** for chromosome-scale scaffolding/anchoring, as it tends to be more robust and easier to tune across datasets.

#Gap filling

TGS-GapCloser.sh  --scaff gap_flank100k.fa --reads genome_50k.fa --output minzhu --racon /bin/racon --tgstype ont --thread 8 --chunk 20 --ne
nucmer --mum --maxgap=500 --mincluster=1000 --prefix=$prefix --threads=20 $ref $query
delta-filter -i 90 -l 5000 -1 $prefix.delta > $prefix.flt.delta
show-coords -cdlroT $prefix.flt.delta >$prefix.flt.coords
