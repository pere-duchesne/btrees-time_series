library(readr)
library(rpart)
library(lubridate)

#Load full tree model
full_tree<-readRDS('./decision_trees/data/full_regtree.RDS')
plotcp(full_regtree)

#Extract the cp with minimum xerror from tree_model$cptable
full_cp_table<-full_regtree$cptable
min_cp_full_tree<-full_cp_table[which.min(full_cp_table[,'xerror']),'CP']
#Calculates the pruned tree version of the full tree model
pruned_full_regtree<-prune(full_regtree,cp=min_cp_full_tree)

test$target_predict_full_pruned<-predict(pruned_full_regtree, test, type='vector')

prediction<-test$target_predict_full_pruned

prune_full_regtree_df<-tibble(model='prune full regtree',target=target,predictions=prediction,loaded_at=now())
model_performance_full_prune<-model_performance(prediction,target,'Prune Full RegTree')

Sqlite_write(prune_full_regtree_df,'regtree_outcomes')
Sqlite_upsert(data=model_performance_full_prune,table_name='model_performance',conflict_cols=c('model'))