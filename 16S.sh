#!/bin/bash
if [ $# != 2 ]
then

echo " bash 16S.sh seqdata_dir outputdir"

echo " eg: bash 16S.sh /Biodata/NGS/PF_data/2015/Project_LQT_GWBJNGSFZ15031001_20150416/ /Biodata/work/hairong.duan/project_2015/16S/Project_LQT_GWBJNGSFZ15031001_20150417"

exit 1
fi


indir=$1
output_dir=$2
groupfile=$3

#######################

Trimpath="/home/li.ye/Software/Trimmomatic-0.30"
NGSQCpath="/home/li.ye/Software/NGSQCToolkit_v2.3"
adaptor="/home/li.ye/Software/adapter/Miseq_adapter.fa"
pandaseq="/home/li.ye/Software/pandaseq"
vsearch="/home/li.ye/Software/vsearch-1.9.6-linux-x86_64"
NGSQC="/home/li.ye/Software/NGSQCToolkit_v2.3"
pipeline_dir="/home/li.ye/Script/pipeline/16S_pipeline_V3"

# raw data and trimmed data ---------------------------------------------------------------------
filter_outdir=$output_dir/00_Data
mkdir -p $filter_outdir

for i in $(ls $indir/*R1*.f*q.gz)
do
        sample=`basename $i|perl -n -e ' my $info=(split /_/)[0];print $info;'`
        `gunzip -cd $i  >$filter_outdir/${sample}_R1.fq`
done

for i in $(ls $indir/*R2*.f*q.gz)
do
        sample=`basename $i|perl -n -e ' my $info=(split /_/)[0];print $info;'`
        `gunzip -cd $i  >$filter_outdir/${sample}_R2.fq`
done

echo "Sample	Length(nt)	#Reads	#Bases	Q20(%)	Q30(%)	GC(%)	N(ppm)" >$filter_outdir/PFdata_stat.txt
echo "Sample	#PE_reads	#Nochimera	AvgLen(nt)	GC(%)	Effective(%)" >$filter_outdir/effective_stat.txt
 
for i in $(ls $filter_outdir/*_R1.fq)
do
        sample=`basename $i|sed 's/\_R1.fq//g'`

	/home/li.ye/Software/fastq_stat $filter_outdir/${sample}_R1.fq $filter_outdir/${sample}_R2.fq $filter_outdir/${sample}.stat

	$pandaseq/pandaseq -f $filter_outdir/${sample}_R1.fq -r $filter_outdir/${sample}_R2.fq -T 4 -o 20 -F -w $filter_outdir/${sample}_contig.fq -g $filter_outdir/pandaseq_log.txt

	java -jar $Trimpath/trimmomatic-0.30.jar SE -threads 4 -phred33 $filter_outdir/${sample}_contig.fq $filter_outdir/${sample}_trim.fq ILLUMINACLIP:$adapter:2:30:10 LEADING:20 TRAILING:20 MINLEN:400

	perl -pe 's|@|>|;s|.*||s if $.%4==3 || $.%4==0;close $ARGV if eof' $filter_outdir/${sample}_trim.fq >$filter_outdir/${sample}_trim.fa

	$vsearch/bin/vsearch --uchime_ref $filter_outdir/${sample}_trim.fa -db $pipeline_dir/database/rdp_gold.fa --nonchimeras $filter_outdir/${sample}_nochimera.fa	

	perl $NGSQC/Statistics/N50Stat.pl -i $filter_outdir/${sample}_nochimera.fa -o $filter_outdir/${sample}_nochimera.stat

	perl $pipeline_dir/pandaseq_rename.pl $filter_outdir $sample 
	
	perl $pipeline_dir/fastq_stat.pl $filter_outdir $sample
	
	perl $pipeline_dir/effective_stat.pl $filter_outdir $sample

	rm $filter_outdir/pandaseq_log.txt $filter_outdir/${sample}_contig.fq $filter_outdir/${sample}_R1.fq $filter_outdir/${sample}_R2.fq $filter_outdir/${sample}_trim.fq $filter_outdir/${sample}_trim.fa $filter_outdir/${sample}.stat $filter_outdir/${sample}_nochimera.stat

done	

perl $pipeline_dir/final_stat.pl $filter_outdir $pipeline_dir

#perl $pipeline_dir/map.pl $output_dir $groupfile

Qiime="/usr/bin"
core_aligned_set="/home/li.ye/Script/pipeline/16S_pipeline_V2_201508/database/core_Silva_aligned.fasta"

#~~~~~~~~~~~~~~~PICK OTU~~~~~~~~~~~~~~~~~~~~~~
#python $Qiime/validate_mapping_file.py -m $output_dir/map.txt -o $output_dir/map_check -p -b

#map="$output_dir/map_check/map_corrected.txt"

python $Qiime/pick_open_reference_otus.py -i $filter_outdir/final.fa -o $output_dir/01_OTU -r $pipeline_dir/database/greengene_13_8_97_otus.fasta
python $Qiime/biom convert -i $output_dir/01_OTU/otu_table_mc2_w_tax.biom -o $output_dir/01_OTU/otu_table_with_taxonomy.txt --to-tsv --header-key=taxonomy
biom=$output_dir/01_OTU/otu_table_mc2_w_tax.biom
perl $pipeline_dir/process_otu.pl $output_dir/01_OTU/otu_table_with_taxonomy.txt > $output_dir/01_OTU/otu_table_with_taxonomy.tree.txt
perl $pipeline_dir/genus_analysis.pl $output_dir/01_OTU/otu_table_with_taxonomy.tree.txt $output_dir/01_OTU/intestinal_type.xls $output_dir/01_OTU/Genus_Statistics.xls
cd $output_dir/01_OTU/
R < $pipeline_dir/intestinal_type.R --vanilla 

mkdir $output_dir/02_Alpha
python $Qiime/alpha_diversity.py -i $biom -m ace,chao1,shannon,simpson,goods_coverage -o $output_dir/02_Alpha/alpha_rarefaction.xls

#python $Qiime/make_otu_table.py -i $output_dir/01_OTU/final_otus.txt -t $output_dir/01_OTU/assigned_taxonomy/rep_set_tax_assignments.txt -o $output_dir/01_OTU/otu_table_mc2_w_tax.biom

#python $pipeline_dir/convert_biom.py -i $output_dir/01_OTU/otu_table_mc2_w_tax.biom -o $output_dir/01_OTU/otu_table_with_taxonomy.txt -b --header_key=taxonomy
#python $Qiime/biom convert -i $output_dir/01_OTU/otu_table_mc2_w_tax.biom -o $output_dir/01_OTU/otu_table_with_taxonomy.txt --to-tsv --header-key=taxonomy

#perl $pipeline_dir/extract_otu.pl $output_dir/01_OTU/otu_table_with_taxonomy.txt 1 > $output_dir/01_OTU/otu_table_with_taxonomy_1.txt

#python $Qiime/biom convert -i $output_dir/01_OTU/otu_table_with_taxonomy_1.txt -o $output_dir/01_OTU/otu_table_with_taxonomy_1.biom  --table-type="OTU table" --process-obs-metadata taxonomy --to-json

#biom="$output_dir/01_OTU/otu_table_with_taxonomy_1.biom"

#perl $pipeline_dir/otu_venn_plot.pl $output_dir $pipeline_dir & 

#python $Qiime/align_seqs.py -i $output_dir/01_OTU/rep_set.fna -t $core_aligned_set -o $output_dir/01_OTU/pynast_aligned

#python $Qiime/filter_alignment.py -i $output_dir/01_OTU/pynast_aligned/rep_set_aligned.fasta -o $output_dir/01_OTU/pynast_aligned -e 0.10 -g 0.80

#python $Qiime/make_phylogeny.py -i $output_dir/01_OTU/pynast_aligned/rep_set_aligned_pfiltered.fasta -o $output_dir/01_OTU/rep_set.tre

#tree="$output_dir/01_OTU/rep_set.tre"

# OTU Rank-abundance ---------------------------------------------------------------------------------------

#mkdir $output_dir/02_Rank_Abundance/

#perl $pipeline_dir/otu_rankabundance_plot_V2.pl $output_dir $pipeline_dir &

# Taxonomy summary -----------------------------------------------------------------------------------------

#mkdir $output_dir/03_Taxonomy/

#perl $pipeline_dir/process_otu.pl $output_dir/01_OTU/otu_table_with_taxonomy_1.txt >$output_dir/03_Taxonomy/taxonomy_treefile.xls &
