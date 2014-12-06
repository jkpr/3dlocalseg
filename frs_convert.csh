# mri_convert

set ID = "27"
set FRS_DIR = ~/freesurfer/subjects/fr${ID}_bet_2/mri
set OUT_DIR = ~/.secret/NIH/${ID}
set FRS = "frs"
set BRAIN = "_brain"
set NII = ".nii"
set ASEG = "_aseg"
set T1 = "_t1"
set AL = "_al"
set BRIK = ".brik"

cd ${FRS_DIR}

mri_convert -it mgz -ot nii T1.mgz ${FRS}${T1}_bet_2${NII}
mv ${FRS}${T1}_bet_2${NII} ${OUT_DIR}

mri_convert -it mgz -ot nii brainmask.mgz ${FRS}${BRAIN}${NII}
mv ${FRS}${BRAIN}${NII} ${OUT_DIR}

mri_convert -it mgz -ot nii aseg.mgz ${FRS}${ASEG}${NII}
mv ${FRS}${ASEG}${NII} ${OUT_DIR}

mri_convert -it mgz -ot afni aseg.mgz ${FRS}${ASEG}2
cp aseg.auto_noCCseg.label_intensities.txt ${OUT_DIR}/${FRS}_labels.txt

cd ${OUT_DIR}

3dcopy ${FRS}${T1}${NII} ${FRS}${T1}_tmp
3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${FRS}${T1}_tmp+orig -prefix ${FRS}${T1}${ALIGN} -1Dmatrix_save ${FRS}${T1}${ALIGN} -cost ls -parfix 4 0 -parfix 5 0 -parfix 6 0 -parfix 7 0 -parfix 8 0 -parfix 9 0 -parfix 10 0 -parfix 11 0 -parfix 12 0

# Had to go a special route for subject 27
#align_epi_anat.py -dset1 frs_t1_tmp+orig -dset2 wt_rs+orig -dset1_strip None -dset2_strip None -suffix alw3 -master_dset1 t1_avg_alw+orig -big_move
#3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${FRS}${T1}_tmpalw3+orig -prefix ${FRS}${T1}_tmp_alw4 -1Dmatrix_save ${FRS}${T1}_tmp_alw4 -cost ls





3dcopy ${FRS}${BRAIN}${NII} ${FRS}${BRAIN}_tmp
3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${FRS}${BRAIN}_tmp+orig -1Dmatrix_apply ${FRS}${T1}${ALIGN}.aff12.1D -prefix ${FRS}${BRAIN}${ALIGN} 


# Had to do two transformations to get it to work on subject 27
#3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${FRS}${BRAIN}_tmp+orig -1Dmatrix_apply ${FRS}${T1}_tmpalw3_mat.aff12.1D -prefix ${FRS}${BRAIN}${ALIGN}_1
#3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${FRS}${BRAIN}${ALIGN}_1+orig -1Dmatrix_apply ${FRS}${T1}_tmp${ALIGN}4.aff12.1D -prefix ${FRS}${BRAIN}${ALIGN}

3dcopy ${FRS}${ASEG}${NII} ${FRS}${ASEG}_tmp
3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${FRS}${ASEG}_tmp+orig -1Dmatrix_apply ${FRS}${T1}${ALIGN}.aff12.1D -prefix ${FRS}${ASEG}${ALIGN} 

# Had to do two transformations to get it to work on subject 27
#3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${FRS}${ASEG}_tmp+orig -1Dmatrix_apply ${FRS}${T1}_tmpalw3_mat.aff12.1D -prefix ${FRS}${ASEG}${ALIGN}_1
#3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${FRS}${ASEG}${ALIGN}_1+orig -1Dmatrix_apply ${FRS}${T1}_tmp${ALIGN}4.aff12.1D -prefix ${FRS}${ASEG}${ALIGN}

foreach image ( all_mlr+orig frs_brain.nii frs_brain_alw+orig frs_t1.nii frs_t1_alw+orig frs_aseg.nii frs_aseg_alw+orig)
    echo "Checking orientation (-orient) for '$image'"
    3dinfo $image | grep orient
end