################################################################################
#' Read and Dereplicate a Fastq file.
#' 
#' This is a custom interface to \code{\link{FastqStreamer}} 
#' for dereplicating amplicon sequences from a fastq or fastq.gz file,
#' while also controlling peak memory requirement to support large files.
#' This function relies heavily on the \code{\link[ShortRead]{tables}} method.
#'
#' @param fl (Required). Character.
#'  The file path to the fastq or fastq.gz file.
#'  Actually, any file format supported by \code{\link{FastqStreamer}}.
#' 
#' @param n (Optional). A \code{numeric(1)} indicating
#'  the maximum number of records (reads) to parse and dereplicate
#'  at any one time. This controls the peak memory requirement
#'  so that large fastq files are supported.
#'  Defaults is \code{1e6}, one-million reads.
#'  See \code{\link{FastqStreamer}} for details on this parameter,
#'  which is passed on.
#' 
#' @param verbose (Optional). A \code{logical(1)} indicating
#'  whether to throw any standard R \code{\link{message}}s 
#'  on the intermittent and final status of the dereplication.
#'  Default is \code{FALSE}, no messages.
#'
#' @return Named integer vector. Named by sequence, valued by number of occurence.
#'
#' @seealso \code{\link{replicateReads}}, \code{\link{removeReadsWithNs}}, 
#' \code{\link{findBarcodes}}, \code{\link{splitByBarcode}}
#'
#' @export
#' @import ShortRead 
#'
#' @examples 
#' # Test that chunk-size, `n`, does not affect the result.
#' testFile = system.file("extdata", "test-nonunique.fastq.gz", package="dadac")
#' test1 = dereplicateFastqReads(testFile, verbose = TRUE)
#' test2 = dereplicateFastqReads(testFile, 35, TRUE)
#' test3 = dereplicateFastqReads(testFile, 100, TRUE)
#' all.equal(test1, test2[names(test1)])
#' all.equal(test1, test3[names(test1)])
dereplicateFastqReads <- function(fl, n = 1e6, verbose = FALSE){
  # require("ShortRead")
  if(verbose){
    message("Dereplicating sequence entries in Fastq file: ", fl, appendLF = TRUE)
  }
  ## iterating over an entire file using fastq streaming
  f <- FastqStreamer(fl, n = n)
  # `yield` is the method for returning the next chunk from the stream.
  # Use `fq` as the "current chunk"
  suppressWarnings(fq <- yield(f))
  # Calculate the dereplicated counts for the first chunk
  derepCounts = tables(fq, n = Inf)$top
  # This loop will stop if/when the end of the file is already reached.
  # If end is already reached, this loop is skipped altogether.
  while( length(suppressWarnings(fq <- yield(f))) ){
    # A little loop protection
    idrep = alreadySeen = NULL
    # Dot represents one turn inside the chunking loop.
    if(verbose){
      message(".", appendLF = FALSE)
    }
    idrep <- tables(fq, n = Inf)$top
    # identify sequences already present in `derepCounts`
    alreadySeen = names(idrep) %in% names(derepCounts)
    # Sum these values, if any
    if(any(alreadySeen)){
      sqnms = names(idrep)[alreadySeen]
      derepCounts[sqnms] <- derepCounts[sqnms] + idrep[sqnms]
    }
    # Concatenate the remainder to `derepCounts`, if any
    if(!all(alreadySeen)){
      derepCounts <- c(derepCounts, idrep[!alreadySeen])
    }
  }
  if(verbose){
    message("Encountered ",
            length(derepCounts),
            " unique sequences from ",
            sum(derepCounts),
            " total sequences read.")
  }
  return(derepCounts)
}
################################################################################
#' Load .uniques file
#' Basically a wrapper for read.table customized for .uniques format
#'
#' @param fl (Required). \code{character(1)}.
#'  The file path to the .uniques file,
#'  a delimited text table file containing unique sequences and their abundances.
#'  
#' @param colClasses (Optional). \code{character}.
#'  The classes of the columns in the delimited text file.
#'  Defaults to \code{c("integer", "character")}.
#'  See \code{\link[utils]{read.table}} for more information.
#' 
#' @param ... (Optional). Additional arguments passed on to \code{\link[utils]{read.table}}.
#'
#' @return Named integer vector. Named by sequence, valued by number of occurence.
#'
#' @export
#' 
importUniques <- function(fl, colClasses = c("integer", "character"), ...){
  unqs <- read.table(fl, colClasses = colClasses, ...)
  # Check that things worked as expected.
  if(ncol(unqs) != 2) stop(paste("Unexpected number of columns:", ncol(unqs)))
  if(class(unqs[,2]) != "character") stop(paste("Integer/sequence pairs required(1)."))
  if(class(unqs[,1]) != "integer") {
    if(class(unqs[,1]) != "numeric") {
      stop(paste("Integer/sequence pairs required(2)."))
    }
    foo <- as.integer(unqs[,1])
    if(all.equal(foo, unqs[,1])) {
      unqs[,1] <- as.integer(unqs[,1])
    } else {
      stop(paste("Integer/sequence pairs required(3)."))
    }
  }
  # Checks are done, create the uniques vector.
  rvec <- unqs[,1]
  names(rvec) <- unqs[,2]
  return(rvec)
}
################################################################################