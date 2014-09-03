# This function outputs the randomly chosen axial slices for 
# manual segmentation

n_slices <- 5
sub_id <- c(20130204, 20130213, 20130227)
min_slice <- c(83, 83, 83)
max_slice <- c(214, 217, 227)

out <- sapply(seq_along(sub_id), function(i)
{
  set.seed(sub_id[i])
  r_slices <- sample(max_slice[i] - min_slice[i], n_slices)
  final_slices <- sort(r_slices + min_slice[i])
  c(sub_id[i], min_slice[i], max_slice[i], final_slices)
})

df <- as.data.frame(t(out))
colnames(df) <- c("id","min","max",paste("s",seq_len(5),sep=""))
df

set.seed(20130204)
sample

set.seed(20130213)
sample(100,5)

set.seed(20130227)
sample(100,5)

