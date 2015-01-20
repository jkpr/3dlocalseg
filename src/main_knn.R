# Main knn
base_dir <- "~/.secret/NIH/"
setwd(base_dir)
source("image_knn.R")

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 0)
{
    test <- "fsl"
    
    array_id <- as.numeric(args[1])
    test_id <- ""
    if (1 <= array_id && array_id <= 20) {
        test_id <- "04"
    } else if (21 <= array_id && array_id <= 40) {
        test_id <- "13"
    } else if (41 <= array_id && array_id <= 60) {
        test_id <- "27"
    } else if (61 <= array_id && array_id <= 80) {
        test_id <- "29"
    }
    
    start_time <- Sys.time()
    test_cl <- run_one_knn(test_id, test)
    end_time <- Sys.time()
    diff_time <- end_time - start_time
    filename <- paste0("knn_arr_",array_id,".rda")
    save(start_time, end_time, diff_time, test_id, array_id, file=filename)
    
    data_info <- get_data_info(test)
    data_row <- which(test_id == data_info$id)
    mask_file <- data_info[data_row,"mask"]
    dest_file <- paste0("knn_",test,"_",test_id,"_arr_",array_id,"+orig")
    write_vec_afni(test_cl, mask_file, dest_file)
}
