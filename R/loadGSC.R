#' Load a gene set collection
#' 
#' Load a gene set collection, to be used in \code{\link{runGSA}}, in GMT, SBML
#' or SIF format, or optionally from a \code{data.frame}.
#' 
#' This function is used to create a gene-set collection object to be used with
#' \code{\link{runGSA}}.
#' 
#' The "gmt" files available from the Molecular Signatures Database
#' (\url{http://www.broadinstitute.org/gsea/msigdb/}) can be loaded using
#' \code{loadGSC}. This website is a valuable resource and contains several
#' different collections of gene sets.
#' 
#' By using the functionality of e.g. the \code{biomaRt} package, a gene-set
#' collection with custom gene names (matching the statistics used in
#' \code{\link{runGSA}}) can easily be compiled into a two-column data.frame
#' (column order: genes, gene sets) and loaded with \code{type="data.frame"}.
#' 
#' If a sif-file is used it is assumed that the first column contains gene sets
#' and the third column contains genes.
#' 
#' A genome-scale metabolic model in SBML format can be used to define gene
#' sets. In this case, metabolites will be the gene sets, containing all the
#' genes that code for enzymes catalyzing reactions in which the metabolite
#' takes part in. In order to load an SBML-file it is required that libSBML and
#' \code{rsbml} is installed. Note that the SBML loading is an experimental
#' feature and is highly dependent on the version and format of the SBML file
#' and requires it to contain gene associations for the reactions. By examining
#' the returned \code{GSC} object it is easy to see if the correct gene sets
#' were loaded.
#' 
#' @param file a character string, giving the name of the file containing the
#' gene set collection. Optionally an object that can be coerced into a
#' two-column data.frame, the first column containing genes and the second gene
#' sets, representing all "gene"-to-"gene set" connections.
#' @param type a character string giving the file type. Can be either of
#' \code{"gmt"}, \code{"sbml"}, \code{"sif"}. If set to \code{"auto"} the type
#' will be taken from the file extension. If the gene-set collection is loaded
#' into R from another source and stored in a data.frame, it can be loaded with
#' the setting \code{"data.frame"}.
#' @param addInfo an optional data.frame with two columns, the first
#' containging the gene set names and the second containing additional
#' information for each gene set. Some additional info may load automatically
#' from the different file types.
#' @return A list like object of class \code{GSC} containing two elements. The
#' first is \code{gsc}, a list of the gene sets, each element a character
#' vector of genes. The second element is \code{addInfo}, a data.frame
#' containing the optional additional information.
#' @author Leif Varemo \email{piano.rpkg@@gmail.com} and Intawat Nookaew
#' \email{piano.rpkg@@gmail.com}
#' @seealso \pkg{\link{piano}}, \code{\link{runGSA}}
#' @examples
#' 
#'    # Randomly generated gene sets:
#'    g <- sort(paste("g",floor(runif(100)*500+1),sep=""))
#'    g <- c(g,sort(paste("g",floor(runif(900)*1000+1),sep="")))
#'    g <- c(g,sort(paste("g",floor(runif(1000)*2000+1),sep="")))
#'    s <- paste("s",floor(rbeta(2000,0.9,1.7)*50+1),sep="")
#'    
#'    # Make data.frame:
#'    gsc <- cbind(g,s)
#'    
#'    # Load gene set collection from data.frame:
#'    gsc <- loadGSC(gsc)
#' 
loadGSC <- function(file, type="auto", addInfo) {

   # Initial argument checks:
   if(missing(addInfo)) {
      addUserInfo <- "skip"
      addInfo <- "none"
   } else {
      addUserInfo <- "yes"
   }
   
   tmp <- try(type <- match.arg(type, c("auto","gmt","sbml","sif","data.frame"), several.ok=FALSE), silent=TRUE)
   if(is(tmp, "try-error")) {
      stop("argument type set to unknown value")
   }
   
   # Check file extension if type="auto":
   if(type == "auto") {
      if(is(file, "character")) {
         tmp <- unlist(strsplit(file,"\\."))
         type <- tolower(tmp[length(tmp)])
         if(!type %in% c("gmt","sif","sbml","xml")) stop(paste("can not handle .",type," file extension, read manually using e.g. read.delim() and load as data.frame",sep=""))
      } else {
         type <- "data.frame"
      }
   }
   
   
   #************************
   # GMT
   #************************
   
   # Read gmt-file:
   if(type == "gmt") {
      
     con <- file(file)
     tmp <- try(suppressWarnings(open(con)), silent=TRUE)
     if(is(tmp, "try-error")) stop("file could not be read")
     if(addUserInfo == "skip") addInfo <- vector()
     gscList <- list()
     i <- 1
     tmp <- try(suppressWarnings(
       while(length(l<-scan(con, nlines=1, what="character", quiet=TRUE, sep="\t")) > 0) {
         if(addUserInfo == "skip") addInfo <- rbind(addInfo,l[1:2])
         tmp <- l[3:length(l)]
         gscList[[l[1]]] <- unique(tmp[tmp != "" & tmp != " " & !is.na(tmp)])
         i <- i + 1
       }
     ), silent=TRUE)
     if(is(tmp, "try-error")) stop("file could not be read")
     close(con)
     
     # Remove duplicate gene sets:
     gsc <- gscList[!duplicated(names(gscList))]
     if(addUserInfo == "skip") addInfo <- unique(addInfo)
     #info$redundantGS <- length(gscList) - length(gsc)
   
      
   #************************
   # SBML
   #************************
      
   } else if(type %in% c("sbml","xml")) {
      
      #require(rsbml) # old, line below is preferred:
      if (!requireNamespace("rsbml", quietly = TRUE)) stop("package rsbml is missing")
      # Read sbml file:
      tmp <- try(sbml <- rsbml::rsbml_read(file))
      if(is(tmp, "try-error")) {
         stop("file could not be read by rsbml_read()")
      }
      
      # Create gsc object:
      gsc <- list()
      for(iReaction in 1:length(rsbml::reactions(rsbml::model(sbml)))) {
         
         # Species ID for metabolites in current reaction:
         metIDs <- names(c(rsbml::reactants(rsbml::reactions(rsbml::model(sbml))[[iReaction]]),
                           rsbml::products(rsbml::reactions(rsbml::model(sbml))[[iReaction]])))
         
         # Get gene id:s for genes associated with current reaction:
         geneIDs <- names(rsbml::modifiers(rsbml::reactions(rsbml::model(sbml))[[iReaction]]))
         
         # If any genes found:
         if(length(geneIDs) > 0) {
            
            # Get gene names:
            geneNames <- rep(NA,length(geneIDs))
            for (iGene in 1:length(geneIDs)) {
              
              GG <- rsbml::name(species(rsbml::model(sbml))[[geneIDs[iGene]]])
              if ( length(strsplit(GG,':')[[1]]) > 1) {
                geneNames = strsplit(GG,':')[[1]]
              }
              if ( length(strsplit(GG,';')[[1]]) > 1) {
                geneNames = strsplit(GG,';')[[1]]
              }
              else {
                geneNames[iGene] <- GG
              }
            }
            
            # Loop over metabolites for current reaction, add gene names:
            for(iMet in 1:length(metIDs)) {
               gsc[[metIDs[iMet]]] <- c(gsc[[metIDs[iMet]]], geneNames)
            }
         }
      }
      
      # Fix the gene-set names to metabolite names (in place of ids):
      if(length(gsc) == 0) {
         stop("no gene association found")
      } else {
         for(iMet in 1:length(gsc)) {         
            tmp1 <- rsbml::name(species(rsbml::model(sbml))[[names(gsc)[iMet]]])
            tmp2 <- rsbml::compartment(species(rsbml::model(sbml))[[names(gsc)[iMet]]])
            names(gsc)[iMet] <- paste(tmp1," (",tmp2,")",sep="")
         }
      }
      
      
   #************************
   # SIF
   #************************ 
      
   } else if(type == "sif") {
      tmp <- try(gsc <- as.data.frame(read.delim(file, header=FALSE, quote="", as.is=TRUE), 
                                      stringsAsFactors=FALSE), silent=TRUE)
      if(is(tmp, "try-error")) {
         stop("argument file could not be read and converted into a data.frame")
      }
      
      # Check gsc for three columns:
      if(ncol(gsc)!=3) {
         stop("sif file should contain three columns")  
      }
      
      # Get gsc and addInfo part:
      if(addUserInfo == "skip") addInfo <- gsc[,c(1,2)]
      gsc <- gsc[,c(3,1)]
      
      # Remove redundant rows:
      tmp <- nrow(gsc)
      gsc <- unique(gsc)
      #info$redundantGS <- tmp - nrow(gsc)
      
      # Convert to list object:
      geneSets <- unique(gsc[,2])
      gscList <- list()
      for(iGeneSet in 1:length(geneSets)) {
         gscList[[iGeneSet]] <- gsc[gsc[,2] == geneSets[iGeneSet],1]
      }
      names(gscList) <- geneSets
      gsc <- gscList
      
      
   #************************
   # Data.frame
   #************************
   
   # Gene set collection as data.frame:
   } else if(type == "data.frame") {
      tmp <- try(gsc <- as.data.frame(file, stringsAsFactors=FALSE), silent=TRUE)
      if(is(tmp, "try-error")) {
         stop("argument file could not be converted into a data.frame")
      }
      # Get rid of factors:
      for(i in 1:ncol(gsc)) {
         gsc[,i] <- as.character(gsc[,i])
      }
      
      # Check gsc for two columns:
      if(ncol(gsc)!=2) {
         stop("argument file has to contain exactly two columns")  
      }
      
      # Remove redundant rows:
      tmp <- nrow(gsc)
      gsc <- unique(gsc)
      #info$redundantGS <- tmp - nrow(gsc)
      
      # Convert to list object:
      geneSets <- unique(gsc[,2])
      gscList <- list()
      for(iGeneSet in 1:length(geneSets)) {
         gscList[[iGeneSet]] <- gsc[gsc[,2] == geneSets[iGeneSet],1]
      }
      names(gscList) <- geneSets
      gsc <- gscList
   }
   
   
   #***************************
   # AddInfo
   #***************************
      
   # Additional info as data.frame:
   if(addUserInfo == "yes") {
      tmp <- try(addInfo <- as.data.frame(addInfo, stringsAsFactors=FALSE), silent=TRUE)
      if(is(tmp, "try-error")) {
         stop("failed to convert additional info in argument 'addInfo' into a data.frame")
      }
   }
   
   if(is(addInfo, "data.frame")) {
      
      # Check for 2 columns:
      if(ncol(addInfo) != 2) stop("additional info in argument 'file' or 'addInfo' has to contain 2 columns")
      
      # Check addInfo correlation to gsc:
      tmp <- nrow(addInfo)
      addInfo <- unique(addInfo[addInfo[,1] %in% names(gsc),])
      #info$unmatchedAddInfo <- tmp - nrow(addInfo)
   } else {
      #info$unmatchedAddInfo <- 0     
   }
   
   #********************************
   # Return values:
   #********************************
   
   res <- list(gsc,addInfo)
   names(res) <- c("gsc","addInfo")
   class(res) <- "GSC"
   return(res)
   
}
