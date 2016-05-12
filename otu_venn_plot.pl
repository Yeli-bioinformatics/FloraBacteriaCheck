$dir = $ARGV[0];
$pipeline = $ARGV[1];
open OTU,"<$dir/01_OTU/otu_table_with_taxonomy_1.txt";
open OUT,">$dir/01_OTU/otu_table.xls";
<OTU>;
while(<OTU>)
{
	chomp;
	$_ =~ s/\#OTU ID/OTUID/g;
	@A = split(/\t/,$_);
	$l = @A;
	for($i=0;$i<$l-2;$i++)
	{
		print OUT "$A[$i]\t";
	}
	$i = $l - 2;
	print OUT "$A[$i]\n";
}
close OTU;
close OUT;

$l = $l - 2;
if(($l>1)&&($l<6))
{
system("Rscript $pipeline/venn.R $dir/01_OTU/otu_table.xls $dir/01_OTU/otu_venn.tif");	
}
close FILE;
