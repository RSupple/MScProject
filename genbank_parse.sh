#!/bin/csh -f

#retrieves CDS segments which are nested within unique segments.
set ref=225

#first retrieve CDS segment coordinates
#strip file of characters other than coordinates of interval of CDS and where 'join' then use outer coordinates
awk ' /^     CDS/ {print $2}' $ref.gb | sed 's/\./ /g; s/[a-z]//g; s/[0-9]*,[0-9]*//; s/(//g; s/)//g; s/>//g; s/<//g; s/,//g' >! parse_$ref.txt
sed -i -e 's/\r//g' parse_$ref.txt #removes hidden ^M that disrupts $cds_end

foreach row ( "`cat /d/mw8/u/sr002/qod/v1.0.2/bin/parse_$ref.txt`" ) 

set argv = ( $row )
set cds_start=$1
set cds_end=$2

    foreach row ( "`cat /d/mw8/u/sr002/qod/v1.0.2/bin/gen_spec_cover/$ref.txt`" ) 

    set argv = ( $row )
    set gsc_start=$1
    set gsc_end=$2

        if ( $cds_start >= $gsc_start && $cds_end <= $gsc_end ) then

	#- this retrieves the coords of the CDS intervals and using this...

        echo $gsc_start $cds_start $cds_end $gsc_end >>! genbank_cds_$ref.txt 

        endif

    end
end







