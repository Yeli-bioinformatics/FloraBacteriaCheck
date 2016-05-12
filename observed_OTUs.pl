#!/usr/bin/perl
$dir = $ARGV[0];
$pipeline = $ARGV[1];

open IN, "$dir/04_Rarefaction_curve/alpha_rarefaction_plots/average_tables/observed_speciesSampleID.txt";
open OUT,">$dir/04_Rarefaction_curve/Observed_OTUs.txt";
while(<IN>)
{
chomp;
if(/xaxis: /)
{
	$_ =~ s/xaxis: //g;
	print OUT "SampleID\t$_\n";
}
if(/>> /)
{
        $_ =~ s/>> //g;
        print OUT "$_\t";
}
if(/series /)
{
        $_ =~ s/series //g;
        print OUT "$_\n";
}	
}
close IN;
close OUT;

system("Rscript $pipeline/observed_OTUs_V2.R $dir/04_Rarefaction_curve/Observed_OTUs.txt $dir/04_Rarefaction_curve/Observed_OTUs_rarefaction_curves.tif");
