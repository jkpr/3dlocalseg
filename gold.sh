### Create "gold standard" from masks

# Resolve conflicts
3dcalc -a 


3dcalc -a full_space_mask+orig -b full_skin_mask+orig \
	-expr "a * (1-step(b))" -prefix OUT_1
3dcalc -a csf_mask1+orig -b dura_mask+orig -c bone_marrow+orig \
	-expr "a * (1-step(b)) * (1-step(c))" -prefix CSF_1
3dcalc -a gm_mask1+orig  -b csf_mask1+orig -c dura_mask+orig -d bone_marrow+orig \
	-expr "a * (1-step(b)) * (1-step(c)) * (1-step(d))" -prefix GM_1
3dcalc -a wm_mask2+orig  -b csf_mask1+orig -c dura_mask+orig -d bone_marrow+orig \
	-expr "a * (1-step(b)) * (1-step(c)) * (1-step(d))" -prefix WM_1
3dcalc -a dura_mask+orig -expr "a" -prefix MEN_1
3dcalc -a bone_marrow+orig -b dura_mask+orig \
	-expr "a * (1-step(b))" -prefix MAR_1
3dcalc -a full_skin_mask+orig -expr "a" -prefix SK_1




3dcalc -a "OUT_1+orig" -b "CSF_1+orig" -c "GM_1+orig" \
	-d "WM_1+orig" -e "MEN_1+orig" -f "MAR_1+orig" \
	-g "SK_1+orig" \
	-expr "a+b*11+c*21+d*31+e*41+f*51+g*61" -prefix gold+orig

3dbucket -prefix wildf.c.mask -fbuc wildf.EE.c+orig -fbuc OUT_1+orig -fbuc CSF_1+orig \
	-fbuc GM_1+orig -fbuc WM_1+orig -fbuc MEN_1+orig -fbuc MAR_1+orig -fbuc SK_1+orig

3drefit -relabel_all labs.txt wildf.c.mask+orig

