#Genome alignment
nucmer --mum -c 1000 --maxgap=500 --prefix=$name.raw --threads=20 $ref $que
delta-filter -i 90 -l 1000 -1 $name.raw.delta >$name.flt.delta
show-coords -THrd $pre.flt.delta >$pre.flt.coords

#SVMU
svmu $pre.flt.delta $ref $query h null $pre

#SYRI
syri -c $pre.flt.coords -r $ref -q $qry -d $pre.flt.delta

#Reads alignment

bwa mem -k 32 -w 10 -B 3 -O 11 -E 4 -t 10 -R "@RG\tID:foo_lane\tPL:illumina\tLB:library\tSM:sample" genome.fasta read_1.fq.gz read_2.fq.gz | samtools view -S -b - > sample.bam
samtools sort -@ 8 -T sample -o sample.sort.bam sample.bam
picard MarkDuplicates -I sample.sort.bam -O sample.sort.markdup.bam -M sample.markdup_metrics.txt

#Smoove

https://github.com/brentp/smoove
