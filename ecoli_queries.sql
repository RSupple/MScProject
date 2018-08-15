/*sample queries for database.
retrieves taxid, scientific name and genbank genes whose number of gb genes are < 5000 and the genus is shigella
*/

SELECT taxid, sci_name, gb_genes 
FROM taxonomy 
LEFT JOIN organism 
ON bpid=bio_id 
WHERE gb_genes < 5000 
AND genus = 'Shigella';

/*
retrieves BPID, taxid and genbank genes and scientific name with more than one taxid i.e. retrieves BPIDs sharing same taxid
*/

SELECT bio_id, taxid, gb_genes, sci_name 
FROM taxonomy 
LEFT JOIN organism 
ON bio_id = bpid 
GROUP BY taxid 
HAVING count(*) >1;




