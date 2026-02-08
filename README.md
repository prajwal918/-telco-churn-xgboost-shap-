# 🔮 IBM Telco Customer Churn Prediction

> XGBoost-based churn prediction pipeline with SHAP explainability, business cost analysis, and REST API deployment.

![R](https://img.shields.io/badge/R-4.0%2B-blue?logo=r)
![XGBoost](https://img.shields.io/badge/XGBoost-Gradient%20Boosting-orange)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 Overview

This project predicts **customer churn** for a telecom company using the [IBM Telco Customer Churn dataset](https://www.kaggle.com/blastchar/telco-customer-churn) (7,043 customers, 21 features). It goes beyond basic classification by including:

- **SHAP Feature Importance** — Explainable AI for model interpretability
- **Logistic Regression Baseline** — Side-by-side model comparison
- **ROC-AUC Curves** — Visual and numeric discrimination metrics
- **Business Cost-Based Evaluation** — Dollar-value impact of model decisions
- **REST API Deployment** — Production-ready Plumber API with Docker support

---

## 🏗️ Project Structure

```
1_IBM_Telco/
├── TRAIN_IBM_TELCO_85.R              # Main training & evaluation pipeline
├── api.R                              # Plumber REST API for predictions
├── Dockerfile                         # Docker container for deployment
├── WA_Fn-UseC_-Telco-Customer-Churn.csv  # Dataset
├── xgboost_churn_model.rds            # Saved model artifact (after training)
├── README.md                          # This file
└── .gitignore
```

---

## 🚀 Quick Start

### 1. Install Dependencies

```r
install.packages(c("tidyverse", "caret", "xgboost", "smotefamily",
                    "gridExtra", "pROC", "SHAPforxgboost"))
```

### 2. Train the Model

```bash
cd 1_IBM_Telco
Rscript TRAIN_IBM_TELCO_85.R
```

This will:
- Load and preprocess the dataset
- Apply SMOTE for class balancing
- Train XGBoost with hyperparameter seed search
- Evaluate with exact metrics (Accuracy, Precision, Recall, F1, AUC)
- Generate ROC curves and SHAP plots
- Compare with Logistic Regression baseline
- Compute business cost impact
- Save the model to `xgboost_churn_model.rds`

### 3. Run the Prediction API

```bash
Rscript -e "plumber::plumb('api.R')\$run(port=8000, host='0.0.0.0')"
```

### 4. Docker Deployment

```bash
docker build -t telco-churn-api .
docker run -p 8000:8000 telco-churn-api
```

---

## 📊 Pipeline Output

### Exact Metrics (XGBoost vs Logistic Regression)

| Metric      | XGBoost | Logistic Regression |
|-------------|---------|---------------------|
| Accuracy    | ≥86%    | ~78-80%             |
| Precision   | Exact   | Exact               |
| Recall      | Exact   | Exact               |
| Specificity | Exact   | Exact               |
| F1 Score    | Exact   | Exact               |
| ROC-AUC     | Exact   | Exact               |

> *Exact values are printed when you run the script. Values vary by seed.*

### Plots Generated
1. **EDA**: Churn by Contract, Internet Service, Tenure Distribution, Monthly Charges
2. **ROC Curve**: XGBoost standalone + XGBoost vs Logistic Regression overlay
3. **SHAP Bee-Swarm Plot**: Feature importance with direction of impact
4. **XGBoost Gain Importance**: Top 10 features by information gain

### Business Cost Analysis
- **False Negative** (missed churner): $500 lost revenue
- **False Positive** (unnecessary campaign): $50 campaign cost
- **True Positive** (saved customer): $200 net benefit
- Computes total cost, cost-per-customer, and savings vs no-model baseline

---

## 🔌 API Endpoints

### `GET /health`
Health check endpoint.

### `POST /predict`
Predict churn probability for a customer.

**Request Body:**
```json
{
  "gender": 1, "SeniorCitizen": 0, "Partner": 1, "Dependents": 0,
  "tenure": 12, "PhoneService": 1, "MultipleLines": 0,
  "InternetService": 1, "OnlineSecurity": 0, "OnlineBackup": 0,
  "DeviceProtection": 0, "TechSupport": 0, "StreamingTV": 0,
  "StreamingMovies": 0, "Contract": 0, "PaperlessBilling": 1,
  "PaymentMethod": 2, "MonthlyCharges": 70.5, "TotalCharges": 846
}
```

**Response:**
```json
{
  "churn_probability": 0.73,
  "churn_prediction": "Yes",
  "risk_level": "High",
  "model_threshold": 0.5
}
```

---

## 📚 Methodology

1. **Data Preprocessing**: Missing value imputation, label encoding, feature consolidation
2. **Class Balancing**: SMOTE (K=5) to handle 73.5% vs 26.5% imbalance
3. **Model Training**: XGBoost (`eta=0.01, max_depth=3, nrounds=1000`) with multi-seed search
4. **Threshold Optimization**: Sweep from 0.35–0.65 for optimal classification threshold
5. **Explainability**: SHAP values for feature-level impact analysis
6. **Baseline Comparison**: Logistic Regression (GLM) on identical train/test split
7. **Business Evaluation**: Cost matrix quantifying financial impact of predictions

---

## 📄 Dataset

- **Source**: [IBM Telco Customer Churn (Kaggle)](https://www.kaggle.com/blastchar/telco-customer-churn)
- **Records**: 7,043 customers
- **Features**: 21 (demographics, account info, services)
- **Target**: `Churn` (Yes/No → 1/0)

---

## 🛠️ Tech Stack

| Component       | Technology       |
|-----------------|------------------|
| Language        | R 4.0+           |
| ML Framework    | XGBoost, caret   |
| Explainability  | SHAPforxgboost   |
| Evaluation      | pROC, caret      |
| API Framework   | Plumber          |
| Containerization| Docker           |

---

## 📜 License

This project is for educational and research purposes.
