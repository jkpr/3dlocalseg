# radiologist ratings
# Have 4 slices of interest for each subject and test and model combination
library(ggplot2)


set.seed(2014-11-12)
slice_of_interest <- c("a1","a2","c1","s1")
subject <- c("04","13","27","29")
test <- c("FSL","FreeSurfer","TOADS")
model <- c("MLR - Full","MLR - Spline","k-NN")

df <- expand.grid(slice_of_interest, model, test, subject)
df$swap <- sample(c(1,-1), size=nrow(df), replace=T)
df_order <- sample(seq_len(nrow(df)), size=nrow(df))
df_scrambled <- df[df_order,]
names(df_scrambled) <- c("Slice","Classification","Software","Subject","swap")


labels <- paste0(rep(LETTERS[1:12], each=12),sprintf("%02d",rep(1:12, 12)))
df_scrambled$Labels <- labels




# For each row of data frame, generate ImageMagick code
out <- apply(df_scrambled, 1, function(x) {
    print(x)
    
    software <- ""
    subject <- x[4]
    if (x[3] == "FreeSurfer") {
        software <- "frs"
    } else if (x[3] == "FSL") {
        software <- "fsl"
    } else if (x[3] == "TOADS") {
        software <- "toads"
    } else {
        stop("Unrecognized software", x[3])
    }
    folder <- paste0(software,"_",subject)
    slice <- x[1]
    
    classification <- ""
    if (x[2] == "MLR - Full") {
        classification <- "mlr_full"
    } else if (x[2] == "MLR - Spline") {
        classification <- "mlr_spline"
    } else if (x[2] == "k-NN") {
        classification <- "knn"
    } else {
        stop("Unrecognized classification", x[2])
    }
    
    true_t1 <- paste0(folder,"/",slice, "_truth.jpg")
    software_seg <- paste0(folder,"/",slice,"_",software,".jpg")
    classification_seg <- paste0(folder,"/",slice,"_",classification,".jpg")
    diff <- paste0(folder,"/",slice,"_",classification,"_diff.jpg")
    
    image_order <- ifelse(x[5] == "-1", paste(classification_seg, software_seg),
                                        paste(software_seg, classification_seg))
    dest_file <- paste0(x[6],".jpg")
    command <- paste("montage", true_t1, image_order, diff, 
                     "-mode Concatenate -tile x1", dest_file)
    return(command)
})


scores_a <- c(-1,-2,2,-1,1,-2,1,0,-1,0,1,1)
scores_b <- c(1,-1,-2,-1,0,-2,-1,-2,2,-1,1,1)
scores_c <- c(1,0,-1,2,-2,2,2,-1,1,-1,1,1)
scores_d <- c(-1,-2,2,0,-1,1,-1,2,-1,-1,1,2)
scores_e <- c(-1,-2,-1,-1,1,-1,1,-2,0,1,-2,2)
scores_f <- c(-1,2,-1,1,0,1,-2,-2,0,-1,0,1)
scores_g <- c(1,1,0,1,1,1,-2,1,-1,-2,2,1)
scores_h <- c(1,1,-1,2,1,-1,-2,-2,1,2,2,1)
scores_i <- c(-1,-1,-1,0,-1,2,-2,0,-1,-1,1,2)
scores_j <- c(-1,-1,-1,-2,-1,1,1,1,1,0,-1,1)
scores_k <- c(-1,1,-1,-1,-1,2,-1,-1,0,0,1,-1)
scores_l <- c(-1,1,1,1,1,-1,1,-1,1,0,-1,1)

all_scores <- c(scores_a,scores_b,scores_c,scores_d,scores_e,scores_f,scores_g,
                scores_h,scores_i,scores_j,scores_k,scores_l)

df_scrambled$Score <- all_scores*df_scrambled$swap
df_scrambled$Score <- factor(df_scrambled$Score)

p1 <- ggplot(df_scrambled, aes(Score,fill=Subject)) + geom_bar(position="dodge") + facet_wrap(~ Classification+Software, nrow=3, ncol=3) + ylab("Rating count")
plot(p1)

p2 <- ggplot(df_scrambled, aes(Score,fill=Classification)) + geom_bar(position="dodge") + facet_wrap(~ Software, nrow=3) + ylab("Rating count") + 
    ggtitle("Comparison of classification methods and software segmentations\nwith radiology resident ratings") + scale_y_continuous(breaks=seq(0,15,3))
plot(p2)

p3 <- ggplot(df_scrambled, aes(Score,fill=Software)) + geom_bar(position="dodge") + facet_wrap(~ Classification, nrow=3) + ylab("Rating count") + 
    ggtitle("Comparison of classification methods and software segmentations\nby radiology resident rankings") + scale_y_continuous(breaks=seq(0,15,3))
plot(p3)