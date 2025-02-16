#RNA-seq

fastp -i $i.R1.fq.gz -I $i.R2.fq.gz -o $i.R1.clean.fq.gz -O $i.R2.clean.fq.gz -h $i.html 

extract_splice_sites.py	genome.gtf > Sus_scrofa.ss

extract_exons.py genome.gtf > Sus_scrofa.exon

hisat2-build --ss Sus_scrofa.ss --exon Sus_scrofa.exon genome.fa Sus_tran

hisat2 -p 8 --dta -x Sus_tran -1 $i.R1.clean.fq.gz -2 $i.R2.clean.fq.gz -S $i.sam

samtools view -bS $i.sam > $i.bam

samtools sort -@ 8 -o $i.sorted.bam $i.bam

stringtie -p 8 -G genome.gtf -o $i.gtf -l $i $i.duroc.sort.bam

stringtie --merge -p 8 -G Sus_scrofa.Sscrofa11.1.110.gtf -o stringtie_merged.gtf mergelist.txt

gffcompare -r Sus_scrofa.Sscrofa11.1.110.gtf -G -o merged stringtie_merged.gtf

stringtie  -p 10 -e -G stringtie_merged.gtf -o $i.gtf -A $i.sort.bam

prepDE.py -i sample.txt
