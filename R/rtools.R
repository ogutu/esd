## Author A. Mezghani
## Description Contains some rtools ...
## Created 14.11.2014

as.decimal <- function(x=NULL) {
    ## converts from degree min sec format to degrees ...
    ##x is in the form "49°17´38´´"
    if (!is.null(x)) {
        deg <-as.numeric(substr(x,1,2)) 
        min <- as.numeric(substr(x,4,5))
        sec <- as.numeric(substr(x,7,8))     
        x <- deg + min/60 + sec/3600
    }
    return(x)
}


## compute the percentage of missing data in x
missval <- function(x) sum(is.na(coredata(x)))/length(coredata(x))

## compute the quantile 95% of x
q95 <- function(x,na.rm=TRUE) quantile(x,probs=.95,na.rm=na.rm)

## compute the quantile 5% of x
q5 <- function(x,na.rm=TRUE) quantile(x,probs=.05,na.rm=na.rm)

## compute the quantile 5% of x
q995 <- function(x,na.rm=TRUE) quantile(x,probs=.995,na.rm=na.rm)

## compute the quantile 5% of x
q975 <- function(x,na.rm=TRUE) quantile(x,probs=.975,na.rm=na.rm)

## count the number of valid data points
nv <- function(x,...) sum(is.finite(x))

## Compute the coefficient of variation of x
cv <- function(x,na.rm=TRUE) {sd(x,na.rm=na.rm)/mean(x,na.rm=na.rm)}

## Compute the linear trend
trend.coef <- function(x,...) {
  t <- 1:length(x)
  model <- lm(x ~ t)
  y <- c(model$coefficients[2]*10)
  names(y) <- c("trend.coefficients")
  return(y)
}

## Compute the p-value of the linear trend 
trend.pval <- function(x,...) {
    t <- 1:length(x)
    model <- lm(x ~ t)
    y <- anova(model)$Pr[1]
    names(y) <- c("trend.pvalue")
    return(y)
}

# Wrap-around for lag.zoo to work on station and field objects:
lag.station <- function(x,...) {
  y <- lag(zoo(x),...)
  y <- attrcp(x,y)
  class(y) <- class(x)
  invisible(y)
}

lag.field <- function(x,...) lag.station(x,...)
  
exit <- function() q(save="no")
