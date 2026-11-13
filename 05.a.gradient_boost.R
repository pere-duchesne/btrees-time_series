library(dplyr)
library(lubridate)
library(gbm)

dir<-'./decision_trees/'
source(paste0(dir,'sqlite.R'))
source(paste0(dir,'model_performance.R'))

train<-Sqlite_Read('movie_regression_train_data')|>mutate(across(where(is.character),as.factor))
test<-Sqlite_Read('movie_regression_test_data')|>mutate(across(where(is.character),as.factor))
train<-select(train,-id)
test<-select(test,-id)

#Gradient boosting model
gradient<-gbm(Collection~.,data=train,distribution='gaussian',n.trees=6000,interaction.depth=3,shrinkage=0.01,verbose=FALSE)
test$gradient_prediction<-predict(gradient,test,n.trees=6000)

prediction<-test$gradient_prediction
target<-test$Collection

gradient_df<-tibble(model='random forest',target=target,predictions=prediction,loaded_at=now())
model_performance_df<-model_performance(model='Gradient Boosting',target=target,prediction=prediction)

Sqlite_write(gradient_df,'regtree_outcomes')
Sqlite_upsert(model_performance_df,'model_performance',conflict_cols=c('model'))
