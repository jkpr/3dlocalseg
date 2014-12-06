# Freesurfer: aseg -> CSF, GM, WM

ASEG=frs_aseg_alw+orig.HEAD
NAME=frs_seg

3dcalc -datum short -a ${ASEG} -prefix ${NAME} -verbose -expr \
"amongst(a,1,4,5,14,15,24,40,43,44,72,75,76,80,81,82) +                         \
2*amongst(a,3,8,9,10,12,13,16,17,18,26,28,42,47,48,49,50,51,52,53,54,58,60) +  \
3*amongst(a,2,7,11,41,46,77,78,79)"

7 - white
8 - grey
9 - grey
10 - grey (white)
11 - grey
12 - grey
13 - white (grey)