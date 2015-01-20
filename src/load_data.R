source("~/afni/AFNIio.R")

apply_mask <- function(image, mask)
{
    dr_image <- drop(image)
    dr_mask <- drop(mask)
    stopifnot(all(dim(dr_image) == dim(dr_mask)))
    masked <- as.vector(dr_image[as.logical(dr_mask)])
    return(masked)
}

convert_vector_to_image <- function(vec, mask)
{
    dr_mask <- drop(mask)
    stopifnot(length(vec)==sum(as.logical(dr_mask)))
    mask[as.logical(dr_mask)] <- vec
    return(mask)
}

write_vec_afni <- function(vec, mask_file, dest_file)
{
    mask <- read.AFNI(mask_file)
    vol <- convert_vector_to_image(vec, mask$brk)
    write.AFNI(filename=dest_file, brk=vol, origin=mask$origin, 
               delta=mask$delta, orient=mask$orient, view="+orig")
}

#'
#' @param mask should be the returned value of read.AFNI
write_vec_with_mask_afni <- function(vec, mask, dest_file)
{
    vol <- convert_vector_to_image(vec, mask$brk)
    write.AFNI(filename=dest_file, brk=vol, origin=mask$origin, 
               delta=mask$delta, orient=mask$orient, view="+orig")
}

get_masked_images <- function(src_file, mask_file)
{
    all_afni <- read.AFNI(src_file)
    this_mask <- read.AFNI(mask_file)
    all_mlr <- as.data.frame(apply(all_afni$brk, 4, apply_mask, 
                                   mask=this_mask$brk))
    im_names <- strsplit(all_afni$NI_head$BRICK_LABS$dat,"~")[[1]]
    im_names <- gsub("\"","",im_names)
    im_names <- gsub(" ","",im_names)
    colnames(all_mlr) <- im_names
    
    # Classifications
    cl <- data.frame(cl=apply_mask(this_mask$brk, this_mask$brk))
    
    # Combine them
    df <- cbind(cl,all_mlr)
    return(df)
}

#' @param data_info A data frame with three columns: id, src, mask. All three
#' are characters, and 'src' and 'mask' should be the file names that for 
#' the image and classification data, respectively.
get_all_masked_images <- function(data_info)
{
    out <- lapply(seq_len(nrow(data_info)), function(x)
    {
        src_file <- data_info[x,"src"]
        mask_file <- data_info[x,"mask"]
        df <- get_masked_images(src_file, mask_file)
        df$id <- data_info[x,"id"]
        return(df)
    })
    all_df <- do.call(rbind,out)
    return(all_df)
}

get_data_info <- function(software=c("fsl","freesurfer","toads"))
{
    software <- match.arg(software)
    id <- c("04","13","27","29")
    src <- paste0("~/.secret/NIH/",id,"/all+orig.HEAD")
    mask <- switch(software,
        fsl= {
            paste0("~/.secret/NIH/",id,"/fsl_seg+orig.HEAD") 
        },
        freesurfer= {
            paste0("~/.secret/NIH/",id,"/frs_seg+orig.HEAD")
        },
        toads= {
            paste0("~/.secret/NIH/",id,"/toads_seg+orig.HEAD")
        })
    df <- data.frame(id=id,src=src,mask=mask, stringsAsFactors=FALSE)
    return(df)
}

get_roc_data_info <- function(subject=c("04","13","27","29"), 
                              test=c("freesurfer", "fsl", "toads"),
                              model=c("full","spline","primitive")) {
    subject <- match.arg(subject)
    test <- match.arg(test)
    model <- match.arg(model)

    src_dir <- paste0("~/.secret/NIH/",subject,"/",test,"_output")
    mlr_file <- paste0(src_dir,"/mlr_",subject,"_",model,"_p+orig.HEAD")
    seg_src_list <- list("freesurfer"="frs","toads"="toads","fsl"="fsl")
    seg_src <- seg_src_list[[test]]
    seg_file <- paste0(src_dir,"/",seg_src,"_seg+orig.HEAD")
    
    all_info <- list(seg=seg_file,mlr=mlr_file)
    return(all_info)
}