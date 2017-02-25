##-------------------------------------------------------------------------------------------------------
#####################   required fields 								|
#####################	fill this part properly								|
##													|
## run settings												|
genome=genome.fa # needs correction
reads=reliable.fa  # whatever reliable sequences
tmpdir=/path/to/your/workdir   	## dir where you want to output logs, intermediate and final results
T='20'        			## threads, ie. the number of files the genome is going to be divided into.
extend_len='5'
##													|
## environment config											|
blastn=/path/to/bin/blastn	##				
makedb=/path/to/binmakeblastdb	##			
bin=/path/to/the/perl-scripts/  ## dir where involved perl scripts are stored.		|
##-------------------------------------------------------------------------------------------------------



#################### keep this part intact 
###################


cd $tmpdir;
idx=$reads.idx
step=$1;



##--------------------------------STEP 1-------------------------------------------------------------------------
ln -s $genome ./
if [ $step == 1 ]; then
a=`grep ">" $genome | wc -l`
((s=$a/$T+1))

if [ -f $tmpdir/blast.commands.all ]; then
rm $tmpdir/blast.commands.all
fi
if [ -f $tmpdir/shell.list.all ]; then
rm $tmpdir/shell.list.all
fi

#perl $bin/split.pl $s $genome $tmpdir  # spliting genome
cat $tmpdir/fa.list | while read line ;do 

## generating all blast commands
cat >> $tmpdir/blast.commands.all << EOF
$blastn -num_threads 2  -outfmt 4 -db $idx -query $line -out $line.blast.m4
perl $bin/find_indel.pl -m4  $line.blast.m4  -extend_len $extend_len  $line.cns
EOF

## generating fofn of blast shell scripts
cat >> $tmpdir/shell.list.all << EOF
$line.qsub.sh
EOF

## generating individual blast work shell
cat > $line.qsub.sh << EOF
$blastn -num_threads 2 -outfmt 4 -db $idx -query $line -out $line.blast.m4
perl $bin/find_indel.pl -m4  $line.blast.m4 -extend_len  $extend_len  $line.cns
EOF
done
fi
##---------------------------------------------------------------------------------------------------------





##---------------------------------STEP 2------------------------------------------------------------------------
if [ $step == 2 ]; then
$makedb  -in  $reads -out  $idx  -dbtype  nucl
# or cat this command into a shell and qsub.
fi
##---------------------------------------------------------------------------------------------------------





##---------------------------------STEP 3------------------------------------------------------------------------
##----------------------------------- massive computing --------------------------------------------------
if [ $step == 3 ]; then
cat  $tmpdir/shell.list.all  | while read line ; do
qsub $line
sleep 1
done
fi
##---------------------------------------------------------------------------------------------------------




##---------------------------------STEP 4------------------------------------------------------------------------
##-------------------------------------- final step, cat results together---------------------------------------
###########    cat results
if [ $step == 4 ]; then
cat $tmpdir/*cut/*.cns > $tmpdir/final.results.cns.fa
fi
##---------------------------------------------------------------------------------------------------------


