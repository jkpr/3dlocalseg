# Create a confusion matrix based on predicted probabilities and true class labels

confusion <- function(obs, pred, r=NULL, pct=FALSE) {
  tab <- table(obs, pred)
  Total <- rowSums(tab)
  tab <- tab/matrix(Total, nrow=nrow(tab), ncol=ncol(tab))
  if (pct) tab <- tab*100
  
  if (!is.null(r)) {
    tab <- round(tab, r)
  }
  tab <- cbind(tab, Total)
  tab
}
