library(rpart)
library(rpart.plot)
library(readr)
library(dplyr)

source('./decision_trees/sqlite.R')
source('./decision_trees/model_performance.R')

train<-read_csv('./decision_trees/data/train.csv',show_col_types=FALSE)
test<-read_csv('./decision_trees/data/test.csv',show_col_types=FALSE)
#Prunning a tree: a technique that prevent tree growth
#This script only generates the full tree that is going to be taken later for bagging (also for random forest)
#Make a full tree to prune afterwards
full_regtree<-rpart(Collection~.,data=train,control=rpart.control(cp=0))
#rpart.plot(full_regtree)
#printcp(full_regtree)
#plotcp(full_regtree)

#Predictions full_regtree
test$target_predict_full<-predict(full_regtree,test,type='vector')

prediction<-test$target_predict_full
target<-test$Collection

full_regtree_df<-tibble(model='full regtree',target=target,predictions=prediction,loaded_at=now())
model_performance_full<-model_performance(prediction,target,'Full RegTree')

Sqlite_write(full_regtree_df,'regtree_outcomes')
Sqlite_upsert(data=model_performance_full,table_name='model_performance',conflict_cols=c('model'))

saveRDS(full_regtree,'decision_trees/data/full_regtree.RDS')