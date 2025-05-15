#!/bin/bash
# QIIME2 Pipeline for 16S rRNA Data Processing
# Author: Akshay PP
# Description: From demultiplexed FASTQ to taxonomic assignment and feature table export

# Activate QIIME2 environment
source activate qiime2-2024.2  # Change to your installed version

# 1. Import demultiplexed paired-end sequences
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.csv \
  --output-path paired-end-demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

# 2. Summarize demux quality
qiime demux summarize \
  --i-data paired-end-demux.qza \
  --o-visualization demux.qzv

# 3. Denoising using DADA2
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs paired-end-demux.qza \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 250 \
  --p-trunc-len-r 200 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza

# 4. Summarize feature table and representative sequences
qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file metadata.tsv

qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv

# 5. Assign taxonomy using pretrained classifier (e.g., SILVA or Greengenes)
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv

# 6. Create a barplot of taxonomy
qiime taxa barplot \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization taxa-barplot.qzv

# 7. Export Feature Table and Sequences for downstream tools (e.g., PICRUSt2)
qiime tools export \
  --input-path table.qza \
  --output-path exported-feature-table

qiime tools export \
  --input-path rep-seqs.qza \
  --output-path exported-rep-seqs

qiime tools export \
  --input-path taxonomy.qza \
  --output-path exported-taxonomy

echo "QIIME2 pipeline completed successfully!"
