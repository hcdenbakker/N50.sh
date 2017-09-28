#!/bin/bash

# this bash script generates some simple assembly statistics
# should be used like: N50.sh Multi_fasta_file

assembly=$1
mkdir temp;
#get contig lengths, ordered from large to small; 1. remove newlines in sequences, 2. remove fasta headers
# 3. get contig sizes (line lengths) and order them from large to small.
cat $assembly | awk '!/^>/ { printf "%s", $0; n = "\n" } /^>/ { print n $0; n = "" } END { printf "%s", n }'| sed '/^>/ d'| awk '{ print length($0) }' | sort -gr > temp/contig_lengths.txt;

#number of contigs
Y=$(cat temp/contig_lengths.txt | wc -l);

#sum of contig_lengths
X=$(paste -sd+ temp/contig_lengths.txt | bc);

# cumulative contig lengths

awk 'BEGIN {sum=0} {sum= sum+$0; print sum}' temp/contig_lengths.txt > temp/contig_lengths_cum.txt;

# get cumulative contig contributions (%) to the entire assembly

awk -v var=$X 'BEGIN {FS=OFS=","} {for (i=1; i<=NF; i++) $i/=var;}1' temp/contig_lengths_cum.txt > temp/cum_perc.txt; 

# join results

paste temp/contig_lengths.txt temp/cum_perc.txt > temp/matrix.txt;

# get N50, N90, largest scaffold/contig

N50=$(awk '$2 >= 0.50' temp/matrix.txt |head -1| awk '{ print $1}');
N90=$(awk '$2 >= 0.90' temp/matrix.txt |head -1| awk '{ print $1}');
large_contig=$(head -1 temp/contig_lengths.txt);
rm -r temp;

echo "assembly:$assembly"
echo "number of contigs/scaffolds:$Y"
echo "assembly size:$X"
echo "largest contig/scaffold:$large_contig"
echo "N50:$N50";
echo "N90:$N90";
