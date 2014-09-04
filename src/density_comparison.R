library(oro.nifti)
library(ggplot2)

setwd("~/Documents/NIH")

classes <- c("ALL","WM","GM","CSF")
images <- c("fl","t1_1","t1_2","t1_3","t1_4","wt_rs","mtc_1","mtc_2","mtc_3")
subjects <- c("04","13","27")
folders <- c("EE", "JJ", "HH")
folder_map <- as.list(folders)
names(folder_map) <- subjects

