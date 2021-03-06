
rcm_plot_validation_duration<-function(rcm, unit = '.'){
  selected_unit<-unit
  rcm <- rcm %>% filter(grepl(selected_unit,unit))


  rcm$days_to_validation <- lubridate::dmy(rcm$date.validated)-rcm$date.hqsubmission.actual
  rcm<-rcm %>% filter(!is.na(days_to_validation))
  rcm$days_to_validation <- rcm$days_to_validation %>% as.numeric

  ggplot(rcm %>% arrange(unit,type))+
    geom_density(aes(days_to_validation,fill=type),
                 color = NA,
                 position = 'stack')+
    facet_grid(rows=vars(unit))+theme_minimal()+
    scale_x_log10()

  }


#' Colours for standard item stati
#' @return vector with six colour hexcodes
rcm_status_cols<-function(){
  return(c("#fff1d3", # other
           "#fff1d3", # not received
           "#f18200", # with HQ
           "#2dbd91", # validated
           "#58e9f9", # field
           "#2d91bd"  # partner
  )
  )

}




#' Gant chart of all RCM items
#' @param rcm the research cycle matrix from rcm_download(raw=F)
#' @return ggplot item
rcm_gant<-function(rcm){

  rcm$status[!grepl("HQ|validated|field|partner",rcm$status)]<-"other"
  rcm$status<-as.factor(rcm$status)
  rcm$date.min<-NULL
  rcm$date.max<-NULL
  rcm$date.min<-apply(rcm[,grep("^date\\.",names(rcm))],1,function(x){format.Date(min(as.Date(x,format="%Y-%m-%d"),na.rm = T),format="%Y-%m-%d")})
  rcm$date.min <-as.Date(rcm$date.min,format="%Y-%m-%d")
  rcm$date.max<-apply(rcm[,grep("^date\\.",names(rcm))],1,function(x){format.Date(max(as.Date(x,format="%Y-%m-%d"),na.rm = T),format="%Y-%m-%d")})
  rcm$date.max <-as.Date(rcm$date.max,format="%Y-%m-%d")

  rcm$date.minormax<-ifelse(is.na(rcm$date.min),rcm$date.max,rcm$date.min) %>% (lubridate::as_date)
  rcm$date_style_status<-NA
  rcm$date_style_status[rcm$status=="validated"]<-"date.validated"
  rcm$date_style_status[rcm$status=="1 not received "]<-"date.hqsubmission.planned.latest"
  rcm$date_style_status[rcm$status=="2 with HQ"]<-"date.hqsubmission.actual"
  rcm$date_style_status[rcm$status=="with field"]<-"date.hqsubmission.actual"
  rcm$date_style_status[rcm$status=="validated"]<-"date.validated"
  rcm$date_style_status[rcm$status=="other"]<-"date.endcollection.planned"

  hasnodate<-rcm %>% apply(1,function(x){all(is.na(x[c("date.hqsubmission.actual",
                                                       "date.endcollection.planned",
                                                       "date.endcollection.actual",
                                                       "date.hqsubmission.planned.first",
                                                       "date.hqsubmission.planned.latest",
                                                       "date.validated")]))})
  rcm %>% gather("datetype","date",
                 date.hqsubmission.actual,
                 date.endcollection.planned,
                 date.endcollection.actual,
                 date.hqsubmission.planned.first,
                 date.hqsubmission.planned.latest,
                 date.validated) -> rcm_dateslong
  rcm_dateslong$datetype<-factor(rcm_dateslong$datetype,levels = c("date.endcollection.planned"   ,
                                                                   "date.endcollection.actual",
                                                                   "date.hqsubmission.planned.first",
                                                                   "date.hqsubmission.planned.latest",
                                                                   "date.hqsubmission.actual",
                                                                   "date.validated",ordered=T)
  )
  rcm_dateslong$date.minormax[is.na(rcm_dateslong$date.minormax)] <- (min(rcm_dateslong$date.min,na.rm=T))-1
  rcm_dateslong$date <- sapply(rcm_dateslong$date,lubridate::as_date)
  rcm_dateslong$date<-lubridate::as_date(rcm_dateslong$date)

  ggplot(rcm)+
    geom_point(data = rcm_dateslong,
               aes(x=date, y=reorder(file.id,as.numeric(date.minormax)),colour=datetype))+

    # geom_segment(data=rcm,mapping = aes(y=reorder(file.id,as.numeric(date.minormax),),yend=file.id,
    #                                     x=rcm$date.min,xend=date.max,
    #                                     colour=date_style_status),
    #              lwd=0.5)+

    geom_point(data = rcm_dateslong, aes(x=date, y=reorder(file.id,as.numeric(date.minormax)),colour=datetype))+
    scale_colour_manual(name="",values=c("date.endcollection.planned"="#ACACAD"   ,
                                         "date.endcollection.actual"="#58585A",
                                         "date.hqsubmission.planned.first"= "#FACDCD",
                                         "date.hqsubmission.planned.latest"="#F7ACAC" ,
                                         "date.hqsubmission.actual"="#CDCDCD",
                                         "date.validated"="#EE5859"),labels=c("planned collection end",
                                                                              "actual collection end",
                                                                              "planned HQ submission (first)",
                                                                              "planned HQ submission (latest)",
                                                                              "actual HQ submission",
                                                                              "validation")
    )+scale_y_discrete(labels=function(x){strtrim(x,60)})+

     # theme(panel.background = element_blank(),
     #      panel.grid.major = element_line(colour="#CCCCCC", size=0.05),
     #      # panel.grid.major = element_blank(),
     #      panel.grid.minor=element_blank(),
     #      axis.text.y= element_text(size = 9))+theme(legend.position = "top")+labs(x="date",y="file id")

  theme(panel.background = element_blank(),
        panel.grid.major = element_line(colour="#CCCCCC", size=0.05),
        # panel.grid.major = element_blank(),
        panel.grid.minor=element_blank(),
        axis.text.y= element_text(size = 1),axis.text.x= element_text(size = 1,angle = 90,vjust = 0))+theme(legend.position = "top")+labs(x="date",y="file id")+
    geom_vline(xintercept = Sys.Date(),col="black",lwd=1)+scale_x_date()




}



#' plot validation timeline
#' @param rcm the RCM as given by rcm_download()
#' @return ggplot object
#' @export
validation_timeline<-function(rcm, passed_days_included = 30, future_days_included = 30){
  # rcm<-rcm[rcm$unit=="data",]
  rcm$status[(rcm$status %in% c("", NA, " "))]<-"1 not received"
  rcm$status[!grepl("HQ|validated|field|partner|received",rcm$status)]<-"unclear / not received"
  rcm$date.hqsubmission.actual[rcm$status %in% c("1 not received","unclear / not received")]<-
    lubridate::ymd(rcm$date.hqsubmission.planned.latest[rcm$status %in% c("1 not received","unclear / not received")])
  # rcm$status[!(grepl("",rcm$status)),]<- "planned / other"
  ggplot(rcm)+geom_histogram(aes(date.hqsubmission.actual,fill=status),alpha=0.7,binwidth=1)+
    theme_minimal()+
    # scale_fill_manual(name="Unit",values=c("data"="black",
    #                                          "GIS"="blue",
    #                                          "reporting"="pink",
    #                                          "research design"="orange",
    #                                          "other" = "grey"))+
    scale_fill_manual(name="",values=c("1 not received"= "#000000",
                                       "2 with HQ"="#EE5858",
                                       "3 validated"= "#58EE58", # "#CDCDCD",
                                       "with field"="#EEEE58",
                                       "with partner" = "#5858EE",
                                       "unclear / not received"='#585858',
                                       rep("#EEEEEE",100)))+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))+
    facet_grid(unit~.,scales = "fixed")+
     labs(x="date received (or planned)","")+
    theme(axis.line.y=element_blank())+
    theme(panel.border=element_blank())+
    theme(
      axis.title.y=element_blank(),
      axis.text.y=element_text(size = 7),
      axis.ticks.y=element_blank()
          )+
    theme(panel.grid.minor.y = element_blank())+
    scale_x_date(date_minor_breaks = "1 day",date_breaks = "1 week",limits = c(Sys.Date()-passed_days_included,Sys.Date()+future_days_included))+
    geom_vline(aes(xintercept=lubridate::as_date(Sys.Date())),lty = "dotted")

}
