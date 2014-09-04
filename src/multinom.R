library(oro.nifti)
library(nnet)
source("/Users/pringlejk/Documents/afni_files/AFNIio.R")

setwd("~/Documents/NIH")
images <- c("fl","t1_1","t1_2","t1_3","t1_4","wt_rs","mtc_1","mtc_2","mtc_3")
subjects <- c("04","13","27")
mult_form <- as.formula("y ~ fl + t1_1 + t1_2 + t1_3 + t1_4 + wt_rs + mtc_1 + mtc_2 + mtc_3")

classes <- c("OTHER","WM","GM","CSF")
label_map <- list(OTHER=1, WM=11, GM=21, CSF=31)
mc_map <- expand.grid(classes,classes)
names(mc_map) <- c("Fitted","Truth")
mc_map$Value <- rep((0:3)*10,each=4) + rep(1:4,4)
mc_maplist <- list()
for(i in 1:nrow(mc_map)){
  mc_maplist[[paste0(mc_map[i,1], mc_map[i,2])]] <- mc_map[i,3]
}

write.table(cbind(paste0("Fitted:",mc_map$Fitted,"~Truth:",mc_map$Truth),mc_map$Value),file="labels.txt",row.names=FALSE,col.names=FALSE)

get_confusion_matrix <- function(truth, fitted){
  # truth and fitted should be factor vectors with same levels
  truth_levels <- levels(truth)
  refitted <- factor(fitted, levels=truth_levels)
  
  out <- t(sapply(truth_levels, function(x){
    truth_voxels <- which(truth==x)
    one_row <- table(refitted[truth_voxels])
    return(one_row)
  }))
  n <- rowSums(out)
  
  df <- as.data.frame(apply(out, 2, function(x) x/n))
  df$n <- n
  return(df)
}

write_conf_matrix <- function(mat, file=NULL){
  cm <- max(nchar(colnames(mat))) + 1
  nm <- max(nchar(mat[,ncol(mat)]))
  m <- max(nm,cm)
  s <- paste(rep(" ",m),collapse="")
  str <- paste(sprintf(paste0("%",m,"s"), c("",colnames(mat))),collapse=" ")
  str <- paste0(sprintf(paste0("%",round(nchar(str)/2)+7+m,"s"), "Predicted"),"\n",s,str)
  str <- paste0(str,"\n")
  for(i in seq_len(nrow(mat))){
    if (i == round(nrow(mat)/2+1)){
      str <- paste0(str,sprintf(paste0("%",m-1,"s"),"Truth")," ")
    } else {
      str <- paste0(str,s)
    }
    str <- paste0(str,sprintf(paste0("%",m,"s"),rownames(mat)[i]))
    for(j in seq_len(ncol(mat))){
      if (j == ncol(mat)){
        str <- paste0(str," ",sprintf(paste0("%",m,"d"),mat[i,j]))
      }else{
        str <- paste0(str," ",sprintf(paste0("%",m,".",m-2,"f"),mat[i,j]))
      }
    }
    str <- paste0(str,"\n")
  }
  if (is.null(file)){
    return(str)
  } else {
    sink(file)
    cat(str)
    sink()
  }
}

convert_labels_to_numbers <- function(vec, map){
  new_vec <- rowSums(sapply(levels(vec), function(x){
    as.numeric(vec==x) * map[[x]]
  }))
  return(new_vec)
}

convert_labels_to_numbers2 <- function(fitted, truth, map){
  label <- paste0(fitted,truth)
  new_vec <- sapply(label, function(x) map[[x]])
  return(new_vec)
}

convert_vector_to_image <- function(vec, mask){
  # Mask should be AFNI class
  mask[as.logical(mask)] <- vec
  return(mask)
}

write_probs_to_afni <- function(preds, id, dest_file=paste0("results",id,"_p+orig")){
  # Preds should be a matrix, the result of multinom
  reordered <- preds[,order(colnames(preds))]
  mask_file <- paste0("a201302",id,"/brain_mask_sm+orig.HEAD")
  mask <- read.AFNI(mask_file)
  new_dim <- mask$dim
  new_dim[4] <- ncol(reordered)
  preds_array <- array(0, dim=new_dim)
  for(i in 1:ncol(reordered)){
    preds_array[,,,i][as.logical(mask$brk)] <- reordered[,i]
  }
  labels <- paste0("P(c=",colnames(reordered),"|A)")
  write.AFNI(filename=dest_file, brk=preds_array, label=labels, 
             origin=mask$origin, delta=mask$delta, orient=mask$orient, view="+orig")
}

save_to_afni <- function(image, dest_file){
  if (image@BRICK_TYPES == 0L) image@BRICK_TYPES <- 1L
  image@BRICK_STATS <- c(0,max(image))
  writeAFNI(nim=image,fname=dest_file)
}

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


# Saturated model
modelA <- multinom(mult_form, data=multinom_df)

# Predict on 27
modelB <- multinom(formula=mult_form, data=subset(multinom_df, Id=="04" | Id=="13"))

modelB_preds <- predict(modelB, newdata=subset(multinom_df, Id=="27"), "probs")
write_probs_to_afni(modelB_preds, id="27")

modelB_max_p_class <- predict(modelB, newdata=subset(multinom_df, Id=="27"))
#modelB_max_p_class <- factor(apply(modelB_preds, 1, function(x) names(which.max(x))))

modelB_conf_mat <- get_confusion_matrix(subset(multinom_df,Id=="27")$y, modelB_max_p_class)
write_conf_matrix(modelB_conf_mat, "conf_mat27.txt")

num_vecB <- convert_labels_to_numbers(modelB_max_p_class, label_map)
afni_imB <- convert_vector_to_image(num_vecB, readAFNI(paste0("a201302","27","/brain_mask_sm+orig.HEAD")))
save_to_afni(afni_imB, "results27+orig")

num_vec2B <- convert_labels_to_numbers2(modelB_max_p_class, subset(multinom_df,Id=="27")$y, mc_maplist)
afni_im2B <- convert_vector_to_image(num_vec2B, readAFNI(paste0("a201302","27","/brain_mask_sm+orig.HEAD")))
save_to_afni(afni_im2B, "results_mc27+orig")

# Predict on 04
modelC <- multinom(formula=mult_form, data=subset(multinom_df, Id=="27" | Id=="13"))

modelC_preds <- predict(modelC, newdata=subset(multinom_df, Id=="04"), "probs")
write_probs_to_afni(modelC_preds, id="04")

modelC_max_p_class <- predict(modelC, newdata=subset(multinom_df, Id=="04"))
modelC_conf_mat <- get_confusion_matrix(subset(multinom_df,Id=="04")$y, modelC_max_p_class)
write_conf_matrix(modelC_conf_mat, "conf_mat04.txt")

num_vecC <- convert_labels_to_numbers(modelC_max_p_class, label_map)
afni_imC <- convert_vector_to_image(num_vecC, readAFNI(paste0("a201302","04","/brain_mask_sm+orig.HEAD")))
save_to_afni(afni_imC, "results04+orig")
modelC_conf_mat <- get_confusion_matrix(subset(multinom_df,Id=="04")$y, modelC_max_p_class)

num_vec2C <- convert_labels_to_numbers2(modelC_max_p_class, subset(multinom_df,Id=="04")$y, mc_maplist)
afni_im2C <- convert_vector_to_image(num_vec2C, readAFNI(paste0("a201302","04","/brain_mask_sm+orig.HEAD")))
save_to_afni(afni_im2C, "results_mc04+orig")
  
# Predict on 13
modelD <- multinom(formula=mult_form, data=subset(multinom_df, Id=="27" | Id=="04"))

modelD_preds <- predict(modelD, newdata=subset(multinom_df, Id=="13"), "probs")
write_probs_to_afni(modelD_preds, id="13")

modelD_max_p_class <- predict(modelD, newdata=subset(multinom_df, Id=="13"))
modelD_conf_mat <- get_confusion_matrix(subset(multinom_df,Id=="13")$y, modelD_max_p_class)
write_conf_matrix(modelD_conf_mat, "conf_mat13.txt")

num_vecD <- convert_labels_to_numbers(modelD_max_p_class, label_map)
afni_imD <- convert_vector_to_image(num_vecD, readAFNI(paste0("a201302","13","/brain_mask_sm+orig.HEAD")))
save_to_afni(afni_imD, "results13+orig")

num_vec2D <- convert_labels_to_numbers2(modelD_max_p_class, subset(multinom_df,Id=="13")$y, mc_maplist)
afni_im2D <- convert_vector_to_image(num_vec2D, readAFNI(paste0("a201302","13","/brain_mask_sm+orig.HEAD")))
save_to_afni(afni_im2D, "results_mc13+orig")



## Stuff to do in the shell
# new ID for stuff
# 3drefit -newid results27+orig
# 3drefit -newid results_mc27+orig
# 3drefit -redo_bstat results_mc27+orig
# @MakeLabelTable -lab_file labels.txt 0 1 -dset results_mc27+orig