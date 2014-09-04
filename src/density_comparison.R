library(oro.nifti)
library(ggplot2)

setwd("~/Documents/NIH")

classes <- c("ALL","WM","GM","CSF")
images <- c("fl","t1_1","t1_2","t1_3","t1_4","wt_rs","mtc_1","mtc_2","mtc_3")
subjects <- c("04","13","27")
folders <- c("EE", "JJ", "HH")
data_dir_stem <- "/Volumes/home/pringlejk/a201302"
data_dirs <- paste0(data_dir_stem,subjects,"/",folders,"/")

all_s_file <- "all_s+orig.HEAD"
brain_mask_file <- "brain_mask_sm+orig.HEAD"
wm_mask_file <- "wm_mask2+orig.HEAD"
gm_mask_file <- "gm_mask1+orig.HEAD"
csf_mask_file <- "csf_mask1+orig.HEAD"

#x <- 1

get_data_df <- function(all_wm, all_gm, all_csf, images, id){
  # Value Image Class Id
  wm_df <- data.frame(Value=c(all_wm), Image=rep(images, each=nrow(all_wm)), Class="WM", Id=id)
  gm_df <- data.frame(Value=c(all_gm), Image=rep(images, each=nrow(all_gm)), Class="GM", Id=id)
  csf_df <- data.frame(Value=c(all_csf), Image=rep(images, each=nrow(all_csf)), Class="CSF ", Id=id)
  df <- rbind(wm_df, gm_df, csf_df)
  
  all_inds <- sort(sample(nrow(df), size=round(0.1*nrow(df)), replace=TRUE))
  all_df <- df[all_inds,c("Value","Image")]
  all_df$Class <- "ALL"
  all_df$Id <- id
  new_df <- rbind(df, all_df)
  return(new_df)
}

out <- do.call(rbind,lapply(seq_along(subjects), function(x){
  this_sub <- subjects[x]
  this_dir <- data_dirs[x]
  
  cat("Loading subject",this_sub,paste0("\"",this_dir,all_s_file,"\""),"\n")
  all_s <- readAFNI(paste0(this_dir,all_s_file))
  cat("Loading subject",this_sub,paste0("\"",this_dir,brain_mask_file,"\""),"\n")
  brain_mask <- readAFNI(paste0(this_dir,brain_mask_file))
  # This next apply command puts the brain voxels in each MRI 
  # contrast as a separate column vector
  all_brain <- apply(all_s, 4, function(y) {
    y[as.logical(drop(brain_mask))]
  })
  image_names <- strsplit(all_s@BRICK_LABS,"~")[[1]]
  stopifnot(image_names==images)
  
  cat("Loading subject",this_sub,"masks\n")
  # These next commands subsets the GM/WM/CSF masks to be
  # binary masks only in the brain
  wm_mask <- readAFNI(paste0(this_dir,wm_mask_file))
  wm_brain <- drop(wm_mask[as.logical(brain_mask)])
  gm_mask <- readAFNI(paste0(this_dir,gm_mask_file))
  gm_brain <- drop(gm_mask[as.logical(brain_mask)])
  csf_mask <- readAFNI(paste0(this_dir,csf_mask_file))
  csf_brain <- drop(csf_mask[as.logical(brain_mask)])
  
  all_wm <- apply(all_brain, 2, function(z) {
    z[as.logical(wm_brain)]
  })
  all_gm <- apply(all_brain, 2, function(z) {
    z[as.logical(gm_brain)]
  })
  all_csf <- apply(all_brain, 2, function(z) {
    z[as.logical(csf_brain)]
  })
  
  
  df <- get_data_df(all_wm, all_gm, all_csf, image_names, this_sub)
  return(df)
}))

p_s <- ggplot(data=out, aes(x=Value, color=Id)) + geom_density() + 
  facet_wrap(~ Image + Class, ncol=4, scales="free") + 
  ggtitle("Comparison of image intensity densities in the brain across subjects,\nbroken down by MRI contrast and tissue class\nScaled images")
ggsave(filename="~/Documents/NIH/dens_s.png", plot=p_s, width=15, height=20, units="in")


##```````````````````~~~~~~~~~~~~~~~~~~~```````````````===================````````
## Now do unscaled

all_us_file <- "all_us+orig.HEAD"

#x <- 1

get_data_df <- function(all_wm, all_gm, all_csf, images, id){
  # Value Image Class Id
  wm_df <- data.frame(Value=c(all_wm), Image=rep(images, each=nrow(all_wm)), Class="WM", Id=id)
  gm_df <- data.frame(Value=c(all_gm), Image=rep(images, each=nrow(all_gm)), Class="GM", Id=id)
  csf_df <- data.frame(Value=c(all_csf), Image=rep(images, each=nrow(all_csf)), Class="CSF ", Id=id)
  df <- rbind(wm_df, gm_df, csf_df)
  
  all_inds <- sort(sample(nrow(df), size=round(0.1*nrow(df)), replace=TRUE))
  all_df <- df[all_inds,c("Value","Image")]
  all_df$Class <- "ALL"
  all_df$Id <- id
  new_df <- rbind(df, all_df)
  return(new_df)
}

out_us <- do.call(rbind,lapply(seq_along(subjects), function(x){
  this_sub <- subjects[x]
  this_dir <- data_dirs[x]
  
  cat("Loading subject",this_sub,paste0("\"",this_dir,all_s_file,"\""),"\n")
  all_us <- readAFNI(paste0(this_dir,all_us_file))
  cat("Loading subject",this_sub,paste0("\"",this_dir,brain_mask_file,"\""),"\n")
  brain_mask <- readAFNI(paste0(this_dir,brain_mask_file))
  # This next apply command puts the brain voxels in each MRI 
  # contrast as a separate column vector
  all_brain <- apply(all_us, 4, function(y) {
    y[as.logical(drop(brain_mask))]
  })
  image_names <- strsplit(all_us@BRICK_LABS,"~")[[1]]
  stopifnot(image_names==images)
  
  cat("Loading subject",this_sub,"masks\n")
  # These next commands subsets the GM/WM/CSF masks to be
  # binary masks only in the brain
  wm_mask <- readAFNI(paste0(this_dir,wm_mask_file))
  wm_brain <- drop(wm_mask[as.logical(brain_mask)])
  gm_mask <- readAFNI(paste0(this_dir,gm_mask_file))
  gm_brain <- drop(gm_mask[as.logical(brain_mask)])
  csf_mask <- readAFNI(paste0(this_dir,csf_mask_file))
  csf_brain <- drop(csf_mask[as.logical(brain_mask)])
  
  all_wm <- apply(all_brain, 2, function(z) {
    z[as.logical(wm_brain)]
  })
  all_gm <- apply(all_brain, 2, function(z) {
    z[as.logical(gm_brain)]
  })
  all_csf <- apply(all_brain, 2, function(z) {
    z[as.logical(csf_brain)]
  })
  
  
  df <- get_data_df(all_wm, all_gm, all_csf, image_names, this_sub)
  return(df)
}))

p_us <- ggplot(data=out_us, aes(x=Value, color=Id)) + geom_density() + 
  facet_wrap(~ Image + Class, ncol=4, scales="free") + 
  ggtitle("Comparison of image intensity densities in the brain across subjects,\nbroken down by MRI contrast and tissue class\nUnscaled images")
ggsave(filename="~/Documents/NIH/dens_us.png", plot=p_us, width=15, height=20, units="in")