    set GD = uuu
    mkdir $GD

@MakeLabelTable -labeltable lt   \
                -lab_v OUT_0 1   \
                -lab_v CSF_0 11  \
                -lab_v GM_0  21  \
                -lab_v WM_0  31  \
                -lab_v MEN_0 41  \
                -lab_v MAR_0 51  \
                -lab_v SK_0  61

3dcalc -overwrite -datum short -a full_space_mask+orig -expr 'step(a)*1' -prefix OUT_0
3dcalc -overwrite -datum short -a csf_mask1+orig -expr 'step(a)*11' -prefix CSF_0
3dcalc -overwrite -datum short -a gm_mask+orig -expr 'step(a)*21' -prefix GM_0
3dcalc -overwrite -datum short -a wm_mask+orig -expr 'step(a)*31' -prefix WM_0
3dcalc -overwrite -datum short -a dura_mask+orig -expr 'step(a)*41' -prefix MEN_0
3dcalc -overwrite -datum short -a bone_marrow+orig. -expr 'step(a)*51' -prefix MAR_0
3dcalc -overwrite -datum short -a full_skin_mask+orig. -expr 'step(a)*61' -prefix SK_0

~/3dGenFeatureDist  -classes 'OUT_0; CSF_0; GM_0; WM_0; MEN_0; MAR_0; SK_0' \
                     -features 'fl; t1_1; t1_2; t1_3; t1_4; wt_rs; mtc_1; mtc_2; mtc_3' \
                     -sig all_s+orig.HEAD \
                     -samp 'OUT_0+orig.HEAD CSF_0+orig.HEAD GM_0+orig.HEAD \
                            WM_0+orig.HEAD MEN_0+orig.HEAD MAR_0+orig.HEAD \
                            SK_0+orig.HEAD'  \
                     -labeltable lt.niml.lt \
                     -prefix ttt
~/@ExamineGenFeatDists -fdir ttt -odir ttt

set vd = 101010
# THIS ONE WORKS
3dGenPriors -sig all_s+orig \
            -do pc -tdist ttt/ -labeltable lt.niml.lt \
            -mask d${DILATE}${ALIGN}${MASK}+orig -debug 2 -vox_debug ${vd} \
            -classes 'OUT_0; CSF_0; GM_0; WM_0; MEN_0; MAR_0; SK_0' \
            -features 'fl; t1_1; t1_2; t1_3; t1_4; wt_rs; mtc_1; mtc_2; mtc_3'  \
            -featexponent by_featgroups -featgroups 'fl t1 wt_rs mtc' \
            -uid HV1.EE \
            -prefix wildf.EE -vox_debug_file ${vd}.EE.dbg \
            -overwrite 

3dGenPriors -sig all_s+orig \
            -do pc -tdist ttt/ -labeltable lt.niml.lt \
            -mask d${DILATE}${ALIGN}${MASK}+orig -debug 2 -vox_debug ${vd} \
            -classes 'OUT_0; CSF_0; GM_0; WM_0; MEN_0; MAR_0; SK_0' \
            -features 'fl; t1_1; t1_2; t1_3; t1_4; wt_rs;'  \
            -featexponent by_featgroups -featgroups 'fl t1 wt_rs' \
            -uid HV1.FF \
            -prefix wildf.FF -vox_debug_file ${vd}.FF.dbg \
            -overwrite 

# THIS ONE DOES NOT (FATAL SIGNAL 11 SIGSEGV)
3dGenPriors -sig all_s+orig \
            -do pc -tdist ttt/ -labeltable lt.niml.lt \
            -mask d${DILATE}${ALIGN}${MASK}+orig -debug 2 -vox_debug ${vd} \
            -classes 'OUT_0; CSF_0; GM_0; WM_0; MEN_0; MAR_0; SK_0' \
            -features 'fl; t1_1; t1_2; t1_3; t1_4; wt_rs; mtc_1; mtc_2; mtc_3'  \
            -featexponent by_featgroups -featgroups 'fl t1 wt_rs mtc' \
            -uid ${GD}/HV1.EE \
            -prefix ${GD}/wildf.EE -vox_debug_file ${GD}/${vd}.EE.dbg \
            -overwrite 



## USE ON A DIFFERENT ALIGNED SET OF IMAGES 
set vd = 101010
3dGenPriors -sig all_s+orig \
            -do pc -tdist ../../a20130227/HH/ttt/ \
            -labeltable ../../a20130227/HH/lt.niml.lt \
            -mask d${DILATE}${ALIGN}${MASK}+orig -debug 2 -vox_debug ${vd} \
            -classes 'OUT_0; CSF_0; GM_0; WM_0; MEN_0; MAR_0; SK_0' \
            -features 'fl; t1_1; t1_2; t1_3; t1_4; wt_rs; mtc_1; mtc_2; mtc_3' \
            -featexponent by_featgroups -featgroups 'fl t1 wt_rs mtc' \
            -uid HV2.EE \
            -prefix wildf.EE -vox_debug_file ${vd}.EE.dbg \
            -overwrite 

3dGenPriors -sig all_s+orig \
            -do pc -tdist ../../a20130227/HH/ttt/ \
            -labeltable ../../a20130227/HH/lt.niml.lt \
            -mask d${DILATE}${ALIGN}${MASK}+orig -debug 2 -vox_debug ${vd} \
            -classes 'OUT_0; CSF_0; GM_0; WM_0; MEN_0; MAR_0; SK_0' \
            -features 'fl; t1_1; t1_2; t1_3; t1_4; wt_rs;' \
            -featexponent by_featgroups -featgroups 'fl t1 wt_rs' \
            -uid HV2.FF \
            -prefix wildf.FF -vox_debug_file ${vd}.FF.dbg \
            -overwrite 


##### GET A MAX PROBABILITY SUB-BRICK
3dTstat -max -prefix wildf_max_prob wildf.EE.p+orig
3dbucket -glueto wildf.EE.c+orig wildf_max_prob+orig
3dbucket -prefix wildf.EE.c.pmax -fbuc wildf.EE.c+orig -fbuc wildf_max_prob+orig
# Do not do this? Different datum types?


### AN EXPERIMENT TO USE ALL FEATURES
~/3dGenFeatureDist  -classes 'OUT_0; CSF_0; GM_0; WM_0; MEN_0; MAR_0; SK_0' \
                     -features 'fl; t1_1; t1_2; t1_3; t1_4; wt_rs; mtc_1; mtc_2; mtc_3; stdev_2[0]; stdev_2[1]; stdev_2[2]; stdev_2[3]; stdev_2[4]; stdev_2[5]; stdev_2[6]; stdev_2[7]; stdev_2[8]; mad_2[0]; mad_2[1]; mad_2[2]; mad_2[3]; mad_2[4]; mad_2[5]; mad_2[6]; mad_2[7]; mad_2[8]; skew_2[0]; skew_2[1]; skew_2[2]; skew_2[3]; skew_2[4]; skew_2[5]; skew_2[6]; skew_2[7]; skew_2[8]; stdev_4[0]; stdev_4[1]; stdev_4[2]; stdev_4[3]; stdev_4[4]; stdev_4[5]; stdev_4[6]; stdev_4[7]; stdev_4[8]; mad_4[0]; mad_4[1]; mad_4[2]; mad_4[3]; mad_4[4]; mad_4[5]; mad_4[6]; mad_4[7]; mad_4[8]; skew_4[0]; skew_4[1]; skew_4[2]; skew_4[3]; skew_4[4]; skew_4[5]; skew_4[6]; skew_4[7]; skew_4[8]; stdev_6[0]; stdev_6[1]; stdev_6[2]; stdev_6[3]; stdev_6[4]; stdev_6[5]; stdev_6[6]; stdev_6[7]; stdev_6[8]; mad_6[0]; mad_6[1]; mad_6[2]; mad_6[3]; mad_6[4]; mad_6[5]; mad_6[6]; mad_6[7]; mad_6[8]; skew_6[0]; skew_6[1]; skew_6[2]; skew_6[3]; skew_6[4]; skew_6[5]; skew_6[6]; skew_6[7]; skew_6[8]' \
                     -sig all_s+orig.HEAD ls_2_stdev+orig.HEAD ls_4_stdev+orig.HEAD ls_6_stdev+orig.HEAD ls_2_mad+orig.HEAD ls_4_mad+orig.HEAD ls_6_mad+orig.HEAD ls_2_skew+orig.HEAD ls_4_skew+orig.HEAD ls_6_skew+orig.HEAD\
                     -samp 'OUT_0+orig.HEAD CSF_0+orig.HEAD GM_0+orig.HEAD \
                            WM_0+orig.HEAD MEN_0+orig.HEAD MAR_0+orig.HEAD \
                            SK_0+orig.HEAD'  \
                     -labeltable lt.niml.lt \
                     -prefix uuu
~/@ExamineGenFeatDists -fdir uuu -odir uuu

3dGenPriors -sig all_s+orig.HEAD ls_2_stdev+orig.HEAD ls_4_stdev+orig.HEAD ls_6_stdev+orig.HEAD ls_2_mad+orig.HEAD ls_4_mad+orig.HEAD ls_6_mad+orig.HEAD ls_2_skew+orig.HEAD ls_4_skew+orig.HEAD ls_6_skew+orig.HEAD\
            -do pc -tdist uuu/ -labeltable lt.niml.lt \
            -mask d${DILATE}${ALIGN}${MASK}+orig -debug 2 -vox_debug ${vd} \
            -classes 'OUT_0; CSF_0; GM_0; WM_0; MEN_0; MAR_0; SK_0' \
            -features 'fl; t1_1; t1_2; t1_3; t1_4; wt_rs; mtc_1; mtc_2; mtc_3; stdev_2[0]; stdev_2[1]; stdev_2[2]; stdev_2[3]; stdev_2[4]; stdev_2[5]; stdev_2[6]; stdev_2[7]; stdev_2[8]; mad_2[0]; mad_2[1]; mad_2[2]; mad_2[3]; mad_2[4]; mad_2[5]; mad_2[6]; mad_2[7]; mad_2[8]; skew_2[0]; skew_2[1]; skew_2[2]; skew_2[3]; skew_2[4]; skew_2[5]; skew_2[6]; skew_2[7]; skew_2[8]; stdev_4[0]; stdev_4[1]; stdev_4[2]; stdev_4[3]; stdev_4[4]; stdev_4[5]; stdev_4[6]; stdev_4[7]; stdev_4[8]; mad_4[0]; mad_4[1]; mad_4[2]; mad_4[3]; mad_4[4]; mad_4[5]; mad_4[6]; mad_4[7]; mad_4[8]; skew_4[0]; skew_4[1]; skew_4[2]; skew_4[3]; skew_4[4]; skew_4[5]; skew_4[6]; skew_4[7]; skew_4[8]; stdev_6[0]; stdev_6[1]; stdev_6[2]; stdev_6[3]; stdev_6[4]; stdev_6[5]; stdev_6[6]; stdev_6[7]; stdev_6[8]; mad_6[0]; mad_6[1]; mad_6[2]; mad_6[3]; mad_6[4]; mad_6[5]; mad_6[6]; mad_6[7]; mad_6[8]; skew_6[0]; skew_6[1]; skew_6[2]; skew_6[3]; skew_6[4]; skew_6[5]; skew_6[6]; skew_6[7]; skew_6[8]' \
            -uid crazyHV1.FF \
            -prefix crazyf.FF -vox_debug_file crazy${vd}.FF.dbg \
            -overwrite 