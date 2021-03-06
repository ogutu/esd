as.storm <- function(x) {
  x$Code99 <- as.numeric(as.character(x$Code99))
  x <- x[x$Code99<90,]
  x$cyclone <- factor2numeric(x$cyclone)
  x$Date <- factor2numeric(x$Date)
  x$Year <- factor2numeric(x$Year)
  x$Lon <- factor2numeric(x$Lon)
  x$Lat <- factor2numeric(x$Lat)
  x$Pressure <- factor2numeric(x$Pressure)
  if (x$Code99[1]>9) {
    m <- paste("M",as.character(x$Code99[1]),sep="")
  } else m <- paste("M0",as.character(x$Code99[1]),sep="")
  x$Method <- m
  M <- imilast2matrix(x)
  invisible(M)
}

factor2numeric <- function(x) {
  suppressWarnings(as.numeric(levels(x))[x])}

imilast2matrix <- function(x) {
  x <- data.frame(x)
  aggregate(x$Lon, list(x$cyclone), function(x) approx.lon(x,n=10)$y)$x -> lon
  aggregate(x$Lat, list(x$cyclone), function(x) approx(x,n=10)$y)$x -> lat
  aggregate(x$Pressure, list(x$cyclone), function(x) approx(x,n=10)$y)$x -> slp
  aggregate(x$Date, list(x$cyclone), function(x) x[1])$x -> t1
  aggregate(x$Date, list(x$cyclone), function(x) x[length(x)])$x -> t2
  aggregate(x$Date, list(x$cyclone), length)$x -> n
  colnames(lon) <- rep('lon',10)
  colnames(lat) <- rep('lat',10)
  colnames(slp) <- rep('slp',10)
  #X <- list(lon=lon,lat=lat,slp=slp,start=t1,end=t2,n=n)
  X <- cbind(lon=lon,lat=lat,slp=slp,start=t1,end=t2,n=n)
  attr(X, "location")= NA
  attr(X, "variable")= 'storm tracks'
  attr(X, "unit")= NA
  attr(X, "longitude")= NA
  attr(X, "latitude")= NA
  attr(X, "altitude")= 0
  attr(X, "country")= NA
  attr(X, "longname")= "mid-latitude storm tracks"
  attr(X, "station_id")= NA
  attr(X, "quality")= NA
  attr(X, "calendar")= "gregorian"
  attr(X, "source")= "IMILAST"
  attr(X, "URL")= "http://journals.ametsoc.org/doi/abs/10.1175/BAMS-D-11-00154.1"
  attr(X, "type")= "analysis"
  attr(X, "aspect")= "interpolated"
  attr(X, "reference")= "Neu, et al. , 2013: IMILAST: A Community Effort to Intercompare Extratropical Cyclone Detection and Tracking Algorithms. Bull. Amer. Meteor. Soc., 94, 529–547."
  attr(X, "info")= NA
  attr(X, "method")= x$Method[1]
  attr(X, "history")= history.stamp()
  class(X) <- 'storm'
  invisible(X)
}

matrix2imilast <- function(x) {
  Cyclone <- unlist(mapply(function(i,n) rep(i,n),seq(1,dim(x)[1]),x[,33]))
  ilon <- colnames(x)=='lon'
  ilat <- colnames(x)=='lat'
  islp <- colnames(x)=='slp'
  ilen <- colnames(x)=='n'
  Lon <- unlist(apply(x,1,function(x) approx.lon(x[ilon],n=x[ilen])$y))
  Lat <- unlist(apply(x,1,function(x) approx(x[ilat],n=x[ilen])$y))
  Pressure <- unlist(apply(x,1,function(x) approx(x[islp],n=x[ilen])$y))
  fn <- function(x) {
    d <- strptime(x[31:32],format="%Y%m%d%H")
    d <- seq(d[1],d[2],length=x[ilen])
    d <- as.numeric(strftime(d,"%Y%m%d%H"))
    invisible(d)
  }
  Date <- unlist(apply(x,1,fn))
  Year <- as.integer(Date*1E-6)
  Code99 <- rep(as.numeric(substring(attr(x,"method"),2)),length(Date))
  X <- data.frame(Cyclone,Date,Year,Lon,Lat,Pressure,Code99)
}

  
#fname="/vol/fou/klima/IMILAST/ERAinterim_1.5_NH_M03_19890101_20090331_ST.txt"
#m03 <- read.fwf(fname,width=c(2,7,4,11,5,5,5,4,7,7,10),
#        col.names=c("Code99","cyclone","timeStep","Date","Year",
#        "Month","Day","Time","Lon","Lat","Pressure"))
#x <- as.stormtrack(m03)
