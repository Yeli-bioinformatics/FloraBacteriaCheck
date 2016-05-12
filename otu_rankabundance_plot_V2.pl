#!/usr/bin/perl
$dir = $ARGV[0];
$pipeline = $ARGV[1];
open IN,"$dir/01_OTU/otu_table.xls";
open OUT,">$dir/02_Rank_Abundance/rank.txt";
my $samplelist=<IN>;
print OUT $samplelist;
chomp($samplelist);
my @A = split(/\t/,$samplelist);
my $l = @A;
my $i;
while(<IN>)
{
	chomp;
	my @B = split(/\t/,$_);
	for($i=1;$i<$l;$i++){ $sum{$B[0]} = $sum{$B[0]} + $B[$i]; }
	if($sum{$B[0]} > 1)
	{
		for($i=1;$i<$l;$i++){  @{$A[$i]} = (@{$A[$i]},$B[$i]);	}
	}
}

for($i=1;$i<$l;$i++)
{
	foreach $n(@{$A[$i]}){$sum{$i}=$sum{$i}+$n;}
	@{$i} = sort { $b <=> $a } @{$A[$i]};
}
$i=1;
my $k = @{$i};
for($j=0;$j<$k;$j++)
{
	print OUT "$j\t";
	for($i=1;$i<$l-1;$i++)
	{
		$p = ${$i}[$j]/$sum{$i}*100;
		printf OUT ("%.2f",$p);
		print OUT "\t";
	}
	$i = $l-1;
	$p = ${$i}[$j]/$sum{$i}*100;
        printf OUT ("%.2f",$p);
	print OUT "\n";
}
close IN;
close OUT;
	
system("Rscript $pipeline/rankabundance.R $dir/02_Rank_Abundance/rank.txt $dir/02_Rank_Abundance/rank_abundance.tif");

