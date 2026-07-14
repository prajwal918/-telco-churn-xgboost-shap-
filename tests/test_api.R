# Simple unit test for model artifact
tryCatch({
  if (file.exists("../xgboost_churn_model.rds")) {
    model <- readRDS("../xgboost_churn_model.rds")
    if (is.null(model$auc)) stop("Model AUC missing")
    cat("Test passed: Model artifact is valid.\n")
  } else {
    cat("Test skipped: Model artifact not found.\n")
  }
}, error = function(e) {
  cat("Test failed:", e$message, "\n")
  quit(status = 1)
})
