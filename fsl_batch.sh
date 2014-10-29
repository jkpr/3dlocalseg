#!/bin/bash

# Run this with
# qsub -N fr29 -l mem_free=20G,h_vmem=20G fsl_batch.sh

# FSL Setup
FSLDIR=/home/student/jpringle/fsl/fsl
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
source ${FSLDIR}/etc/fslconf/fsl.sh

FR="fsl"
ID="04"
DIR=~/.secret/NIH/${ID}
LOG=${DIR}/fsl.log
T1="t1"
BET="_bet"
NII=".nii"
MPRAGE=${DIR}/${T1}${NII}
OUT="fsl_seg"

cd ${DIR}

echo "Starting FSL for subject ${ID}" >> ${LOG}
echo "with file '${MPRAGE}'" >> ${LOG}
date >> ${LOG}
echo "-----------------" >> ${LOG}

# Get the skull stripped brain
#bet ${T1}${NII} ${T1}${BET}

echo "Finishing BET" >> ${LOG}
date >> ${LOG}
echo "-----------------" >> ${LOG}

fast -n 3 -t 1 -b -g -v -o $OUT ${T1}${BET}${NII}

echo "Finishing FAST" >> ${LOG}
echo date >> ${LOG}
echo "=================" >> ${LOG}


