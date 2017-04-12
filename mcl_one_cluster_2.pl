#!/usr/bin/perl
use Data::Dumper;
use Getopt::Long;

my $dis_cutof=300;## 1kp
my $cluster=10;
my $cover_cutof=1000;
my $mark="right";
GetOptions(
                "dis_cutof:n"=>\$dis_cutof,     ## the largest distance of a pair X or Y axis
                "cluster:n"=>\$cluster,## the least num of pairs of a cluster
                "cover_cutof:n"=>\$cover_cutof;
                "side:s"=>\$mark,        ## the scaffold side  right/left(defult)
                "help"=>\$Help
          );

open IN,$ARGV[0] or die "$!";
my %lines;
my $id=1;
my %array;
while(<IN>){
        chomp;
        my @f=split;
        $lines{$id}=$_;
        $list{$f[3]}{$f[0]}{$id}=1;
        $id++;
}
close IN;


my %check;
my %pair;
my %check_all;
foreach my $scaffold(keys %list){
#       print STDERR "$scaffold start to mcl ...\n";
        %pair=();
        foreach my $chr(keys %{$list{$scaffold}}){
                my %list_sub=%{$list{$scaffold}{$chr}};
#               %pair=();
                foreach my $key1(keys %list_sub){
                        foreach my $key2(keys %list_sub){
                                push @{$pair{$key1}},$key2 if(&is_pair($key1,$key2));
                        }
                }
        }
#       print  Dumper \%pair;

        my %out;
        my $cluster_num=1;
        %check_all=();
        %check=();
        foreach my $key (keys %pair){
                next if($check_all{$key});
                %check=();
                my @aa=@{$pair{$key}};
                for my $aa(@aa){
                        $check{$aa}=1;
                        $check_all{$aa}=1;
                }
                for my $aa (@aa){
                        &check($aa);
                }
                my @id=keys %check;
#               next if(@id<$cluster);
                @id=sort {$a<=>$b}@id;
                $out{$cluster_num}=[@id];
                $cluster_num++;
        }

#       print Dumper \%out;


        my @out_num;
        foreach my $key(keys %out){
                my $num=@{$out{$key}};
                push @out_num,[$key,$num];
        }

        @out_num=sort {$b->[1]<=>$a->[1]}@out_num;
        my $max_num=$out_num[0][1];
        my @out_cover;
        for(my $i=0;$i<=$#out_num;$i++){
#               next if($out_num[$i][1]<$max_num);
                my @id=@{$out{$out_num[$i][0]}};
                my @st_en;
                for my $id(@id){
                        my @e=split(/\s+/,$lines{$id});
                        if($mark='left'){
                                ($e[1],$e[2])=($e[2],$e[1]) if($e[1]>$e[2]);
                                push @st_en,[$e[1],$e[2]];
                        }else{
                                ($e[4],$e[5])=($e[5],$e[4]) if($e[4]>$e[5]);
                                push @st_en,[$e[4],$e[5]];
                        }
                }
                my $cover=cover(\@st_en);
                push @out_cover,[$out_num[$i][0],$cover];
        }
        @out_cover=sort {$b->[1]<=>$a->[1]}@out_cover;
                                                                        for(my $i=0;$i<=$#out_cover;$i++){

                                                                                if($out_cover[$i][1]>=$cover_cutof or $i==0){
                                                                                        my @id=@{$out{$out_cover[$i][0]}};
                                                                                        for my $id(@id){
                                                                                                print $lines{$id},"\n";
                                                                                        }
                                                                                }
                                                                        }
        #my @id=@{$out{$out_cover[0][0]}};
#       print  Dumper \@out_cover;
        #for my $id(@id){
                #print  $lines{$id},"\n";
        #}
#       print STDERR "$scaffold finished  ...\n";
}

sub cover{
        my $arr=shift;
        my @aa=@$arr;
        my $cover_len;
        @aa=sort{$a->[0]<=>$b->[0]}@aa;
        my $start=$aa[0][0];
        my $end=$aa[0][1];
        for(my $i=1;$i<@aa;$i++){
                if($aa[$i][0]>$end){
                        $cover_len+=($end-$start+1);
                        $start=$aa[$i][0];
                        $end=$aa[$i][1];
                }
                if($aa[$i][0]<=$end){
                        $end=($aa[$i][1]>$end)?$aa[$i][1]:$end;
                }
        }
        $cover_len+=($end-$start+1);
        return $cover_len;
}



sub check{
        my $cc=shift;
        my @cc=@{$pair{$cc}};
        for $bb(@cc){
                unless(defined $check{$bb}){
                        $check_all{$bb}=1;
                        $check{$bb}=1;
                        &check($bb);
                }
        }
}


sub is_pair{
        my $id1=shift;
        my $id2=shift;
        my $is_pair=0;
        my $line1=$lines{$id1};
        my $line2=$lines{$id2};
        my @aa=split(/\t/,$line1);
        my @bb=split(/\t/,$line2);
        $is_pair=1 if(abs($aa[1]-$bb[1])<$dis_cutof && abs($aa[4]-$bb[4])<$dis_cutof);
        $is_pair=1 if(abs($aa[2]-$bb[1])<$dis_cutof && abs($aa[5]-$bb[4])<$dis_cutof);
        $is_pair=1 if(abs($aa[2]-$bb[2])<$dis_cutof && abs($aa[5]-$bb[5])<$dis_cutof);
        $is_pair=1 if(abs($aa[1]-$bb[2])<$dis_cutof && abs($aa[4]-$bb[5])<$dis_cutof);
        return $is_pair;
}

