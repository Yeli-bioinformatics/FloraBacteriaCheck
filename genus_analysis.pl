#!/usr/bin/perl

use strict;

open TREE,"$ARGV[0]" or die "can't  open the file:$!";
open BTYPE,">$ARGV[1]" or die "can't open the file:$!";
open GENUS,">$ARGV[2]" or die "can't open the file:$!";

<TREE>;
my %genus;
my $genus_total;
while(<TREE>){
	if(/^Genus.*g__\w/){
		my @aa=split "\t";
		$aa[2]=~s/g__//;
		$genus{$aa[2]}=$aa[3];
		$genus_total+=$aa[3];
	}
}

print BTYPE "Genus\tAbundance\tRatio\n";
my $other_g=$genus_total;
foreach my $i ("Bacteroides","Prevotella", "Ruminococcus"){
	if(exists $genus{$i}){
		print BTYPE $i,"\t",$genus{$i},"\t",$genus{$i}/$genus_total,"\n";
		$other_g-=$genus{$i};
	}
}
print BTYPE "Other_g","\t",$other_g,"\t",$other_g/$genus_total,"\n";
close BTYPE;

print GENUS "Genus\tAbundance\tRatio\n";
my $other_g="";
foreach my $i(sort {$genus{$b}<=>$genus{$a}} keys %genus){
	my $ratio=$genus{$i}/$genus_total;
	if($ratio>=0.001){
		print GENUS $i,"\t",$genus{$i},"\t",$ratio,"\n";
	}
	else{
		$other_g +=$genus{$i};
	}
}
print GENUS "Other_Genus\t",$other_g,"\t",$other_g/$genus_total,"\n";
