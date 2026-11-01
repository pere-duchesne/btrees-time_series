library(RSQLite)

Sqlite_write<-function(df,table_name){
  conn<-dbConnect(SQLite(), './decision_trees/_.sqlite')
  dbWriteTable(conn,table_name,df,append=TRUE,row.names=FALSE)
  dbDisconnect(conn)
}

Sqlite_upsert<-function(data,table_name,conflict_cols,create_if_missing=TRUE) {
    if (create_if_missing) {
    infer_sql_type <- function(x) {
      if (inherits(x, "Date")) return("DATE")
      if (inherits(x, "POSIXct")) return("TIMESTAMP")
      if (inherits(x, "integer")) return("INTEGER")
      if (inherits(x, "numeric")) return("REAL")
      if (inherits(x, "logical")) return("BOOLEAN")
      "TEXT"
    }
    cols_sql<-paste(sprintf("%s %s", names(data), vapply(data, infer_sql_type, character(1))),collapse = ', ')
    pk_sql <- sprintf("PRIMARY KEY (%s)", paste(conflict_cols, collapse = ', '))
    create_sql<-sprintf("CREATE TABLE IF NOT EXISTS %s (%s, %s)",table_name, cols_sql, pk_sql)
    conn<-dbConnect(SQLite(), './decision_trees/_.sqlite')
    dbExecute(conn, create_sql)
    }
  conn<-dbConnect(SQLite(), './decision_trees/_.sqlite')
  tmp_table<-paste0('tmp_upsert_', paste(sample(c(letters, 0:9), 8, replace=TRUE), collapse=''))
  dbWriteTable(conn,tmp_table,data,temporary=TRUE,overwrite=TRUE)
  all_cols<-names(data)
  update_cols<-setdiff(all_cols, conflict_cols)
  conflict_str<-paste(conflict_cols, collapse=', ')
  sql<-"CREATE TABLE IF NOT EXISTS"
  if (length(update_cols)==0) {
    sql<-sprintf("INSERT INTO %s (%s) SELECT %s FROM %s WHERE true ON CONFLICT (%s) DO NOTHING",table_name,paste(all_cols, collapse=', '),paste(all_cols, collapse = ', '),tmp_table,conflict_str)
  } else {
    update_str<-paste(sprintf("%s = EXCLUDED.%s", update_cols, update_cols),collapse = ', ')
    sql<-sprintf("INSERT INTO %s (%s) SELECT %s FROM %s WHERE true ON CONFLICT (%s) DO UPDATE SET %s",table_name,paste(all_cols,collapse=', '),paste(all_cols, collapse = ', '),tmp_table,conflict_str,update_str)
  }
  on.exit(dbRemoveTable(conn, tmp_table), add = TRUE)
  dbExecute(conn, sql)
}