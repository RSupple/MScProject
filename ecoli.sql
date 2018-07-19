-- Table taxonomy
CREATE TABLE taxonomy 
(	bio_id		 INT			 NOT NULL,
		CHECK (1 <= bio_id <= 99999),
	taxid		 INT 			 NOT NULL,
		CHECK (100000 <= taxid <= 999999), 
	sci_name	 VARCHAR (50)		 NOT NULL,
	genus		 VARCHAR (15)		 NOT NULL,
	species		 VARCHAR (30)		 NOT NULL,
	non_rank_1	 VARCHAR (30),		
	non_rank_2	 VARCHAR (50),		
	PRIMARY KEY (bio_id)	
);




-- Table organism
CREATE TABLE organism 
(	bpid	 	 INT 			 NOT NULL,
		CHECK (1 <= bpid <= 99999),
	contigs		 INT 			 NOT NULL,
		CHECK (1 <= contigs <= 5000),
	gb_genes	 INT			 DEFAULT '0',
		CHECK (0 <= gb_genes <= 20000),			
	p_genes		 INT 			 NOT NULL,
		CHECK (0 <= p_genes <= 20000),
	gen_length	 INT 			 NOT NULL,
		CHECK (4000000 <= gen_length <= 20000000),
	PRIMARY KEY (bpid),
	FOREIGN KEY (bpid) REFERENCES taxonomy (bio_id)
);





