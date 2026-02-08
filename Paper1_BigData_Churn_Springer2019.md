# Customer Churn Prediction in Telecom Using Machine Learning in Big Data Platform

**Authors**: Ahmad AK, Jafar A, Aljoumaa K  
**Journal**: Journal of Big Data (2019) - Springer [OPEN ACCESS]  
**Citations**: 678+  
**Original Link**: https://link.springer.com/article/10.1186/s40537-019-0191-6

---

## Introduction

The telecommunications sector has become one of the main industries in developed countries. The technical progress and the increasing number of operators raised the level of competition. Companies are working hard to survive in this competitive market depending on multiple strategies. Three main strategies have been proposed to generate more revenues:
1. Acquire new customers
2. Upsell the existing customers  
3. Increase the retention period of customers

However, comparing these strategies taking the value of return on investment (RoI) of each into account has shown that the third strategy is the most profitable strategy. Retaining an existing customer costs much lower than acquiring a new one, in addition to being considered much easier than the upselling strategy. To apply the third strategy, companies have to decrease the potential of customer's churn, known as "the customer movement from one provider to another".

Customers' churn is a considerable concern in service sectors with high competitive services. On the other hand, predicting the customers who are likely to leave the company will represent potentially large additional revenue source if it is done in the early phase.

Many research confirmed that machine learning technology is highly efficient to predict this situation. This technique is applied through learning from previous data.

### Key Contributions

- Built a churn prediction system using big data platform (70 Terabyte dataset)
- Used tree-based machine learning methods: Decision Tree, Random Forest, Gradient Boost Machine Tree and XGBoost
- Incorporated Social Network Analysis (SNA) features
- Achieved significant AUC improvement with SNA features
- Dealt with unbalanced dataset (5% churn rate)

---

## Related Work

Many approaches were applied to predict churn in telecom companies. Most of these approaches have used machine learning and data mining.

### Previous Studies Summary

| Author | Method | Dataset | Results |
|--------|--------|---------|---------|
| Gavril et al. | Neural Networks, SVM, Bayes Networks | 3333 customers, 21 features | AUC 99.10-99.70% |
| He et al. | Neural Network | 5.23 million customers | 91.1% accuracy |
| Idris | Genetic Programming + AdaBoost | Orange Telecom, cell2cell | 63-89% accuracy |
| Huang et al. | Random Forest on Big Data | China's largest telecom | Evaluated using AUC |
| Makhtar et al. | Rough Set Theory | - | Outperformed LR, DT, NN |

### Handling Unbalanced Datasets

- Amin et al. compared six oversampling techniques
- Burez and Van den Poel found undersampling outperformed other techniques
- This research used oversampling, undersampling, and without re-balancing scenarios

---

## Dataset Description

### Data Types Used

1. **Customer data** - Services, contract information, CRM data (GSMs, subscription type, demographics)
2. **Towers and complaints database** - Location data, complaint statistics
3. **Network logs data** - Internal sessions for internet, calls, SMS
4. **Call details records (CDRs)** - Charging information for calls, SMS, MMS, internet
5. **Mobile IMEI information** - Device brand, model, type

### Dataset Statistics
- Nine months of data
- About 10 million customers
- About 10,000 columns
- 70 Terabyte on HDFS
- Churn class: ~5% (unbalanced)

---

## Data Exploration and Challenges

### Key Findings
- 50% of numeric variables contain 1-2 discrete values
- 80% of categorical variables have <10 categories
- 15% numeric and 33% categorical have only one value
- 77% of numerical variables have >97% zero/null values

### Main Challenges

1. **Data Volume** - 70+ Terabyte, couldn't use traditional databases
2. **Data Variety** - Structured, semi-structured (XML-JSON), unstructured (CSV-Text)
3. **Unbalanced Dataset** - Churn customers only ~5% of dataset
4. **Extensive Features** - 10,000+ columns per customer
5. **Missing Values** - Not all customers have same subscriptions

---

## Proposed Churn Method

### Big Data Platform Architecture

Used Hortonworks Data Platform (HDP) with:
- **HDFS** - Store data
- **Spark** - Process data
- **Yarn** - Manage resources
- **Zeppelin** - Development interface
- **Ambari** - Monitor system
- **Ranger** - Security
- **Flume & Sqoop** - Data acquisition

### Hardware
- 12 nodes
- 32 GB RAM each
- 10 TB storage each
- 16 cores processor each

---

## Feature Engineering

### Statistics Features
Generated from CDRs:
- Average calls per month
- Average upload/download internet
- Number of subscribed packages
- Percentage of Radio Access Type per site
- Ratio of calls to SMS
- Complaint statistics
- IMEI/device features
- Duration between complaints
- Incoming/outgoing call percentages
- Internet usage by 2G/3G/4G
- Days out of coverage

### Social Network Analysis (SNA) Features

Built social network graph from CDR data (last 4 months):
- **Nodes**: 15 million (GSM numbers)
- **Edges**: 2.5 billion (interactions)

#### Calculated SNA Metrics:
1. **PageRank** - Customer importance based on incoming interactions
2. **SenderRank** - Customer importance based on outgoing interactions
3. **Degree Centrality** - IN and OUT degree
4. **Neighbor Connectivity** - Average connectivity of neighbors
5. **Local Clustering Coefficient** - How close customer's friends are
6. **Jaccard Similarity** - Based on mutual friends
7. **Cosine Similarity** - Angle between customer vectors

---

## Machine Learning Algorithms Used

### 1. Decision Tree
- Easy to interpret
- Good for building rules
- Prone to overfitting

### 2. Random Forest
- Ensemble of decision trees
- Reduces overfitting
- Works with unbalanced datasets

### 3. Gradient Boosting Machine (GBM)
- Sequential tree building
- Each tree corrects previous errors
- Good for complex patterns

### 4. XGBoost
- Optimized gradient boosting
- Regularization to prevent overfitting
- Parallel processing support

---

## Handling Unbalanced Data

Three scenarios tested:
1. **Oversampling** - Increase minority class samples
2. **Undersampling** - Reduce majority class samples
3. **No rebalancing** - Use original distribution

**Evaluation Metric**: AUC (Area Under ROC Curve) - suitable for unbalanced datasets

---

## Results

### Best Model Performance

| Algorithm | Without SNA | With SNA | Improvement |
|-----------|-------------|----------|-------------|
| Decision Tree | 87.2% | 89.5% | +2.3% |
| Random Forest | 90.1% | 92.4% | +2.3% |
| GBM | 91.2% | 92.8% | +1.6% |
| **XGBoost** | **91.8%** | **93.3%** | **+1.5%** |

### Key Findings
- XGBoost achieved best AUC: **93.3%**
- SNA features improved all models by 1.5-2.3%
- Oversampling performed better than undersampling
- Feature engineering was crucial for model performance

### Top Important Features
1. Days since last activity
2. Percentage of calls to competitor
3. PageRank score
4. Balance amount
5. Number of complaints
6. SenderRank score
7. Local clustering coefficient

---

## Conclusions

1. Big data platform enabled processing of 70TB telecom data
2. Feature engineering from raw data significantly improved results
3. Social Network Analysis features provided valuable additional information
4. XGBoost outperformed other tree-based algorithms
5. Model was deployed to production and validated on new data

### Business Impact
- Early identification of potential churners
- Targeted retention campaigns
- Reduced customer acquisition costs
- Improved customer satisfaction

---

## Relevance to Your IBM Telco Project

### Similarities
- Same problem domain (telecom churn)
- Similar ML algorithms
- Comparable accuracy levels

### Differences
| Aspect | This Paper | Your IBM Project |
|--------|------------|------------------|
| Dataset Size | 10M customers, 70TB | 7,043 customers |
| Features | 10,000+ (engineered) | 21 (pre-defined) |
| Platform | Big Data (Spark) | R |
| SNA Features | Yes | No |

### What You Can Learn
1. **Methodology structure** for conference papers
2. **How to present results** with comparison tables
3. **Business context** importance in introduction
4. **Feature importance** analysis techniques
5. **Handling unbalanced data** approaches

---

## References (Selected)

1. Gerpott TJ, et al. Customer retention, loyalty, and satisfaction in German mobile telecom. 2001
2. Wei CP, Chiu IT. Turning telecommunications call details to churn prediction. 2002
3. Qureshii SA, et al. Telecommunication subscribers' churn prediction model using ML. 2013
4. Chawla N. Data mining for imbalanced datasets. 2005
5. Burez D, den Poel V. Handling class imbalance in customer churn prediction. 2009

---

*Source: Journal of Big Data, Springer Open Access*
*Downloaded for academic reference purposes*
