# knn, parallelized....
library(FNN)
base_dir <- "~/.secret/NIH/"
setwd(base_dir)
source("load_data.R")
source("similarity.R")

#'
#'
#' @param df Should be a matrix with just the images
#' @param cl The classifications of each row, a vector the same length as the 
#' number of rows as df
#' @param id The subject id of each row, a vector the same length as the 
#' number of rows as df  
cross_validate_by_id <- function(df, cl, id, test_id, reduce_train_size = 1)
{
    test <- subset(df, id == test_id)
    train <- subset(df, id != test_id)
    train_cl <- cl[id != test_id]
    if (0 < reduce_train_size && reduce_train_size < 1)
    {
        reduction_ids <- sample(seq_len(nrow(train)), 
                                ceiling(nrow(train)*reduce_train_size))
        train <- train[reduction_ids,]
        train_cl <- train_cl[reduction_ids]
    }
    
    k <- floor(sqrt(nrow(train)))

    test_cl <- knn(train, test, train_cl, k)
    return(test_cl)
}

run_one_knn <- function(test_id=c("04","13","27","29"), 
                    test=c("fsl","freesurfer","toads"), 
                    reduce_train_size=0.05)
{
    test_id <- match.arg(test_id)
    test <- match.arg(test)
    data_info <- get_data_info(test)
    all_data <- get_all_masked_images(data_info)
    images_to_use <- c("t1","t2","pd","fl","wt","mtc_3")
    df <- as.data.frame(scale(all_data[,images_to_use]))
    
    cl <- all_data[,"cl"]
    id <- all_data[,"id"]
    
    test_cl <- cross_validate_by_id(df, cl, id, test_id, reduce_train_size)
    return(test_cl)
}

run_all_knn <- function(test_id=c("04","13","27","29"), 
                        test=c("fsl","freesurfer","toads"), 
                        reduce_train_size=0.05, n_reps=20)
{
    return(0)
}

get_row_maxes <- function(mat)
{
    sapply(seq_len(nrow(mat)), function(row)
    {
        this_row <- mat[row,]
        this_table <- table(this_row)
        max_count <- max(this_table)
        max_ind <- which(this_table == max_count)
        max_elem <- names(this_table)[max_ind]
        random_elem <- sample(max_elem,1)
        cl <- as.numeric(random_elem)
        return(random_elem)
    })
}

combine_results <- function(test=c("fsl","freesurfer","toads"))
{
    test <- match.arg(test)
    data_info <- get_data_info(test)
    
    out <- lapply(seq_len(nrow(data_info)), function(x)
    {
        id <- data_info[x,"id"]
        mask_file <- data_info[x,"mask"]
        mask_vol <- read.AFNI(mask_file)
        min <- (x-1)*20+1
        max <- (x)*20
        
        all_image_files <- paste0("knn_",test,"_",id,"_arr_",min:max,"+orig.BRIK")
        which_to_keep <- all_image_files %in% dir()
        image_files <- all_image_files[which_to_keep]
        all_reps <- sapply(image_files, function(file_name)
        {
            image_vol <- read.AFNI(file_name)
            vec <- apply_mask(image_vol$brk, mask_vol$brk)
            return(vec)
        })
        knn_vec <- get_row_maxes(all_reps)
        dest_file <- paste0(test,"_knn_",id,"+orig")
        write_vec_with_mask_afni(knn_vec, mask_vol, dest_file)
        
        mask_vec <- apply_mask(mask_vol$brk, mask_vol$brk)
        this_simil <- get_similarity(factor(mask_vec,labels=c("CSF","GM","WM")),
                                     knn_vec)
        save(this_simil, file=paste0(test,"_knn_",id,"_similarity.rda"))
        
        df <- data.frame(truth=mask_vec, fitted=knn_vec, id=id)
        return(df)
    })
    
    all_df <- do.call(rbind,out)
    simil <- get_similarity(factor(all_df$truth,labels=c("CSF","GM","WM")),
                            all_df$fitted)
    file_all_combined <- paste0(test,"_knn_similarity.rda")
    save(simil, file=file_all_combined)
}