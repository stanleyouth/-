#!/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;

my ($m4,$ext_length);

GetOptions(
'm4=s'=>\$m4,
'extend_len=s'=>\$ext_length,
);

open IN,$m4 or die $!;
$/="\n\n\n\n";<IN>;<IN>;<IN>;$/="\n";
while(<IN>){
	chomp;
	my $line=$_;
	if($line=~/^$/){
			$/="\n\n\n\n";
			<IN>;
			$/="\n";
			next;
	}
	my $query=$line;
	$/="\n\n";
	my $db=<IN>;
	chomp $db;
	$/="\n";
#	print "$query\n$db\n";exit;
	my $cns=&find_indel($query,$db,$ext_length);
	print $cns."\n";
	next;
}

sub find_indel{
	my ($query,$db,$ext_l)=@_;
	$query=~s/\s+\S+$//;
	my @db_raw=split("\n",$db);
#	print Dumper @db_raw;
	my @db;
	foreach my $db_line(@db_raw){
		$db_line=~s/\s+\S+$//;
		push @db,$db_line;
	}
	my %posi;
	my $count=0;
#	my @all;
#	push @all,(@db,$query);
#	print Dumper @all;
	for my $find_dash_line(($query,@db)){
		$count++;
		while($find_dash_line=~/-/g){
			my $posi=pos($find_dash_line);
		#	print $posi."\n";
			push @{$posi{$count}},$posi-1;
		}
		
	}
#	print Dumper %posi;
#	print "\n\n\n";
	my $posi_p=\%posi;
## break point

	my %region=&merge($ext_l,$posi_p);
	my $region=\%region;
	my $db_2=\@db;
	my $cns_seq=&cns($region,$query,$db_2);
	return $cns_seq;
}

sub merge{
	my ($ext,$position)=@_;
	my %posi=%{$position};
#	print Dumper %posi;
	my %groups;
	my @a;
	for my $key( keys %posi){
		my @loc=@{$posi{$key}};
		my @loc_s=sort{$a<=>$b}@loc;
			push @a,@loc_s;
	}
	@a=sort{$a<=>$b}@a;
#	print Dumper @a;
	my @group_b;
	push @group_b,0;
	#print $#a;
	for (my $i=0;$i<$#a;$i++){
		if($a[$i+1]-$a[$i]<=$ext){
			next;
		}else{
			push @group_b,$i+1;
		}
	}
#	print Dumper @group_b;
	push @group_b,$#a+1;
#	print Dumper @group_b;
	my $boundry_count=0;
	for(my $i=0;$i<$#group_b;$i++){
		$boundry_count++;
		push @{$groups{$boundry_count}},($a[$group_b[$i]],$a[$group_b[$i+1]-1]);
	}
#	print Dumper %groups;
#	print"\n\n\n";
	return %groups;	
}

sub cns{
	my ($region,$query,$db)=@_;
	my %region=%{$region};
	my %cns_to_query;
	my @db=@{$db};
	my @key=keys %region;
	@key=sort{$a<=>$b}@key;
#	print Dumper @key;
#	print Dumper %region;
	for my $key( @key ){
		my @b=@{$region{$key}};
		my @polymo;
		for my $line(@db){
			my $Localseq=substr($line,$b[0],$b[1]-$b[0]+1);
			$Localseq=~s/\s//g;
			push @polymo,$Localseq if length($Localseq)>=1;
		}
		my %freq;
		for my $line_2(@polymo){
			$line_2=~s/-//g;
			$line_2="Del" if ($line_2 eq "");
			$freq{$line_2}++;
		}
#		print  Dumper %freq;
		my @freq_s=sort { $freq{$b} <=> $freq{$a} } keys %freq;
#		print Dumper @freq_s;
		push @{$cns_to_query{$key}},(@b,$freq_s[0]);
#		print $freq{$freq_s[0]}."\n\n";
	}
	my $start=0;
	my $cns;
#	print Dumper %cns_to_query;
	for my $key_2( @key ){
		$cns.=substr($query,$start,$cns_to_query{$key_2}[0]-$start);
		$cns_to_query{$key_2}[2]="" if($cns_to_query{$key_2}[2] eq "Del");
#		print $cns_to_query{$key_2}[2]."\n\n";
		$cns.=$cns_to_query{$key_2}[2];
		$start=$cns_to_query{$key_2}[1]+1;
	}
	$cns.=substr($query,$start,);
	$cns=~s/^\S+\s+\S+\s+//;
	return $cns;
}



