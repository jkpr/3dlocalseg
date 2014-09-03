library(oro.nifti)
library(nnet)

setwd("~/Documents/NIH")
images <- c("fl","t1_1","t1_2","t1_3","t1_4","wt_rs","mtc_1","mtc_2","mtc_3")
subjects <- c("04","13","27")

#x <- subjects[3]

multinom_df <- do.call(rbind,lapply(subjects, function(x){
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
  df_brain <- as.data.frame(all_brain)
  colnames(df_brain) <- image_names
  
  cat("Loading subject",x,"masks\n")
  wm_mask <- readAFNI(paste0(this_dir,"/wm_mask2+orig.HEAD"))
  wm_brain <- drop(wm_mask[as.logical(brain_mask)])
  gm_mask <- readAFNI(paste0(this_dir,"/gm_mask1+orig.HEAD"))
  gm_brain <- drop(gm_mask[as.logical(brain_mask)])
  csf_mask <- readAFNI(paste0(this_dir,"/csf_mask1+orig.HEAD"))
  csf_brain <- drop(csf_mask[as.logical(brain_mask)])
  
  y <- wm_brain + 2*gm_brain + 4*csf_brain
  uni_y <- unique(y)
  stopifnot(uni_y %in% c(0,1,2,4))
  
  df <- cbind(data.frame(Id=x, y=y), df_brain)
  return(df)
}))

multinom_df$y <- factor(multinom_df$y)
levels(multinom_df$y) <- c("OTHER","WM","GM","CSF")
mult_form <- as.formula("y ~ fl + t1_1 + t1_2 + t1_3 + t1_4 + wt_rs + mtc_1 + mtc_2 + mtc_3")
modelA <- multinom(mult_form, data=multinom_df)

modelB <- multinom(formula=mult_form, data=subset(multinom_df, Id=="04" | Id=="13"))
modelB_preds <- predict(modelB, newdata=subset(multinom_df, Id=="27"), "probs")
modelB_max_p_class <- factor(apply(modelB_preds, 1, function(x) names(which.max(x))))
names(which.max(modelB$fitted.values))
