#!/bin/bash 

# qsub -N knn-cleanup -l mem_free=30G,h_vmem=30G batch_knn.sh

DIR=~/.secret/NIH
R CMD BATCH ${DIR}/image_knn.R
