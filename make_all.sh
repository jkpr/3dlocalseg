# Make a new ALL

OD=tmp_dir
mkdir ${OD}

3dcalc -datum short -a all_mlr+orig'[0]' -expr "a" -prefix ${OD}/t1
3dcalc -datum short -a all_mlr+orig'[1]' -expr "a" -prefix ${OD}/t2
3dcalc -datum short -a all_mlr+orig'[2]' -expr "a" -prefix ${OD}/pd
3dcalc -datum short -a all_mlr+orig'[3]' -expr "a" -prefix ${OD}/fl
3dcalc -datum short -a all_mlr+orig'[4]' -expr "a" -prefix ${OD}/wt


3dcalc -datum short -a all_s+orig'[1]' -expr "a" -prefix ${OD}/t1_1
3dcalc -datum short -a all_s+orig'[2]' -expr "a" -prefix ${OD}/t1_2
3dcalc -datum short -a all_s+orig'[3]' -expr "a" -prefix ${OD}/t1_3
3dcalc -datum short -a all_s+orig'[4]' -expr "a" -prefix ${OD}/t1_4
3dcalc -datum short -a all_s+orig'[6]' -expr "a" -prefix ${OD}/mtc_1
3dcalc -datum short -a all_s+orig'[7]' -expr "a" -prefix ${OD}/mtc_2
3dcalc -datum short -a all_s+orig'[8]' -expr "a" -prefix ${OD}/mtc_3

cd ${OD}
3dTcat -relabel -prefix all t1+orig t2+orig pd+orig fl+orig wt+orig t1_1+orig t1_2+orig t1_3+orig t1_4+orig mtc_1+orig mtc_2+orig mtc_3+orig
3drefit -relabel_all ../../all.txt all+orig.HEAD
mv all+orig* ..
cd ..

rm -r tmp_dir