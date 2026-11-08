library(randomForest)
library(lubridate)
library(dplyr)
source('./decision_trees/sqlite.R')
source('./decision_trees/model_performance.R')

train<-Sqlite_Read(table_name='movie_regression_train_data')
test<-Sqlite_Read(table_name='movie_regression_test_data')

#Random Forest Regression
random_forest<-randomForest(Collection~.,data=train,ntree=13)
test$random_forest_prediction<-predict(random_forest,test)

prediction<-test$random_forest_prediction
target<-test$Collection

random_forest_df<-tibble(model='random forest',target=target,predictions=prediction,loaded_at=now())
model_performance_df<-model_performance(model='Random Forest',target=target,prediction=prediction)

Sqlite_write(random_forest_df,'regtree_outcomes')
Sqlite_upsert(model_performance_df,'model_performance',conflict_cols=c('model'))
