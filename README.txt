1- Align and scale data with @toys
2- Create some classes - I used InstaCorr with some choice locations
   and created so masks by saving IC results then thresholding manually

from somewhere like HV1/EE
@MakeLabelTable -labeltable lt   \
                -lab_v CAV.0 1  \
                -lab_v CSF.0 11  \
                -lab_v GM.0  21  \
                -lab_v WM.0  31  \
                -lab_v WM.1  32  \
                -lab_v MEN.0 2   \
                -lab_v OTH.0 3   \
                -lab_v SK.0  4   
                

3dcalc -overwrite -datum short -a cav+orig. -expr 'step(a-2.9)*1' -prefix CAV.0
3dcalc -overwrite -datum short -a csf3+orig -expr 'step(a-0.1779)*11' -prefix CSF.0
3dcalc -overwrite -datum short -a gm+orig. -expr 'step(a-8.27)*21' -prefix GM.0
3dcalc -overwrite -datum short -a mens+orig -expr 'step(a-3.3)*2' -prefix MEN.0
3dcalc -overwrite -datum short -a vessels+orig. -expr 'step(a-1.1)*3' -prefix OTH.0
3dcalc -overwrite -datum short -a wm+orig. -expr 'step(a-7.7)*31' -prefix WM.0
3dcalc -overwrite -datum short -a wm2+orig. -expr 'step(a-13.2)*32' -prefix WM.1

#Rad stats?
3dcalc -overwrite -datum short -a t1_rad+orig.'[UOoU]' -b t1_rad+orig.'[ok]' \
                               -expr '(step(a-0.84)*step(b))*4' -prefix SK.0
                               
Then one creates the distributions of the features for each class
   3dGenFeatureDist  -classes 'CAV.0; CSF.0; GM.0; WM.0; WM.1; OTH.0; SK.0' \
                     -features 'fl; t1.1; t1.2; t1.3; t1.4; wt; UOoU'   \
                     -sig all_s+orig.HEAD t1_rad+orig.'[UOoU]' \
                     -samp 'CAV.0+orig.HEAD CSF.0+orig.HEAD GM.0+orig.HEAD \
                            MEN.0+orig.HEAD OTH.0+orig.HEAD WM.0+orig.HEAD \
                            WM.1+orig.HEAD SK.0+orig.HEAD'  \
                     -labeltable lt.niml.lt\
                     -prefix ttt 
   @ExamineGenFeatDists -fdir ttt -odir ttt

Now you can generate priors (trivial case first)
   set vd = 18927502
   3dGenPriors -sig all_s+orig t1_rad+orig.'[UOoU]'\
               -do pc -tdist ttt/ -labeltable lt.niml.lt \
               -mask t1_avg_alw+orig. -debug 2 -vox_debug ${vd} \
               -classes 'CAV.0; CSF.0; GM.0; WM.0; WM.1; OTH.0; SK.0' \
               -features 'fl; t1.1; t1.2; t1.3; t1.4; wt; UOoU'  \
               -featexponent by_featgroups -featgroups 'fl t1 wt UOoU' \
               -uid HV1.EE \
               -prefix wildf.EE -vox_debug_file ${vd}.EE.dbg \
               -overwrite 

Now try HV2, etc.
foreach hh (HV2 HV3)
   cd ../../${hh}/EE
   set vd = 14177156
   3dGenPriors -sig all_s+orig t1_rad+orig.'[UOoU]'\
               -do pc -tdist ../../HV1/EE/ttt/ \
               -labeltable ../../HV1/EE/lt.niml.lt \
               -mask t1_avg_alw+orig. -debug 2 -vox_debug ${vd} \
               -classes 'CAV.0; CSF.0; GM.0; WM.0; WM.1; OTH.0; SK.0' \
               -features 'fl; t1.1; t1.2; t1.3; t1.4; wt; UOoU'  \
               -uid ${hh}.EE \
               -featexponent by_featgroups -featgroups 'fl t1 wt UOoU' \
               -prefix wildf.EE -vox_debug_file ${vd}.EE.dbg \
               -overwrite 
end
