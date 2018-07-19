#file takes promer alignment file and parses for QOD friendly mat format
#captured fields are coordinates of genome alignmnet
#first line captures acc code
/^-- Alignments between/ {printf ">%s\n", $6;}                       
/^-- BEGIN/ {                                         \
  printf "#%d\n", (($8-$6)<0?-($8-$6):($8-$6))+1;       
  printf "[%d, %d] [%d, %d]\n",$6,$8,$11,$13;         \
}




#(($8-$6)<0?-($8-$6):($8-$6))+1
#if 8th field is < 6th field then result will be -ve.  
#abs value required so <0? checks if $8-$6 is negative. 
#if -ve i.e. -($8-$6) then convert to +ve :($8-$6). 
#+ve difference will remain +ve
#+1 because inclusive counting