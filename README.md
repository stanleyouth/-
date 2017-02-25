# -
##    Scripts and sundries used in genome assembly and annotation
##    一些小功能的脚本实现
##### This repo includs scripts I typed during my research about genomics.
---------
---------
### N50.py
This scripts is the first python I write, to implememt the length summary and statistics of a fasta file (genome).
<br>
can be used like :
```bash
python N50.py fasta [10|20|30..|90]   ## if the last argument is missing, then a whole summary is generated.
```
---------
---------
### Pseudochromosome assembly or scaffold length improove with a reference
Pseudochromosome assembly with a chromosome-level genome reference of a very close related species.<br> 
This pipeline is based a pipeline which graphically display the synteny between two genomes. I went one step further to improove the genome whose average length is shorter according the genome whose is longer.<br>
This pipe require a usable MUMmer and works in this order:
```bash
    nucmer -p  prefix ref query   ### ref and query represents two genome sequnce files, the only two oringal inputs
    perl delta2list.pl prefix.delta ref.size query.size > ref_query.list
    perl mcl_one_cluster.pl ref_query.list > ref_query.list.mcl
    perl cat_pseudochromosome.pl ref_query.list.mcl ref.size query improoved.results
```    
----------
----------
### Correct small InDels in a genome, using cDNA, clean reads in fastq format or reliable contigs assembled using NGS data
Third generation sequencing tech facilitates complex genome assemble, and improoved the quality of many genome.
However genomes assembled from these erronuos long reads inherited the drawbacks of long reads.
We observed the small InDel occurency is about one in every 100-1000 bp.
Many error correction applications are developed, mostly based on mapping NGS data to genome, which may cost weeks.
This script calls small InDels from blast results and output a corrected results.<br>
This scripts can also be used to generate a consensus sequence from multi similiar sequences.
Properly alter blast2consensus.config before you run:
```bash
sh blast2consensus.sh <1|2|3|4>  ### 1,2,3,4 represents four steps of this script
```
---------
---------
### will be more