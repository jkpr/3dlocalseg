get_similarity <- function(truth, fitted, 
                           index=c("all","confusion","jaccard","dice"))
{
    index <- match.arg(index)
    
    # truth and fitted should be factor vectors with same levels
    truth_levels <- levels(truth)
    refitted <- factor(fitted, labels=truth_levels)
    
    # Truth is down the rows, Fitted is across the rows
    out <- t(sapply(truth_levels, function(x){
        truth_voxels <- which(truth==x)
        one_row <- table(refitted[truth_voxels])
        return(one_row)
    }))
    row_sums <- rowSums(out)
    
    confusion <- as.data.frame(apply(out, 2, function(x) x/row_sums))
    confusion$n <- row_sums
    
    jaccard <- sapply(truth_levels, function(x)
    {
        intersection <- sum((truth == x) * (refitted==x))
        denom <- sum(as.logical((truth == x) + (refitted==x)))
        ind <- intersection / denom
        return(ind)
    })
    
    dice <- sapply(truth_levels, function(x)
    {
        intersection <- sum((truth == x) * (refitted==x))
        denom <- sum((truth == x)) + sum((refitted==x))
        ind <- 2 * intersection / denom
        return(ind)
    })
    
    l <- switch(index, all = {
        list(confusion=confusion, jaccard=jaccard, dice=dice)
    },
    confusion = {
        list(confusion=confusion)
    },
    jaccard = {
        list(jaccard=jaccard)
    },
    dice = {
        list(dice=dice)
    })
    return(l)
}