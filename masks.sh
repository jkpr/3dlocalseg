#! /bin/tcsh -fex

### GET MASKS OF THINGS
3dSkullStrip -input ${CALC_RAGE}${ALIGN}${ZERO}+orig \
             -prefix ${CALC_RAGE}${ALIGN}${STRIP}${MASK}


## EDIT THE MASK SOMEHOW?
3dcalc -a ${CALC_RAGE}${ALIGN}${STRIP}${MASK}+orig \
       -expr "step(a-4)" -prefix brain${MASK}_tmp

# Fill in holes
3dmask_tool -input brain${MASK}_tmp+orig \
            -prefix d${DILATE}_brain${MASK}_tmp -dilate_input $DILATE -${DILATE}

# EDIT the mask to make sure it covers the entire brain.
# Smooth out the brain. Get the skullstripped brain
3dcopy COPY_d${DILATE}_brain${MASK}_tmp+orig brain_mask
3dmask_tool -input brain_mask+orig -prefix brain_mask_sm -dilate_input 1 -1
3dcalc -a ${CALC_RAGE}${ALIGN}+orig -b brain_mask_sm+orig \
       -expr "a*step(b)" -prefix ${CALC_RAGE}${ALIGN}${STRIP}

# Create nifti version
3dAFNItoNIFTI -prefix ${CALC_RAGE}${STRIP} ${CALC_RAGE}${ALIGN}${STRIP}+orig

## RUN TOADS IN MIPAV
## THE RESULT DOES NOT HAVE THE CORRECT HEADER INFO,
## BUT THE DATA SEEM TO BE IN THE PROPER ORDER.
## USE 3dinfo to check what is happening with the DATA

## My code to fix it
3dcopy t1_avg_ss_clone_Toads_seg_max_mem.nii.gz t1_avg_toads
3drefit -orient ASR t1_avg_toads+orig
3drefit -duporigin ../../t1_avg_alw_ss+orig t1_avg_toads+orig


# 0  way outside the brain
# 1  outside the brain
# 5  sulcal/cisternal CSF
# 6  ventricles
#10  lesions
#14  cerebellar cortical gray matter
#15  cerebral cortical gray matter
#16  caudate
#17  thalamus
#18  putamen
#22  brainstem
#24  cerebellar white matter
#25  cerebral white matter


##### MAKE MASKS FROM TOADS

3dcalc -a t1_avg_toads+orig -expr "step(equals(a,24) + equals(a,25))"  \
       -prefix wm_mask1



## RUN 3dSEG on stuff
3dSeg -anat ${CALC_RAGE}${ALIGN}${STRIP}+orig -mask AUTO \
      -classes 'CSF ; GM ; WM' -prefix ${CALC_RAGE}${SEG}

#### GUESSES
### CSF : 0.95
### GM  : 0.49
### WM  : 0.49

set CSF_THRESH = 0.94
set GM_THRESH = 0.49
set WM_THRESH = 0.49
set CSF = csf
set WM = wm
set GM = gm

3dcalc -a ${CALC_RAGE}${SEG}/Posterior+orig'[P(CSF|y)]' \
       -expr "step(a - ${CSF_THRESH})" -prefix ${CSF}${MASK}

3dcalc -a ${CALC_RAGE}${SEG}/Posterior+orig'[P(WM|y)]' \
       -expr "step(a - ${WM_THRESH})" -prefix ${WM}${MASK}

3dcalc -a ${CALC_RAGE}${SEG}/Posterior+orig'[P(GM|y)]' \
       -expr "step(a - ${GM_THRESH})" -prefix ${GM}${MASK}

set CSF_THRESH = 59
3dcalc -a ${WATER}${RESAMPLE}${ZERO}+orig -expr "step(a - 59)" \
       -prefix ${CSF}${MASK}1

###### SKIN FAT MASK

set E_THRESH = 25
set SKIN = skin

# First get the edges
3dedge3 -input ${MTC}1${ALIGN}${ZERO}+orig -prefix ${MTC}1${EDGE}

# Second create a binary mask
3dcalc -a ${MTC}1${EDGE} \
       -expr "step(a - ${E_THRESH})" -prefix ${SKIN}${MASK}

3dcalc -a tissue_mask+orig -prefix part_marrow_mask \
       -expr "step(a-1)"

3dmask_tool -input part_skin_mask+orig -prefix full_skin_mask -dilate_input 1 -1

##### OUTSIDE MASK
set E_THRESH_2 = 1950
3dedge3 -input ${MTC}2${SCALE}+orig -prefix ${MTC}2${EDGE}

3dcalc -a ${MTC}2${EDGE}+orig \
       -expr "step(a - ${E_THRESH_2})" -prefix space${MASK}

3dcalc -a COPY_space_mask+orig -prefix full_space_mask \
       -expr "step(a - 1)"

###### BRAIN MASK
set E_THRESH_3 = 25
3dedge3 -input ${MTC}3${ALIGN}+orig -prefix ${MTC}3${EDGE}

3dcalc -a ${MTC}3${EDGE}+orig \
       -expr "step(a - ${E_THRESH_3})" -prefix get_brain_mask

