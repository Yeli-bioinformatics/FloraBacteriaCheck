$file = $ARGV[0];
$sample = $ARGV[1];
$sample =~ s/-//g;
open FASTA,"<$file/$ARGV[1]\_nochimera.fa";
$/ ='>';
$i = 0;
open OUT, ">>$file/final.fa";
while(<FASTA>)
{
     chomp;
     my ($titleline, $sequence) = split(/\n/,$_,2);
     next unless ($sequence && $titleline);
     my ($id) = $titleline =~ /^(\S+)/;
     $sequence =~ s/\s//g;
     $i++;
     print OUT ">$sample\_$i\n$sequence\n";
}
close FASTA;
close OUT;
