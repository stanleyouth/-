#!/usr/bin/perl
=head
        perl sgRNAfinder.pl  query.fasta  genome.fasta  sgRNA_length
		
		output "Seq_name\tSequence\tStart\tEnd\tStrand\tGC\tTarget_sites\n";

=cut


use strict;
use warnings;
use Getopt::Long;


###########Read from the fasta file#################################
my $targ_fa=shift;
open IN1,"$targ_fa"||die ("inputfile $ARGV[0] cannot open $!");
$/=">";	<IN1>;
my %targ_seq;
while(my $line1=<IN1>){
	chomp($line1);
	my @inf=split(/\n/,$line1);
	my @tmp_header=split(/\s+/,(shift @inf));
	my $seq=join "",@inf;
	
	$seq=~ s/\s//g;
	$seq= uc($seq);
	$targ_seq{$tmp_header[0]}=$seq;	
}
close IN1;


my %genome_seq;
my $geno_fa=shift;
open IN2, "$geno_fa" or die $!;
$/=">";<IN2>;$/="\n";
while(my $id=<IN2>){
	if($id=~/(\S+)/){
		$id=$1;
	}
	$/=">";
	my $seq=<IN2>;
	chomp $seq;
	$/="\n";
	$seq=~s/\s//g;
	$genome_seq{$id}=uc($seq);
}
close IN2;
print "here1\n";


my $sg_RNA_length=shift;
open OUT, "> $targ_fa\_$sg_RNA_length.sg_RNA.targs " or die $!;
my %sg_RNA;
my $sg_count=0;
$sg_RNA_length-=3;
for my $gene(keys %targ_seq){
	my $seq=$targ_seq{$gene};
	for(my $i=1;$i+$sg_RNA_length+3-1<=length($seq);$i+=1){
		my $subseq=substr($seq,$i-1,$sg_RNA_length+3);
		next if $subseq=~/N/;
		if($subseq=~/GG$/){
			$sg_count+=1;
			$sg_RNA{$sg_count}{"gene"}=$gene;
			$sg_RNA{$sg_count}{"seq"}=$subseq;
			my $end=$i+$sg_RNA_length+3-1;
			$sg_RNA{$sg_count}{'end'}=$end;
			$sg_RNA{$sg_count}{'start'}=$i;
			$sg_RNA{$sg_count}{'orient'}="+";
		}elsif($subseq=~/^CC/){
			$sg_count+=1;
			$sg_RNA{$sg_count}{"gene"}=$gene;
			my $reverse=reverse($subseq);
			$reverse=~tr/ATCG/TAGC/;
			$sg_RNA{$sg_count}{"seq"}=$reverse;
			my $end=$i+$sg_RNA_length+3-1;
			$sg_RNA{$sg_count}{'end'}=$end;
			$sg_RNA{$sg_count}{'start'}=$i;
			$sg_RNA{$sg_count}{'orient'}="-";
		}
	}
}
print "here2\n";


for my $count (keys %sg_RNA) {
	my $sg_RNA=$sg_RNA{$count}{"seq"};
	my $rev=reverse($sg_RNA);
	$rev=~tr/ATCG/TAGC/;
	for my $chr(keys %genome_seq){
		print "$chr\n";
		my $chr_seq=$genome_seq{$chr};
		while($chr_seq=~m/($sg_RNA)/g){
			my $pos=pos($chr_seq);
			if(! exists $sg_RNA{$count}{"offtarg"}){
				$sg_RNA{$count}{"offtarg"}="";
			}
			$sg_RNA{$count}{"offtarg"}.="$chr\_+\_$pos ";
		}
		
		while($chr_seq=~m/($rev)/g){
			my $pos=pos($chr_seq);
			if(! exists $sg_RNA{$count}{"offtarg"}){
				$sg_RNA{$count}{"offtarg"}="";
			}
			$sg_RNA{$count}{"offtarg"}.="$chr\_-\_$pos ";;
		}
	}
	my ($gene,$seq,$start,$end,$orien,$offtargs)=($sg_RNA{$count}{"gene"},$sg_RNA{$count}{"seq"},$sg_RNA{$count}{"start"},$sg_RNA{$count}{"end"},$sg_RNA{$count}{"orient"},$sg_RNA{$count}{"offtarg"});
	if($orien eq "+"){
		$sg_RNA{$count}{"seq"}=~s/GG$//;
	}elsif($orien eq "-"){
		$sg_RNA{$count}{"seq"}=~s/^CC//;
	} 
	my $GC=$sg_RNA{$count}{"seq"}=~tr/[GC]//;

	print OUT  "$gene\t$seq\t$start\t$end\t$orien\t$GC\t$offtargs\n";
}


