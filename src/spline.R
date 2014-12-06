# Integrate a density curve
integrate <- function(d, a=NA, b=NA)
{
    # Assume the x member of d are sorted low to hi
    # Implement the trapezoial rule
    n <- length(d$x)
    stopifnot(n == length(d$y))
    
    which_low_x <- which(d$x < a)
    min_ind <- ifelse(length(which_low_x) == 0, 1, max(which_low_x))
    which_hi_x <- which(d$x > b)
    max_ind <- ifelse(length(which_hi_x) == 0, n, min(which_hi_x))
    
    stopifnot(min_ind < max_ind)
    x <- d$x[min_ind:max_ind]
    y <- d$y[min_ind:max_ind]
    len <- length(y)
    integral <- sum(0.5*diff(x)*(y[1:(len-1)] + y[2:len]))
    return(integral)
}

get_mode <- function(d)
{
    dy <- diff(d$y)
    peaks <- which(diff(sign(dy)) == -2) + 1
    plateaus <- which(dy == 0)
    candidate_max <- union(peaks, plateaus)
    stopifnot(length(candidate_max) > 0)
    
    #Function definition not complete
    return(candidate_max)
}

get_mode <- function(d)
{
    max_y <- max(d$y)
    max_ind <- which(d$y == max_y)
    mode <- d$x[max_ind]
    return(mode)
}


# If the density is multimodal, we want to take the farthest right endpoint
get_right <- function(vec)
{
    d <- diff(vec)
    d_ind <- which(d != 1)
    outside <- ifelse(length(d_ind) == 0, min(vec), vec[max(d_ind)+1])
    return(outside)
}

# If the density if multimodal, we want to take the farthest left endpoint
get_left <- function(vec)
{
    d <- diff(vec)
    d_ind <- which(d != 1)
    outside <- ifelse(length(d_ind) == 0, max(vec), vec[min(d_ind)])
    return(outside)
}

#' Returns the mode of the density
get_spline_point <- function(d)
{
    mode <- get_mode(d)
    return(mode)
}

# Left, center, and right of the mode
get_spline_points <- function(d, auc=0.95)
{
    max_y <- max(d$y)
    step_y <- seq(0, max_y, length=500)
    
    max_ind <- which(d$y == max_y)
    stopifnot(length(max_ind) == 1)

    out <- sapply(step_y, function(y){
        end_points <- which(d$y < y)
        lefts <- end_points[end_points < max_ind]
        rights <- end_points[end_points > max_ind]
        left <- ifelse(length(lefts) == 0, NA, d$x[get_left(lefts)])
        right <- ifelse(length(rights) == 0, NA, d$x[get_right(rights)])
        i <- integrate(d, left, right)
        lryi <- c(left, right, y, i)
        return(lryi)
    })
    
    # Out is a matrix, and the fourth row has the integral values
    i <- out[4,]
    keepers <- which(i > auc)
    best_range <- drop(out[1:2,max(keepers)])
    stopifnot(all(!is.na(best_range)))
    lcr <- c(best_range[1], d$x[max_ind], best_range[2])
    return(lcr)
}



# Positive part
pp <- function(x)
{
    as.numeric(x > 0)*x
}

get_all_knots <- function(df, labels, spline_table)
{
    image_types <- names(spline_table)
    all_knots <- lapply(image_types, function(x){
        cats_to_spline <- spline_table[[x]]
        out <- sapply(cats_to_spline, function(y){
            this_subset <- subset(df, labels == y)
            this_d <- density(this_subset[,x]) 
            knot <- get_spline_point(this_d)
            return(knot)
        })
        sorted_knots <- sort(as.vector(out))
        return(sorted_knots)
    })
    names(all_knots) <- image_types
    return(all_knots)
}

#' Return a data frame with original image data and splines
#' 
#' @param df Data frame with the original image data. The names of the columns
#' are assumed to be the names of the MRI sequences.
#' @param labels Tissue classifications for each row. Default is CSF - 1, 
#' GM - 2, and WM - 3
#' @param spline_table A list with a vector for each image containing 
#' the pertinent labels to make a spline. For example, Water Image should 
#' have c(1) and FLAIR should have c(1,2,3).
#' @param suff The splines are named [MRI sequence][suff][spline number].
#' Splines are sorted
get_df_w_spline <- function(df, labels, spline_table, suff="_sp")
{
    #image_types <- colnames(df)
    image_types <- names(spline_table)
    all_knots <- get_all_knots(df, labels, spline_table)
    
    # For each image type, get a data frame
    all_splines <- lapply(image_types, function(x){
        # For each knot, get the adjusted positive part
        spline_mat <- sapply(all_knots[[x]], function(y){
            pp(df[,x] - y)
        })
        spline_df <- as.data.frame(spline_mat)
        df_names <- paste0(x,suff,seq_len(ncol(spline_df)))
        names(spline_df) <- df_names
        return(spline_df)
    })
    all_splines_df <- do.call(cbind,all_splines)
    full_df <- cbind(df, all_splines_df)
    return(full_df)
}