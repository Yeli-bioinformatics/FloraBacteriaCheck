$file = $ARGV[0];
$sample = $ARGV[1];
$sample =~ s/-//g;
open FILE1,"<$file/$ARGV[1]\.stat";
open FILE2,"<$file/$ARGV[1]\_nochimera.stat";
open OUT, ">>$file/effective_stat.txt";
while(<FILE1>)
{
     chomp;
     @A = split(/\t/,$_);
     $PEreads = $A[1]/2;
     print OUT "$sample\t$PEreads\t";
}

while(<FILE2>)
{
	chomp;
	if($_ =~ /Total sequences\s+(\d+)/) { $Nochimera = $1; }
	elsif($_ =~ /Average sequence length\s+(\S+)/) { $AvgLen = $1; }
	elsif($_ =~ /\(G \+ C\)s\s+(\S+) %/) { $GC = $1; }	
}
$Peffective = $Nochimera/$PEreads*100;
print OUT "$Nochimera\t$AvgLen\t$GC\t",sprintf("%.2f",$Peffective),"\n";    
close FILE1;
close OUT;
