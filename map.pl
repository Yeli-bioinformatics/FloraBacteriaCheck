$dir = $ARGV[0];
$groupfile = $ARGV[1];
open FILE,"<$groupfile";
<FILE>;
open OUT, ">$dir/map.txt";
print OUT "#SampleID\tBarcodeSequence\tLinkerPrimerSequence\tRun_Number\tSample_Type\tDescription\n";
while(<FILE>)
{
     chomp;
     @A = split(/\t/,$_);
     $sample = $A[0];
     $sample =~ s/-//g;
     print OUT "$sample\t\t\t$A[1]\tControl\t$sample\n";
}
close FILE;
close OUT;
