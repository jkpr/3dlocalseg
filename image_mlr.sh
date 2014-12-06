#!/bin/bash 

# qsub -N mlr-all -l mem_free=40G,h_vmem=40G image_mlr.sh

DIR=~/.secret/NIH
LOG=${DIR}/mlr.log


echo "Starting MLR for subject all subjects" >> ${LOG}
date >> ${LOG}
echo "-----------------" >> ${LOG}

R CMD BATCH ${DIR}/main_mlr.R

echo "Finishing MLR" >> ${LOG}
date >> ${LOG}
echo "=================" >> ${LOG}
