#!/bin/bash 

# qsub -N knn-array -t 1-80 -l mem_free=30G,h_vmem=30G batch_knn.sh

echo "Running array job ${SGE_TASK_ID}"
date
DIR=~/.secret/NIH
RScript ${DIR}/main_knn.R ${SGE_TASK_ID}
echo "Finishing array job ${SGE_TASK_ID}"
date