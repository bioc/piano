% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/polarPlot.r
\name{polarPlot}
\alias{polarPlot}
\title{Polar plot}
\usage{
polarPlot(
  pValues,
  chromosomeMapping,
  colors = c("red", "green", "blue", "yellow", "orange", "purple", "tan", "cyan",
    "gray60", "black"),
  save = FALSE,
  verbose = TRUE
)
}
\arguments{
\item{pValues}{a \code{data.frame} containing p-values for different
contrasts in different columns. Column names are used as contrast names.
Maximum number of columns allowed are ten.}

\item{chromosomeMapping}{character string giving the name of the chromosome
mapping file, or an object of class \code{data.frame} or similar containing
the chromosome mapping. See details below.}

\item{colors}{character vector of colors to be used by the Polar plot.}

\item{save}{should the figures be saved? Defaults to \code{FALSE}.}

\item{verbose}{verbose? Defaults to \code{TRUE}.}
}
\value{
Does not return any object.
}
\description{
Produces a Polar plot, mapping p-values to chromosome location. This
function is used by \code{\link{diffExp}}.
}
\details{
This function is mainly used by \code{\link{diffExp}} but can also be used
separately by the user.

The argument \code{chromosomeMapping} should be either a \code{data.frame}
or a tab delimited text file and include the columns \emph{chromosome} with
the chromosome name and \emph{chromosome location} containing the starting
position of each gene. A \code{-} sign can be used to denote the antisense
strand but this will be disregarded while plotting. The rownames should be
\emph{probe IDs} or, if using a text file, the first column with a column
header should contain the \emph{probe IDs}. If relying on an
\code{ArrayData} object (called \code{arrayData}) and containing an
\code{annotation} field, the \code{chromosomeMapping} can be set to
\code{arrayData$annotation[,c(2,3)]} (see the example below).

The Polar plot sorts the genes according to chromosomal location, for each
chromosome starting with unknown positions followed by increasing number in
the \emph{chromosome location} column. Genes which do not map to any
chromosome are listed as U for unknown. The radial lines in the Polar plot
are -log10 scaled p-values, so that a longer line means a smaller p-value.
This gives an overview of the magnitude of differential expression for each
contrast.
}
\examples{

  # Get path to example data and setup files:
  dataPath <- system.file("extdata", package="piano")

  # Load normalized data:
  myArrayData <- loadMAdata(datadir=dataPath, dataNorm="norm_data.txt.gz", platform="yeast2")

  # Perform differential expression analysis:
  pfc <- diffExp(myArrayData, plot=FALSE, 
                 contrasts=c("aerobic_Clim - anaerobic_Clim",
                             "aerobic_Nlim - anaerobic_Nlim"))

  # Get chromosome mapping from myArrayData:
  chrMap <- myArrayData$annotation[,c(2,3)]
  # Get p-values from pfc
  pval <- pfc$pValues
  # Draw the polar plot:
  polarPlot(pval, chromosomeMapping=chrMap)

}
\seealso{
\pkg{\link{piano}}, \code{\link{diffExp}},
\code{\link[plotrix:radial.plot]{radial.plot}}
}
\author{
Leif Varemo \email{piano.rpkg@gmail.com} and Intawat Nookaew
\email{piano.rpkg@gmail.com}
}
