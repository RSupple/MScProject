#!/usr/local/bin/python

def get_genseq (bioproject):
    """Downloads fasta file from NCBI, compress and writes to a QOD genomes file."""

    """
    User defined Bioproject as variable.
    Fasta file downloads first via Entrez Elink then string passed to Entrez efetch (Biopython 9.15),( NCBI manual).
    File is written to the variable named file in QOD genomes folder.
    """
    import os
    import gzip #file compression essential:many large files exceed data storage limit
    from Bio import Entrez
    from Bio import SeqIO
    Entrez.email = "rudo.supple@gmail.com" #obligated to provide

    filename = "/d/mw8/u/sr002/qod/v1.0.2/bin/genomes/Ecoli/{0}.fsa.gz".format(bioproject)  #format string method to insert variable into filename
    limit = "srcdb+ddbj/embl/genbank[prop]" # sequence type 

    if not os.path.isfile(filename): #if file does not exist
        #Download fasta file from NCBI
        #completed genome
        link_handle = Entrez.elink(dbfrom="bioproject", db="nuccore", cmd="neighbor_history", id=(bioproject), linkname="bioproject_nuccore", term=limit)
        record = Entrez.read(link_handle)
        link_handle.close()

        #WebEnv and QueryKey are retrieved from elink. QueryKey is subset of LinkSetDbHistory
        fetch_handle=Entrez.efetch(db="nuccore", rettype="fasta", retmode="text", webenv=record[0]['WebEnv'], query_key=record[0]['LinkSetDbHistory'][0]['QueryKey'])
        out_handle = gzip.open(filename, "wt") #open file and write enable
        out_handle.write(fetch_handle.read()) #write output to file
        out_handle.close()
        fetch_handle.close()
        print ("Saved", (bioproject))
    else:
        print("Already saved", (bioproject))

if __name__ == "__main__": #enable module to run as script
    get_genseq()

#run W_regex.py in order to access module
