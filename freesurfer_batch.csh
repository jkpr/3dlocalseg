#!/bin/tcsh -fex

setenv FREESURFER_HOME /home/student/jpringle/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.csh

set FR = "fr"
set ID = "04"
set DIR = ~/.secret/NIH/${ID}
set LOG = ${DIR}/freesurfer.log
set MPRAGE = ${DIR}/t1.nii

echo "Starting FreeSurfer for subject ${ID}" >> ${LOG}
echo "with file '${MPRAGE}'" >> ${LOG}
date >> ${LOG}
echo "-----------------" >> ${LOG}

recon-all -all -i ${MPRAGE} -s ${FR}${ID}

echo "Finishing FreeSurfer" >> ${LOG}
echo date >> ${LOG}
echo "=================" >> ${LOG}
