
library(oro.nifti)
library(nnet)

gold <- readAFNI("gold+orig")
wildf <- readAFNI("wildf.EE.c+orig")
crazyf<- readAFNI("crazyf.FF.c+orig")

all_s <- readAFNI("all_s+orig")
bmask <- readAFNI("brain_mask_sm+orig.HEAD")
hmask <- readAFNI("d5_alw_mask+orig")
image_names <- strsplit(all_s@BRICK_LABS,"~")[[1]]



# Multinomial logistic regression
features <- apply(all_s, 4, as.vector)
colnames(features) <- image_names
df <- as.data.frame(features)
df <- df[as.vector(hmask)==1,]
df$y <- factor(as.vector(gold))
levels(df$y) <- c("OTHER", "OUT", "CSF", "GM", "WM", "MEN", "MAR", "SK")
df <- df[hmask==1,]

mult_form <- as.formula("y ~ fl + t1_1 + t1_2 + t1_3 + t1_4 + wt_rs + mtc_1 + mtc_2 + mtc_3")


fit1 <- multinom(mult_form, data=df)
pred1 <- predict(fit1)
prob1 <- fit1$fitted.values
class1 <- hmask
class1[as.vector(hmask)==1] <- pred1
probs1 <- array(0, dim=dim(all_s[,,,-9]))

for (i in 1:8) {
  print(i)
  probs1[,,,i][hmask==1] <- prob1[,i]
}

res <- all_s
res@.Data[,,,1] <- class1
res@.Data[,,,2:9] <- probs1
writeAFNI(res, fname="mlogit")




confusion(y, pred1, r=1, pct=TRUE)

# Naive Bayes
wildf.mask  <- as.vector(wildf)[ as.vector(bmask)==1]
crazyf.mask <- as.vector(crazyf)[as.vector(bmask)==1]

confusion(y, wildf.mask, r=1, pct=TRUE)
confusion(y, crazyf.mask, r=1, pct=TRUE)




