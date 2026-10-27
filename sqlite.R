library(RSQLite)
Sqlite<-function(df,table_name){
  conn<-dbConnect(SQLite(), './decision_trees/_.sqlite')
  dbWriteTable(conn,table_name,df,append=TRUE,row.names=FALSE)
  dbDisconnect(conn)
}