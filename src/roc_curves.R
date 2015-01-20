# Get ROCs for different tissue classes

base_dir <- "~/.secret/NIH/"
setwd(base_dir)
source("load_data.R")
source("spline.R")
library(ggplot2)

get_probs_and_mask <- function(tissue=c("CSF","GM","WM"),
                               subject=c("04","13","27","29"),
                               test=c("freesurfer", "fsl", "toads"),
                               model=c("full","spline","primitive")) {
    tissue <- match.arg(tissue)
    subject <- match.arg(subject)
    test <- match.arg(test)
    model <- match.arg(model)
    
    all_info <- get_roc_data_info(subject, test, model)
    seg_file <- all_info$seg
    seg <- read.AFNI(seg_file)
    seg_arr <- drop(seg$brk)
    
    mlr_file <- all_info$mlr
    mlr_p <- read.AFNI(mlr_file)
    tissue_index <- which(tissue == c("CSF","GM","WM"))
    mlr_arr <- mlr_p$brk[,,,tissue_index]
    
    seg_vec <- apply_mask(seg_arr, seg_arr)
    tissue_binary <- as.numeric(seg_vec == tissue_index)
    mlr_vec <- apply_mask(mlr_arr, seg_arr)
    
    df <- data.frame(tissue=tissue_binary, model=mlr_vec)
    colnames(df) <- c(tissue,model)
    return(df)
}

#'
#'
#' @param cl Vector of classifications (1 or 0)
#' @param probs Vector of probabilities
get_roc_points <- function(cl, probs) {
    q <- quantile(x=probs, probs=seq(0,1,length=201))
    n_pos <- sum(cl)
    n_false <- length(cl) - n_pos
    out <- sapply(q, function(cutoff) {
        test_pos <- as.numeric(probs >=cutoff)
        true_pos <- sum(cl * test_pos)
        tpr <- true_pos / n_pos
        false_pos <- sum(test_pos) - true_pos
        fpr <- false_pos / n_false
        return(c(fpr,tpr))
    })
    df <- data.frame(fpr = out[1,], tpr = out[2,])
    return(df)
}

get_one_roc_data <- function(subject=c("04","13","27","29"), 
                             test=c("freesurfer", "fsl", "toads"),
                             model=c("full","spline","primitive")) {
    subject <- match.arg(subject)
    test <- match.arg(test)
    model <- match.arg(model)
    
    csf_df <- get_probs_and_mask("CSF",subject,test,model)
    csf_roc_df <- get_roc_points(csf_df[,1], csf_df[,2])
    csf_roc_df$tissue <- "CSF"
    gm_df <- get_probs_and_mask("GM",subject,test,model)
    gm_roc_df <- get_roc_points(gm_df[,1], gm_df[,2])
    gm_roc_df$tissue <- "GM"
    wm_df <- get_probs_and_mask("WM",subject,test,model)
    wm_roc_df <- get_roc_points(wm_df[,1], wm_df[,2])
    wm_roc_df$tissue <- "WM"
    df <- rbind(csf_roc_df,gm_roc_df,wm_roc_df)
    df$model <- model
    df$subject <- subject
    return(df)
}

get_all_roc_data <- function(test=c("freesurfer", "fsl", "toads")) { 
    test <- match.arg(test)
    subject_ids <- c("04","13","27","29")
    out <- lapply(subject_ids, function(subject) {
        full <- get_one_roc_data(subject, test, "spline")
        prim <- get_one_roc_data(subject, test, "primitive")
        this_df <- rbind(full,prim)
        return(this_df)
    })
    df <- do.call(rbind,out)
    return(df)
}

make_roc_plot <- function(test=c("freesurfer", "fsl", "toads")) { 
    test <- match.arg(test)
    df <- get_all_roc_data(test)
    df$Model <- df$model
    df$Subject <- "Subject 1"
    df$Subject[df$subject=="13"] <- "Subject 2"
    df$Subject[df$subject=="27"] <- "Subject 3"
    df$Subject[df$subject=="29"] <- "Subject 4"
    
    
    p <- ggplot(data=df, group=as.factor(tissue),aes(x=fpr, y=tpr)) + 
        geom_line(aes(color=Model)) +
        scale_x_continuous(limits=c(0,0.1),breaks=c(0.00,0.05,0.10)) +
        facet_wrap(~ Subject + tissue, nrow=4, ncol=3) +
        ylab("True Positive Rate") + 
        xlab("False Positive Rate") +
        ggtitle("Partial ROC curves for different tissue classes\nwithin each subject")
    return(p)
}

df_list <- split(df, paste(df$Subject,df$tissue,df$model))
out <- lapply(df_list,function(this_df) {
    d <- data.frame(x=this_df$fpr, y=this_df$tpr)
    d <- d[nrow(d):1,]
    full <- integrate(d,0,1)
    partial <- integrate(d,0,0.1)
    return(data.frame(subject=unique(this_df$subject), 
                      tissue=unique(this_df$tissue),
                      model=unique(this_df$model),
                      partial=partial,
                      full=full))
})

auc <- do.call(rbind,out)
primitive_ind <- 2*(1:12) - 1
spline_ind <- 2*(1:12)
partial_ratios <- sapply(primitive_ind, function(x) {
    partial_ratio <- auc[x+1,"partial"]/auc[x,"partial"]
    return(partial_ratio)
})

full_ratios <- sapply(primitive_ind, function(x) {
    partial_ratio <- auc[x+1,"full"]/auc[x,"full"]
    return(partial_ratio)
})

