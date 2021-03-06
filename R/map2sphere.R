# This function maps a longitude-latitude grid onto a sphere. This
# function will be embeeded in map as an option.
#" c("lonlat","sphere","NP","SP")
# First transform longitude (theta) and latitude (phi) to cartesian
# coordinates:
#
# (theta,phi) -> (x,y,z) = r
#
# Use a transform to rotate the sphere through the following matrix
# product:
#
# ( x' )    ( a1  b1  c1 )  ( x )
# ( y' ) =  ( a2  b2  c2 )  ( y )
# ( z' )    ( a3  b3  c3 )  ( z )
#
# There can be three different rotation, about each of the axes
# For 90-degree rotatins, e.g. aroud the z-axis:
# Z = 90 (X = Y = 0): x' = y; y' = -x: z'= z
# a1 = cos(Z) ; b1=sin(Z); c1=cos(Z);
# a2 = -sin(Z); b2=cos(Z); c2=cos(Z)
# a3 = cos(Z) ; b3=cos(Z); c3=sin(Z)
# Y = 90 (Z = X = 0): x' = -z; z' = x; y' = y
# a1= cos(Y); b1 = cos(Y); c1=-sin(Y);
# a2= cos(Y); b2 = sin(Y); c2= cos(Y);
# a3= sin(Y); b3 = cos(Y); c3= cos(Y)
# X = 90 (Y = Z = 0): x' = x; z' = y; y' = - z
# a1 = sin(X); b1 = cos(X); c1 = cos(X)
# a2 = cos(X); b2 = cos(X); c2 = -sin(X);
# a3 = cos(X); b3 = sin(X), c3 = cos(X)
#
# a1 =  cosYcosZ; b1 = cosXsinZ; c1= -cosXsinY
# a2 = -cosXsinZ; b2 = cosXcosZ; c2= -sinXcosY
# a3 =  cosXsinY; b3 = sinXcosZ; c3=  cosXcosY
#
# Rasmus E. Benestad
# 14.04.2013


rotM <- function(x=0,y=0,z=0) {
  X <- -pi*x/180; Y <- -pi*y/180; Z <- -pi*z/180
  cosX <- cos(X); sinX <- sin(X); cosY <- cos(Y)
  sinY <- sin(Y); cosZ <- cos(Z); sinZ <- sin(Z)
  rotM <- rbind( c( cosY*cosZ, cosY*sinZ,-sinY*cosZ ),
                 c(-cosX*sinZ, cosX*cosZ,-sinX*cosZ ),
                 c( sinY*cosX, sinX*cosY, cosX*cosY ) )
  return(rotM)
}

gridbox <- function(x,col,density = NULL, angle = 45) {
#  if (length(x) != 5) {print(length(x)); stop("gridbox")}
# W,E,S,N
# xleft, ybottom, xright, ytop
  i <- round(x[9])
#  rect(x[1], x[3], x[2], x[4],col=cols[i],border=cols[i])
  polygon(c(x[1:4],x[1]),c(x[5:8],x[5]),
          col=col[i],border=col[i])
}

#angleofview <- function(r,P) {
#  angle <- acos( (P%*%r)/( sqrt(P%*%P)*sqrt(r%*%r) ) )
#  return(angle)
#}

map2sphere <- function(x,it=NULL,is=NULL,lonR=NULL,latR=NULL,axiR=0,new=TRUE,
                       what=c("fill","contour"),colorbar=TRUE,breaks=NULL,
                       gridlines=TRUE,col=NULL,...) {

  if (!is.null(it) | !is.null(it)) x <- subset(x,it=it,is=is)
  # Data to be plotted:
  lon <- attr(x,'longitude')
  lat <- attr(x,'latitude')
  # To deal with grid-conventions going from north-to-south or east-to-west:
  srtx <- order(attr(x,'longitude')); lon <- lon[srtx]
  srty <- order(attr(x,'latitude')); lat <- lat[srty]
  map <- x[srtx,srty]
  param <- attr(x,'variable')
  unit <- attr(x,'unit')
  
  # Rotatio:
  if (is.null(lonR)) lonR <- mean(lon)  # logitudinal rotation
  if (is.null(latR)) latR <- mean(lat)  # Latitudinal rotation
  # axiR: rotation of Earth's axis

  # coastline data:
  data("geoborders",envir=environment())
  ok <- is.finite(geoborders$x) & is.finite(geoborders$y)
  theta <- pi*geoborders$x[ok]/180; phi <- pi*geoborders$y[ok]/180
  x <- sin(theta)*cos(phi)
  y <- cos(theta)*cos(phi)
  z <- sin(phi)

# Calculate contour lines if requested...  
#contourLines
  lonxy <- rep(lon,length(lat))
  latxy <- sort(rep(lat,length(lon)))
  map<- c(map)

# Remove grid boxes with missign data:
  ok <- is.finite(map)
  #print(paste(sum(ok)," valid grid point"))
  lonxy <- lonxy[ok]; latxy <- latxy[ok]; map <- map[ok]

# Define the grid box boundaries:
  dlon <- min(abs(diff(lon))); dlat <- min(abs(diff(lat)))
  Lon <- rbind(lonxy - 0.5*dlon,lonxy + 0.5*dlon,
               lonxy + 0.5*dlon,lonxy - 0.5*dlon)
  Lat <- rbind(latxy - 0.5*dlat,latxy - 0.5*dlat,
               latxy + 0.5*dlat,latxy + 0.5*dlat)
  Theta <- pi*Lon/180; Phi <- pi*Lat/180

# Transform -> (X,Y,Z):
  X <- sin(Theta)*cos(Phi)
  Y <- cos(Theta)*cos(Phi)
  Z <- sin(Phi)
  #print(c( min(x),max(x)))

# Define colour palette:
  if (is.null(breaks)) {
    n <- 30
    breaks <- pretty(c(map),n=n)
  } else n <- length(breaks)
  if (is.null(col)) col <- colscal(n=n) else
  if (length(col)==1) {
     palette <- col
     col <- colscal(palette=palette,n=n)
  }
  nc <- length(col)
  
  index <- round( nc*( map - min(breaks) )/
                    ( max(breaks) - min(breaks) ) )

# Rotate coastlines:
  a <- rotM(x=0,y=0,z=lonR) %*% rbind(x,y,z)
  a <- rotM(x=latR,y=0,z=0) %*% a
  x <- a[1,]; y <- a[2,]; z <- a[3,]

# Grid coordinates:
  d <- dim(X)
  #print(d)

# Rotate data grid:  
  A <- rotM(x=0,y=0,z=lonR) %*% rbind(c(X),c(Y),c(Z))
  A <- rotM(x=latR,y=0,z=0) %*% A
  X <- A[1,]; Y <- A[2,]; Z <- A[3,]
  dim(X) <- d; dim(Y) <- d; dim(Z) <- d
  #print(dim(rbind(X,Z)))

# Plot the results:
  if (new) dev.new()
  par(bty="n",xaxt="n",yaxt="n")
  plot(x,z,pch=".",col="grey90",xlab="",ylab="",...)

# plot the grid boxes, but only the gridboxes facing the view point:
  Visible <- colMeans(Y) > 0
  X <- X[,Visible]; Y <- Y[,Visible]; Z <- Z[,Visible]
  index <- index[Visible]
  apply(rbind(X,Z,index),2,gridbox,col)
  # c(W,E,S,N, colour)
  # xleft, ybottom, xright, ytop

# Plot the coast lines  
  visible <- y > 0
  points(x[visible],z[visible],pch=".")
  #plot(x[visible],y[visible],type="l",xlab="",ylab="")
  lines(cos(pi/180*1:360),sin(pi/180*1:360))

# Add contour lines?
# Add grid ?
  
# Colourbar:
  if (colorbar) {
    #print(breaks)
    par0 <- par()
    par(fig = c(0.3, 0.7, 0.05, 0.10),cex=0.8,
        new = TRUE, mar=c(1,0,0,0), xaxt = "s",yaxt = "n",bty = "n")
  #print("colourbar")
    if (is.null(breaks))
      breaks <- round( nc*(seq(min(map),max(map),length=nc)- min(map) )/
                      ( max(map) - min(map) ) )
    bar <- cbind(breaks,breaks)
    #browser()
    image(breaks,c(1,2),bar,col=col)

    par(bty="n",xaxt="n",yaxt="n",xpd=FALSE,
        xaxt = "n",fig=par0$fig,mar=par0$mar,new=TRUE)
    
  }
  plot(range(x,na.rm=TRUE),range(z,na.rm=TRUE),type="n",
       xlab="",ylab="")
  text(-0.95,0.95,paste(param,' (',unit,')',sep=''),cex=1.5,pos=4)
  
  #result <- data.frame(x=colMeans(Y),y=colMeans(Z),z=c(map))
  result <- NULL # For now...
  invisible(result)
}

#map2sphere(x)

vec <- function(x,y,it=10,a=1,r=1,ix=NULL,iy=NULL,new=TRUE,nx=150,ny=80,
                projection='lonlat',lonR=NULL,latR=NULL,axiR=0,...) {
  x <- subset(x,it=it); y <- subset(y,it=it)
  d <- attr(x,'dimensions')
  #print(d); print(dim(x))
  if (is.null(ix)) ix <- pretty(lon(x),n=nx)
  if (is.null(iy)) iy <- pretty(lat(x),n=ny)
  #print(c(d[2],d[1]))
  X <- coredata(x); Y <- coredata(y)
  dim(X) <- c(d[1],d[2])
  dim(Y) <- c(d[1],d[2])
  #browser()
#  X <- t(X); Y <- t(Y)
  x0 <- rep(ix,length(iy))
  y0 <- sort(rep(iy,length(ix)))
  ij <- is.element(ix,lon(x))
  ji <- is.element(iy,lat(x))
  #print(ix); print(lon(x)); print(sum(ij))
  #print(iy); print(lat(x)); print(sum(ji))
  #browser()
  dim(x0) <- c(length(ij),length(ji)); dim(y0) <- dim(x0)
  x0 <- x0[ij,ji]
  y0 <- y0[ij,ji]
  ii <- is.element(lon(x),ix)
  jj <- is.element(lat(x),iy)
  x1 <- a*X[ii,jj]; y1 <- a*Y[ii,jj]
  #print(dim(x1)); print(c(length(x0),sum(ii),sum(jj)))
  x1 <- x0 + x1; y1 <- y0 + y1
  if (projection=='sphere') {
    # Rotate data grid:
    # The coordinate of the arrow start:
    
    theta <- pi*x0/180; phi <- pi*y0/180
    x <- r*c(sin(theta)*cos(phi))
    y <- r*c(cos(theta)*cos(phi))
    z <- r*c(sin(phi))
    a <- rotM(x=0,y=0,z=lonR) %*% rbind(x,y,z)
    x0 <- a[1,]; y0 <- a[3,]
    invisible <- a[2,] < 0
    x0[invisible] <- NA; y0[invisible] <- NA
    #The coordinate of the arrow end:
    theta <- pi*x1/180; phi <- pi*y1/180
    x <- r*c(sin(theta)*cos(phi))
    y <- r*c(cos(theta)*cos(phi))
    z <- r*c(sin(phi))
    a <- rotM(x=0,y=0,z=lonR) %*% rbind(x,y,z)
    x1 <- a[1,]; y1 <- a[3,]
    invisible <- a[2,] < 0
    x1[invisible] <- NA; y1[invisible] <- NA
  }    

  if (new) {
    dev.new()
    plot(range(x0,x1),range(y0,y1),xlab='',ylab='')
    data(geoborders)
    lines(geoborders$x,geoborders$y)
  }
  arrows(x0, y0, x1, y1,...)
}
