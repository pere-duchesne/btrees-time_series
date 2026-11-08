library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(caTools)
library(rpart)
library(rpart.plot)
library(rattle)

dir<-'./decision_trees/'

source(paste0(dir, 'sqlite.R'))
source(paste0(dir, 'model_performance.R'))

#Train-Test split
train<-Sqlite_Read('movie_regression_train_data')
test<-Sqlite_Read('movie_regression_test_data')

train<-select(train,-id)
train<-select(test,-id)

#Regression Tree
simple_regtree<-rpart(formula=Collection~.,data=train,control=rpart.control(maxdepth=3))
#maxdepth controls the number of tree layers
summary(simple_regtree)
fancyRpartPlot(simple_regtree,yesno=2,split.col='black',nn.col='black',caption='',palette='Set2',branch.col='black')

#Predict
test$target_predict<-predict(simple_regtree,test,type='vector')

prediction<-test$target_predict
target<-test$Collection

simple_regtree_df<-tibble(model='simple regtree',target=target,predictions=prediction,loaded_at=now())
model_performance_simple<-model_performance(prediction,target,'Simple RegTree')

Sqlite_write(simple_regtree_df,'regtree_outcomes')
Sqlite_upsert(data=model_performance_simple,table_name='model_performance',conflict_cols=c('model'))

#Plot Results
ggplot(data=test, aes(x=target_predict, y=Collection))+
  geom_point(colour='steelblue',alpha=0.85,shape=17)+
  labs(x='Target Prediction',y='Target',title='Prediction vs. Target Values',subtitle='Movie Collection Simple Tree Prediction')+
  theme_minimal(base_size=13)