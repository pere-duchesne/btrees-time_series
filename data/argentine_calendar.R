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

retrieve_holidays<-function(years){
	URL_holidays<-'https://api.argentinadatos.com/v1/feriados/'
	df<-data.frame()
	for (year in years) {
		end_point<-paste0(URL_holidays,as.character(year), sep='/')
		response<-GET(end_point)
		if (status_code(response)==200) {
			response_content<-content(response, as='text', encoding='UTF-8')
			temp<-fromJSON(response_content)
			df<-bind_rows(df,temp)
		}else{
			print(paste('Error:', year, status_code(response)))
		}
	}
	return(df)
}

wrapper<-function(years){
	calendar<-make_days(years)
	holidays<-retrieve_holidays(years)
	holidays<-holidays|>
		select(fecha)|>
		mutate(fecha=as.Date(fecha),
			type=1)
	df<-calendar|>
		left_join(holidays, by=c('date'='fecha'))|>
		mutate(type=if_else(is.na(type),0,type))
	json_df<-toJSON(df, pretty=TRUE, na='null')
	return(json_df)
}

save_calendar<-function(years){
	json_df<-wrapper(years)
	write_json(json_df, 'calendar.json', pretty=TRUE, auto_unbox=TRUE)
}
