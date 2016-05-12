#!/usr/bin/perl

#use strict;

my $dir="$ARGV[0]";


open L2, "$dir/02_Tax_Summary/otu_table_mc2_w_tax_sorted_L2.txt" or die "$!";
$_ = <L2>;
chomp;
@A = split(/\t/,$_);
$len = @A;
while(<L2>)
{
	chomp;
	@B = split(/\t/,$_);
	for($i=1;$i<=$len;$i++)
	{
		if($B[$i] > 0){ $num2{$A[$i]}++; }
	}
}

open L3, "$dir/02_Tax_Summary/otu_table_mc2_w_tax_sorted_L3.txt" or die "$!";
$_ = <L3>;
while(<L3>)
{
	chomp;
	@B = split(/\t/,$_);
	for($i=1;$i<=$len;$i++)
	{
		if($B[$i] > 0){ $num3{$A[$i]}++; }
	}
}

open L4, "$dir/02_Tax_Summary/otu_table_mc2_w_tax_sorted_L4.txt" or die "$!";
$_ = <L4>;
while(<L4>)
{
	chomp;
	@B = split(/\t/,$_);
	for($i=1;$i<=$len;$i++)
	{
		if($B[$i] > 0){ $num4{$A[$i]}++; }
	}
}

open L5, "$dir/02_Tax_Summary/otu_table_mc2_w_tax_sorted_L5.txt" or die "$!";
$_ = <L5>;
while(<L5>)
{
	chomp;
	@B = split(/\t/,$_);
	for($i=1;$i<=$len;$i++)
	{
		if($B[$i] > 0){ $num5{$A[$i]}++; }
	}
}

open L6, "$dir/02_Tax_Summary/otu_table_mc2_w_tax_sorted_L6.txt" or die "$!";
$_ = <L6>;
while(<L6>)
{
	chomp;
	@B = split(/\t/,$_);
	for($i=1;$i<=$len;$i++)
	{
		if($B[$i] > 0){ $num6{$A[$i]}++; }
	}
}


open OUT, ">$dir/02_Tax_Summary/tax.stat";
print OUT "Samples\tPhylum\tClass\tOrder\tFamily\tGenus\n";
for($i=1;$i<=$len;$i++)
{
	print OUT "$A[$i]\t$num2{$A[$i]}\t$num3{$A[$i]}\t$num4{$A[$i]}\t$num5{$A[$i]}\t$num6{$A[$i]}\n";
}
close L2;
close L3;
close L4;
close L5;
close L6;
close OUT;
