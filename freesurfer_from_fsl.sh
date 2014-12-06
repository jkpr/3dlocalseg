#!/bin/bash 

# Try number two
# qsub -N fr27 -l mem_free=20G,h_vmem=20G freesurfer_from_fsl.sh

export FREESURFER_HOME=/home/student/jpringle/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

FR="fr"
ID="27"
DIR=~/.secret/NIH/${ID}
LOG=${DIR}/freesurfer.log
MPRAGE=${DIR}/t1.nii
BET=${DIR}/t1_bet.nii.gz

echo "Starting FreeSurfer for subject ${ID}" >> ${LOG}
echo "Starting with FSL's skullstripped data" >> ${LOG}
echo "Working with file '${MPRAGE}'" >> ${LOG}
date >> ${LOG}
echo "-----------------" >> ${LOG}

recon-all -autorecon1 -noskullstrip -i ${BET} -s ${FR}${ID}

echo "Finishing FreeSurfer -autorecon1" >> ${LOG}
echo date >> ${LOG}
echo "=================" >> ${LOG}