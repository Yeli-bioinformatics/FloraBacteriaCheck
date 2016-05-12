#!/usr/bin/perl

use strict;
use List::Util qw /sum max min/;

open F1,"$ARGV[0]" or die "can't open the file:$!";
readline F1;
my $title=readline F1;
my @samplename=split "\t",$title;
shift @samplename;
pop @samplename;
my %hash;
my %hashb;
my %otu_anno;
my $sample_num;
$otu_anno{"k__Bacteria"}++;

while(<F1>){
	chomp();
	if(/\tUnclassified/){
		next;	
	}
	my @aa=split "\t";
	my @bb=split "; ",$aa[-1];
	$sample_num=(scalar @aa) - 2;

	my $index=0;
	foreach my $term (keys %otu_anno){
		if($term=~/\w/){
			if($term=~/^\Q$aa[-1]/){
				$index=1;
				last;
			}
			elsif($aa[-1]=~/^\Q$term/){
				delete $otu_anno{$term};
				$otu_anno{$aa[-1]}++;
				$index=1;
				last;
     			}
     		}
	 }

	if($index==0){
		$otu_anno{$aa[-1]}++;
	}
	my $term="";
	for(my $i=1;$i<=scalar @bb;$i++){
		$term.=$bb[$i-1]."; ";
		for(my $k=1;$k<=$sample_num; $k++){
#			$hashb{$i."_".$bb[$i-1]}[$k-1]+=$aa[$k];
			$hashb{$term}[$k-1]+=$aa[$k];
		}
	}
}

foreach my $i(keys %otu_anno){
	my @bb=split "; ",$i;
	if(scalar @bb == 1){
		$hash{$bb[0]}=1;
	}
	elsif(scalar @bb == 2){
#		$hash{"1_".$bb[0]}{"2_".$bb[1]}=1;
		$hash{$bb[0]}{$bb[1]}=1;
	}
	elsif(scalar @bb == 3){
#		$hash{"1_".$bb[0]}{"2_".$bb[1]}{"3_".$bb[2]}=1;
		$hash{$bb[0]}{$bb[1]}{$bb[2]}=1;
	}
	elsif(scalar @bb == 4){
#		$hash{"1_".$bb[0]}{"2_".$bb[1]}{"3_".$bb[2]}{"4_".$bb[3]}=1;
		$hash{$bb[0]}{$bb[1]}{$bb[2]}{$bb[3]}=1;
	}
	elsif(scalar @bb == 5){
#		$hash{"1_".$bb[0]}{"2_".$bb[1]}{"3_".$bb[2]}{"4_".$bb[3]}{"5_".$bb[4]}++;
		$hash{$bb[0]}{$bb[1]}{$bb[2]}{$bb[3]}{$bb[4]}++;
	}
	elsif(scalar @bb == 6){
#		$hash{"1_".$bb[0]}{"2_".$bb[1]}{"3_".$bb[2]}{"4_".$bb[3]}{"5_".$bb[4]}{"6_".$bb[5]}++;
		$hash{$bb[0]}{$bb[1]}{$bb[2]}{$bb[3]}{$bb[4]}{$bb[5]}++;
	}
	else{   
#		$hash{"1_".$bb[0]}{"2_".$bb[1]}{"3_".$bb[2]}{"4_".$bb[3]}{"5_".$bb[4]}{"6_".$bb[5]}{"7_".$bb[6]}++;
		$hash{$bb[0]}{$bb[1]}{$bb[2]}{$bb[3]}{$bb[4]}{$bb[5]}{$bb[6]}++;
	}
}

print "taxlevel\trankID\ttaxon\t",join "\t",@samplename,"Total\n";
my $num_1=0;
foreach my $a (keys %hash){
	$num_1++;
#	print "Kingdom\t0\.$num_1\t",$a,"\t",join "\t",@{$hashb{$a}},"\t",sum(@{$hashb{$a}}),"\n";
	print "Kingdom\t0\.$num_1\t",$a,"\t",(join "\t",@{$hashb{$a."; "}}),"\t",sum(@{$hashb{$a."; "}}),"\n";
		if(defined ($hash{$a})&&($hash{$a} != 1)){
		my $num_2=0;
		foreach my $b (keys %{$hash{$a}}){
			$num_2++;
#			print "Phylum\t0\.$num_1\.$num_2\t",$b,"\t",join "\t",@{$hashb{$b}},"\t",sum(@{$hashb{$b}}),"\n";
			print "Phylum\t0\.$num_1\.$num_2\t",$b,"\t",(join "\t",@{$hashb{$a."; ".$b."; "}}),"\t",sum(@{$hashb{$a."; ".$b."; "}}),"\n";
			if(defined ($hash{$a}{$b}) && ($hash{$a}{$b} !=1)){
			my $num_3=0;
			foreach my $c (keys %{$hash{$a}{$b}}){
				$num_3++;
#				print "Class\t0\.$num_1\.$num_2\.$num_3\t",$c,"\t",	join "\t",@{$hashb{$c}},"\t",sum (@{$hashb{$c}}),"\n";
				print "Class\t0\.$num_1\.$num_2\.$num_3\t",$c,"\t",(join "\t",@{$hashb{$a."; ".$b."; ".$c."; "}}),"\t",sum (@{$hashb{$a."; ".$b."; ".$c."; "}}),"\n";
				if(defined ($hash{$a}{$b}{$c}) && ($hash{$a}{$b}{$c} != 1)){
				my $num_4=0;
				foreach my $d (keys %{$hash{$a}{$b}{$c}}){
						$num_4++;
#						print "Order\t0\.$num_1\.$num_2\.$num_3\.$num_4\t",$d,"\t",join "\t",@{$hashb{$d}},"\t",sum(@{$hashb{$d}}),"\n";
						print "Order\t0\.$num_1\.$num_2\.$num_3\.$num_4\t",$d,"\t",(join "\t",@{$hashb{$a."; ".$b."; ".$c."; ".$d."; "}}),"\t",sum(@{$hashb{$a."; ".$b."; ".$c."; ".$d."; "}}),"\n";
						if(defined ($hash{$a}{$b}{$c}{$d}) && ($hash{$a}{$b}{$c}{$d} !=1)){
						my $num_5;
						foreach my $e (keys %{$hash{$a}{$b}{$c}{$d}}){
							$num_5++;
#							print "Family\t0\.$num_1\.$num_2\.$num_3\.$num_4\.$num_5\t",$e,"\t",	join "\t",@{$hashb{$e}},"\t",sum(@{$hashb{$e}}),"\n";
							print "Family\t0\.$num_1\.$num_2\.$num_3\.$num_4\.$num_5\t",$e,"\t",(join "\t",@{$hashb{$a."; ".$b."; ".$c."; ".$d."; ".$e."; "}}),"\t",sum(@{$hashb{$a."; ".$b."; ".$c."; ".$d."; ".$e."; "}}),"\n";
							if(defined ($hash{$a}{$b}{$c}{$d}{$e}) && ($hash{$a}{$b}{$c}{$d}{$e}!=1) ){
							my $num_6;
							foreach my $f (keys %{$hash{$a}{$b}{$c}{$d}{$e}}){
								$num_6++;
#								print "Genus\t0\.$num_1\.$num_2\.$num_3\.$num_4\.$num_5\.$num_6\t",$f,"\t",	join "\t",@{$hashb{$f}},"\t",sum(@{$hashb{$f}}),"\n";
								print "Genus\t0\.$num_1\.$num_2\.$num_3\.$num_4\.$num_5\.$num_6\t",$f,"\t",(join "\t",@{$hashb{$a."; ".$b."; ".$c."; ".$d."; ".$e."; ".$f."; "}}),"\t",sum(@{$hashb{$a."; ".$b."; ".$c."; ".$d."; ".$e."; ".$f."; "}}),"\n";
								if(defined ($hash{$a}{$b}{$c}{$d}{$e}{$f}) && ($hash{$a}{$b}{$c}{$d}{$e}{$f} !=1)){
								my $num_7=0;
								foreach my $g (keys %{$hash{$a}{$b}{$c}{$d}{$e}{$f}}){
										$num_7++;
#										print "Type\t0\.$num_1\.$num_2\.$num_3\.$num_4\.$num_5\.$num_6\.$num_7\t",$g,"\t",	join "\t",@{$hashb{$g}},"\t",sum(@{$hashb{$g}}),"\n";
										print "Type\t0\.$num_1\.$num_2\.$num_3\.$num_4\.$num_5\.$num_6\.$num_7\t",$g,"\t",(join "\t",@{$hashb{$a."; ".$b."; ".$c."; ".$d."; ".$e."; ".$f."; ".$g."; "}}),"\t",sum(@{$hashb{$a."; ".$b."; ".$c."; ".$d."; ".$e."; ".$f."; ".$g."; "}}),"\n";
									}
								}
							}
						}
					}
				}
				}
			}
			}
		}
		}
	}
}
