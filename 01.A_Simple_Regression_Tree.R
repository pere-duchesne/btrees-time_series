library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(caTools)
library(rpart)

df<-read_csv('./decision_trees/data/Movie_regression.csv',show_col_types=FALSE)
#Check for missing values
missing<-df|>
  gather(key, value)|>
  group_by(key)|>
  count(missing=is.na(value))|>
  pivot_wider(names_from=missing,values_from=n, values_fill=0)|>
  rename(valid=`FALSE`,nulls=`TRUE`)|>
  mutate(pct_missing=nulls/(nrow(df)))|>
  mutate(pct_valid=1-pct_missing)
#Plot missing
ggplot(missing, aes(x=pct_valid,y=key))+
  geom_col(fill='red')+
  labs(title='Missing Data',subtitle='Missing Data By Column',x='PCT Valid',y='Variable Name')
#Time taken distribution
ggplot(data=df, aes(x=Time_taken))+
  geom_histogram(colour='gray',fill='black',bins=30)+
  labs(title='Time Taken', subtitle = 'Time Taken distribution',x='Time Taken',y='Frequencies')+
  theme_minimal(base_size = 13)
#Time taken fill missing
time_taken<-(!is.na(df$Time_taken)&df$Time_taken>0)
time_taken<-df$Time_taken[time_taken]
df[(df$Time_taken==0|is.na(df$Time_taken)),'Time_taken']<-sample(time_taken,size=1)

#Taget->Collection
ggplot(data=df, aes(x=Collection))+
  geom_histogram(colour='white',fill='red',bins=30)+
  labs(x='Collection',y='Frequencies',title='Distribution of Collection')+
  theme_minimal(base_size=13)

#Train-Test split
set.seed(0)
split<-sample.split(df$Collection,SplitRatio=0.8)
train<-subset(df,split=TRUE)
test<-subset(df,split=FALSE)

#Regression Tree
regtree<-rpart(formula=Collection~.,data=train,control=rpart.control(maxdepth=3))
#maxdepth controls the number of tree layers
summary(regtree)
