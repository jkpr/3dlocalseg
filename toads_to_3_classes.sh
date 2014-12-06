# Convert TOADS output to 3 classes

ASEG=toads_seg_all+orig.HEAD
NAME=toads_seg

3dcalc -datum short -a ${ASEG} -prefix ${NAME} -verbose -expr \
     "amongst(a,5,6) +                         \
    2*amongst(a,14,15,16,17,18) +  \
    3*amongst(a,22,24,25)"



# For the masks I already have...
CSF=csf_mask1+orig.HEAD
GM=gm_mask1+orig.HEAD
WM=wm_mask2+orig.HEAD

3dcalc -datum short -a ${CSF} -b ${GM} -c ${WM} -prefix ${NAME} \
    -expr "step(a) + 2*step(b) + 3*step(c)"