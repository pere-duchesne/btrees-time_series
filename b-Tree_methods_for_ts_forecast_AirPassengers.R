library(lubridate)
library(ggplot2)

library(randomForest)
library(xgboost)
library(xts)

dir<-'./decision_trees/'

source(paste0(dir, 'sqlite.R'))
source(paste0(dir, 'model_performance.R'))

data('AirPassengers')
ts_data<-AirPassengers

##Pre-process and Preparation
#Convert data into a data frame
ts_df<-data.frame(Year=as.integer(index(ts_data)),Month<-rep(1:12,12),Passengers=coredata(ts_data))
ts_df$Date<-make_date(ts_df$Year,ts_df$Month)
ts_df<-ts_df[,c('Date','Passengers')]
index(ts_df)
#Get the ts data object
ts_xts<-xts(x=ts_df$Passengers,order.by=ts_df$Date)
#Get lagged data
lags<-1:12
lagged_data<-stats::lag(ts_xts,k=lags)
#Convert lagged_data into a dataframe
lagged_df<-data.frame(lagged_data)
#Merge data frames
df<-cbind(ts_df,lagged_df)
#Adding rolling mean ad std.dev features
df[,'roll3_mean']<-rollapply(data=df$Passengers,width=3,FUN=mean,align='right',fill=NA)
df[,'roll3_std']<-rollapply(data=df$Passengers,width=3,FUN=sd,align='right',fill=NA)
#Final modifications on the data frame
df<-df[complete.cases(df),]
row.names(df)<-1:nrow(df)
#Split data set into train - test sets
n<-nrow(df)
train_percentage<-0.8
train_size<-floor(n*train_percentage)
train<-df[1:train_size,]
test<-df[(train_size+1):n,]

##Ensemble b-trees

#randomForest on train set
random_forest<-randomForest(Passengers~.,data=train,ntree=100)
#Make predictions
test$predictions_rf<-predict(random_forest,test)
target<-test$Passengers
predictions<-test$predictions_rf
#Make and load calculations for random forest
random_forest_df<-data.frame(model='random forest ts',target=target,predictions=predictions,loaded_at=now())
model_performance_random_forest<-model_performance(predictions,target,'Random Forest TS')

Sqlite_write(random_forest_df,'regtree_outcomes')
Sqlite_upsert(data=model_performance_random_forest,table_name='model_performance',conflict_cols=c('model'))

#XGboost on train set
ytrain<-train$Passengers

Xtrain<-model.matrix(Passengers~.,data=train)
Xtest<-model.matrix(Passengers~.,data=test)

xgboost<-xgboost(x=Xtrain,y=ytrain,nround=95,objective='reg:squarederror',learning_rate=0.4,max_depth=3)
test$predictions_xgboost<-predict(xgboost,Xtest)
predictions<-test$predictions_xgboost

#Make and load calculations for Xgboost
xgboost_df<-data.frame(model='xgboost ts',target=target,predictions=predictions,loaded_at=now())
model_performance_xgboost_df<-model_performance(predictions,target,'XGboost TS')

Sqlite_write(xgboost_df,'regtree_outcomes')
Sqlite_upsert(data=model_performance_xgboost_df,table_name='model_performance',conflict_cols=c('model'))

#Graph
ggplot(data=df)+
  geom_line(aes(x=Date,y=Passengers,colour='Original'))+
  geom_line(data=test, aes(x=Date,y=predictions_rf,colour='Random Forest'),alpha=0.75,size=1)+
  geom_line(data=test, aes(x=Date,y=predictions_xgboost,colour='XGboost'),alpha=0.25,size=1)+
  scale_colour_manual(values=c('Original'='steelblue','Random Forest'='black','XGboost'='red'))+
  scale_x_date(breaks=12,date_breaks='year',date_labels='%Y')+
  labs(title='Forecasting AirPassengers with based-tree methods',
       subtitle='Time Series Analysis',
       x='',y='Passengers',colour='')+
  theme_minimal(base_size=18)+
  theme(legend.position='bottom',
        plot.title=element_text(size=24, face='bold'),
        plot.subtitle=element_text(size=18),
        axis.title=element_text(size=18))
