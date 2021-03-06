% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hasBledModel.R
\name{hasBledModel}
\alias{hasBledModel}
\title{Apply the existing model HAS-BLED using the standardised framework}
\usage{
hasBledModel(connectionDetails, cdmDatabaseSchema, cohortDatabaseSchema,
  outcomeDatabaseSchema, cohortTable, outcomeTable, cohortId, outcomeId,
  oracleTempSchema = NULL, removePriorOutcome = T)
}
\arguments{
\item{connectionDetails}{The connection details for extracting the data}

\item{cdmDatabaseSchema}{A string specifying the database containing the cdm}

\item{cohortDatabaseSchema}{A string specifying the database containing the target population cohort}

\item{outcomeDatabaseSchema}{A string specifying the database containing the outcome cohort}

\item{cohortTable}{A string specifying the table containing the target population cohort}

\item{outcomeTable}{A string specifying the table containing the outcome cohort}

\item{cohortId}{An iteger specifying the cohort id for the target population cohorts}

\item{outcomeId}{An iteger specifying the cohort id for the outcome cohorts}

\item{oracleTempSchema}{The temp schema require is using oracle}

\item{removePriorOutcome}{Remove people with prior outcomes from the target population}
}
\value{
A list containing the model performance and the personal predictions for each subject in the target population
}
\description{
Apply the existing model HAS-BLED using the standardised framework
}
\details{
This function applies HAS_BLED to a target cohort and validates the performance
}
