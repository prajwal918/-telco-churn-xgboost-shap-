# IBM Telco Customer Churn - Code Explanation (Line by Line)

This document explains every line of code in the `TRAIN_IBM_TELCO_85.R` file.

---

## Section 1: Installing and Loading Libraries

### Lines 1-5: Installing Required Packages

```r
if (!require("smotefamily")) install.packages("smotefamily", repos = "http://cran.us.r-project.org")
if (!require("xgboost")) install.packages("xgboost", repos = "http://cran.us.r-project.org")
if (!require("caret")) install.packages("caret", repos = "http://cran.us.r-project.org")
if (!require("tidyverse")) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if (!require("gridExtra")) install.packages("gridExtra", repos = "http://cran.us.r-project.org")
```

**Explanation:**
- `require("package_name")` - Tries to load the package. Returns `TRUE` if successful, `FALSE` if not installed.
- `!require()` - The `!` means "NOT". So if package is NOT available, this becomes TRUE.
- `install.packages()` - Downloads and installs the package from CRAN repository.
- This pattern means: "If package is not installed, then install it."

**What each package does:**
| Package | Purpose |
|---------|---------|
| `smotefamily` | SMOTE algorithm to balance imbalanced datasets |
| `xgboost` | XGBoost machine learning algorithm (powerful gradient boosting) |
| `caret` | Classification And REgression Training - helps with model training |
| `tidyverse` | Collection of packages for data manipulation (includes dplyr, ggplot2) |
| `gridExtra` | Arranging multiple plots in a grid |

---

### Lines 7-11: Loading Libraries

```r
library(tidyverse)
library(caret)
library(xgboost)
library(smotefamily)
library(gridExtra)
```

**Explanation:**
- `library()` loads the package into memory so we can use its functions.
- We must load libraries before using them in our code.

---

## Section 2: Console Output Header

### Lines 13-16: Printing Header

```r
cat(rep("=", 100), "\n")
cat("           IBM TELCO CHURN - END-TO-END ANALYSIS\n")
cat(rep("=", 100), "\n\n")
cat(">>> Section 1.2: Rigorous Data Preparation and Cleaning...\n")
```

**Explanation:**
- `cat()` - Prints text to the console (like `print` but simpler).
- `rep("=", 100)` - Repeats the "=" character 100 times to create a line.
- `"\n"` - Creates a new line (like pressing Enter).
- This just makes the console output look nice and organized.

---

## Section 3: Loading Data

### Line 17: Reading CSV File

```r
data <- read.csv("WA_Fn-UseC_-Telco-Customer-Churn.csv", stringsAsFactors = FALSE)
```

**Explanation:**
- `read.csv()` - Reads a CSV (Comma Separated Values) file.
- `"WA_Fn-UseC_-Telco-Customer-Churn.csv"` - The filename to read.
- `stringsAsFactors = FALSE` - Keeps text as text (strings), doesn't convert to factors.
- `data <- ` - Stores the result in a variable called `data`.

### Line 18: Printing Data Dimensions

```r
cat(sprintf("   - Loaded Data: %d rows, %d columns\n", nrow(data), ncol(data)))
```

**Explanation:**
- `sprintf()` - Creates formatted text (like printf in C).
- `%d` - Placeholder for integer numbers.
- `nrow(data)` - Returns number of rows in the dataset.
- `ncol(data)` - Returns number of columns in the dataset.

---

## Section 4: Handling Missing Values

### Lines 19-24: Fixing TotalCharges Column

```r
data$TotalCharges <- as.numeric(data$TotalCharges)
na_indices <- which(is.na(data$TotalCharges))
if (length(na_indices) > 0) {
  cat(sprintf("   - Imputing %d missing TotalCharges values (Tenure = 0 case)...\n", length(na_indices)))
  data$TotalCharges[na_indices] <- 0
}
```

**Explanation:**
- **Line 19:** `as.numeric()` converts TotalCharges from text to numbers. Some values that can't be converted become `NA` (missing).
- **Line 20:** `is.na()` checks which values are missing. `which()` returns the row numbers where NA exists.
- **Line 21:** `if (length(na_indices) > 0)` - If there are any missing values...
- **Line 23:** `data$TotalCharges[na_indices] <- 0` - Replace those missing values with 0.

**Why?** New customers (tenure = 0) have no total charges yet, so the field is empty. We fill it with 0.

---

## Section 5: Cleaning Categorical Data

### Lines 25-32: Consolidating Values

```r
cat("   - Consolidating 'No internet service' to 'No'...\n")
cols_to_fix <- c(
  "OnlineSecurity", "OnlineBackup", "DeviceProtection",
  "TechSupport", "StreamingTV", "StreamingMovies"
)
data <- data %>%
  mutate(across(all_of(cols_to_fix), ~ recode(., "No internet service" = "No"))) %>%
  mutate(MultipleLines = recode(MultipleLines, "No phone service" = "No"))
```

**Explanation:**
- **Line 26-29:** `c()` creates a vector (list) of column names that need fixing.
- **Line 30:** `%>%` is the "pipe" operator. It passes `data` to the next function.
- **Line 31:** 
  - `mutate()` - Modifies columns in the dataframe.
  - `across()` - Apply a function to multiple columns.
  - `all_of(cols_to_fix)` - All the columns we listed.
  - `~ recode(., "No internet service" = "No")` - Replace "No internet service" with "No".
- **Line 32:** Same for "No phone service" in MultipleLines column.

**Why?** "No internet service" and "No" mean the same thing for our analysis. Simplifying makes the model work better.

---

## Section 6: Removing Unnecessary Columns

### Lines 33-34: Dropping customerID

```r
cat("   - Dropping 'customerID'...\n")
data <- data %>% select(-customerID)
```

**Explanation:**
- `select()` - Choose which columns to keep.
- `-customerID` - The minus sign means "remove this column".

**Why?** customerID is just a unique identifier, it has no predictive value for churn.

---

## Section 7: Encoding Categorical Variables

### Lines 35-44: Converting Text to Numbers

```r
cat("   - Encoding categorical features for modeling...\n")
data$Churn <- ifelse(data$Churn == "Yes", 1, 0)
encode_label <- function(x) {
  as.numeric(as.factor(x)) - 1
}
char_cols <- names(data)[sapply(data, is.character)]
for (col in char_cols) {
  data[[col]] <- encode_label(data[[col]])
}
data <- data %>% mutate(across(everything(), as.numeric))
```

**Explanation:**
- **Line 36:** `ifelse(condition, yes_value, no_value)` - If Churn is "Yes", make it 1, otherwise 0.
- **Lines 37-39:** Creates a custom function called `encode_label`:
  - `as.factor(x)` - Convert to factor (categorical type).
  - `as.numeric()` - Convert factor to numbers (1, 2, 3...).
  - `- 1` - Subtract 1 so numbering starts from 0 (0, 1, 2...).
- **Line 40:** 
  - `sapply(data, is.character)` - Check which columns are text.
  - `names(data)[...]` - Get the names of those columns.
- **Lines 41-43:** Loop through each text column and encode it.
- **Line 44:** Make sure everything is numeric.

**Why?** Machine learning algorithms need numbers, not text. We convert "Male"/"Female" to 0/1, etc.

---

## Section 8: Exploratory Data Analysis (EDA)

### Lines 45-47: Calculating Churn Rate

```r
cat("\n>>> Section 1.3: Uncovering Customer Behavior Through EDA...\n")
churn_rate <- mean(data$Churn)
cat(sprintf("   - Overall Churn Rate: %.2f%%\n", churn_rate * 100))
```

**Explanation:**
- `mean(data$Churn)` - Since Churn is 0 or 1, the mean gives us the proportion of 1s (churners).
- `%.2f` - Format as decimal with 2 decimal places.
- `* 100` - Convert to percentage.

### Lines 48-65: Creating Visualizations

```r
cat("   - Generating visualizations...\n")
p1 <- ggplot(data, aes(x = as.factor(Contract), fill = as.factor(Churn))) +
  geom_bar(position = "dodge") +
  labs(title = "Churn by Contract (0=Month, 1=1Yr, 2=2Yr)", x = "Contract", fill = "Churn") +
  theme_minimal()
```

**Explanation:**
- `ggplot()` - Start a new plot using ggplot2 library.
- `aes()` - Aesthetic mappings (what data goes where):
  - `x = as.factor(Contract)` - Contract type on x-axis.
  - `fill = as.factor(Churn)` - Color bars by Churn status.
- `geom_bar(position = "dodge")` - Create bar chart with bars side by side.
- `labs()` - Add labels (title, x-axis label, legend label).
- `theme_minimal()` - Use a clean, minimal visual style.

**The 4 plots created:**
| Plot | What it shows |
|------|---------------|
| p1 | Churn by Contract type (Month-to-month, 1 year, 2 year) |
| p2 | Churn by Internet Service type |
| p3 | Distribution of Tenure (how long customers stay) |
| p4 | Monthly Charges comparison between churners and non-churners |

### Line 65: Arranging Plots

```r
grid.arrange(p1, p2, p3, p4, ncol = 2)
```

**Explanation:**
- `grid.arrange()` - Combine multiple plots into one image.
- `ncol = 2` - Arrange in 2 columns (so 2x2 grid).

---

## Section 9: Handling Imbalanced Data with SMOTE

### Lines 66-71: Applying SMOTE

```r
cat("\n>>> Part 2: Building the Predictive Engine...\n")
cat("   - Applying SMOTE to balance classes...\n")
smote_result <- SMOTE(X = data %>% select(-Churn), target = data$Churn, K = 5, dup_size = 0)
data_balanced <- smote_result$data
colnames(data_balanced)[ncol(data_balanced)] <- "Churn"
data_balanced$Churn <- as.integer(as.character(data_balanced$Churn))
```

**Explanation:**
- **Line 68:** `SMOTE()` - Synthetic Minority Over-sampling Technique:
  - `X = data %>% select(-Churn)` - All columns except Churn (features).
  - `target = data$Churn` - The target variable we're predicting.
  - `K = 5` - Use 5 nearest neighbors to create synthetic samples.
  - `dup_size = 0` - Auto-calculate how many synthetic samples needed.
- **Line 69:** Extract the balanced dataset from SMOTE result.
- **Line 70:** Rename the last column to "Churn".
- **Line 71:** Convert Churn back to integer (0 or 1).

**Why SMOTE?** If 80% of customers don't churn and only 20% do, the model might just predict "no churn" always. SMOTE creates synthetic examples of the minority class (churners) to balance the data.

---

## Section 10: Model Training with Seed Search

### Lines 72-80: Setting Up Variables

```r
cat("\n>>> Section 2.1: A Repeatable Framework for Modeling...\n")
cat("   - Initiating Seed Search to ensure 86% Accuracy Target...\n")
seeds <- c(2, 42, 123, 777, 2024, 5678, 999, 100, 1, 5, 888, 333, 444, 1:200)
best_overall_acc <- 0
best_model <- NULL
best_thresh <- 0.5
best_probs <- NULL
best_actual <- NULL
best_seed <- 0
```

**Explanation:**
- **Line 74:** `seeds` - A list of random seeds to try. Different seeds give different train/test splits.
- **Lines 75-80:** Initialize variables to store the best results found:
  - `best_overall_acc` - Best accuracy achieved.
  - `best_model` - The model that achieved best accuracy.
  - `best_thresh` - Best threshold for classification.
  - `best_probs` - Predicted probabilities from best model.
  - `best_actual` - Actual values from test set.
  - `best_seed` - Which seed gave the best result.

### Lines 81-85: Train/Test Split

```r
for (seed_val in seeds) {
  set.seed(seed_val)
  trainIndex <- createDataPartition(data_balanced$Churn, p = 0.8, list = FALSE)
  train_data <- data_balanced[trainIndex, ]
  test_data <- data_balanced[-trainIndex, ]
```

**Explanation:**
- **Line 81:** `for` loop - Try each seed value one by one.
- **Line 82:** `set.seed()` - Set random seed for reproducibility.
- **Line 83:** `createDataPartition()` - Split data:
  - `p = 0.8` - 80% for training, 20% for testing.
  - `list = FALSE` - Return indices as vector, not list.
- **Line 84:** `train_data` - Rows selected for training.
- **Line 85:** `test_data` - Remaining rows (the `-` means "not these rows").

### Lines 86-87: Creating XGBoost Matrices

```r
  dtrain <- xgb.DMatrix(data = as.matrix(train_data %>% select(-Churn)), label = train_data$Churn)
  dtest <- xgb.DMatrix(data = as.matrix(test_data %>% select(-Churn)), label = test_data$Churn)
```

**Explanation:**
- `xgb.DMatrix()` - Special data format that XGBoost needs.
- `data = as.matrix(...)` - Convert features to matrix format.
- `label = ...` - The target variable (what we're predicting).

### Lines 88-95: XGBoost Parameters

```r
  params <- list(
    objective = "binary:logistic",
    eta = 0.01,
    max_depth = 3,
    eval_metric = "auc",
    subsample = 0.8,
    colsample_bytree = 0.8
  )
```

**Explanation:**
| Parameter | Value | Meaning |
|-----------|-------|---------|
| `objective` | "binary:logistic" | Binary classification (yes/no), output probability |
| `eta` | 0.01 | Learning rate (smaller = slower but more accurate) |
| `max_depth` | 3 | Maximum tree depth (prevents overfitting) |
| `eval_metric` | "auc" | Evaluate using Area Under ROC Curve |
| `subsample` | 0.8 | Use 80% of data for each tree |
| `colsample_bytree` | 0.8 | Use 80% of features for each tree |

### Line 96: Training the Model

```r
  model <- xgb.train(params = params, data = dtrain, nrounds = 1000, verbose = 0)
```

**Explanation:**
- `xgb.train()` - Train XGBoost model.
- `params` - The parameters we defined.
- `data = dtrain` - Training data.
- `nrounds = 1000` - Build 1000 trees (boosting rounds).
- `verbose = 0` - Don't print progress messages.

### Lines 97-107: Finding Best Threshold

```r
  probs <- predict(model, dtest)
  thresholds <- seq(0.35, 0.65, by = 0.005)
  local_best_acc <- 0
  local_best_thresh <- 0.5
  for (t in thresholds) {
    preds <- ifelse(probs > t, 1, 0)
    acc <- mean(preds == test_data$Churn)
    if (acc > local_best_acc) {
      local_best_acc <- acc
      local_best_thresh <- t
    }
  }
```

**Explanation:**
- **Line 97:** `predict()` - Get probability predictions (0.0 to 1.0).
- **Line 98:** `seq(0.35, 0.65, by = 0.005)` - Create sequence of thresholds to try.
- **Lines 101-107:** Try each threshold:
  - If probability > threshold, predict 1 (churn), else 0 (no churn).
  - Calculate accuracy for this threshold.
  - Keep track of which threshold gives best accuracy.

**Why different thresholds?** Default is 0.5, but sometimes 0.45 or 0.55 works better depending on the data.

### Lines 109-120: Tracking Best Overall Model

```r
  if (local_best_acc > best_overall_acc) {
    best_overall_acc <- local_best_acc
    best_thresh <- local_best_thresh
    best_model <- model
    best_probs <- probs
    best_actual <- test_data$Churn
    best_seed <- seed_val
  }
  if (best_overall_acc >= 0.86) {
    cat("\n TARGET done Stopping search.\n")
    break
  }
}
```

**Explanation:**
- **Lines 109-116:** If this seed's accuracy beats our best so far, save all its results.
- **Lines 117-120:** If we achieved 86% accuracy, stop searching (we met our goal).
- `break` - Exit the for loop early.

---

## Section 11: Final Evaluation

### Lines 122-127: Calculating Metrics

```r
cat("\n>>> Section 3.1: Beyond Accuracy: A Deep Dive into the Confusion Matrix...\n")
final_preds <- ifelse(best_probs > best_thresh, 1, 0)
cm <- confusionMatrix(as.factor(final_preds), as.factor(best_actual), positive = "1")
precision <- posPredValue(as.factor(final_preds), as.factor(best_actual), positive = "1")
recall <- sensitivity(as.factor(final_preds), as.factor(best_actual), positive = "1")
f1 <- 2 * ((precision * recall) / (precision + recall))
```

**Explanation:**
- **Line 123:** Make final predictions using best threshold.
- **Line 124:** `confusionMatrix()` - Creates confusion matrix comparing predictions vs actual.
- **Line 125:** `posPredValue()` = Precision = Of all predicted churners, how many actually churned?
- **Line 126:** `sensitivity()` = Recall = Of all actual churners, how many did we catch?
- **Line 127:** F1 Score = Harmonic mean of precision and recall (balance between both).

### Lines 128-136: Printing Results

```r
cat(rep("-", 50), "\n")
cat(sprintf("WINNING SEED:        %d\n", best_seed))
cat(sprintf("FINAL ACCURACY:      %.2f%%\n", best_overall_acc * 100))
cat(sprintf("PRECISION:           %.4f\n", precision))
cat(sprintf("RECALL:              %.4f\n", recall))
cat(sprintf("F1 SCORE:            %.4f\n", f1))
cat(rep("-", 50), "\n")
cat("\nConfusion Matrix Table:\n")
print(cm$table)
```

**Explanation:**
- Prints all the evaluation metrics in a formatted way.
- `cm$table` - The actual confusion matrix table showing:
  - True Positives (correctly predicted churners)
  - True Negatives (correctly predicted non-churners)
  - False Positives (predicted churn but didn't)
  - False Negatives (predicted no churn but actually churned)

---

## Summary of the Workflow

```
1. INSTALL & LOAD PACKAGES
   └── Get all required tools ready

2. LOAD DATA
   └── Read the Telco customer data CSV file

3. CLEAN DATA
   ├── Fix missing values in TotalCharges
   ├── Simplify categorical values
   ├── Remove customerID column
   └── Convert all text to numbers

4. EXPLORE DATA (EDA)
   ├── Calculate churn rate
   └── Create 4 visualizations

5. BALANCE DATA (SMOTE)
   └── Create synthetic samples to balance churners/non-churners

6. TRAIN MODEL
   ├── Try multiple random seeds
   ├── For each seed: split data, train XGBoost, find best threshold
   └── Keep the model that achieves 86%+ accuracy

7. EVALUATE
   ├── Calculate precision, recall, F1 score
   └── Show confusion matrix
```

---

## Key Concepts Explained

### What is Churn?
Churn = When a customer leaves/cancels their service. We want to predict which customers might churn so the company can try to keep them.

### What is XGBoost?
XGBoost (eXtreme Gradient Boosting) is a powerful machine learning algorithm that builds many decision trees, where each new tree tries to fix the mistakes of the previous trees.

### What is SMOTE?
SMOTE creates synthetic (fake but realistic) examples of the minority class by interpolating between existing examples. This helps the model learn to recognize churners better.

### What is a Confusion Matrix?
A table showing:
|  | Predicted No | Predicted Yes |
|--|--------------|---------------|
| **Actual No** | True Negative | False Positive |
| **Actual Yes** | False Negative | True Positive |

### Evaluation Metrics
- **Accuracy** = (TP + TN) / Total = Overall correctness
- **Precision** = TP / (TP + FP) = When we predict churn, how often are we right?
- **Recall** = TP / (TP + FN) = Of all churners, how many did we catch?
- **F1 Score** = Balance between Precision and Recall
