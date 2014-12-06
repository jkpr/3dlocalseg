# Prepare the classifications

3dcopy fsl_seg_seg.nii.gz fsl_seg_fl
# For subject 13
# 3dcopy fsl_seg_2_seg.nii.gz fsl_seg_fl

3dcalc -datum short -a fsl_seg_fl+orig -expr "a" -prefix fsl_seg+orig
rm fsl_seg_fl+orig.{HEAD,BRIK}