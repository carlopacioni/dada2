% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/taxonomy.R
\name{assignTaxonomy}
\alias{assignTaxonomy}
\title{assignTaxonomy assigns taxonomy to provided sequences.}
\usage{
assignTaxonomy(seqs, refFasta, minBoot = 80)
}
\arguments{
\item{seqs}{(Required). A character vector of the sequences to be assigned.}

\item{refFasta}{(Required). A character string naming the path to the reference fasta file, or an
R connection. This reference fasta file should be formatted with the id line corresponding to the
taxonomy (or classification) of the reference sequence, with each level separated by a semicolon. Eg.

 >Kingom;Phylum;Class;Order;Family;Genus;
 ACGAATGTGAAGTAA......}

\item{minBoot}{(Optional). Default 80. The minimum bootstrap confidence for assigning a taxonomic level.}
}
\value{
\code{character}. An character vector of assigned taxonomies exceeding the minBoot level of
  bootstrapping confidence. Levels are separated by semicolons.
}
\description{
assignTaxonomy implements the RDP classifier algorithm in Wang 2007 with kmer size 8.
}

