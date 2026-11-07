library(randomForest)
library(readr)
source('./decision_trees/sqlite.R')
source('./decision_trees/model_performance.R')

fdirectory<-'./decision_trees/data/'
if (file.exists(paste0(fdirectory,'Movie_regression_cleaned.csv'))){
  df<-read_csv(paste0(fdirectory,'Movie_regression_cleaned.csv'),show_col_types=FALSE)
}else{
  print('File does not exist')
}
names(df)<-make.names(names(df))
