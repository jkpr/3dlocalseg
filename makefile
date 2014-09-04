myfiles = all_s+orig* \
          all_us+orig* \
          dura_mask+orig* \
          bone_marrow+orig* \
          full_skin_mask+orig* \
          full_space_mask+orig* \
          wm_mask* \
          gm_mask* \
          csf_mask* \
          d5_alw_mask* \
          brain_mask_sm* \
          t1_avg_toads*

out_dir = ..
tar_name = backup.tar.gz

help :
	@echo "make backup  : Create a tarball with important images"
	@echo "make backup2 : Overwrite the tarball if it is there"
	@echo "make show    : Show what files are stored in the tarball"
	@echo "make clean   : Remove the tarball"

backup : $(out_dir)/$(tar_name)

$(out_dir)/$(tar_name) : $(myfiles)
	tar -cvzf $@ $^

backup2 : $(myfiles)
	tar -cvzf $(out_dir)/$(tar_name) $(myfiles)

show :
	@for p in $(myfiles); \
	do \
	echo $$p ; \
	done

clean :
	rm -f $(out_dir)/$(tar_name)