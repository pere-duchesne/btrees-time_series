library(rpart)
library(rpart.plot)
library(readr)
library(dplyr)

dir<-'./decision_trees/'

source(paste0(dir,'sqlite.R'))
source(paste0(dir,'/model_performance.R'))

train<-Sqlite_Read('movie_regression_train_data')
test<-Sqlite_Read('movie_regression_test_data')

train<-select(train,-id)
test<-select(test,-id)

#Prunning a tree: a technique that prevents tree from growing
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
#Save the model for futher steps and techniquess
saveRDS(full_regtree,'decision_trees/data/full_regtree.RDS')