# density_comparison2.R
library(ggplot2)
library(reshape2)
base_dir <- "~/.secret/NIH/"
setwd(base_dir)
source("load_data.R")

prettify_image_names <- function(image_names)
{
    l <- list(t1="T1", t2="T2", pd="PD", fl="FLAIR", wt="Water", 
              t1_1="T1 echo 1", t1_2="T1 echo 2", t1_3="T1 echo 3", 
              t1_4="T1 echo 4", mtc_1="MTC 1", mtc_2="MTC 2", mtc_3="MTC 3")
    new_names <- unname(sapply(image_names, function(x)
    {
        if (length(l[[x]]) == 1) {
            l[[x]]
        } else {
            x
        }
    }))
    return(new_names)
}

#'
#' @param images is as list, and each item in the list is a vector of the 
#' specific images to be included in a plot
get_density_plot <- function(images, test=c("fsl","freesurfer","toads"))
{
    test <- match.arg(test)
    data_info <- get_data_info(test)
    all_data <- get_all_masked_images(data_info)
    all_data$Class <- "CSF"
    all_data[all_data$cl==2,"Class"] <- "GM"
    all_data[all_data$cl==3,"Class"] <- "WM"
    
    
    # Add on "All"
    subset_inds <- sample(nrow(all_data), round(0.1*nrow(all_data)))
    brain_data <- all_data[subset_inds,]
    brain_data$Class <- "All"
    
    df <- rbind(all_data, brain_data)
    
    df$Subject <- 1
    df[df$id=="13","Subject"] <- 2
    df[df$id=="27","Subject"] <- 3
    df[df$id=="29","Subject"] <- 4
    df$Subject <- factor(df$Subject)
    
    cl_ind <- which(colnames(df) == "cl")
    id_ind <- which(colnames(df) == "id")
    df <- df[,-c(cl_ind,id_ind)]
    
    out <- lapply(images, function(image_set)
    {
        subset_df <- df[,c(image_set,"Subject","Class")]
        new_colnames <- prettify_image_names(colnames(subset_df))
        colnames(subset_df) <- new_colnames
        
        melted_df <- melt(subset_df, id.vars=c("Subject","Class"), 
                          variable.name="Image")
        
        melted_df_fixed <- subset(melted_df, 
            !(
                (Image == "Water" & value > 30) | 
                (Image == "Water" & Class == "GM" & value > 5) |
                (Image == "Water" & Class == "WM" & value > 3) |
                (Image == "T1" & Class == "CSF" & value > 1.5)    
            )
        )
        
        t1_echoes <- c("T1 echo 1", "T1 echo 2", "T1 echo 3", "T1 echo 4")
        melted_df_fixed <- subset(melted_df,
            !(
                (Image %in% t1_echoes & value > 0.75)    
            )                          
        )
        
        p <- ggplot(data=melted_df_fixed, aes(x=value, color=Subject)) + 
            geom_density() + 
            facet_wrap(~ Image + Class, ncol=4, scales="free") + 
            ggtitle("Comparison of image intensity densities in the brain across subjects,\nbroken down by MRI contrast and tissue class\nScaled images with FSL masks")
        return(p)
    })
    
    i <- 0
    for(p in out)
    {
        i <- i + 1
        filename <- paste0("dens_other_",i,".png")
        ggsave(filename=filename, plot=p, width=13, height=15, units="in")
    }
    
}