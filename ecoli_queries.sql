SELECT taxid, sci_name, gb_genes 
FROM taxonomy 
LEFT JOIN organism 
ON bpid=bio_id 
WHERE gb_genes < 5000 
AND genus = 'Shigella';




SELECT bio_id, taxid, gb_genes, sci_name 
FROM taxonomy 
LEFT JOIN organism 
ON bio_id = bpid 
GROUP BY taxid 
HAVING count(*) >1;




