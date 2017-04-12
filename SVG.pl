#!usr/bin/perl -w
use strict;

use SVG;
use Data::Dumper;
use Getopt::Long;

my $type;
GetOptions(
                "type:s"=>\$type,
          );
$type ||= 'point';

die  "perl $0 <list> <size1> <size2> <out.svg> <zoom>\n" unless ($#ARGV==4);
my $in_list = shift;
my $in_sizea = shift;
my $in_sizeb = shift;
my $out_svg=shift;
my $zoom=shift;

my (%hash_sizea,%hash_sizeb);
my $xlen=0;
my $ylen=0;

open IN1,$in_sizea or die $!;
while (<IN1>)
{
        chomp;
        my @aa = split /\s+/;
        $hash_sizea{$aa[0]}[0] = $xlen;
        $xlen += $aa[1];
        $hash_sizea{$aa[0]}[1] = $xlen;  #chromA;size
}
close IN1;

open IN2,$in_sizeb or die $!;
while (<IN2>)
{
        chomp;
        my @aa =split /\s+/;
        $hash_sizeb{$aa[0]}[0]= $ylen;
        $ylen += $aa[1];
        $hash_sizeb{$aa[0]}[1]= $ylen;   #chromB;size
}
close IN2;

open IN3,$in_list or die $!;
my %hash_list;

while (<IN3>)
{
        chomp;
        my @aa = split /\s+/;
        $hash_list{$aa[0]}{$aa[1]} = [$aa[2],$aa[3],$aa[4],$aa[5]];
}
close IN3;

my $wide = 200+$xlen/$zoom;
my $height = 200+$ylen/$zoom;

my $svg = SVG->new('width',$wide,'height',$height);
$svg->rect('x',100,'y',100,'width',$xlen/$zoom,'height',$ylen/$zoom,'stroke','black','fill','none','stroke-width',1);

my $x=0;
foreach my $tem1(keys %hash_sizea)
{
        $x=$hash_sizea{$tem1}[1];
        my $x0 = $hash_sizea{$tem1}[0];
        $svg->line('x1',100+$x/$zoom,'y1',100,'x2',100+$x/$zoom,'y2',100+$ylen/$zoom,'stroke-width',1,'stroke','black');

#       $svg->text('x',100+($x+$x0)/10000,'y',50,'font-family', 'Arial', 'font-size',13,'text-anchor','middle', '-cdata',$tem1);
}

my $y=0;
foreach my $tem2(keys %hash_sizeb)
{
        $y=$hash_sizeb{$tem2}[1];
        my $y0=$hash_sizeb{$tem2}[0];
        $svg->line('x1',100,'y1',100+$y/$zoom,'x2',100+$xlen/$zoom,'y2',100+$y/$zoom,'stroke-width',0.1,'stroke','gray');

}
my $check = 1;
my $coordinateX = 100000;
my $coordinateY = 100000;

while ($coordinateX<$xlen)
{
        $svg->line('x1',100+$coordinateX/$zoom,'y1',100,'x2',100+$coordinateX/$zoom,'y2',94,'stroke-width',1,'stroke','black');
        if ($check%2 == 0)
        {
                my $coor = $coordinateX / 10000;
                $coor = $coor;
#               $svg->text('x',100+$coordinateX/$zoom,'y',95,'font-family','Arial','font-size','13','text-anchor','middle','-cdata',$coor);
        }
        $check++;
        $coordinateX +=100000;
}

$check = 1;
while ($coordinateY < $ylen)
{
        $svg->line('x1',100,'y1',100+$coordinateY/$zoom,'x2',94,'y2',100+$coordinateY/$zoom,'stroke-width','1','stroke','black');
        if ($check%2 == 0)
        {
                my $coor = $coordinateY / 10000;
                $coor = $coor;
#               $svg->text('x',95,'y',105+$coordinateY/$zoom,'font-family','Arial','font-size','13','text-anchor','end','-cdata',$coor);
        }
        $check ++;
        $coordinateY +=100000;
}






foreach my $tem3(keys %hash_list)
{
        foreach my $tem4(keys %{$hash_list{$tem3}})
        {
                my @cc = @{$hash_list{$tem3}{$tem4}};


                if (exists $hash_sizea{$tem3}[0] && exists $hash_sizeb{$cc[1]}[0])
                {
                        my $x1=($hash_sizea{$tem3}[0]+$tem4)/$zoom+100;
                        my $x2=($hash_sizea{$tem3}[0]+$cc[0])/$zoom+100;
                        my $y1=($hash_sizeb{$cc[1]}[0]+$cc[2])/$zoom+100;
                        my $y2=($hash_sizeb{$cc[1]}[0]+$cc[3])/$zoom+100;

                        my $color='red';
                        $svg->line('x1',$x1,'y1',$y1,'x2',$x2,'y2',$y2,'stroke-width',2,'stroke','red') if($type eq 'line');
                        $svg->circle('cx'=>$x1,'cy'=>$y1,'r'=>1,'stroke-width',0,'stroke',$color,'fill',$color) if($type eq 'point');

                }
        }
}

print "$xlen,$ylen\n";

open OUT,">$out_svg" or die $!;
my $out = $svg->xmlify;

print OUT "$out";
