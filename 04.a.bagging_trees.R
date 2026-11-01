library(readr)
library(dplyr)
library(lubridate)
library(randomForest)
source('./decision_trees/sqlite.R')
source('./decision_trees/model_performance.R')

fdirectory<-'./decision_trees/data/'
if (file.exists(paste0(fdirectory,'Movie_regression_cleaned.csv'))){
  df<-read_csv(paste0(fdirectory,'Movie_regression_cleaned.csv'),show_col_types=FALSE)
}else{
  print('File does not exist')
}
df|>is.na()|>sum()
names(df)<-make.names(names(df))
library(caTools)
set.seed(0)
sample_split<-sample.split(df$Collection,SplitRatio=0.8)
train<-subset(df,sample_split)
test<-subset(df,!sample_split)

bagging_trees<-randomForest(formula=Collection~.,data=train,mty=ncol(df)-1)

test$bagging_predict<-predict(bagging_trees,test)

prediction<-test$bagging_predict
target<-test$Collection

bagging_regtree_df<-tibble(model='bagging regtree',target=target,predictions=prediction,loaded_at=now())
model_performance_bagging<-model_performance(prediction,target,'Bagging RegTree')

Sqlite_write(bagging_regtree_df,'regtree_outcomes')
Sqlite_upsert(data=model_performance_bagging,table_name='model_performance',conflict_cols=c('model'))
