# UUoU calculations

source("/Users/james/Documents/programming/AFNI/AFNIio.R")
setwd("~/Google Drive/Documents/NIH")
volume_all <- read.AFNI("edge_vol+orig.HEAD")
volume <- drop(volume$brk)
volume_vec <- volume_brk[volume_brk > 0]
# 90 percentile of non-neg values divided by 3
# or median?
# Perhaps dilate and erode to help fill the little gaps?
# Anterior commissure i,j,k = 1+(121,99,88)

get_seq_length <- function(volume_dimen, multiplier = 1)
{
    result <- round(sum(volume_dimen)*multiplier)
    rounded <- round(result)
    to_return <- ifelse(rounded < 0, 0, rounded)
    return(to_return)
}

get_seq <- function(volume_dimen, multiplier=1)
{
    seq_length <- get_seq_length(volume_dimen, multiplier)
    this_seq <- seq(0,1,length=seq_length)
    return(this_seq)
}

get_radius_unit_vector <- function(voxel, seed, voxel_dimen)
{
    radius_vector <- (voxel - seed)*voxel_dimen
    vector_length <- sqrt(sum(radius_vector*radius_vector))
    unit_vector <- radius_vector/vector_length
    return(unit_vector)
}

ijk_to_xyz <- function(voxel, voxel_dimen)
{
    xyz <- (voxel - 0.5)*voxel_dimen
    return(xyz)
}

xyz_to_ijk <- function(xyz, voxel_dimen)
{
    # Find the boundaries of a voxel centered at (x,y,z) in (i,j,k) space
    fuzzy_min <- xyz/voxel_dimen - 0.5
    fuzzy_max <- xyz/voxel_dimen + 0.5
    # Shift the box since the centers are offset by a half in all dimensions
    fuzzy_min <- fuzzy_min + 0.5
    fuzzy_max <- fuzzy_max + 0.5
    ijk_guess_1 <- ceiling(fuzzy_min)
    ijk_guess_2 <- floor(fuzzy_max)
    # There should only be one integer in between the min and the max
    stopifnot(ijk_guess_1 == ijk_guess_2)
    return(ijk_guess_1)
}

#' Return a point in (x.y,z) space that is just outside the volume along the
#' radial line established by the voxel and the seed
#'
#'
#'
get_last_radius_pt <- function(voxel, seed, voxel_dimen, volume_dimen)
{
    unit_vector <- get_radius_unit_vector(voxel, seed, voxel_dimen)
    voxel_length <- sqrt(sum(voxel_dimen*voxel_dimen))
    scale_factor <- 8
    new_r_vec <- unit_vector*voxel_length/scale_factor
    seq_multiples <- rep(seq_len(sum(volume_dimen)*scale_factor),
                         each=length(new_r_vec)) - 1
    r_vec_multiples <- new_r_vec*seq_multiples
    seed_xyz <- ijk_to_xyz(seed, voxel_dimen)
    r_vec_points <- seed_xyz + r_vec_multiples
    # Each point along radius is a row in a matrix, starting at seed
    radius_mat <- matrix(r_vec_points,ncol=length(new_r_vec),byrow=TRUE)
    # Get matrix that tells if each coordinate is inside volume
    xyz_ok <- t(apply(radius_mat, 1, function(xyz){
        voxel_ok <- (xyz > 0) & (xyz < volume_dimen*voxel_dimen)
        return(voxel_ok)
    }))
    # Get all rows that are outside volume
    outside_mat_inds <- which(!apply(xyz_ok, 1, all))
    # There should be some outside the volume, if not, throw an error
    stopifnot(length(outside_mat_inds) > 0)
    outside_mat_ind <- min(outside_mat_inds)
    last_pt <- radius_mat[outside_mat_ind,]
    return(last_pt)
}

#' Return a matrix that contains points along the radial vector from seed to
#' voxel. Ideally, the points will be close together.
#'
#'
get_radius_points <- function(voxel, seed, voxel_dimen, volume_dimen)
{
    first_pt <- ijk_to_xyz(seed, voxel_dimen)
    last_pt <- get_last_radius_pt(voxel, seed, voxel_dimen, volume_dimen)
    vec <- last_pt - first_pt
    scale_factor <- 8
    seq_multiples <- rep(get_seq(volume_dimen, scale_factor),each=length(vec))
    r_vec_multiples <- seq_multiples*vec
    r_vec_points <- first_pt + r_vec_multiples
    radius_mat <- matrix(r_vec_points,ncol=length(new_r_vec),byrow=TRUE)
    return(radius_mat)
}

#' Get the (i,j,k) coordinates of the matrix cells along the radius defined by
#' voxel and seed
#'
#'
get_ijk_voxels <- function(xyz_mat, voxel_dimen, volumen_dimen)
{
    ijk_mat_all <- t(apply(xyz_mat, 1, xyz_to_ijk, voxel_dimen=voxel_dimen))
    ijk_mat_unique <- unique(ijk_mat_all)
    ijk_ok <- t(apply(ijk_mat_unique, 1, function(ijk){
        index_ok <- (ijk > 0) & (ijk <= volume_dimen)
    }))
    ijk_inds <- which(apply(ijk_ok, 1, all))
    ijk_mat <- ijk_mat_unique[ijk_inds,]
    return(ijk_mat)
}

get_volume_dimen <- function(volume)
{
    volume_dimen <- dim(volume)
    return(volume_dimen)
}

get_cutoff <- function(volume, prob=0.9, scale=3)
{
    volume_positive <- volume[volume > 0]
    cutoff <- unname(quantile(volume_positive, probs=prob)/scale)
    return(cutoff)
}


#'
#'
#' @param voxel A vector in c(i,j,k) format to denote the voxel to calculate 
#' edge distance ratio
#' @param seed A vector in c(i,j,k) format to denote the seed voxel
#' @param voxel_dimen A vector that has the voxel dimensions in the same units
#' @param volume A 3d image, indexable by volume[i,j,k]
#' @return Returns a data frame with columns i, j, k, ratio
get_ijk_ratio <- function(voxel, seed, voxel_dimen, volume, cutoff)
{
    volume_dimen <- get_volume_dimen(volume)
    xyz_mat <- get_radius_points(voxel, seed, voxel_dimen, volume_dimen)
    ijk_mat <- get_ijk_voxels(xyz_mat, voxel_dimen, volume_dimen)
    radius_values <- t(apply(ijk_mat,1,function(ijk){
        intensity <- volume[ijk[1],ijk[2],ijk[3]]
        dist <- sqrt(sum(((ijk - seed)*voxel_dimen)*((ijk - seed)*voxel_dimen)))
        return(c(dist, intensity))
    }))
    last_voxel_row <- max(which(radius_values[,2] > cutoff))
    last_voxel_dist <- radius_values[last_voxel_row,1]
    stopifnot(last_voxel_dist > 0)
    ratios <- sapply(radius_values[,1], function(x) x/last_voxel_dist)
    df <- as.data.frame(ijk_mat)
    colnames(df) <- c("i","j","k")
    df$ratio <- ratios
    return(df)
}

get_ratio_volume <- function(seed, voxel_dimen, volume, overwrite=FALSE)
{
    cutoff <- get_cutoff(volume)
    volume_dimen <- get_volume_dimen(volume)
    ratio_volume <- array(data= -1, dim=volume_dimen)
    for (i in 1:volume_dimen[1])
    {
        for (j in 1:volume_dimen[2])
        {
            for (k in 1:volume_dimen[3])
            {
                voxel <- c(i,j,k)
                
                # Skip this loop if the voxel is the seed
                # or if the voxel already has a value
                voxel_is_seed <- all(voxel == seed)
                voxel_has_value <- (ratio_volume[i,j,k] > -1)
                if (voxel_is_seed | voxel_has_value) next
                
                df <- get_ijk_ratio(voxel, seed, voxel_dimen, volume, cutoff)
                for (l in seq_len(nrow(df)))
                {
                    ind <- matrix(c(df[l,"i"],df[l,"j"],df[l,"k"]),nrow=1)
                    this_voxel_has_value <- ratio_volume[ind] > -1
                    if (this_voxel_has_value){
                        if (overwrite){
                            ratio_volume[ind] <- min(ratio_volume[ind], df[l,"ratio"])
                        }else{
                            next
                        }
                    }else{
                        ratio_volume[ind] <- df[l,"ratio"]
                    }
                }
            }
        }
    }
    return(ratio_volume)
}