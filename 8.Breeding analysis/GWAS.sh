#GWAS

Plink --file data --recode12 --output-missing-genotype 0 --transpose --out data

./emmax-kin-intel64 data -v -d 10 -o test.kinf

emmax-intel64 -v -d 10 -t data -p p.txt -k test.kinf -c covar.txt -o p_EMMAX
