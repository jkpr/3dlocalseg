@MakeLabelTable -labeltable brain_lt   \
                -lab_v OTH_0 1   \
                -lab_v WM_0 11  \
                -lab_v GM_0 21  \
                -lab_v CSF_0 31

#3dcalc -a brain_mask_sm+orig -b csf_mask1+orig -c gm_mask1+orig -d wm_mask2+orig \
#       -expr 'step(a - step(b+c+d))' -prefix OTH_0
3dcopy csf_mask1+orig CSF_0
3dcopy gm_mask1+orig GM_0
3dcopy wm_mask2+orig WM_0


set sub_ids = {"04","13","27"}

~/3dGenFeatureDist  -classes 'WM_0; GM_0; CSF_0' \
                     -features 'fl; t1_1; t1_2; t1_3; t1_4; wt_rs; mtc_1; mtc_2; mtc_3' \
                     -sig a201302${sub_ids[1]}/all_s+orig.HEAD a201302${sub_ids[2]}/all_s+orig.HEAD \
                     -samp "a201302${sub_ids[2]}/CSF_0+orig.HEAD a201302${sub_ids[2]}/GM_0+orig.HEAD a201302${sub_ids[2]}/WM_0+orig.HEAD a201302${sub_ids[1]}/CSF_0+orig.HEAD a201302${sub_ids[1]}/GM_0+orig.HEAD a201302${sub_ids[1]}/WM_0+orig.HEAD" \
                     -labeltable brain_lt.niml.lt \
                     -prefix a201302${sub_ids[3]}/ttt
~/@ExamineGenFeatDists -fdir a201302${sub_ids[2]}/ttt -odir a201302${sub_ids[2]}/ttt