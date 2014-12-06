set PD_NIFTI = pd_t2_ax_tse_47sl_1.nii.gz
set T2_NIFTI = pd_t2_ax_tse_47sl_2.nii.gz

# Destination AFNI files
set WATER = wt
set T1_ECHO = t1_
set FLAIR = fl
set CALC_RAGE = t1_avg
set MTC = mtc_
set PD = pd
set T2 = t2

# Various suffixes for resulting files
set THRESH = _th
set ALIGN = _alw
set MASK = _mask
set ZERO = _z
set LOC_STAT = _ls
set SCALE = _s
set RESAMPLE = _rs
set STRIP = _ss
set SMOOTH = _sm
set SEG = _seg
set EDGE = _edge

# Specific measure variables
set DILATE = 5
set RAD = 45
set WT_TH = 78

3dcopy $PD_NIFTI $PD
3dcopy $T2_NIFTI $T2

3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${PD}${ALIGN}2+orig -cost ls -prefix ${PD}${ALIGN} -1Dmatrix_save ${PD}${ALIGN}2
# 3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${T2}+orig -cost ls -prefix ${T2}${ALIGN} -1Dmatrix_save ${T2}${ALIGN}

# It turns out that the PD / T2 are related, so they are exactly the same grid and location. Thus instead of aligning T2 separately, use the affine matrix
3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${T2}+orig -1Dmatrix_apply ${PD}${ALIGN}.aff12.1D -prefix ${T2}${ALIGN}

# If the PD is too far off in space, then consider using the -big_move option
align_epi_anat.py -dset1 pd_alw+orig -dset2 t1_avg_alw+orig -dset1_strip None -dset2_strip None -suffix al6 -master_dset1 t1_avg_alw+orig -big_move

# Delete later. It took a lot of tries to align pd/t2 to the base image.
# 3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input pd+orig -1Dmatrix_apply t2al4_mat.aff12.1D -prefix ${PD}${ALIGN}_tmp
# 3dAllineate -base ${CALC_RAGE}${ALIGN}+orig -master ${CALC_RAGE}${ALIGN}+orig -input ${PD}${ALIGN}_tmp+orig -1Dmatrix_apply t2al4_al5_mat.aff12.1D -prefix ${PD}${ALIGN} 

foreach IMAGE (${PD}${ALIGN}+orig.HEAD ${T2}${ALIGN}+orig.HEAD ${CALC_RAGE}${ALIGN}+orig.HEAD)
    set p = `ParseName -out Prefix $IMAGE`
    3dLocalstat -nbhd "SPHERE($RAD)" -stat perc:90 \
                -datum short -reduce_max_vox 5 \
                -prefix ${p}${LOC_STAT} ${p}+orig
end

# What is below is added above to the loop
# 3dLocalstat -nbhd "SPHERE($RAD)" -stat perc:90 -datum short -reduce_max_vox 5 -prefix ${CALC_RAGE}${ALIGN}${LOC_STAT} ${CALC_RAGE}${ALIGN}+orig

3dcalc -a ${PD}${ALIGN}${LOC_STAT}+orig \
       -b ${PD}${ALIGN}+orig \
       -expr 'step(a)*b/a' -prefix ${PD}${SCALE}

3dcalc -a ${T2}${ALIGN}${LOC_STAT}+orig \
       -b ${T2}${ALIGN}+orig \
       -expr 'step(a)*b/a' -prefix ${T2}${SCALE}

3dcalc -a ${CALC_RAGE}${ALIGN}${LOC_STAT}+orig \
       -b ${CALC_RAGE}${ALIGN}+orig \
       -expr 'step(a)*b/a' -prefix ${CALC_RAGE}${SCALE}

3dcalc -a all_s+orig'[5]' -expr "a" -prefix ${WATER}_rs
3dcalc -a all_s+orig'[0]' -expr "a" -prefix ${FLAIR}${SCALE}

set mlr_list = (${CALC_RAGE}${SCALE}+orig.HEAD ${T2}${SCALE}+orig.HEAD ${PD}${SCALE}+orig.HEAD ${FLAIR}${SCALE}+orig.HEAD ${WATER}${RESAMPLE}+orig.HEAD )
3dTcat -relabel -prefix all_mlr $mlr_list
3drefit -relabel_all ../all_mlr.txt all_mlr+orig.HEAD