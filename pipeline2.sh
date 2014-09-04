#! /bin/tcsh -fex

# Setup
set OD = JJ
mkdir $OD

# Source NIFTI files
set WATER_NIFTI = waterimage_noir_hires_lowte_adiabfast_1.nii.gz
set T1_ECHO_NIFTI = (t1_memprage_nib_?.nii.gz)
set FLAIR_NIFTI = flair_sag_vfl_1.nii.gz
set CALC_RAGE_NIFTI = Calc_MPRAGE.nii.gz
set MTC_NIFTI = mtc_on_{1.2,4.0,98.0}khz_500deg_10us_1.nii.gz
# set PD_NIFTI = pd_t2_ax_tse_1.nii.gz

# Destination AFNI files
set WATER = wt
set T1_ECHO = t1_
set FLAIR = fl
set CALC_RAGE = t1_avg
set MTC = mtc_
# set PD = pd

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

# A) Copy everything from NIFTI to AFNI format
3dcopy $WATER_NIFTI $OD/$WATER
3dcopy $FLAIR_NIFTI $OD/$FLAIR
3dcopy $CALC_RAGE_NIFTI $OD/$CALC_RAGE
# 3dcopy $PD_NIFTI $OD/$PD

set i = 1
while ($i <= $#T1_ECHO_NIFTI)
    3dcopy $T1_ECHO_NIFTI[$i] ${OD}/${T1_ECHO}${i}
@ i ++
end

set i = 1
while ($i <= $#MTC_NIFTI)
    3dcopy $MTC_NIFTI[$i] ${OD}/${MTC}${i}
@ i ++
end

# Change output directory for calculations
cd ${OD}

# B) Threshold the water image. This number is context-dependent
3dcalc -a ${WATER}+orig -expr "step(a-${WT_TH})*a" -prefix ${WATER}${THRESH}

# C) Align Calc_MPRAGE to thresholded water image, then do the same 
# transformation to T1 echo images, using same "box frame" as Calc_MPRAGE
align_epi_anat.py -dset1 ${CALC_RAGE}+orig -dset2 ${WATER}${THRESH}+orig \
                  -dset1_strip None -dset2_strip None -suffix $ALIGN \
                  -master_dset1 ${CALC_RAGE}+orig -child_anat ${T1_ECHO}?+orig*

# Cont'd) Align MTC images to thresholded water image
set i = 1
while ($i <= $#MTC_NIFTI)
    align_epi_anat.py -dset1 ${MTC}${i}+orig -dset2 ${WATER}${THRESH}+orig \
                  -dset1_strip None -dset2_strip None -suffix ${ALIGN} \
                  -master_dset1 ${CALC_RAGE}+orig
@ i ++
end

# Had to align one of them separately to a different MTC that did align
# set i = 1
# align_epi_anat.py -dset1 ${MTC}${i}+orig -dset2 ${MTC}2_alw+orig \
#                   -dset1_strip None -dset2_strip None -suffix ${ALIGN}3 \
#                   -master_dset1 ${CALC_RAGE}+orig

# Cont'd) Align FLAIR to thresholded water image
align_epi_anat.py -dset1 ${FLAIR}+orig -dset2 ${WATER}${THRESH}+orig \
                  -dset1_strip None -dset2_strip None -suffix ${ALIGN} \
                  -master_dset1 ${CALC_RAGE}+orig

# TEST TO SEE IF ALIGNMENT WENT CORRECTLY
3dresample -input ${WATER}+orig -master ${CALC_RAGE}${ALIGN}+orig \
           -rmode Li -prefix ${WATER}${RESAMPLE}_tmp
set cl = (${FLAIR}${ALIGN}+orig.HEAD \
          ${T1_ECHO}?${ALIGN}+orig.HEAD \
          ${WATER}${RESAMPLE}_tmp+orig.HEAD \
          ${MTC}?${ALIGN}+orig.HEAD)
3dTcat   -relabel -prefix all_us $cl



# D) Create a head mask (then manually draw to fill in gaps):
3dAutomask -prefix ${CALC_RAGE}${ALIGN}${MASK} ${CALC_RAGE}${ALIGN}+orig

# E) Dilate mask to make sure everything is covered (in the head):
3dmask_tool -input ${CALC_RAGE}${ALIGN}${MASK}+orig \
            -prefix d${DILATE}${ALIGN}${MASK} -dilate_input $DILATE
# F) Zero out everything away from head in all images
foreach IMAGE (${T1_ECHO}?${ALIGN}+orig.HEAD ${FLAIR}${ALIGN}+orig.HEAD \
            ${CALC_RAGE}${ALIGN}+orig.HEAD ${MTC}?${ALIGN}+orig.HEAD)
    set p = `ParseName -out Prefix $IMAGE`
    3dcalc -a $IMAGE -b d${DILATE}${ALIGN}${MASK}+orig \
           -expr 'step(b)*a' -prefix ${p}${ZERO}
end

# G) Calculate local stats (percentiles) on all the images except water
foreach IMAGE (${T1_ECHO}?${ALIGN}+orig.HEAD ${MTC}?${ALIGN}+orig.HEAD \
            ${FLAIR}${ALIGN}+orig.HEAD ${CALC_RAGE}${ALIGN}+orig.HEAD)
    set p = `ParseName -out Prefix $IMAGE`
    3dLocalstat -nbhd "SPHERE($RAD)" -stat perc:65:95:5 \
                -datum short -reduce_max_vox 5 \
                -prefix ${p}${LOC_STAT} ${p}${ZERO}+orig
end

# Cont'd) ...and the same for water, since it doesn't have a "_z"
3dLocalstat -nbhd "SPHERE($RAD)" -stat perc:65:95:5 \
            -datum short -reduce_max_vox 5 \
            -prefix ${WATER}${LOC_STAT} ${WATER}+orig.HEAD

# H) Scale T1 echoes by Calc_MPRAGE percentiles
foreach IMAGE (${T1_ECHO}?+orig.HEAD)
    set p = `ParseName -out Prefix $IMAGE`

    3dcalc -a ${CALC_RAGE}${ALIGN}${LOC_STAT}+orig'[perc:90.00]' \
           -b ${p}${ALIGN}${ZERO}+orig \
           -expr 'step(a)*b/a' -prefix ${p}${SCALE}
end

# ALTERNATIVE: Scale by T1 echoes' own percentiles
#foreach vv (${T1_ECHO}?+orig.HEAD)
#    set p = `ParseName -out Prefix $vv`
#    3dcalc -a ${p}${ALIGN}+orig -b ${p}${ALIGN}${LOC_STAT}+orig'[perc:90.00]' \
#              -expr 'step(b)*a/b' \
#              -prefix ${p}${SCALE}
#end

# Cont'd) Scale MTC images by themselves
foreach IMAGE (${MTC}?+orig.HEAD)
    set p = `ParseName -out Prefix $IMAGE`
    3dcalc -a ${p}${ALIGN}${LOC_STAT}+orig'[perc:90.00]' \
           -b ${p}${ALIGN}${ZERO}+orig \
           -expr 'step(a)*b/a' -prefix ${p}${SCALE}
end

# Cont'd) Scale Calc_MPRAGE by CALC_MPRAGE percentiles
3dcalc -a ${CALC_RAGE}${ALIGN}${LOC_STAT}+orig'[perc:90.00]' \
       -b ${CALC_RAGE}${ALIGN}${ZERO}+orig \
       -expr 'step(a)*b/a' -prefix ${CALC_RAGE}${SCALE}

# Cont'd) ...and the same for FLAIR, scale by iteself
3dcalc -a ${FLAIR}${ALIGN}${LOC_STAT}+orig'[perc:90.00]' \
       -b ${FLAIR}${ALIGN}${ZERO}+orig \
       -expr 'step(a)*b/a' -prefix ${FLAIR}${SCALE}

# Cont'd) ...and the same for the water image, scale by itself
3dcalc -a ${WATER}${LOC_STAT}+orig'[perc:70.00]' -b ${WATER}+orig  \
       -expr 'step(a)*b/a' \
       -prefix ${WATER}${SCALE}

# I) Resample the scaled water image so it is the same size as the rest and 
#    mask out the rest
3dresample -input ${WATER}${SCALE}+orig -master ${CALC_RAGE}${ALIGN}+orig \
           -rmode Li -prefix ${WATER}${RESAMPLE}${SCALE}_tmp
3dcalc -a ${WATER}${RESAMPLE}${SCALE}_tmp+orig \
       -b d${DILATE}${ALIGN}${MASK}+orig \
       -expr 'step(b)*a' -prefix ${WATER}${RESAMPLE}${SCALE}

# Cont'd) Resample the unscaled water image and mask it
3dresample -input ${WATER}+orig -master ${CALC_RAGE}${ALIGN}+orig \
           -rmode Li -prefix ${WATER}${RESAMPLE}_tmp
3dcalc -a ${WATER}${RESAMPLE}_tmp+orig \
       -b d${DILATE}${ALIGN}${MASK}+orig \
       -expr 'step(b)*a' -prefix ${WATER}${RESAMPLE}${ZERO}

# J) Join them all together, first the scaled, then the unscaled
set cl_s = (${FLAIR}${SCALE}+orig.HEAD ${T1_ECHO}?${SCALE}+orig.HEAD \
          ${WATER}${RESAMPLE}${SCALE}+orig.HEAD ${MTC}?${SCALE}+orig.HEAD)
3dTcat   -relabel -prefix all_s $cl_s
if ( -f feats.txt ) rm -f feats.txt
foreach l ($cl_s)
  echo $l | sed "s/${SCALE}+orig.HEAD//g" >> feats.txt
end
3drefit -relabel_all feats.txt all_s+orig.HEAD

# Cont'd) ...unscaled
set cl_us = (${FLAIR}${ALIGN}+orig.HEAD \
          ${T1_ECHO}?${ALIGN}+orig.HEAD \
          ${WATER}${RESAMPLE}_tmp+orig.HEAD \
          ${MTC}?${ALIGN}+orig.HEAD)
3dTcat   -relabel -prefix all_us $cl_us
3drefit -relabel_all feats.txt all_us+orig.HEAD

# GET MORE STATS
set nbhds = {2,4,6}
foreach i ( $nbhds )
  3dLocalstat -nbhd "SPHERE($i)" -stat stdev -prefix ls_${i}_stdev all_s+orig
  3dLocalstat -nbhd "SPHERE($i)" -stat MAD -prefix ls_${i}_mad all_s+orig
  3dLocalstat -nbhd "SPHERE($i)" -stat P2skew -prefix ls_${i}_skew all_s+orig
end


set stat_type = {stdev,mad,skew}
set subbrick = {0,1,2,3,4,5,6,7,8}
foreach i ( $nbhds )
  foreach j ( $stat_type )
    foreach k ( $subbrick )
      echo "${j}_${i}[${k}]" >> ${j}${i}.txt
    end
    3drefit -relabel_all ${j}${i}.txt ls_${i}_${j}+orig
  end
end

3drefit -relabel_all ls_${i}_${j}+orig