# ============================================================================
# Plumber API for IBM Telco Churn Prediction
# Deploy with: Rscript -e "plumber::plumb('api.R')$run(port=8000, host='0.0.0.0')"
# ============================================================================

if (!require("plumber")) install.packages("plumber", repos = "http://cran.us.r-project.org")
if (!require("xgboost")) install.packages("xgboost", repos = "http://cran.us.r-project.org")
library(plumber)
library(xgboost)

MODEL_PATH <- "xgboost_churn_model.rds"
if (!file.exists(MODEL_PATH)) {
  stop("Model file not found. Run TRAIN_IBM_TELCO_85.R first to generate '", MODEL_PATH, "'")
}
model_artifact <- readRDS(MODEL_PATH)
cat("Model loaded successfully. AUC:", model_artifact$auc, "\n")

#* @apiTitle IBM Telco Churn Prediction API
#* @apiDescription Predict customer churn using a trained XGBoost model

#* Health check
#* @get /health
function() {
  list(
    status = "ok",
    model = "XGBoost Telco Churn",
    accuracy = model_artifact$accuracy,
    auc = model_artifact$auc,
    threshold = model_artifact$threshold
  )
}

#* Predict churn for a single customer
#* @param gender Encoded gender (0/1)
#* @param SeniorCitizen Senior citizen flag (0/1)
#* @param Partner Has partner (0/1)
#* @param Dependents Has dependents (0/1)
#* @param tenure Months with company
#* @param PhoneService Has phone service (0/1)
#* @param MultipleLines Has multiple lines (0/1)
#* @param InternetService Internet service type (0/1/2)
#* @param OnlineSecurity Has online security (0/1)
#* @param OnlineBackup Has online backup (0/1)
#* @param DeviceProtection Has device protection (0/1)
#* @param TechSupport Has tech support (0/1)
#* @param StreamingTV Has streaming TV (0/1)
#* @param StreamingMovies Has streaming movies (0/1)
#* @param Contract Contract type (0/1/2)
#* @param PaperlessBilling Paperless billing (0/1)
#* @param PaymentMethod Payment method (0/1/2/3)
#* @param MonthlyCharges Monthly charges amount
#* @param TotalCharges Total charges amount
#* @post /predict
function(req, gender, SeniorCitizen, Partner, Dependents, tenure,
         PhoneService, MultipleLines, InternetService, OnlineSecurity,
         OnlineBackup, DeviceProtection, TechSupport, StreamingTV,
         StreamingMovies, Contract, PaperlessBilling, PaymentMethod,
         MonthlyCharges, TotalCharges) {

  features <- data.frame(
    gender = as.numeric(gender),
    SeniorCitizen = as.numeric(SeniorCitizen),
    Partner = as.numeric(Partner),
    Dependents = as.numeric(Dependents),
    tenure = as.numeric(tenure),
    PhoneService = as.numeric(PhoneService),
    MultipleLines = as.numeric(MultipleLines),
    InternetService = as.numeric(InternetService),
    OnlineSecurity = as.numeric(OnlineSecurity),
    OnlineBackup = as.numeric(OnlineBackup),
    DeviceProtection = as.numeric(DeviceProtection),
    TechSupport = as.numeric(TechSupport),
    StreamingTV = as.numeric(StreamingTV),
    StreamingMovies = as.numeric(StreamingMovies),
    Contract = as.numeric(Contract),
    PaperlessBilling = as.numeric(PaperlessBilling),
    PaymentMethod = as.numeric(PaymentMethod),
    MonthlyCharges = as.numeric(MonthlyCharges),
    TotalCharges = as.numeric(TotalCharges)
  )

  # Ensure column order matches training
  expected_cols <- model_artifact$feature_names
  for (col in expected_cols) {
    if (!(col %in% names(features))) {
      features[[col]] <- 0
    }
  }
  features <- features[, expected_cols, drop = FALSE]

  dmat <- xgb.DMatrix(data = as.matrix(features))
  prob <- predict(model_artifact$model, dmat)

  threshold <- model_artifact$threshold
  prediction <- ifelse(prob > threshold, "Yes", "No")
  risk_level <- ifelse(prob > 0.7, "High", ifelse(prob > 0.4, "Medium", "Low"))

  list(
    churn_probability = round(prob, 4),
    churn_prediction = prediction,
    risk_level = risk_level,
    model_threshold = threshold
  )
}

#* Predict churn for a batch of customers (JSON array)
#* @post /predict_batch
function(req) {
  customers <- req$body
  if (!is.data.frame(customers)) {
    customers <- do.call(rbind, lapply(customers, as.data.frame))
  }

  expected_cols <- model_artifact$feature_names
  for (col in expected_cols) {
    if (!(col %in% names(customers))) {
      customers[[col]] <- 0
    }
  }
  customers <- customers[, expected_cols, drop = FALSE]
  customers <- as.data.frame(lapply(customers, as.numeric))

  dmat <- xgb.DMatrix(data = as.matrix(customers))
  probs <- predict(model_artifact$model, dmat)

  threshold <- model_artifact$threshold
  data.frame(
    churn_probability = round(probs, 4),
    churn_prediction = ifelse(probs > threshold, "Yes", "No"),
    risk_level = ifelse(probs > 0.7, "High", ifelse(probs > 0.4, "Medium", "Low"))
  )
}
