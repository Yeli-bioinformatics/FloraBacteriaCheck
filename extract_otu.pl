#!/usr/bin/perl

open TAX,"$ARGV[0]" or die; ##otu_table_with_taxonomy.txt

my $num = $ARGV[1];

$head = <TAX>;
$title = <TAX>;

print "$head";
print "$title";

chomp;
@A = split (/\t/,$title);
$len = @A-2;

while(<TAX>){
	chomp;
	my @B = split /\t/,$_;
	my $sum = 0;
	for (my $i=1;$i<=$len;$i++){
	$sum += $B[$i];
	}
#print "$sum\n";
	if ($sum > $num){
	my $value = join ("\t", @B);
	print "$value\n";
	}
}
close TAX;
