#!/bin/csh -f

#shell script to access mummer to create alignment file between two genomes, reference_query.
#where query is wgs and reference is complete genome
#genomes are taken from genome folder and alignment output saved into mumaligns folder

set ref=225
set wgsquery=51111

#unzip genome files
gunzip genomes/complete/$ref.fsa.gz 
gunzip genomes/$wgsquery.fsa.gz 

set a = ` awk '/>/{print  $1}' genomes/complete/$ref.fsa | sed 's/>//' `

#run promer
eval "/d/as2/s/mummer/v3.23/promer --prefix="$ref"_"$wgsquery" genomes/complete/"$ref".fsa genomes/"$wgsquery".fsa"

#parse Accession codes out of genomes file then sed strips the '>' from the beginning to give list of acc codes for genome
eval `awk '/>/ {print  $1}' genomes/"$wgsquery".fsa | sed 's/>//' > "$wgsquery"_accs.txt`

#script to take accs. from above txt file for draft genome file to create mummer commands
foreach line (`cat $wgsquery\_accs.txt`)
    set b=`echo $line`
    eval "/d/as2/s/mummer/v3.23/show-aligns "$ref"_"$wgsquery".delta "$a" "$b" >>! mumaligns/"$ref"_"$wgsquery".aligns"
end
 
#takes overrall genome acc code (holds no seq data) to act as header in alignments file
eval `awk '/00000000./{print $1}' genomes/"$wgsquery".fsa > alignments/"$ref"_"$wgsquery".mat`

#awk script to convert mummer alignment file to QODfriendly format 
eval `awk -f mumwgs.awk mumaligns/"$ref"_"$wgsquery".aligns >> alignments/"$ref"_"$wgsquery".mat`

#re-zip genome files and zip QOD alignment file
gzip genomes/complete/$ref.fsa
gzip genomes/$wgsquery.fsa
eval `gzip alignments/"$ref"_"$wgsquery".mat`

#THEN RUNQOD

