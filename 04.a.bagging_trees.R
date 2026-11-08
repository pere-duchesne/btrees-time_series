library(dplyr)
library(lubridate)
library(randomForest)

dir<-'./decision_trees/'

source(paste0(dir,'sqlite.R'))
source(paste0(dir,'/model_performance.R'))

train<-Sqlite_Read('movie_regression_train_data')
test<-Sqlite_Read('movie_regression_test_data')

train<-select(train,-id)
test<-select(test,-id)

bagging_trees<-randomForest(formula=Collection~.,data=train,mty=ncol(df)-1)

test$bagging_predict<-predict(bagging_trees,test)

prediction<-test$bagging_predict
target<-test$Collection

bagging_regtree_df<-tibble(model='bagging regtree',target=target,predictions=prediction,loaded_at=now())
model_performance_bagging<-model_performance(prediction,target,'Bagging RegTree')

Sqlite_write(bagging_regtree_df,'regtree_outcomes')
Sqlite_upsert(data=model_performance_bagging,table_name='model_performance',conflict_cols=c('model'))
