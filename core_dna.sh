#!/bin/csh -f

#create file of core covering intervals for use to retrieve core dna segments - see appendix 3 for detailed explanation
set ref=225

awk ' /^P#/ {if ($6 > 0) {print $3, $5}}' core_qod/$ref.txt | sed 's/.://; s/^.//' | awk ' {print $1, ($2 + 1)}' | sed 's/ /\n/' | uniq -u >! core_cover/c$ref.txt

paste - - < core_cover/c$ref.txt | awk '{print $1, ($2 - 1)}' >! core_cover/$ref.txt

rm -f core_cover/c$ref.txt


#retrieve DNA corresponding to core segments

gunzip genomes/qodEcoli/*.fsa.gz

#foreach ref ( "`cat O157H7.txt`" ) optional as the program takes a very long time to run.
    #Remove \n from file else it is counted as a character in while loop
    awk 'NR>1' genomes/qodEcoli/$ref.fsa | tr -d "\n" > genomes/strip/$ref.fsa

    #create header
    echo `awk 'NR=1 {print $2,$3,$4,$5,$6}' genomes/qodO157H7/"$ref".fsa` - Bioproject $ref unique DNA: > core_dna/c$ref.txt #create holding file

    foreach line ( "`cat core_cover/$ref.txt`" )

	set argv = ( $line )
	set start = $1
	set end = $2
	set i = $start

	echo " $start-$end" >> core_dna/c$ref.txt #addition of space which is later substituted for newline

	while ( $i <= $end ) #iterate through boundaries of co-ordinates retrieving DNA code from a newline stripped file

	    awk -v var="$i" 'BEGIN {RS="RS"; FS=""; ORS=""}; {print $var }' genomes/strip/$ref.fsa >> core_dna/c$ref.txt

	    @ i++
	
	end

    end

    eval fold -w70 core_dna/c$ref.txt | awk 'NR==1{print}; NR>1{sub(/ /,"\n\n");print}' > core_dna/$ref.txt #reformats text

#end

gzip genomes/qodEcoli/*.fsa
rm -f core_dna/c*.txt #remove holding file without permission request



