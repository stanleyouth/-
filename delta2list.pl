#!/usr/bin/perl
die "perl $0 <delta> <size_out1> <size_out2>\n" unless ($#ARGV==2);
open DELTA,$ARGV[0] or die "$!";
my (%hash_ref,%hash_query);
my ($ref_id,$query_id);
while(<DELTA>){
	chomp;
	if($_=~/^>/){
		my @inf=split;
		$ref_id=substr($inf[0],1);
		$query_id=$inf[1];
		$hash_ref{$ref_id}=$inf[2];
		$hash_query{$inf[1]}=$inf[3];
		next;
	}
	my @inf=split;
	next unless(@inf==7);
	print "$ref_id\t$inf[0]\t$inf[1]\t$query_id\t$inf[2]\t$inf[3]\n";	
}
close DELTA;
open REF,">$ARGV[1]" or die "can't create $!";
my @ref;
foreach my $id(keys %hash_ref){
	push @ref,[$id,$hash_ref{$id}];
}
%hash_ref=();
@ref=sort{$b->[1]<=>$a->[1]}@ref;
for (my $i=0;$i<@ref;$i++){
	print REF "$ref[$i][0]\t$ref[$i][1]\n";
}
@ref=();
close REF;
open QUE,">$ARGV[2]" or die "can't create $!";
my @query;
foreach my $id(keys %hash_query){
	push @query,[$id,$hash_query{$id}];
}
%hash_query=();
@query=sort{$b->[1]<=>$a->[1]}@query;
for (my $i=0;$i<@query;$i++){
	print QUE "$query[$i][0]\t$query[$i][1]\n";
}
@query=();
close QUE;
