% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/runGSA.r
\name{runGSA}
\alias{runGSA}
\title{Gene set analysis}
\usage{
runGSA(
  geneLevelStats,
  directions = NULL,
  geneSetStat = "mean",
  signifMethod = "geneSampling",
  adjMethod = "fdr",
  gsc,
  gsSizeLim = c(1, Inf),
  permStats = NULL,
  permDirections = NULL,
  nPerm = 10000,
  gseaParam = 1,
  ncpus = 1,
  verbose = TRUE
)
}
\arguments{
\item{geneLevelStats}{a vector or a one-column data.frame or matrix,
containing the gene level statistics. Gene level statistics can be e.g.
p-values, t-values or F-values.}

\item{directions}{a vector or a one-column data.frame or matrix, containing
fold-change like values for the related gene-level statistics. This is
mainly used if statistics are p-values or F-values, but not required. The
values should be positive or negative, but only the sign information will be
used, so the actual value will not matter.}

\item{geneSetStat}{the statistical GSA method to use. Can be one of
\code{"fisher"}, \code{"stouffer"}, \code{"reporter"},
\code{"tailStrength"}, \code{"wilcoxon"}, \code{"mean"}, \code{"median"},
\code{"sum"}, \code{"maxmean"}, \code{"gsea"}, \code{"fgsea"} or
\code{"page"}. See below for details.}

\item{signifMethod}{the method for significance assessment of gene sets,
i.e. p-value calculation. Can be one of \code{"geneSampling"},
\code{"samplePermutation"} or \code{"nullDist"}}

\item{adjMethod}{the method for adjusting for multiple testing. Can be any
of the methods supported by \code{p.adjust}, i.e. \code{"holm"},
\code{"hochberg"}, \code{"hommel"}, \code{"bonferroni"}, \code{"BH"},
\code{"BY"}, \code{"fdr"} or \code{"none"}. The exception is for
\code{geneSetStat="gsea"}, where only the options \code{"fdr"} and
\code{"none"} can be used.}

\item{gsc}{a gene set collection given as an object of class \code{GSC} as
returned by the \code{\link{loadGSC}} function.}

\item{gsSizeLim}{a vector of length two, giving the minimum and maximum gene
set size (number of member genes) to be kept for the analysis. Defaults to
\code{c(1,Inf)}.}

\item{permStats}{a matrix with permutated gene-level statistics (columns)
for each gene (rows). This should be calculated by the user by randomizing
the sample labels in the original data, and recalculating the gene level
statistics for each comparison a large number of times, thus generating a
vector (rows in the matrix) of background statistics for each gene. This
argument is required and only used if
\code{signifMethod="samplePermutation"}.}

\item{permDirections}{similar to \code{permStats}, but should instead
contain fold-change like values for the related permutated statistics. This
is mainly used if the statistics are p-values or F-values, but not required.
The values should be positive or negative, but only the sign information
will be used, so the actual value will not matter. This argument is only
used if \code{signifMethod="samplePermutation"}, but not required. Note
however, that if \code{directions} is give then also \code{permDirections}
is required, and vice versa.}

\item{nPerm}{the number of permutations to use for gene sampling, i.e. if
\code{signifMethod="geneSampling"}. The original Reporter features algorithm
(\code{geneSetStat="reporter"} and \code{signifMethod="nullDist"}) also uses
a permutation step which is controlled by \code{nPerm}.}

\item{gseaParam}{the exponent parameter of the GSEA and FGSEA approach. This
defaults to 1, as recommended by the GSEA authors.}

\item{ncpus}{the number of cpus to use. If larger than 1, the gene
permutation part will be run in parallel and thus decrease runtime. Requires
R package \pkg{snowfall} to be installed. Should be set so that
\code{nPerm/ncpus} is a positive integer. (Not used by FGSEA.)}

\item{verbose}{a logical. Whether or not to display progress messages during
the analysis.}
}
\value{
A list-like object of class \code{GSAres} containing the following
elements:

\item{geneStatType}{The interpretated type of gene-level statistics}
\item{geneSetStat}{The method for gene set statistic calculation}
\item{signifMethod}{The method for significance estimation}
\item{adjMethod}{The method of adjustment for multiple testing}
\item{info}{A list object with detailed info number of genes and gene sets}
\item{gsSizeLim}{The selected gene set size limits} \item{gsStatName}{The
name of the gene set statistic type} \item{nPerm}{The number of
permutations} \item{gseaParam}{The GSEA parameter}

\item{geneLevelStats}{The input gene-level statistics} \item{directions}{The
input directions}

\item{gsc}{The input gene set collection} \item{nGenesTot}{The total number
of genes in each gene set} \item{nGenesUp}{The number of up-regulated genes
in each gene set} \item{nGenesDn}{The number of down-regulated genes in each
gene set}

\item{statDistinctDir}{Gene set statistics of the distinct-directional
class} \item{statDistinctDirUp}{Gene set statistics of the
distinct-directional class} \item{statDistinctDirDn}{Gene set statistics of
the distinct-directional class} \item{statNonDirectional}{Gene set
statistics of the non-directional class} \item{statMixedDirUp}{Gene set
statistics of the mixed-directional class} \item{statMixedDirDn}{Gene set
statistics of the mixed-directional class}

\item{pDistinctDirUp}{Gene set p-values of the distinct-directional class}
\item{pDistinctDirDn}{Gene set p-values of the distinct-directional class}
\item{pNonDirectional}{Gene set p-values of the non-directional class}
\item{pMixedDirUp}{Gene set p-values of the mixed-directional class}
\item{pMixedDirDn}{Gene set p-values of the mixed-directional class}

\item{pAdjDistinctDirUp}{Adjusted gene set p-values of the
distinct-directional class} \item{pAdjDistinctDirDn}{Adjusted gene set
p-values of the distinct-directional class}
\item{pAdjNonDirectional}{Adjusted gene set p-values of the non-directional
class} \item{pAdjMixedDirUp}{Adjusted gene set p-values of the
mixed-directional class} \item{pAdjMixedDirDn}{Adjusted gene set p-values of
the mixed-directional class}

\item{runtime}{The execution time in seconds}
}
\description{
Performs gene set analysis (GSA) based on a given number of gene-level
statistics and a gene set collection, using a variety of available methods,
returning the gene set statistics and p-values of different directionality
classes.
}
\details{
The rownames of \code{geneLevelStats} and \code{directions} should be
identical and match the names of the members of the gene sets in \code{gsc}.
If \code{geneSetStat} is set to \code{"fisher"}, \code{"stouffer"},
\code{"reporter"} or \code{"tailStrength"} only p-values are allowed as
\code{geneLevelStats}. If \code{geneSetStat} is set to \code{"maxmean"},
\code{"gsea"}, \code{"fgsea"} or \code{"page"} only t-like
\code{geneLevelStats} are allowed (e.g. t-values, fold-changes).

For \code{geneSetStat} set to \code{"fisher"}, \code{"stouffer"},
\code{"reporter"}, \code{"wilcoxon"} or \code{"page"}, the gene set p-values
can be calculated from a theoretical null-distribution, in this case, set
\code{signifMethod="nullDist"}. For all methods
\code{signifMethod="geneSampling"} or
\code{signifMethod="samplePermutation"} can be used, except for
\code{"fgsea"} where only \code{signifMethod="geneSampling"} is allowed. If
\code{signifMethod="geneSampling"} gene sampling is used, meaning that the
gene labels are randomized \code{nPerm} times and the gene set statistics
are recalculated so that a background distribution for each original gene
set is acquired. The gene set p-values are calculated based on this
background distribution. Similarly if
\code{signifMethod="samplePermutation"} sample permutation is used. In this
case the argument \code{permStats} (and optionally \code{permDirections})
has to be supplied.

The \code{runGSA} function returns p-values for each gene set. Depending on
the choice of methods and gene statistics up to three classes of p-values
can be calculated, describing different aspects of regulation
directionality. The three directionality classes are Distinct-directional,
Mixed-directional and Non-directional. The non-directional p-values
(\code{pNonDirectional}) are calculated based on absolute values of the gene
statistics (or p-values without sign information), meaning that gene sets
containing a high portion of significant genes, independent of direction,
will turn up significant. That is, gene-sets with a low
\code{pNonDirectional} should be interpreted to be significantly affected by
gene regulation, but there can be a mix of both up and down regulation
involved. The mixed-directional p-values (\code{pMixedDirUp} and
\code{pMixedDirDn}) are calculated using the subset of the gene statistics
that are up-regulated and down-regulated, respectively. This means that a
gene set with a low \code{pMixedDirUp} will have a component of
significantly up-regulated genes, disregardful of the extent of
down-regulated genes, and the reverse for \code{pMixedDirDn}. This also
means that one can get gene sets that are both significantly affected by
down-regulation and significantly affected by up-regulation at the same
time. Note that sample permutation cannot be used to calculate
\code{pMixedDirUp} and \code{pMixedDirDn} since the subset sizes will
differ. Finally, the distinct-directional p-values (\code{pDistinctDirup}
and \code{pDistinctDirDn}) are calculated from statistics with sign
information (e.g. t-statistics). In this case, if a gene set contains both
up- and down-regulated genes, they will cancel out each other. A gene-set
with a low \code{pDistinctDirUp} will be significantly affected by
up-regulation, but not a mix of up- and down-regulation (as in the case of
the mixed-directional and non-directional p-values). In order to be able to
calculate distinct-directional gene set p-values while using p-values as
gene-level statistics, the gene-level p-values are transformed as follows:
The up-regulated portion of the p-values are divided by 2 (scaled to range
between 0-0.5) and the down-regulated portion of p-values are set to 1-p/2
(scaled to range between 1-0.5). This means that a significantly
down-regulated gene will get a p-value close to 1. These new p-values are
used as input to the gene-set analysis procedure to get
\code{pDistinctDirUp}. Similarly, the opposite is done, so that the
up-regulated portion is scaled between 1-0.5 and the down-regulated between
0-0.5 to get the \code{pDistinctDirDn}.
}
\examples{

   # Load example input data to GSA:
   data("gsa_input")
   
   # Load gene set collection:
   gsc <- loadGSC(gsa_input$gsc)
      
   # Run gene set analysis:
   gsares <- runGSA(geneLevelStats=gsa_input$pvals , directions=gsa_input$directions, 
                    gsc=gsc, nPerm=500)
   

}
\references{
Fisher, R. Statistical methods for research workers. Oliver and
Boyd, Edinburgh, (1932).

Stouffer, S., Suchman, E., Devinney, L., Star, S., and Williams Jr, R. The
American soldier: adjustment during army life. Princeton University Press,
Oxford, England, (1949).

Patil, K. and Nielsen, J. Uncovering transcriptional regulation of
metabolism by using metabolic network topology. Proceedings of the National
Academy of Sciences of the United States of America 102(8), 2685 (2005).

Oliveira, A., Patil, K., and Nielsen, J. Architecture of transcriptional
regulatory circuits is knitted over the topology of bio-molecular
interaction networks. BMC Systems Biology 2(1), 17 (2008).

Kim, S. and Volsky, D. Page: parametric analysis of gene set enrichment. BMC
bioinformatics 6(1), 144 (2005).

Taylor, J. and Tibshirani, R. A tail strength measure for assessing the
overall univariate significance in a dataset. Biostatistics 7(2), 167-181
(2006).

Mootha, V., Lindgren, C., Eriksson, K., Subramanian, A., Sihag, S., Lehar,
J., Puigserver, P., Carlsson, E., Ridderstrale, M., Laurila, E., et al.
Pgc-1-alpha-responsive genes involved in oxidative phosphorylation are
coordinately downregulated in human diabetes. Nature genetics 34(3), 267-273
(2003).

Subramanian, A., Tamayo, P., Mootha, V., Mukherjee, S., Ebert, B., Gillette,
M., Paulovich, A., Pomeroy, S., Golub, T., Lander, E., et al. Gene set
enrichment analysis: a knowledgebased approach for interpreting genom-wide
expression profiles. Proceedings of the National Academy of Sciences of the
United States of America 102(43), 15545-15550 (2005).

Efron, B. and Tibshirani, R. On testing the significance of sets of genes.
The Annals of Applied Statistics 1, 107-129 (2007).
}
\seealso{
\pkg{\link{piano}}, \code{\link{loadGSC}},
\code{\link{GSAsummaryTable}}, \code{\link{geneSetSummary}},
\code{\link{networkPlot2}}, \code{\link{exploreGSAres}}, \pkg{\link[samr]{samr}},
\pkg{\link[limma:01Introduction]{limma}}, \pkg{\link[GSA]{GSA}}, \pkg{\link[fgsea]{fgsea}}
}
\author{
Leif Varemo \email{piano.rpkg@gmail.com} and Intawat Nookaew
\email{piano.rpkg@gmail.com}
}
