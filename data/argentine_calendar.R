library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)

make_days<-function(years){
	calendar<-data.frame()
	for (year in years) {
		temp<-data.frame(date=seq(from=make_date(as.character(year),'01','01'),to=make_date(as.character(year),'12','31'),by='day'))
		temp<-temp|>
			mutate(year=year(date),
			       month=month(date),
			       day_of_month=day(date),
			       week_day=wday(date,week_start=1),
			       year_day=yday(date),
			       month_start=floor_date(date,'month'),
			       month_end=ceiling_date(date,'month')-days(1),
			       days_in_month=days_in_month(date),
			       week=isoweek(date),
			       quarter=quarter(date),
			       year_month=year(date)*100+month(date),
			       month_id=interval(min(date), date) %/% months(1) + 1,
			       day_fraction=yday(date)/yday(ceiling_date(date,'year')-days(1)))
		calendar<-bind_rows(calendar,temp)	
	}
	return(calendar)
}

retrieve_holidays <- function(years) {
  #path<-'./decision_trees/data/calendar.json'
  #if (file.exists(path)) {
  #  calendar<-read_json(path)|>fromJSON()
  #  if (!is.null(calendar) && 'year' %in% names(calendar)) {
  #    years_loaded<-unique(calendar$year)
  #    years<-setdiff(years, years_loaded)
  #  }
  #}
  #if (length(years)==0) {
  #  message('Years already loaded. Nothing to add.')
  #  return(data.frame())
  #}
  URL_holidays <- 'https://api.argentinadatos.com/v1/feriados/'
  df <- data.frame()
  for (yr in years) {
    end_point <- paste0(URL_holidays, yr, '/')
    response  <- GET(end_point)
    if (status_code(response) == 200) {
      response_content <- content(response, as = 'text', encoding = 'UTF-8')
      temp <- fromJSON(response_content)
      df   <- bind_rows(df, temp)
    } else {
      warning(sprintf('Error in %s: status %s', yr, status_code(response)))
    }
  }
  return(df)
}

wrapper<-function(years){
	holidays<-retrieve_holidays(years)
	if (nrow(holidays)==0){
		return(data.frame())
	}else{
		calendar<-make_days(years)	
		holidays<-holidays|>
			select(fecha)|>
			mutate(fecha=as.Date(fecha),
				type=1)
		df<-calendar|>
			left_join(holidays, by=c('date'='fecha'))|>
			mutate(type=if_else(is.na(type),0,type))
		return(df)
	}
}

save_calendar<-function(years){
	df<-wrapper(years)
	if (nrow(df)==0){
		message('Nothing to save.')
    return(invisible(NULL))
	}else{
		path<-'./decision_trees/data/calendar.json'
		if (file.exists(path)) {
			existing<-read_json(path)|>fromJSON()
			dates<-c('date','month_start','month_end')
			existing<-existing|>
				mutate(across(dates,as.Date))
			df<-bind_rows(df,existing)
		}
		json_df<-toJSON(df,pretty=TRUE)
		write_json(json_df, path, pretty=TRUE, auto_unbox=TRUE)
	}
}
