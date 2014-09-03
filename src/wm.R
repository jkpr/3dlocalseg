library(oro.nifti)
library(ROCR)

setwd("~/Documents/NIH/a20130227")

head_mask <- readAFNI("d5_alw_mask+orig.HEAD")
brain_mask <- readAFNI("brain_mask_sm+orig.HEAD")
wm_mask <- readAFNI("wm_mask1+orig.HEAD")
all_s <- readAFNI("all_s+orig.HEAD")

image(all_s[128,,,1])
image(all_s[128,,,2])
image(all_s[128,,,3])
image(all_s[128,,,4])
image(all_s[128,,,5])
image(all_s[128,,,6])
image(all_s[128,,,7])
image(all_s[128,,,8])
image(all_s[128,,,9])

dim(all_s)
dim(head_mask)
dim(wm_mask)

apply(all_s,4,dim)

# Vectorize images, subsetted by the mask
out <- apply(all_s,4,function(x)
{
  x[as.logical(drop(head_mask))]
})

image_names <- strsplit(all_s@BRICK_LABS,"~")[[1]]

wm <- wm_mask[as.logical(drop(head_mask))]

rm("all_s")

df <- as.data.frame(out)
colnames(df) <- image_names

df <- cbind(wm, df)

wm_lr <- glm(wm ~ fl + t1_1 + t1_2 + t1_3 + t1_4 + wt_rs + mtc_1 + mtc_2 + mtc_3, family="binomial", data = df)

fitted_wm <- predict(wm_lr)
pred1 <- prediction(fitted_wm, wm)
performance(pred1, "auc")
perf1 <- performance(pred1, measure="tpr", x.measure="fpr")

plot(perf1)
plot(perf1, xlim=c(0,0.1))

wild <- readAFNI("wildf.EE.p+orig.HEAD")
wm_wild <-  wild[,,,4]
wm_wild_brain <- wm_wild[as.logical(drop(head_mask))]

pred2 <- prediction(wm_wild_brain, wm)
performance(pred2, "auc")
perf2 <- performance(pred2, measure="tpr", x.measure="fpr")


plot(perf1, xlim=c(0,0.1))
plot(perf2, add=TRUE, col="blue")
abline(a=0, b=1, col="red", lty=2)
legend(x=0.07, y=0.7, legend=c("Logistic Regression","Naive bayes", "FPR=TPR"), lty=c(1,1,2), col=c("black","blue","red"), cex=0.8)
title("Comparision of local segmentation ROCs")

performance(pred1, "auc", fpr.stop=0.1)
performance(pred2, "auc", fpr.stop=0.1)




#### CONVERT FROM NUMERIC INTO QUANTILES
convert_to_quantiles <- function(src_df, n_quantiles)
{
  # Assume each column is numeric
  out <- lapply(src_df, 2, function(x){
    seq_length = n_quantiles + 1
    probs = seq(0,1, length=seq_length)
    breaks <- quantile(x, probs=probs)
    cat(breaks)
    cut(x, breaks)
  })
}