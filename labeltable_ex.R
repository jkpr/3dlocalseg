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


3dcalc -a 