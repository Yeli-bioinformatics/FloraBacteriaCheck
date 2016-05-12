#!/usr/bin/perl
#!/bin/sh
use strict;
use Getopt::Long;
=head1 name
        taxa.pl
=head1 descripyion
=head1 example
        perl taxa.pl L6 80
=cut

my $pipeline = $ARGV[0];
my $dir = $ARGV[1];
my $top = $ARGV[2];

my $level;
for($level=2;$level<=6;$level++)
{
open L6,"<$dir/Run_Number_otu_table_L$level\.txt"; #otu_table_mc2_w_tax_sorted_L6.txt
open OUT,">$dir/group_taxa_sorted_L$level\_Top$top\.txt";
my $title = <L6>;
print OUT "$title";

my %value;
my %sum;
my $taxa;
my $l = $level - 1;
my $len;

while(<L6>)
{
	chomp;
	my @A = split(/\t/,$_);
	my @B = split(/\;/,$A[0]);
	$len = @A;	
	$taxa = $B[$l];

	if(($taxa eq "p__")||($taxa eq "c__")||($taxa eq "o__")||($taxa eq "f__")||($taxa eq "g__")||($taxa eq "Unclassified")){ $taxa = "Other"; }
	
	$taxa =~ s/^p__//g;
	$taxa =~ s/^c__//g;
	$taxa =~ s/^o__//g;
	$taxa =~ s/^f__//g;
	$taxa =~ s/^g__//g;
	
	my $i;
	for($i=1;$i<$len;$i++)
	{
		if ($value{$taxa}[$i] eq "")
		{
			$value{$taxa}[$i] = $A[$i];
			$sum{$taxa} = $sum{$taxa} + $A[$i];
		}
		else
		{
			$value{$taxa}[$i] = $value{$taxa}[$i] + $A[$i];
			$sum{$taxa} = $sum{$taxa} + $A[$i];
		}
	}
}

my @key = sort {$sum{$b} <=> $sum{$a}} keys %sum;

my $j;
my $i;
my $K;
my $len1 = $len -1;
my $V;
my %total;

for($j=0;$j<=$top;$j++)
{
	$K = $key[$j];
	if($K ne "Other")
	{
		print OUT "$K\t";
	
		for($i=1;$i<$len1;$i++)
        	{
			$V = $value{$K}[$i]*100;
			$total{$i} = $total{$i} + $value{$K}[$i]*100;
			printf OUT ("%.2f",$V);
			print OUT "\t";	
		}
		
		$V = $value{$K}[$len1]*100;
		$total{$len1} = $total{$len1} + $V;
		printf OUT ("%.2f",$V);
		print OUT "\n";
	}
}
print OUT "Other\t";
for($i=1;$i<$len1;$i++)
{
	$V = 100 - $total{$i};
	printf OUT ("%.2f",$V);
        print OUT "\t";
}
$V = 100 - $total{$len1};
printf OUT ("%.2f",$V);
print OUT "\n";
close L6;

system("Rscript $pipeline/tax_bar.R $dir/group_taxa_sorted_L$level\_Top$top\.txt $dir/group_taxa_sorted_L$level\_Top$top\_bar.tif");
}
