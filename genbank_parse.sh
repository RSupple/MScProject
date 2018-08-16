#!/bin/csh -f

#retrieves CDS segments which are nested within unique segments where ref=reference genome.
set ref=225

#first retrieve CDS segment coordinates (cds_start and cds_end from GenBank file)
#strip file of characters other than coordinates of interval of CDS and where 'join' then use outer coordinates
awk ' /^     CDS/ {print $2}' $ref.gb | sed 's/\./ /g; s/[a-z]//g; s/[0-9]*,[0-9]*//; s/(//g; s/)//g; s/>//g; s/<//g; s/,//g' >! parse_$ref.txt
sed -i -e 's/\r//g' parse_$ref.txt #removes hidden ^M that disrupts $cds_end

foreach row ( "`cat /d/mw8/u/sr002/qod/v1.0.2/bin/parse_$ref.txt`" ) 

set argv = ( $row )
set cds_start=$1
set cds_end=$2

    foreach row ( "`cat /d/mw8/u/sr002/qod/v1.0.2/bin/gen_spec_cover/$ref.txt`" ) 

    set argv = ( $row )
    set usc_start=$1 #unique segment coord start
    set usc_end=$2   #unique segment coord end

        if ( $cds_start >= $usc_start && $cds_end <= $usc_end ) then   #cds segments nested within unique segments

	#- this retrieves the coords of the CDS intervals and using this...

        echo $usc_start $cds_start $cds_end $usc_end >>! genbank_cds_$ref.txt 

        endif

    end
end







