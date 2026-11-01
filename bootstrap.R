bootstrap_replicate<-function(n, replicates){
  mxReSamples<-replicate(replicates,sample(1:n,round(n*0.8,0),replace=TRUE))
  return(mxReSamples)
}