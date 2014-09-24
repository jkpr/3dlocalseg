foreach x (`seq 1 1 81`)
   echo $x
   eval `Rscript test.R ${x}`

   afni -com 'OPEN_WINDOW A.axialimage'           \
        -com 'SWITCH_UNDERLAY all_s+orig'         \
        -com "SWITCH_OVERLAY naive${x}.c+orig"    \
        -com 'SET_INDEX A 5920932'                \
        -com 'SET_XHAIRS A.OFF'                   \
        -com "SAVE_JPEG A.axialimage sss${x}.jpg" \
        -com 'QUIT'                       
end
