#!/bin/bash
if [ $# != 3 ]
then

echo " bash ITS.sh seqdata_dir outputdir group_info_file"

echo " eg: bash ITS.sh /Biodata/NGS/PF_data/2015/Project_LQT_GWBJNGSFZ15031001_20150416/ /Biodata/work/hairong.duan/project_2015/ITS/Project_LQT_GWBJNGSFZ15031001_20150417 /Biodata/work/hairong.duan/project_2015/ITS/Project_LQT_GWBJNGSFZ15031001_20150417/group_info.txt"

exit 1
fi


indir=$1
output_dir=$2
groupfile=$3

#######################

Trimpath="/srv/NGS/software/Trimmomatic/Trimmomatic-0.30"
NGSQCpath="/srv/NGS/software/NGSQCToolkit_v2.3"
adaptor="/srv/NGS/database/adapter/Miseq_adapter.fa"
pandaseq="/srv/NGS/user/hairong.duan/biosoftware/pandaseq-master"
usearch="/Bioshare/software/Download"
NGSQC="/srv/NGS/software/NGSQCToolkit_v2.3"
pipeline_dir="/Biodata/work/hairong.duan/16S_pipeline"

# raw data and trimmed data ---------------------------------------------------------------------
filter_outdir=$output_dir/00_Data
mkdir -p $filter_outdir

for i in $(ls $indir/*R1*.fastq.gz)
do
        sample=`basename $i|perl -n -e ' my $info=(split /_/)[0];print $info;'`
        `gunzip -cd $i  >$filter_outdir/${sample}_R1.fq`
done

for i in $(ls $indir/*R2*.fastq.gz)
do
        sample=`basename $i|perl -n -e ' my $info=(split /_/)[0];print $info;'`
        `gunzip -cd $i  >$filter_outdir/${sample}_R2.fq`
done

echo "Sample	Length(nt)	#Reads	#Bases	Q20(%)	Q30(%)	GC(%)	N(ppm)" >$filter_outdir/PFdata_stat.txt
echo "Sample	#PE_reads	#Nochimera	AvgLen(nt)	GC(%)	Effective(%)" >$filter_outdir/effective_stat.txt
 
for i in $(ls $filter_outdir/*_R1.fq)
do
        sample=`basename $i|sed 's/\_R1.fq//g'`

	/srv/NGS/temp/fastq_stat $filter_outdir/${sample}_R1.fq $filter_outdir/${sample}_R2.fq $filter_outdir/${sample}.stat

	$pandaseq/pandaseq -f $filter_outdir/${sample}_R1.fq -r $filter_outdir/${sample}_R2.fq -T 10 -o 20 -F -w $filter_outdir/${sample}_contig.fq -g $filter_outdir/pandaseq_log.txt

	java -jar $Trimpath/trimmomatic-0.30.jar SE -threads 10 -phred33 $filter_outdir/${sample}_contig.fq $filter_outdir/${sample}_trim.fq ILLUMINACLIP:$adapter:2:30:10 LEADING:20 TRAILING:20 MINLEN:400

	perl -pe 's|@|>|;s|.*||s if $.%4==3 || $.%4==0;close $ARGV if eof' $filter_outdir/${sample}_trim.fq >$filter_outdir/${sample}_trim.fa

	$usearch/usearch8.0.1623_i86linux32 -uchime_ref $filter_outdir/${sample}_trim.fa -db /Biodata/work/hairong.duan/16S_pipeline/ITS_database/uchime_sh_refs_dynamic_original_985_11.03.2015.fasta -strand plus -nonchimeras $filter_outdir/${sample}_nochimera.fa	

	perl $NGSQC/Statistics/N50Stat.pl -i $filter_outdir/${sample}_nochimera.fa -o $filter_outdir/${sample}_nochimera.stat

	perl $pipeline_dir/pandaseq_rename.pl $filter_outdir $sample 
	
	perl $pipeline_dir/fastq_stat.pl $filter_outdir $sample
	
	perl $pipeline_dir/effective_stat.pl $filter_outdir $sample

	rm $filter_outdir/pandaseq_log.txt $filter_outdir/${sample}_contig.fq $filter_outdir/${sample}_R1.fq $filter_outdir/${sample}_R2.fq $filter_outdir/${sample}_trim.fq $filter_outdir/${sample}_trim.fa $filter_outdir/${sample}.stat $filter_outdir/${sample}_nochimera.stat

done	

perl $pipeline_dir/final_stat.pl $filter_outdir $pipeline_dir

perl $pipeline_dir/map.pl $output_dir $groupfile

Qiime="/srv/NGS/software/Qiime"
taxonomy="/srv/NGS/ref_database/ITS/its_12_11_otus/taxonomy/97_otu_taxonomy.txt"
rep_set="/srv/NGS/ref_database/ITS/its_12_11_otus/rep_set/97_otus.fasta"
core_aligned_set="/Biodata/work/hairong.duan/16S_pipeline/ITS_database/ITS_aln.afa"

#~~~~~~~~~~~~~~~PICK OTU~~~~~~~~~~~~~~~~~~~~~~
python $Qiime/scripts/check_id_map.py -m $output_dir/map.txt -o $output_dir/map_check -p -b

map="$output_dir/map_check/map_corrected.txt"

python $Qiime/scripts/pick_otus.py -i $filter_outdir/final.fa -o $output_dir/01_OTU --uclust_otu_id_prefix OTU

python $Qiime/scripts/pick_rep_set.py -i $output_dir/01_OTU/final_otus.txt -f $filter_outdir/final.fa -o $output_dir/01_OTU/rep_set.fna

python $Qiime/scripts/assign_taxonomy.py -i $output_dir/01_OTU/rep_set.fna -o $output_dir/01_OTU/assigned_taxonomy -t $taxonomy -r $rep_set --rdp_max_memory 3000

python $Qiime/scripts/make_otu_table.py -i $output_dir/01_OTU/final_otus.txt -t $output_dir/01_OTU/assigned_taxonomy/rep_set_tax_assignments.txt -o $output_dir/01_OTU/otu_table_mc2_w_tax.biom

python /usr/local/bin/convert_biom.py -i $output_dir/01_OTU/otu_table_mc2_w_tax.biom -o $output_dir/01_OTU/otu_table_with_taxonomy.txt -b --header_key=taxonomy

perl $pipeline_dir/extract_otu.pl $output_dir/01_OTU/otu_table_with_taxonomy.txt 1 > $output_dir/01_OTU/otu_table_with_taxonomy_1.txt

python /usr/local/bin/convert_biom.py -i $output_dir/01_OTU/otu_table_with_taxonomy_1.txt -o $output_dir/01_OTU/otu_table_with_taxonomy_1.biom --biom_table_type="OTU table" --process_obs_metadata taxonomy

biom="$output_dir/01_OTU/otu_table_with_taxonomy_1.biom"

perl $pipeline_dir/otu_venn_plot.pl $output_dir $pipeline_dir &

python $Qiime/scripts/align_seqs.py -i $output_dir/01_OTU/rep_set.fna -t $core_aligned_set -o $output_dir/01_OTU/pynast_aligned

python $Qiime/scripts/filter_alignment.py -i $output_dir/01_OTU/pynast_aligned/rep_set_aligned.fasta -o $output_dir/01_OTU/pynast_aligned -e 0.10 -g 0.80

python $Qiime/scripts/make_phylogeny.py -i $output_dir/01_OTU/pynast_aligned/rep_set_aligned_pfiltered.fasta -o $output_dir/01_OTU/rep_set.tre

tree="$output_dir/01_OTU/rep_set.tre"

# OTU Rank-abundance ---------------------------------------------------------------------------------------

mkdir $output_dir/02_Rank_Abundance/

perl $pipeline_dir/otu_rankabundance_plot_V2.pl $output_dir $pipeline_dir &

# Taxonomy summary -----------------------------------------------------------------------------------------

mkdir $output_dir/03_Taxonomy/

perl $pipeline_dir/process_otu.pl $output_dir/01_OTU/otu_table_with_taxonomy_1.txt >$output_dir/03_Taxonomy/taxonomy_treefile.xls &

python $Qiime/scripts/sort_otu_table.py -i $biom -o $output_dir/03_Taxonomy/otu_table_mc2_w_tax_sorted.biom -m $map -s SampleID

python $Qiime/scripts/summarize_taxa.py -i $output_dir/03_Taxonomy/otu_table_mc2_w_tax_sorted.biom -o $output_dir/03_Taxonomy/taxa_summary_by_sample

perl $pipeline_dir/sample_tax_stat.pl $output_dir &

perl $pipeline_dir/sample_tax_Topselect.pl $pipeline_dir $output_dir/03_Taxonomy/taxa_summary_by_sample 20 &

python $Qiime/scripts/summarize_taxa_through_plots.py -o $output_dir/03_Taxonomy/taxa_summary_by_group -i $output_dir/03_Taxonomy/otu_table_mc2_w_tax_sorted.biom -m $map -c Run_Number

perl $pipeline_dir/group_tax_stat.pl $output_dir &

perl $pipeline_dir/group_tax_Topselect.pl $pipeline_dir $output_dir/03_Taxonomy/taxa_summary_by_group 20 &

# Rarefaction curve -------------------------------------------------------------------------------------

mkdir $output_dir/04_Rarefaction_curve

perl $pipeline_dir/extract_otu.pl $output_dir/01_OTU/otu_table_with_taxonomy.txt 5 > $output_dir/01_OTU/otu_table_with_taxonomy_5.txt

python /usr/local/bin/convert_biom.py -i $output_dir/01_OTU/otu_table_with_taxonomy_5.txt -o $output_dir/01_OTU/otu_table_with_taxonomy_5.biom --biom_table_type="OTU table" --process_obs_metadata taxonomy

python $Qiime/scripts/multiple_rarefactions.py -i $output_dir/01_OTU/otu_table_with_taxonomy_5.biom --lineages_included -m 10 -x 100000 -s 5000 -o $output_dir/04_Rarefaction_curve/rarefaction

python $Qiime/scripts/alpha_diversity.py -i $output_dir/04_Rarefaction_curve/rarefaction -o $output_dir/04_Rarefaction_curve/alpha_div/ --metrics observed_species -t $tree

python $Qiime/scripts/collate_alpha.py -i $output_dir/04_Rarefaction_curve/alpha_div/ -o $output_dir/04_Rarefaction_curve/alpha_div_collated

python $Qiime/scripts/make_rarefaction_plots.py -i $output_dir/04_Rarefaction_curve/alpha_div_collated/ -m $map -o $output_dir/04_Rarefaction_curve/alpha_rarefaction_plots

perl $pipeline_dir/observed_OTUs.pl $output_dir $pipeline_dir

# Alpha_Diversity ---------------------------------------------------------------------------------------------

mkdir $output_dir/05_Alpha_Diversity

python $Qiime/scripts/alpha_diversity.py -i $biom -m ACE,chao1,shannon,simpson,goods_coverage -o $output_dir/05_Alpha_Diversity/alpha_rarefaction.xls &

# Beta_Diversity ----------------------------------------------------------------------------------------------

python $Qiime/scripts/beta_diversity_through_plots.py -i $biom -m $map -t $tree -o $output_dir/06_Beta_Diversity

# PCoA ---------------------------------------------------------------------------------------------------------

mkdir $output_dir/07_PCoA

mkdir $output_dir/07_PCoA/unweighted_unifrac_PCoA

cd $output_dir/07_PCoA/unweighted_unifrac_PCoA

Rscript $pipeline_dir/PCoA.R $output_dir/06_Beta_Diversity/unweighted_unifrac_pc.txt

mkdir $output_dir/07_PCoA/weighted_unifrac_PCoA

cd $output_dir/07_PCoA/weighted_unifrac_PCoA

Rscript $pipeline_dir/PCoA.R $output_dir/06_Beta_Diversity/weighted_unifrac_pc.txt

# UPGMA Tree --------------------------------------------------------------------------------------------------

python $Qiime/scripts/jackknifed_beta_diversity.py -i $biom -m $map -t $tree -o $output_dir/08_UPGMA_tree -e 10000

python $Qiime/scripts/make_bootstrapped_tree.py -m $output_dir/08_UPGMA_tree/unweighted_unifrac/upgma_cmp/master_tree.tre -s $output_dir/08_UPGMA_tree/unweighted_unifrac/upgma_cmp/jackknife_support.txt -o $output_dir/08_UPGMA_tree/unweighted_unifrac/upgma_cmp/jackknife_named_nodes.pdf

convert $output_dir/08_UPGMA_tree/unweighted_unifrac/upgma_cmp/jackknife_named_nodes.pdf $output_dir/08_UPGMA_tree/unweighted_unifrac/upgma_cmp/unweighted_unifrac_tree.tif

python $Qiime/scripts/make_bootstrapped_tree.py -m $output_dir/08_UPGMA_tree/weighted_unifrac/upgma_cmp/master_tree.tre -s $output_dir/08_UPGMA_tree/weighted_unifrac/upgma_cmp/jackknife_support.txt -o $output_dir/08_UPGMA_tree/weighted_unifrac/upgma_cmp/jackknife_named_nodes.pdf

convert $output_dir/08_UPGMA_tree/weighted_unifrac/upgma_cmp/jackknife_named_nodes.pdf $output_dir/08_UPGMA_tree/weighted_unifrac/upgma_cmp/weighted_unifrac_tree.tif

#STEP8 --Analysis result -------------------------------------------------------------------------
mkdir $output_dir/Analysis_result
mkdir $output_dir/Analysis_result/00_Data
mkdir $output_dir/Analysis_result/01_OTU
mkdir $output_dir/Analysis_result/02_Rank_Abundance
mkdir $output_dir/Analysis_result/03_Taxonomy
mkdir $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_sample
mkdir $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_sample/all_data
mkdir $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_sample/Top20
mkdir $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_group
mkdir $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_group/all_data
mkdir $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_group/Top20
mkdir $output_dir/Analysis_result/04_Rarefaction_curve
mkdir $output_dir/Analysis_result/05_Alpha_Diversity
mkdir $output_dir/Analysis_result/06_Beta_Diversity
mkdir $output_dir/Analysis_result/07_PCoA
mkdir $output_dir/Analysis_result/07_PCoA/weighted_unifrac_PCoA
mkdir $output_dir/Analysis_result/07_PCoA/unweighted_unifrac_PCoA
mkdir $output_dir/Analysis_result/08_UPGMA_tree
mkdir $output_dir/Analysis_result/08_UPGMA_tree/weighted_unifrac_UPGMA
mkdir $output_dir/Analysis_result/08_UPGMA_tree/unweighted_unifrac_UPGMA

cp $output_dir/00_Data/PFdata_stat.txt $output_dir/Analysis_result/00_Data
cp $output_dir/00_Data/effective_stat.txt $output_dir/Analysis_result/00_Data
cp $output_dir/00_Data/final_len_distribution.tif $output_dir/Analysis_result/00_Data

cp $output_dir/01_OTU/otu_table_mc2_w_tax.biom $output_dir/Analysis_result/01_OTU
cp $output_dir/01_OTU/final_otus.txt $output_dir/Analysis_result/01_OTU
cp $output_dir/01_OTU/otu_table.xls $output_dir/Analysis_result/01_OTU
cp $output_dir/01_OTU/otu_venn.tif $output_dir/Analysis_result/01_OTU
cp $output_dir/01_OTU/rep_set.fna $output_dir/Analysis_result/01_OTU
cp $output_dir/01_OTU/rep_set.tre $output_dir/Analysis_result/01_OTU

cp $output_dir/02_Rank_Abundance/rank_abundance.tif $output_dir/Analysis_result/02_Rank_Abundance

cp $output_dir/03_Taxonomy/taxonomy_treefile.xls $output_dir/Analysis_result/03_Taxonomy
cp $output_dir/03_Taxonomy/taxa_summary_by_sample/Sample_tax_stat.xls $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_sample/
cp $output_dir/03_Taxonomy/taxa_summary_by_sample/otu*txt $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_sample/all_data
cp $output_dir/03_Taxonomy/taxa_summary_by_sample/sample*Top20* $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_sample/Top20
cp $output_dir/03_Taxonomy/taxa_summary_by_group/Group_tax_stat.xls $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_group
cp $output_dir/03_Taxonomy/taxa_summary_by_group/Run*txt $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_group/all_data
cp $output_dir/03_Taxonomy/taxa_summary_by_group/group*Top20* $output_dir/Analysis_result/03_Taxonomy/taxa_summary_by_group/Top20

cp $output_dir/04_Rarefaction_curve/Observed_OTUs_rarefaction_curves.tif $output_dir/Analysis_result/04_Rarefaction_curve

cp $output_dir/05_Alpha_Diversity/alpha_rarefaction.xls $output_dir/Analysis_result/05_Alpha_Diversity

cp $output_dir/06_Beta_Diversity/unweighted_unifrac_dm.txt $output_dir/Analysis_result/06_Beta_Diversity/unweighted_unifrac.txt
cp $output_dir/06_Beta_Diversity/weighted_unifrac_dm.txt $output_dir/Analysis_result/06_Beta_Diversity/weighted_unifrac.txt

cp $output_dir/06_Beta_Diversity/weighted_unifrac_pc.txt $output_dir/Analysis_result/07_PCoA/weighted_unifrac_PCoA
cp $output_dir/06_Beta_Diversity/unweighted_unifrac_pc.txt $output_dir/Analysis_result/07_PCoA/unweighted_unifrac_PCoA
cp $output_dir/07_PCoA/weighted_unifrac_PCoA/* $output_dir/Analysis_result/07_PCoA/weighted_unifrac_PCoA
cp $output_dir/07_PCoA/unweighted_unifrac_PCoA/* $output_dir/Analysis_result/07_PCoA/unweighted_unifrac_PCoA

cp $output_dir/08_UPGMA_tree/unweighted_unifrac/upgma_cmp/* $output_dir/Analysis_result/08_UPGMA_tree/unweighted_unifrac_UPGMA
cp $output_dir/08_UPGMA_tree/weighted_unifrac/upgma_cmp/* $output_dir/Analysis_result/08_UPGMA_tree/weighted_unifrac_UPGMA

cd $output_dir/Analysis_result
tree * >$output_dir/Analysis_result/file_tree.txt

