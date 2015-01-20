# Freesurfer: aseg -> CSF, GM, WM

ASEG=frs_aseg_alw+orig.HEAD
NAME=frs_seg

3dcalc -datum short -a ${ASEG} -prefix ${NAME} -verbose -expr \
"amongst(a,1,4,5,14,15,24,40,43,44,72,75,76,80,81,82) +                         \
2*amongst(a,3,8,9,10,11,12,13,16,17,18,26,28,42,47,48,49,50,51,52,53,54,58,60) +  \
3*amongst(a,2,7,41,46,77,78,79,85,253)"


3dcalc -datum short -a ${ASEG} -prefix ${NAME}_test -expr "isnegative(amongst(a,1,4,5,14,15,24,40,43,44,72,75,76,80,81,82,3,8,9,10,11,12,13,16,17,18,26,28,42,47,48,49,50,51,52,53,54,58,60,2,7,41,46,77,78,79,30,31,62,63,85,251,252,253,254,255)-1)*a"

04 -- 
30, 62 CSF
31, 63, CSF

85, GM

251, 252, 253, 254, 255 are extra (WM)

# 04
3dcalc -datum short -a ${ASEG} -prefix ${NAME} -verbose -expr                        \
"amongst(a,1,4,5,14,15,24,40,43,44,72,75,76,80,81,82, 30, 62, 31, 63) +              \
2*amongst(a,3,8,9,10,11,12,13,16,17,18,26,28,42,47,48,49,50,51,52,53,54,58,60,85) +  \
3*amongst(a,2,7,41,46,77,78,79,253, 251, 252, 253, 254, 255)"



7 - white
8 - grey
9 - grey
10 - grey (white)
11 - grey
12 - grey
13 - white (grey)