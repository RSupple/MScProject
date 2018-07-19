#!/bin/csh -f

module load python3

#web file for RUDO 

######################################################################################################################################################################
#access mummer to create alignment file between two completed genomes: reference_query.
#genomes are taken from genome folder and alignment output saved into mumaligns folder then parsed to alignments file for QOD 

set p=/d/mw8/u/sr002/qod/v1.0.2/bin

foreach ref ( "`cat "$p"/webref_data.txt`" )
#web server side security precution that only bioproject is entered-program terminates
if ("$ref" != "30681" && "$ref" != "40647" && "$ref" != "16235" && "$ref" != "33413" && "$ref" != "38725" && "$ref" != "16718" && "$ref" != "18083" && \
"$ref" != "18281" && "$ref" != "20713" && "$ref" != "28965" && "$ref" != "33775" && "$ref" != "313" && "$ref" != "30031" && "$ref" != "13960" && "$ref" != "33409" && \
"$ref" != "42749" && "$ref" != "13959" && "$ref" != "33373" && "$ref" != "33411" && "$ref" != "43693" && "$ref" != "33875" && "$ref" != "32511" && \
"$ref" != "32513" && "$ref" != "32571" && "$ref" != "27739" && "$ref" != "259" && "$ref" != "226" && "$ref" != "30045" && "$ref" != "32509" && "$ref" != "42729" && \
"$ref" != "41221" && "$ref" != "33375" && "$ref" != "18057" && "$ref" != "19053" && "$ref" != "19469" && "$ref" != "20079" && "$ref" != "225" && "$ref" != "16351" && \
"$ref" != "50883" && "$ref" != "33415" && "$ref" != "16259" && "$ref" != "48011" && "$ref" != "15637" && "$ref" != "13146" && "$ref" != "13145" && \
"$ref" != "33639" && "$ref" != "408" && "$ref" != "310" && "$ref" != "16375" && "$ref" != "13151") then 
exit 1
endif

    gunzip "$p"/genomes/qodEcoli/$ref.fsa.gz

    foreach query ( "`cat "$p"/webquery_data.txt`" )

	gunzip "$p"/genomes/qodEcoli/$query.fsa.gz

	if ( "$ref" != "$query" ) then

	    #awk/sed to take line that contains >, prints first field and sed removes > to obtain accession code from genome file for use in mummer command
	    set a = ` awk '/>/{print  $1}' "$p"/genomes/qodEcoli/$ref.fsa | sed 's/>//' `
	    set b = ` awk '/>/{print  $1}' "$p"/genomes/qodEcoli/$query.fsa | sed 's/>//' `

	    #run promer to align sequences
	    eval "/d/as2/s/mummer/v3.23/promer --prefix="$ref"_"$query" "$p"/genomes/qodEcoli/"$ref".fsa "$p"/genomes/qodEcoli/"$query".fsa"
	    mv -f "$ref"_"$query".delta $p/"$ref"_"$query".delta
	    eval "/d/as2/s/mummer/v3.23/show-aligns -r "$p"/"$ref"_"$query".delta "$a" "$b" > "$p"/mumaligns/"$ref"_"$query".aligns"

	    #awk script to convert mummer alignment file to QODfriendly format and gzip to alignments folder
	    eval "awk -f "$p"/mummer.awk "$p"/mumaligns/"$ref"_"$query".aligns | gzip > "$p"/alignments/"$ref"_"$query".mat.gz"

	    #run qod and save output to file - for core genome
	    eval ""$p"/qod --verbose --ref-seq "$p"/genomes/qodEcoli/"$ref".fsa "$p"/alignments/"$ref"_"$query".mat.gz" >! "$p"/qod-out/"$ref"_"$query".txt 

	    #continue for...genome specific section:
	    #awk/sed to parse unaligned genome region from QOD output, taking only genomic co-ordinates for use in QOD
	    awk '/0 covering interval/ {print $3, $5}' "$p"/qod-out/"$ref"_"$query".txt | sed 's/.://; s/^.//'  > "$p"/cover/"$ref"_"$query".txt

	    #creates mat file for genome specific region to then feed into QOD
	    awk 'NR==1 {print $1 }' "$p"/genomes/qodEcoli/"$query".fsa > "$p"/gen_spec/"$ref"_"$query".mat
	    awk '{ print "#" ($2-$1) +1 }; {print "[" $1 "," $2 "]" " " "[" $1 "," $2 "]" }' "$p"/cover/"$ref"_"$query".txt >> "$p"/gen_spec/"$ref"_"$query".mat
	    gzip "$p"/gen_spec/"$ref"_"$query".mat

	endif

    end

    #retrieve dna coordinates for core and gen_spec covering intervals
    #runqod.sh for core genome
    eval ""$p"/qod --verbose --ref-seq "$p"/genomes/qodEcoli/"$ref".fsa "$p"/alignments/"$ref"_*.mat.gz >! "$p"/core_qod/"$ref".txt" 

    #create file of core covering intervals for use to retrieve core dna segments
    awk '/^P#/{if ($6 > 0){print $3,$5}}' "$p"/core_qod/$ref.txt |sed 's/.://; s/^.//'| awk '{print $1,($2 + 1)}' |sed 's/ /\n/'| uniq -u >! "$p"/core_cover/c$ref.txt
    paste - - < "$p"/core_cover/c$ref.txt | awk '{print $1, ($2 - 1)}' >! "$p"/core_cover/$ref.txt
    rm -f "$p"/core_cover/c$ref.txt

    #run qod and take the 1 covering interval as genome specific
    eval ""$p"/qod --verbose --ref-seq "$p"/genomes/qodEcoli/"$ref".fsa "$p"/gen_spec/"$ref"_*.mat.gz" >! "$p"/gen_spec_qod/$ref.txt
    awk '/1 covering interval/ {print $3, $5}' "$p"/gen_spec_qod/$ref.txt | sed 's/.://; s/^.//'  >! "$p"/gen_spec_cover/$ref.txt

end

#######################################################################################################################################################################
#Graphical representation of unique and core genome segments using dna_features_viewer
#create and run python file

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
gzip "$p"/genomes/qodEcoli/*.fsa

# remove so that subsequent runs of different genomes are not effected
rm -f "$p"/gen_spec/*.mat.gz 
rm -f "$p"/alignments/*.mat.gz 

######################################################################################################################################################################























