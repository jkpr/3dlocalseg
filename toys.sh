#!/bin/tcsh -fex

#Check data directory

set DD = $1
if ( ! -d $DD ) then
   echo "Directory $DD not found"
   exit 1
endif
set OD = EE
set ID = $PWD

cd $DD

set WT = waterimage_noir_hires_lowte_adiabfast_1.nii.gz
set T1L = (t1_memprage_nib_?.nii.gz)
set FL = flair_sag_vfl_1.nii.gz

if ( ! -d $OD ) mkdir -p $OD

WATER_MASK:
   #copy the water
if ( ! -f ${OD}/wt+orig.HEAD) then
   3dcopy ${WT} ${OD}/wt         
endif
   #Manual setting of threshold for water mask
set th = 78
if ( ! -f ${OD}/wt_th+orig.HEAD) then
   3dcalc -a ${WT} -expr "step(a-${th})*a" -prefix ${OD}/wt_th
endif
   
ALLINEATION:
#compute average
if ( ! -f ${OD}/t1_avg+orig.HEAD) then
   3dMean -prefix ${OD}/t1_avg $T1L
endif

#Now register average to water 
   if ( ! -f ${OD}/t1_avg_alw+orig.HEAD) then
      3dAllineate -base ${WT} -weight ${OD}/wt_th+orig.  \
                  -1Dmatrix_save ${OD}/t1_avg_alw              \
                  -input ${OD}/t1_avg+orig.HEAD          \
                  -cost lpc -prefix ${OD}/t1_avg_alw
   endif

   #Now register each T1 to the water
   cd $OD
   set c = 1
   while ($c <= $#T1L)
      if ( ! -f t1.${c}+orig.HEAD) then
         #trivial but to keep naming constant
         cat_matvec -ONELINE t1_avg_alw.aff12.1D > t1.${c}.aff12.1D
         3dAllineate    -base wt+orig. -master wt+orig   \
                        -input ../$T1L[$c] -1Dmatrix_apply t1.${c}.aff12.1D \
                        -prefix t1.${c}
      endif
      @ c ++
   end
   cd -


FLAIR:
#Register the flair
   if ( ! -f ${OD}/fl+orig.HEAD) then
      3dAllineate -base ${WT} -weight ${OD}/wt_th+orig. \
                  -1Dmatrix_save ${OD}/fl                     \
                  -input ${FL} -cost lpc -prefix ${OD}/fl
   endif
   
   
SCALE_FEATURES:
set rad = 45
cd ${OD}
foreach vv (wt+orig.HEAD t1.?+orig.HEAD fl+orig.HEAD t1_avg_alw+orig.HEAD)
   set p = `ParseName -out Prefix $vv`
   if ( ! -f ${p}.ls+orig.HEAD ) then
      3dLocalstat -nbhd "SPHERE($rad)" -stat perc:65:95:5 \
                  -datum short -reduce_max_vox 5 \
                  -prefix ${p}.ls $vv
   else
      echo "Reusing ${p}.ls"
   endif
end

   if ( ! -f fl.s+orig.HEAD ) then
      3dcalc -a fl+orig -b fl.ls+orig'[perc:90.00]' \
             -expr 'step(b)*a/b' \
             -prefix fl.s
   endif
   foreach vv (t1.?+orig.HEAD)
      set p = `ParseName -out Prefix $vv`
      if ( ! -f ${p}.s+orig.HEAD ) then
         3dcalc -a ${p}+orig -b t1_avg_alw.ls+orig'[perc:90.00]' \
                -expr 'step(b)*a/b' \
                -prefix ${p}.s
      endif
   end
   if ( ! -f wt.s+orig.HEAD ) then
      3dcalc -a wt+orig -b wt.ls+orig'[perc:70.00]' \
             -expr 'step(b)*a/b' \
             -prefix wt.s
   endif

   if ( ! -f all_s+orig.HEAD ) then
      set cl = (fl.s+orig.HEAD t1.?.s+orig.HEAD wt.s+orig.HEAD)
      3dTcat   -relabel -prefix all_s \
               $cl
      if ( -f feats.txt ) \rm -f feats.txt
      foreach l ($cl)
         echo $l | sed 's/.s+orig.HEAD//g' >> feats.txt
      end
      #improve labels
      3drefit -relabel_all feats.txt all_s+orig.HEAD 
   endif
   
   if ( ! -f all_us+orig.HEAD ) then
      set cl = (fl+orig.HEAD t1.?+orig.HEAD wt+orig.HEAD)
      3dTcat   -relabel -prefix all_us \
               $cl
      #improve labels
      3drefit -relabel_all feats.txt all_us+orig.HEAD 
   endif
   

   if ( ! -f t1_rad+orig.HEAD ) then
      3dSkullStrip -rad_stat -prefix t1 -input t1_avg_alw+orig.
      3drefit -sublabel 2 UOoU t1_rad+orig.
   endif
   
cd -

END:
   cd $ID
