#' Apply the existing model Qstroke stroke risk using the standardised framework
#'
#' @details
#' This function applies Qstroke stroke risk to a target cohort and validates the performance
# using the outcome cohort
#'
#' @param connectionDetails                The connection details for extracting the data
#' @param cdmDatabaseSchema                      A string specifying the database containing the cdm
#' @param cohortDatabaseSchema                    A string specifying the database containing the target population cohort
#' @param outcomeDatabaseSchema                   A string specifying the database containing the outcome cohort
#' @param cohortTable          A string specifying the table containing the target population cohort
#' @param outcomeTable        A string specifying the table containing the outcome cohort
#' @param cohortId             An iteger specifying the cohort id for the target population cohorts
#' @param outcomeId          An iteger specifying the cohort id for the outcome cohorts
#' @param oracleTempSchema   The temp schema require is using oracle
#' @param removePriorOutcome  Remove people with prior outcomes from the target population
#'
#' @return
#' A list containing the model performance and the personal predictions for each subject in the target population
#'
#' @export
qstrokeModel <- function(connectionDetails,
                         cdmDatabaseSchema,
                         cohortDatabaseSchema,
                         outcomeDatabaseSchema,
                         cohortTable,
                         outcomeTable,
                         cohortId,
                         outcomeId,
                         oracleTempSchema=NULL,
                         removePriorOutcome=T){

  #input checks...
  if(missing(connectionDetails))
    stop('Need to enter connectionDetails')
  if(missing(cdmDatabaseSchema))
    stop('Need to enter cdmDatabaseSchema')
  if(missing(cohortDatabaseSchema))
    stop('Need to enter cohortDatabaseSchema')
  if(missing(outcomeDatabaseSchema))
    stop('Need to enter outcomeDatabaseSchema')
  if(missing(cohortTable))
    stop('Need to enter cohortTable')
  if(missing(outcomeTable))
    stop('Need to enter outcomeTable')
  if(missing(cohortId))
    stop('Need to enter cohortId')
  if(missing(outcomeId))
    stop('Need to enter outcomeId')

  conceptSets <- system.file("extdata", "existingStrokeModels_concepts.csv", package = "PredictionComparison")
  conceptSets <- read.csv(conceptSets)

  existingBleedModels <- system.file("extdata", "existingStrokeModels_modelTable.csv", package = "PredictionComparison")
  existingBleedModels <- read.csv(existingBleedModels)

  modelNames <- system.file("extdata", "existingStrokeModels_models.csv", package = "PredictionComparison")
  modelNames <- read.csv(modelNames)

  modelTable <- existingBleedModels[existingBleedModels$modelId==modelNames$modelId[modelNames$name=='Qstroke'],]
  modelTable <- modelTable[,c('modelId','modelCovariateId','coefficientValue')]

  # use history anytime prior by setting long term look back to 9999
  covariateSettings <- FeatureExtraction::createCovariateSettings(useDemographicsRace  = T,
                                                                  useConditionOccurrenceLongTerm = T,
                                                                  useConditionGroupEraLongTerm = T,
                                                                  useDrugGroupEraShortTerm = T,
                                                                  useConditionGroupEraMediumTerm = T,
                                                                  useProcedureOccurrenceLongTerm = T,
                                                                  useObservationLongTerm = T,
                                                                  longTermStartDays = -9999,
                                                                  mediumTermStartDays = -365,
                                                                  shortTermStartDays = -30)

  cust <- data.frame(covariateId=-46, sql="insert into @targetCovariateTable
select distinct a.@rowIdField as row_id, @covariateId as covariate_id,  1 as covariate_value
from
(select row_id from @targetCovariateTable where covariate_id=320128211) a
inner join
(select row_id from @targetCovariateTable where covariate_id=21600381412) b
on a.row_id=b.row_id")

  result <- PatientLevelPrediction::evaluateExistingModel(modelTable = modelTable,
                                                          covariateTable = conceptSets[,c('modelCovariateId','covariateId')],
                                                          interceptTable = NULL,
                                                          type = 'score',
                                                          covariateSettings = covariateSettings,
                                                          customCovariates =cust,
                                                          riskWindowStart = 1,
                                                          riskWindowEnd = 365,
                                                          requireTimeAtRisk = T,
                                                          minTimeAtRisk = 364,
                                                          includeAllOutcomes = T,
                                                          removeSubjectsWithPriorOutcome =removePriorOutcome,
                                                          connectionDetails = connectionDetails,
                                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                                          cohortDatabaseSchema = cohortDatabaseSchema,
                                                          cohortTable = cohortTable,
                                                          cohortId = cohortId,
                                                          outcomeDatabaseSchema = outcomeDatabaseSchema,
                                                          outcomeTable = outcomeTable,
                                                          outcomeId = outcomeId)

  inputSetting <- list(connectionDetails=connectionDetails,
                       cdmDatabaseSchema=cdmDatabaseSchema,
                       cohortDatabaseSchema=cohortDatabaseSchema,
                       outcomeDatabaseSchema=outcomeDatabaseSchema,
                       cohortTable=cohortTable,
                       outcomeTable=outcomeTable,
                       cohortId=cohortId,
                       outcomeId=outcomeId,
                       oracleTempSchema=oracleTempSchema)
  result <- list(model=list(model='qstroke'),
                 analysisRef ='000000',
                 inputSetting =inputSetting,
                 executionSummary = 'Not available',
                 prediction=result$prediction,
                 performanceEvaluation=result$performance)
  class(result$model) <- 'plpModel'
  attr(result$model, "type")<- 'existing model'
  class(result) <- 'runPlp'
  return(result)
}
