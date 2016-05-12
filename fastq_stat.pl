$file = $ARGV[0];
$sample = $ARGV[1];
$sample =~ s/-//g;
open FILE,"<$file/$ARGV[1]\.stat";
open OUT, ">>$file/PFdata_stat.txt";
while(<FILE>)
{
     chomp;
     print OUT "$sample\t$_\n";
}
close FILE;
close OUT;
