\name{is}
\alias{is.T}
\alias{is.precip}
\alias{is.field(}
\alias{is.station}
\alias{is.eof}
\alias{is.pca}
\alias{is.cca}
\alias{is.storm}
\alias{is.daily}
\alias{is.monthly}
\alias{is.seasonal}
\alias{is.annual}
\title{Test for .}
\description{Computes different formulas
}

\usage{
is.T(x)
is.precip(x)
is.field(x) 
is.station(x) 
is.eof(x) 
is.pca(x) 
is.cca(x) 
is.storm(x)
is.daily(x)
is.monthly(x) 
is.seasonal(x)
is.annual(x)
}

\arguments{
  \item{x}{a data object}
}
\value{Boolean}

\author{R. Benestad, MET Norway}
\examples{
data(ferder)
is.T(ferder)
}
\keyword{parameter,element}