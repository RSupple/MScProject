#!/bin/csh -f

#program file for RUDO
#calculates and graphically represents unique segments, retrieving their DNA sequence

######################################################################################################################################################################
#retrieve sequences from Genbank

foreach bpid ( "`cat /d/mw8/u/sr002/gbmodule/W_Ecoli_data.txt`" )
    python3 /d/mw8/u/sr002/gbmodule/W_regex.py
end

######################################################################################################################################################################
#convert Genbank files to pseudo complete file for QOD processing
#create header file, append all lines containing any letter (as some lines contain non-dna), remove non-dna, remove blank lines, make each line 70 long, add newline

foreach bpid ( "`cat /d/mw8/u/sr002/gbmodule/WD_Ecoli_data.txt`" )
    if ( -e "/d/mw8/u/sr002/qod/v1.0.2/bin/genomes/qodEcoli/$bpid.fsa.gz" ) then #check file exists
	echo $bpid already QOD-formatted
    else
	gunzip genomes/Ecoli/$bpid.fsa.gz
	awk ' BEGIN {FS="\n"}; NR==1 {print $1}' genomes/Ecoli/$bpid.fsa > genomes/qodEcoli/$bpid.fsa
	awk ' BEGIN {OFS=""; ORS=""}; /^[A-Z]/' genomes/Ecoli/$bpid.fsa | sed '/^$/d' | fold -w70 | awk '{print} END {print "\n"}'  \
	>>genomes/qodEcoli/$bpid.fsa 
	gzip genomes/qodEcoli/$bpid.fsa
	gzip genomes/Ecoli/$bpid.fsa
	echo $bpid.fsa.gz formated for QOD
    endif
end

#no plasmid format for QOD.  If plasmids are to be included then substitue line 33 for line 17 and omit lines 33-43.

foreach bpid ( "`cat /d/mw8/u/sr002/gbmodule/WC_Ecoli_data.txt`" )
    if ( -e "/d/mw8/u/sr002/qod/v1.0.2/bin/genomes/qodEcoli/$bpid.fsa.gz" ) then #check file exists
	echo $bpid no-plasmid already formatted
    else
	gunzip genomes/Ecoli/$bpid.fsa.gz
	awk 'BEGIN {FS="\n"}; /genome/,/^$/ {print}' genomes/Ecoli/$bpid.fsa > genomes/qodEcoli/$bpid.fsa 
	gzip genomes/Ecoli/$bpid.fsa
	gzip genomes/qodEcoli/$bpid.fsa
	echo $bpid no-plasmid formatted 
    endif
end

######################################################################################################################################################################
#access mummer to create alignment file between two completed genomes: reference_query.
#genomes are taken from genome folder and alignment output saved into mumaligns folder then parsed to alignments file for QOD 

foreach ref ( "`cat webref_data.txt`" )

    gunzip genomes/qodEcoli/$ref.fsa.gz

    foreach query ( "`cat webquery_data.txt`" )

	gunzip genomes/qodEcoli/$query.fsa.gz

	if ( "$ref" != "$query" ) then  #essential to enable unique segments to be discovered else none would be unique

	    #awk/sed to take line that contains >, prints first field and sed removes > to obtain accession code from genome file for use in mummer command
	    set a = ` awk '/>/{print  $1}' genomes/qodEcoli/$ref.fsa | sed 's/>//' `
	    set b = ` awk '/>/{print  $1}' genomes/qodEcoli/$query.fsa | sed 's/>//' `

	    #run promer to align sequences
	    eval "/d/as2/s/mummer/v3.23/promer --prefix="$ref"_"$query" genomes/qodEcoli/"$ref".fsa genomes/qodEcoli/"$query".fsa"
	    eval "/d/as2/s/mummer/v3.23/show-aligns -r "$ref"_"$query".delta "$a" "$b" > mumaligns/"$ref"_"$query".aligns"

	    #awk script to convert mummer alignment file to QODfriendly format and gzip to alignments folder
	    eval "awk -f mummer.awk mumaligns/"$ref"_"$query".aligns | gzip > alignments/"$ref"_"$query".mat.gz"

	    #run qod and save output to file - for core genome
	    eval "./qod --verbose --ref-seq genomes/qodEcoli/"$ref".fsa alignments/"$ref"_"$query".mat.gz" >! qod-out/"$ref"_"$query".txt 

	    #continue for...genome specific section:
	    #awk/sed to parse unaligned genome region from QOD output, taking only genomic co-ordinates for use in QOD
	    awk '/0 covering interval/ {print $3, $5}' qod-out/"$ref"_"$query".txt | sed 's/.://; s/^.//'  > cover/"$ref"_"$query".txt

	    #creates mat file for genome specific region to then feed into QOD
	    awk 'NR==1 {print $1 }' genomes/qodEcoli/"$query".fsa > gen_spec/"$ref"_"$query".mat
	    awk '{ print "#" ($2-$1) +1 }; {print "[" $1 "," $2 "]" " " "[" $1 "," $2 "]" }' cover/"$ref"_"$query".txt >> gen_spec/"$ref"_"$query".mat
	    gzip gen_spec/"$ref"_"$query".mat

	endif

    end

    #retrieve dna coordinates for core and gen_spec covering intervals
    #runqod.sh for core genome
    eval "./qod --verbose --ref-seq genomes/qodEcoli/"$ref".fsa alignments/"$ref"_*.mat.gz >! core_qod/"$ref".txt" 

    #create file of core covering intervals for use to retrieve core dna segments - pls see detailed explanation in appendix
    awk ' /^P#/ {if ($6 > 0) {print $3, $5}}' core_qod/$ref.txt | sed 's/.://; s/^.//' | awk ' {print $1, ($2 + 1)}' | sed 's/ /\n/' | uniq -u >! core_cover/c$ref.txt
    paste - - < core_cover/c$ref.txt | awk '{print $1, ($2 - 1)}' >! core_cover/$ref.txt
    rm -f core_cover/c$ref.txt

    #run qod and take the 1 covering interval as genome specific
    eval "./qod --verbose --ref-seq genomes/qodEcoli/"$ref".fsa gen_spec/"$ref"_*.mat.gz" >! gen_spec_qod/$ref.txt
    awk '/1 covering interval/ {print $3, $5}' gen_spec_qod/$ref.txt | sed 's/.://; s/^.//'  >! gen_spec_cover/$ref.txt

end


#######################################################################################################################################################################

#Graphical representation of unique and core genome segments using dna_features_viewer
#create and run python file

eval "module load python3" #system requirement

echo 'from dna_features_viewer import GraphicFeature, GraphicRecord' >! /d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/$ref.py #overwrite if exist
                               
echo 'features=[' >> /d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/$ref.py


#core segments
foreach line ( "`cat /d/mw8/u/sr002/qod/v1.0.2/bin/core_cover/$ref.txt`" )

    set argv = ( $line )
    set begin = $1
    set finish = $2

    echo 'GraphicFeature(start='$begin', end='$finish', strand=+1, color="#ccccff"),' >> /d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/$ref.py

end

#unique segments
foreach line ( "`cat /d/mw8/u/sr002/qod/v1.0.2/bin/gen_spec_cover/$ref.txt`" )

    set argv = ( $line )
    set begin = $1
    set finish = $2
    
    echo 'GraphicFeature(start='$begin', end='$finish', strand=+1, color="#ffd700"),' >> /d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/$ref.py

end

echo ']' >> /d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/$ref.py

#retreive length of genome from QOD output file
set length =  `awk '/^Length/ {print $9}' /d/mw8/u/sr002/qod/v1.0.2/bin/core_qod/$ref.txt | sed 's/\.//'`

echo 'record = GraphicRecord(sequence_length='$length', features=features)'  >> /d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/$ref.py
echo 'ax, _ = record.plot(figure_width=12)'  >> /d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/$ref.py
echo 'ax.figure.savefig("/d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/'$ref'.png")'  >> /d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/$ref.py #create image

eval "python3 /d/mw8/u/sr002/qod/v1.0.2/bin/dna_view/$ref.py" #execute python script

######################################################################################################################################################################
#retrieve DNA corresponding to genome specific segments
foreach ref ( "`cat webref_data.txt`" )

    #Remove \n from file else it is counted as a character in while loop
    awk 'NR>1' genomes/qodEcoli/$ref.fsa | tr -d "\n" > genomes/strip/$ref.fsa

    #create header
    echo `awk 'NR=1 {print $2,$3,$4,$5,$6}' genomes/qodEcoli/"$ref".fsa` - Bioproject $ref unique DNA: > gs_dna/g$ref.txt #create holding file

    foreach line ( "`cat gen_spec_cover/$ref.txt`" )

	set argv = ( $line )
	set start = $1
	set end = $2
	set i = $start

	echo " $start-$end" >> gs_dna/g$ref.txt #addition of space which is later substituted for newline

	while ( $i <= $end ) #iterate through boundaries of co-ordinates retrieving DNA code from a newline stripped file

	    awk -v var="$i" 'BEGIN {RS="RS"; FS=""; ORS=""}; {print $var }' genomes/strip/$ref.fsa >> gs_dna/g$ref.txt

	    @ i++
	
	end

    end

    eval fold -w70 gs_dna/g$ref.txt | awk 'NR==1{print}; NR>1{sub(/ /,"\n\n");print}' > gs_dna/$ref.txt #reformats text
    
end

gzip genomes/qodEcoli/*.fsa

rm -f gs_dna/g*.txt #remove holding file without permission request

##########



rm gen_spec/*.mat.gz # remove so that subsequent runs of different genomes are not effected
rm alignments/*.mat.gz # remove so that subsequent runs of different genomes are not effected


########
#run core_dna if required seperately as it is v lengthy
