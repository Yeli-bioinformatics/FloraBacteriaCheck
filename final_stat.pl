$file = $ARGV[0];
$pipeline = $ARGV[1];

open FASTA,"<$file/final.fa";
$/ ='>';
while(<FASTA>)
{
     chomp;
     my ($titleline, $sequence) = split(/\n/,$_,2);
     next unless ($sequence && $titleline);
     $sequence =~ s/\s//g;
     $sum++;
     $l = length($sequence);
     if($l<=400){$$num{400}++;}
     if(($l>400)&&($l<=410)){$num{410}++;}
     if(($l>410)&&($l<=420)){$num{420}++;}
     if(($l>420)&&($l<=430)){$num{430}++;}
     if(($l>430)&&($l<=440)){$num{440}++;}
     if(($l>440)&&($l<=450)){$num{450}++;}
     if(($l>450)&&($l<=460)){$num{460}++;}
     if(($l>460)&&($l<=470)){$num{470}++;}
     if(($l>470)&&($l<=480)){$num{480}++;}
     if(($l>480)&&($l<=490)){$num{490}++;}
     if($l>490){$$num{500}++;}
}

open LEN,">$file/final_len_stat.txt";
print LEN "Len\tNum\tLenfre(%)\n";
for($l=400;$l<=500;$l=$l+10)
{
        if($num{$l} eq ""){$num{$l}=0;}
	$Fre = $num{$l}/$sum*100;
	print LEN "$l\t$num{$l}\t";
	print LEN sprintf("%.2f",$Fre);
        print LEN "\n";
}
system("Rscript $pipeline/final_len.R $file/final_len_stat.txt $file/final_len_distribution.tif");

close FASTA;
close LEN;
close DRAW;
