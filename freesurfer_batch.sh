#!/bin/bash 

export FREESURFER_HOME=/home/student/jpringle/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

FR="fr"
ID="04"
DIR=~/.secret/NIH/${ID}
LOG=${DIR}/freesurfer.log
MPRAGE=${DIR}/t1.nii

echo "Starting FreeSurfer for subject ${ID}" >> ${LOG}
echo "with file '${MPRAGE}'" >> ${LOG}
date >> ${LOG}
echo "-----------------" >> ${LOG}

recon-all -all -i ${MPRAGE} -s ${FR}${ID}

echo "Finishing FreeSurfer" >> ${LOG}
echo date >> ${LOG}
echo "=================" >> ${LOG}
