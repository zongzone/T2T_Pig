#Mapping ratio

samtools flagstat --threads 10 sample.bam > sample.flagstat

#Coverage ratio

mosdepth -t 20 sample.out sample.bam

#Busco

busco -m genome -i genome.fa -o sample_mammalia -l mammalia_odb10

#SNV

bcftools query -f '[%GT\n]' sample.vcf | sort | uniq -c

#Merqury

for i in {1..2}; do
  meryl k=21 count output read$i.meryl sample.clean$i.fq.gz
done


meryl union-sum output read.meryl read*.meryl


merqury.sh read.meryl genome.fa profix
