library(dplyr)
library(lubridate)
library(xgboost)

dir<-'./decision_trees/'

source(paste0(dir,'sqlite.R'))
source(paste0(dir,'model_performance.R'))

train<-Sqlite_Read('movie_regression_train_data')|>select(-id)
test<-Sqlite_Read('movie_regression_test_data')|>select(-id)

ytrain<-train$Collection
ytest<-test$Collection

Xtrain<-model.matrix(Collection~.,data=train)
Xtest<-model.matrix(Collection~.,data=test)

XDMatrix_train<-xgb.DMatrix(data=Xtrain,label=ytrain)
XDMatrix_test<-xgb.DMatrix(data=Xtest,label=ytest)

xg_performance<-data.frame()
xg_prediction_pairs<-data.frame()
for (nround in 1:100){
  XGBoost<-xgboost(x=Xtrain,y=ytrain,nround=nround,objective='reg:squarederror',learning_rate=0.3,max_depth=4)
  test$XGBoost_predict<-predict(XGBoost,Xtest)
  prediction<-test$XGBoost_predict
  target<-ytest
  xgboost_df<-tibble(nround=nround,model='xgboost',target=target,predictions=prediction,loaded_at=now())
  model_performance_df<-model_performance(model='XG Boost',target=target,prediction=prediction)
  xg_performance<-bind_rows(xg_performance,model_performance_df)
  xg_prediction_pairs<-bind_rows(xgboost_df,xg_prediction_pairs)
}
model_best_performance_df<-xg_performance[xg_performance$RMSE==min(xg_performance$RMSE),]
xgboost_best_round_df<-xg_prediction_pairs[xg_prediction_pairs$nround==as.numeric(row.names(model_best_performance_df)),-1]

Sqlite_write(xgboost_best_round_df,'regtree_outcomes')
Sqlite_upsert(model_best_performance_df,'model_performance',conflict_cols=c('model'))
