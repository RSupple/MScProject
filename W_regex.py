#!/usr/local/bin/python

#regex to read bioproject_ids of complete genomes from text file
import re 

f = open('/d/mw8/u/sr002/gbmodule/Ecoli_data.txt', 'r') #open file and read
for line in f:
    p = re.compile((r'^[0-9]{3,5}'),re.M) #regex for bioproject id, multi-line
    bioproject_ids = p.findall(f.read()) 

import W_genmod   #retrieves, writes & compress fasta files
for bioproject in bioproject_ids:
    W_genmod.get_genseq(bioproject)



