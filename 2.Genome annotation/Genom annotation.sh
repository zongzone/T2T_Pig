#repeat annotation
BuildDatabase -engine ncbi -name model_genome genome.fa
RepeatModeler -database model_genome -engine ncbi -threads 30 -LTRStruct
RepeatMasker -a -no_is -norna -pa 30 -lib genome.libraries.fa -q genome.fa -gff

#RNA annotation
hisat2 -p 16 -x hisat_genome.fa -1 read_1_clean.fq.gz -2 read_2_clean.fq.gz --un-conc-gz . --dta 2>sample.summary | samtools view -Sb - | samtools sort -o sample.sort.bam
minimap2 --split-prefix --secondary=no -ax splice -uf -t 16 genome.fa isoseq.polished.hq.fa | samtools view -Sb - | samtools sort -o isoseq.sort.bam
stringtie sample.sort.bam -p 16 -o sample.gtf
Trinity --seqType fq --left read_1_clean.fq.gz --right read_2_clean.fq.gz  --CPU 16 --max_memory 75G --normalize_reads --full_cleanup --min_glue 2 --min_kmer_cov 2 --output trinity.out

#ncRNA annotation
blastall -p blastn -e 1e-10 -v 10000 -b 10000 -d genome.fa -i rRNA.fa -o genome.fa.rRNA.blast
tRNAscan-SE -Q genome.fa -o genome.fa.tRNA -f genome.fa.tRNA.structure
cmsearch --cpu 20 Rfam.cm_miRNA genome.fa > genome.fa.miRNA.cmsearc
cmsearch --cpu 20 Rfam.cm_snRNA genome.fa > genome.fa.snRNA.cmsearch

#ab initio annotation
augustus --AUGUSTUS_CONFIG_PATH=conf --species=pasa1 --uniqueGeneId=true  --noInFrameStop=true --gff3=on --genemodel=complete --strand=both genome.fa > genome.fa.Augustus
snap -gff pasa1.hmm genome.fa > genome.fa.SNAP

#homology-based annotation
tblastn -query ref.pep -db genome.fa -outfmt 6 -evalue 1e-05 -num_threads 10 -out ref-genome.blast
genewise ref.pep ref-genome.blast.nuc -genesf -tfor -quiet >out.gw

#EVM integration
evm_partition_inputs --outputdir $PWD --genome $PWD/genome.fa --gene_predictions $PWD/denovo.gff --protein_alignments $PWD/homolog.gff --transcript_alignments $PWD/transcripts.gff --segmentSize 10000000 --overlapSize 50000 --partition_listing evm.partition 1>evm.partition.log 2>evm.partition.err
evm_write_commands --genome $PWD/genome.fa --weights $PWD/weights.txt --gene_predictions $PWD/denovo.gff --protein_alignments $PWD/homolog.gff --transcript_alignments $PWD/transcripts.gff --output_file_name evm.out --partitions $PWD/evm.partition > partitions.evm_cmds
evm_recombine_partial --partitions chr.list --output_file_name evm.out
evm_out_to_gff3 --partitions chr.list --output evm.out --genome genome.fa

#pasa correction
echo "DATABASE=$PWD/genome.sqlite" > annotCompare.config
Launch_PASA_pipeline.pl -c annotCompare.config -g genome.fa -t Trinity.fa -A -L --annots evm.gff3 --CPU 32
