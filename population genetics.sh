#PCA

gcta --bfile b --autosome --make-grm --out grm

gcta --grm grm --pca 3 --out out_pca

#NJ tree

VCF2Dis -InPut SV.vcf -OutPut SV.p

#ADMIXTURE

admixture --cv file.bed $i | tee log${K}.out