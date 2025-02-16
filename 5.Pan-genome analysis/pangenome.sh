#pan-genome

orthofinder -f data/ -t 20 -o newtest -op > command.diamond.list

perl -p -i -e 'if (m/diamond blastp/ ) { s/$/ --outfmt 5 --max-target-seqs 50 --id 10/; s/--compress 1//; s/.txt/.xml/; s/ -e \S+/ --evalue 1e-5/; s/ -p 1 / -p 4 /; } else { s/^.*\n$//; }' command.diamond.list 

ParaFly -c command.diamond.list -CPU 20

perl -e 'while (<>) { print "parsing_blast_result.pl --no-header --max-hit-num 500 --evalue 1e-5 --CIP 0.3 --query-coverage 0.5 --subject-coverage 0.5 $1.xml | gzip -c - > $1.txt.gz\n" if m/(\S+).xml/; }' command.diamond.list > command.parsing_blast_result.list

ParaFly -c command.parsing_blast_result.list -CPU 20 

OrthoFinderWorkingDir=`head -n 1 command.diamond.list | perl -ne 'print $1 if m/-d (\S+)\//'` 

orthofinder -b $OrthoFinderWorkingDir -og
