
##    Scripts

---------
---------
### N50.py
The first python script I write, to implememt the length summary and statistics of a fasta file (genome).
<br>
can be used like :
```bash
python N50.py fasta [10|20|30..|90]   ## if the last argument is missing, then a whole summary is generated.
```
---------
---------
### Pseudochromosome assembly or scaffold length improove with a reference
Pseudochromosome assembly with a chromosome-level genome reference of a very close related species.<br> 
This pipeline is based a pipeline which graphically display the homogenicity between two genomes. I went one step further to improove the genome whose average length is shorter according the genome whose is longer.<br>
This pipe require a usable MUMmer and works in this order:
```bash
    nucmer -p  prefix ref query   ### ref and query represents two genome sequnce files, the only two oringal inputs
    perl delta2list.pl prefix.delta ref.size query.size > ref_query.list
    perl mcl_one_cluster.pl ref_query.list > ref_query.list.mcl
    perl cat_pseudochromosome.pl ref_query.list.mcl ref.size query improoved.results
```   
----------
----------
### homologous block screening.
There are three steps.
1. Mapping Query genome to reference genome using nucmer in MUMmer package, and extract information from DELTA format outputs.<br>
2. Mergeing homologous blocks. The rule is below and three involved threshold need to be customerized in mcl_one_cluster.pl is descripted:<br>
![image](https://github.com/stanleyouth/-/blob/master/how_synteny_works.png)<br>
a. sort original alignment blocks acoording to ref coordinates and then query coordinates.<br>
b. merge blocks in a cluster if d and D is smaller than threshold [-dis_cutof].<br>
c. if both ΣR and ΣQ of this cluster is bigger than threshold [-cover_cutof], and number of alignments in this block (n) is bigger than threshold [-cluster],then this whole cluster passes this filtering.<br>
3. Output a svg file which display these clusters in physical order. In this SVG.pl a parameter can be set to adjust canvas size. Genome size/parameter=canvas width or length in pixel.

shell commands should run like this example. Please download involved perl scripts in this folder by hand.

``` 
## mapping, make sure you have nucmer ready to go.
nucmer  -c 100 -p prefix   ref_genome   query_genome
perl delta2list.pl  prefix.delta ref.size query.size >  ref_query.list


## merge cluster and filtering
perl  mcl_one_cluster.pl   [options]   ref_query.list  > ref_query.list.mcl


## sort according to coordinates and draw SVG.
perl  order.pl  ref_query.list.mcl  ref.size  query.size   > ref_query.list.mcl.order
perl  SVG.pl  ref_query.list  ref.size  ref_query.list.mcl.order  ref_query.list.mcl.svg  50000

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


----------
----------
### design sgRNAs for a specific sequence with reference genome available
This scripts lists candidate sgRNAs. Further selection is needed to shorten the list, according to GC content and other restrictions. An example is given below, sg_RNA_length is the length of sgRNA, while query and genome is the interested gene sequence and the reference genome sequence respectively. A file named query_sg_RNA_length.sg_RNA.targs will be generated, restoring all possible sgRNAs.
```bash
perl  crispr.sgRNA.finder.pl  query    genome    sg_RNA_length
```


---------
---------
### will be more
