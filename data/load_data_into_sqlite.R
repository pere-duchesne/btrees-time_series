library(readr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(caTools)

dir<-'./decision_trees/'
data_dir<-'./data/'

source(paste0(dir,'sqlite.R'))

#Data preparation and load for Movies Collection Regression Truee
movies_file<-'Movie_regression.csv'
movies<-read_csv(paste0(dir,data_dir,movies_file),show_col_types=FALSE)
#Check for missing values
missing<-movies|>
  gather(key, value)|>
  group_by(key)|>
  count(missing=is.na(value))|>
  pivot_wider(names_from=missing,values_from=n,values_fill=0)|>
  rename(valid=`FALSE`,nulls=`TRUE`)|>
  mutate(pct_missing=nulls/(nrow(movies)))|>
  mutate(pct_valid=1-pct_missing)
#Plot missing
ggplot(missing, aes(x=pct_valid,y=key))+
  geom_col(fill='red')+
  labs(title='Missing Data',subtitle='Missing Data By Column',x='PCT Valid',y='Variable Name')
#Time taken distribution
ggplot(data=movies, aes(x=Time_taken))+
  geom_histogram(colour='gray',fill='black',bins=30)+
  labs(title='Time Taken', subtitle = 'Time Taken distribution',x='Time Taken',y='Frequencies')+
  theme_minimal(base_size=13)
#Time taken fill missing
time_taken<-(!is.na(movies$Time_taken)&movies$Time_taken>0)
time_taken<-movies$Time_taken[time_taken]
movies[(movies$Time_taken==0|is.na(movies$Time_taken)),'Time_taken']<-sample(time_taken,size=1)

#Target->Collection
ggplot(data=movies, aes(x=Collection))+
  geom_histogram(colour='white',fill='red',bins=30)+
  labs(x='Collection',y='Frequencies',title='Distribution of Collection')+
  theme_minimal(base_size=13)

movies<-movies|>
  mutate(id=strrep('0',ceiling(3/nchar(row_number())))|>paste0(row_number()))
names(movies)<-names(movies)|>str_replace_all(' ','_')|>str_replace_all('[0-9]','A')

set.seed(0)
split<-sample.split(movies$Collection,SplitRatio=0.8)
train<-subset(movies,split)
test<-subset(movies,!split)

Sqlite_upsert(movies,'movie_regression_data',conflict_cols=c('id'))
Sqlite_upsert(train,'movie_regression_train_data',conflict_cols=c('id'))
Sqlite_upsert(test,'movie_regression_test_data',conflict_cols=c('id'))