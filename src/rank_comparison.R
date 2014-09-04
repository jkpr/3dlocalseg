library(oro.nifti)
library(ggplot2)

setwd("~/Documents/NIH")

probs <- seq(0,1, length=201)
classes <- c("ALL","WM","GM","CSF")
images <- c("fl","t1_1","t1_2","t1_3","t1_4","wt_rs","mtc_1","mtc_2","mtc_3")
subjects <- c("04","13","27")

get_quant_df <- function(quants, id, class, image_names, probs){
  # quants should be a matrix
  Value <- c(quants)
  Image <- rep(image_names, each=nrow(quants))
  Quantile <- rep(probs, times=ncol(quants))
  data.frame(Quantile=Quantile, Value=Value, Image=Image, Class=class, Id=id)
}

#x <- subjects[2]

out <- lapply(subjects, function(x){
  cat("Loading subject",x,"\"all_s\"\n")
  this_dir <- paste0("a201302",x)
  all_s <- readAFNI(paste0(this_dir,"/all_s+orig.HEAD"))
  brain_mask <- readAFNI(paste0(this_dir,"/brain_mask_sm+orig.HEAD"))
  all_brain <- apply(all_s, 4, function(y) {
    y[as.logical(drop(brain_mask))]
  })
  image_names <- strsplit(all_s@BRICK_LABS,"~")[[1]]
  stopifnot(image_names==images)
  rm(all_s)
  
  cat("Loading subject",x,"masks\n")
  wm_mask <- readAFNI(paste0(this_dir,"/wm_mask2+orig.HEAD"))
  wm_brain <- drop(wm_mask[as.logical(brain_mask)])
  gm_mask <- readAFNI(paste0(this_dir,"/gm_mask1+orig.HEAD"))
  gm_brain <- drop(gm_mask[as.logical(brain_mask)])
  csf_mask <- readAFNI(paste0(this_dir,"/csf_mask1+orig.HEAD"))
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

  cat("Getting subject",x,"quantiles\n")
  # Get quantiles
  all_quants <- apply(all_brain, 2, quantile, probs=probs)
  wm_quants <- apply(all_wm, 2, quantile, probs=probs)
  gm_quants <- apply(all_gm, 2, quantile, probs=probs)
  csf_quants <- apply(all_csf, 2, quantile, probs=probs)
  
  all_df <- get_quant_df(all_quants,x,"ALL",image_names,probs)
  wm_df <- get_quant_df(wm_quants,x,"WM",image_names,probs)
  gm_df <- get_quant_df(gm_quants,x,"GM",image_names,probs)
  csf_df <- get_quant_df(csf_quants,x,"CSF",image_names,probs)
  
  df <- rbind(all_df,wm_df,gm_df,csf_df)
  return(df)
})

df <- do.call(rbind, out)

# Plotting stuff
#subset(df,Class=="WM" & Image=="fl")
#ggplot(data=subset(df,Class=="WM" & Image=="fl"), aes(x=Quantile, y=Value, color=Id)) + geom_line()
#ggplot(data=subset(df,Image=="fl"), aes(x=Quantile, y=Value, color=Id)) + geom_line() + facet_wrap(~ Class)

p_s <- ggplot(data=df, aes(x=Quantile, y=Value, color=Id)) + geom_line() + facet_wrap(~ Image + Class, ncol=4, scales="free_y") +
     ggtitle("Comparison of image intensity quantiles in the brain across subjects, broken down by tissue class\nScaled images")
ggsave(filename="quant.png", plot=p_s, width=15, height=20, units="in")


#``````````````````````````,,,,,,,,,,,,,,,,,,,,,,,,,,,,,``````````````````````````

# This code gets the unscaled stuff
# Mount the drive first
setwd("/Volumes/home/pringlejk")

x <- subjects[1]
images_us <- c("fl_alw+orig.HEAD", "t1_1_alw+orig.HEAD", "t1_2_alw+orig.HEAD", 
               "t1_3_alw+orig.HEAD", "t1_4_alw+orig.HEAD", "wt_rs_tmp+orig.HEAD", 
               "mtc_1_alw+orig.HEAD", "mtc_2_alw+orig.HEAD", "mtc_3_alw+orig.HEAD")

data_dir_map <- list()
data_dir_map[[subjects[1]]] <-"EE"
data_dir_map[[subjects[2]]] <- "JJ"
data_dir_map[[subjects[3]]] <- "HH"

df <- do.call(rbind,lapply(subjects, function(x){
  cat("Loading subject",x,"\"all_us\"\n")
  this_dir <- paste0("a201302",x,"/",data_dir_map[[x]])
  all_s <- readAFNI(paste0(this_dir,"/all_us+orig.HEAD"))
  brain_mask <- readAFNI(paste0(this_dir,"/brain_mask_sm+orig.HEAD"))
  all_brain <- apply(all_s, 4, function(y) {
    y[as.logical(drop(brain_mask))]
  })
  image_names <- strsplit(all_s@BRICK_LABS,"~")[[1]]
  stopifnot(image_names==images)
  rm(all_s)
  
  cat("Loading subject",x,"masks\n")
  wm_mask <- readAFNI(paste0(this_dir,"/wm_mask2+orig.HEAD"))
  wm_brain <- drop(wm_mask[as.logical(brain_mask)])
  gm_mask <- readAFNI(paste0(this_dir,"/gm_mask1+orig.HEAD"))
  gm_brain <- drop(gm_mask[as.logical(brain_mask)])
  csf_mask <- readAFNI(paste0(this_dir,"/csf_mask1+orig.HEAD"))
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
  
  cat("Getting subject",x,"quantiles\n")
  # Get quantiles
  all_quants <- apply(all_brain, 2, quantile, probs=probs)
  wm_quants <- apply(all_wm, 2, quantile, probs=probs)
  gm_quants <- apply(all_gm, 2, quantile, probs=probs)
  csf_quants <- apply(all_csf, 2, quantile, probs=probs)
  
  all_df <- get_quant_df(all_quants,x,"ALL",images,probs)
  wm_df <- get_quant_df(wm_quants,x,"WM",images,probs)
  gm_df <- get_quant_df(gm_quants,x,"GM",images,probs)
  csf_df <- get_quant_df(csf_quants,x,"CSF",images,probs)
  
  df <- rbind(all_df,wm_df,gm_df,csf_df)
  return(df)
}))

p_us <- ggplot(data=df, aes(x=Quantile, y=Value, color=Id)) + geom_line() + facet_wrap(~ Image + Class, ncol=4, scales="free_y") +
  ggtitle("Comparison of image intensity quantiles in the brain across subjects, broken down by tissue class\nUnscaled images")
ggsave(filename="~/Documents/NIH/quant_us.png", plot=p_us, width=15, height=20, units="in")

#``````````````````````````,,,,,,,,,,,,,,,,,,,,,,,,,,,,,``````````````````````````