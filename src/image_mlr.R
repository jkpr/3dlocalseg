# Multinomial Logistic Regression
library(nnet)
base_dir <- "~/.secret/NIH/"
setwd(base_dir)
source("load_data.R")
source("spline.R")
source("similarity.R")

write_preds_to_afni <- function(preds, id, model)
{   
    pr_file <- paste0("mlr_", id, "_", model, "_p+orig")
    cl_file <- paste0("mlr_", id, "_", model, "_c+orig")
    # Preds should be a matrix, the result of multinom
    preds_pr <- preds[,1:3]
    colnames(preds_pr) <- c("CSF","GM","WM")
    preds_cl <- preds[,4]
    
    mask_file <- paste0(base_dir,id,"/frs_seg+orig.HEAD")
    mask <- read.AFNI(mask_file)
    new_dim <- mask$dim
    new_dim[4] <- ncol(preds_pr)
    preds_array <- array(0, dim=new_dim)
    for(i in 1:ncol(preds_pr)){
        preds_array[,,,i][as.logical(mask$brk)] <- preds_pr[,i]
    }
    labels <- paste0("P(c=",colnames(preds_pr),"|A)")
    write.AFNI(filename=pr_file, brk=preds_array, label=labels, 
               origin=mask$origin, delta=mask$delta, orient=mask$orient, 
               view="+orig")
    
    preds_vol <- convert_vector_to_image(preds_cl, mask$brk)
    write.AFNI(filename=cl_file, brk=preds_vol, origin=mask$origin, 
               delta=mask$delta, orient=mask$orient, view="+orig")
}

cross_validate_by_id <- function(df, test_id, model_formula, 
                                 reduce_train_size = 1)
{
    test <- subset(df, id == test_id)
    train <- subset(df, id != test_id)
    
    if (0 < reduce_train_size && reduce_train_size < 1)
    {
        reduction_ids <- sample(seq_len(nrow(train)), 
                                ceiling(nrow(train)*reduce_train_size))
        train <- train[reduction_ids,]
    }
    
    model <- multinom(formula=model_formula, data=train, maxit=300)
    preds_pr <- predict(model, newdata=test, "probs")
    preds_cl <- predict(model, newdata=test)
    all_preds <- as.data.frame(preds_pr)
    all_preds$cl <- preds_cl
    return(all_preds)
}

full_model <- function(df, all_data)
{
    base <- "cl ~ t1 + t2 + pd + fl + wt"
    others <- "t1_1 + t1_2 + t1_3 + t1_4 + mtc_1 + mtc_2 + mtc_3"
    model_A_formula <- as.formula(paste(base, others, sep=" + "))
    
    out <- lapply(as.character(unique(df$id)), function(test_id)
    {
        cat("Working with",test_id)
        preds <-cross_validate_by_id(df, test_id, model_A_formula)
        write_preds_to_afni(preds, test_id, "full")
        test_cl <- subset(df, id == test_id)$cl
        this_simil <- get_similarity(factor(test_cl, labels=c("CSF","GM","WM")),
                                     preds$cl)
        save(this_simil, file=paste0("mlr_full_similarity_",test_id,".rda"))
        return(preds)
    })
    
    all_preds <- do.call(rbind, out)
    stopifnot(all_preds$id == df$id)
    
    simil <- get_similarity(factor(df$cl, labels=c("CSF","GM","WM")),
                            all_preds$cl)
    
    save(simil, file="mlr_full_similarity.rda")
}

spline_model <- function(df, all_data)
{
    base <- "cl ~ t1 + t2 + pd + fl + wt"
    spline_inds <- grep("_sp", colnames(df))
    spline_terms <- colnames(df)[spline_inds]
    splines <- paste(spline_terms, collapse=" + ")
    model_B_formula <- as.formula(paste(base, splines, sep=" + "))

    out <- lapply(as.character(unique(df$id)), function(test_id)
    {
        cat("Working with",test_id)
        preds <-cross_validate_by_id(df, test_id, model_B_formula)
        write_preds_to_afni(preds, test_id, "spline")
        test_cl <- subset(df, id == test_id)$cl
        this_simil <- get_similarity(factor(test_cl, labels=c("CSF","GM","WM")),
                                     preds$cl)
        save(this_simil, file=paste0("mlr_spline_similarity_",test_id,".rda"))
        return(preds)
    })
    
    all_preds <- do.call(rbind, out)
    stopifnot(all_preds$id == df$id)
    
    simil <- get_similarity(factor(df$cl, labels=c("CSF","GM","WM")),
                            all_preds$cl)
    
    save(simil, file="mlr_spline_similarity.rda")
}

run_all_mlr <- function(test=c("fsl","freesurfer","toads"))
{
    test <- match.arg(test)
    data_info <- get_data_info(test)
    all_data <- get_all_masked_images(data_info)
    id_col <- which(colnames(all_data) == "id")
    cl_col <- which(colnames(all_data) == "cl")
    spline_table <- list(t1=1:3, t2=1:3, pd=1:3, fl=1:3, wt=1:3, mtc_3=1:3)
    all_data_w_splines <- get_df_w_spline(all_data[,-c(id_col,cl_col)], 
                                          all_data[,cl_col], spline_table)
    df <- cbind(all_data[,c(cl_col,id_col)], all_data_w_splines)
    
    cat("Running full model at",date(),"\n")
    full_model(df, all_data)
    cat("Running spline model at",date(),"\n")
    spline_model(df, all_data)
}