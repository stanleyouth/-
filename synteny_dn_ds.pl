#!/usr/bin/perl -w
use strict;

## two input files :  gff_file providing coordinate information for each genes,
##                    synteny_file with ka and ks added, providing ka and ks value.

my $gff=shift;
my $syn=shift;

my (%gene_start,%gene_end,%gene_chr);
open GFF,$gff or die $!;
while(<GFF>){
        chomp;my @inf=split;
        next unless $inf[2] eq "mRNA";
        my $id; if($inf[-1]=~/ID=([^;\s]+)/){$id=$1;}
        ($inf[3],$inf[4])=($inf[4],$inf[3]) if $inf[3]>$inf[4];
        $gene_start{$id}=$inf[3];
        $gene_end{$id}=$inf[4];
        $gene_chr{$id}=$inf[0];
}
close GFF;

my $block_line_index=0;
my ($chr1,$syn1_s,$syn1_e,$chr2,$syn2_s,$syn2_e,$dn_ds)=(0,0,0,0,0,0,0);
open SYN,$syn or die $!;
while(<SYN>){
        chomp;
        my $line=$_;
        if($line=~/^#/){
                if($block_line_index ne 0){
                        my $line="$chr1\t$syn1_s\t$syn1_e\t$chr2\t$syn2_s\t$syn2_e\t$dn_ds\n";
                #       print $line;
                        $block_line_index=0;
                }else{
                        next;
                }
        }else{
                my @inf=split("\t",$line);
                if($block_line_index ne 0){
                        $block_line_index+=1;
                        $syn1_s = $gene_start{$inf[1]} if $syn1_s > $gene_start{$inf[1]};
                        $syn1_e = $gene_end{$inf[1]}   if $syn1_e < $gene_end{$inf[1]};
                        $syn2_s = $gene_start{$inf[2]} if $syn2_s > $gene_start{$inf[2]};
                        $syn2_e = $gene_end{$inf[2]}   if $syn2_e < $gene_end{$inf[2]};
                        $dn_ds=log($inf[-2]/($inf[-1]+0.00001)+0.00001);
                }else{
                        $block_line_index+=1;
                        $syn1_s = $gene_start{$inf[1]};
                        $syn1_e = $gene_end{$inf[1]};
                        $syn2_s = $gene_start{$inf[2]};
                        $syn2_e = $gene_end{$inf[2]};
                        $chr1 = $gene_chr{$inf[1]};
                        $chr2 = $gene_chr{$inf[2]};
                        $dn_ds=log($inf[-2]/($inf[-1]+0.00001)+0.00001);
                }
                my ($chr1,$start1,$end1,$chr2,$start2,$end2,$log_dn_ds)=(0,0,0,0,0,0,0);
                $start1=$gene_start{$inf[1]};
                $end1=$gene_end{$inf[1]};
                $start2=$gene_start{$inf[2]};
                $end2=$gene_end{$inf[2]};
                $chr1=$gene_chr{$inf[1]};
                $chr2=$gene_chr{$inf[2]};
                $log_dn_ds=log($inf[-2]/($inf[-1]+0.00001)+0.00001);
                print "$chr1\t$start1\t$end1\t$chr2\t$start2\t$end2\t$log_dn_ds\n";
        }
}
close SYN;
#my $line="$chr1\t$syn1_s\t$syn1_e\t$chr2\t$syn2_s\t$syn2_e\n";
#print $line;
