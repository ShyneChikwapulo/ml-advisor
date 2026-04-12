# app/knowledge_base.py
# Verified facts extracted from peer-reviewed research papers.
# Every entry must be directly traceable to the source paper.
# DO NOT add, infer, or round any statistics.

KNOWLEDGE_BASE = {

    "albattah2024_defect_prediction": """
FINDINGS (Albattah & Alzahrani, 2024 - Software Defect Prediction Based on Machine Learning and Deep Learning Techniques: An Empirical Approach):
- Dataset used: Unified Bug Dataset (47,618 classes, 60 software metrics)
- Models evaluated: Support Vector Machine (SVM), Logistic Regression (LR), Random Forest, Extreme Gradient Boosting (XGBoost), Artificial Neural Networks (ANNs), Autoencoders, Deep Belief Networks (DBNs), Long Short-Term Memory (LSTM)
- Best model: LSTM, Accuracy=87%, F1=61% (Binary F1), Precision=70%, Recall=55%
- Runner-up: XGBoost, Accuracy=85%, F1=47% (Binary F1)
- The dataset is highly imbalanced, containing 8,780 buggy classes compared to 38,838 non-buggy classes.
- Key limitation acknowledged by authors: Future work should explore the impact of applying feature selection techniques and developing hybrid classification models.
""",

    "laiq2024_invalid_bug_reports": """
FINDINGS (Laiq et al., 2024 - Industrial adoption of machine learning techniques for early identification of invalid bug reports):
- Dataset used: Proprietary telecommunication company datasets (P1: ~3300 bug reports, P2: ~3400 bug reports, P3: ~1000 bug reports)
- Models evaluated: Support Vector Machine (SVM), Random Forest, Convolutional Neural Network (CNN), XGBoost, Bidirectional Encoder Representations from Transformers (BERT)
- Best model: Omitted (Specific accuracy/precision metrics for the best model are not explicitly reported in the text)
- Runner-up: Omitted (Specific metrics not reported)
- A visual and descriptive explanation of the prediction using SHAP increases the trustability of the technique compared to just presenting the validity predictions.
- Key limitation acknowledged by authors: The machine learning technique's accuracy drops over time in its operational use due to concept drift.
""",

    "saharudin2020_systematic_review": """
FINDINGS (Saharudin et al., 2020 - Machine Learning Techniques for Software Bug Prediction: A Systematic Review):
- Dataset used: 31 main studies selected from an initial list of 1452 studies across four digital databases (2014-2020)
- Models evaluated: Bayesian Network (BN), Neural Network (NN), Support Vector Machine (SVM), Clustering, Feature Selection (FS), Ensemble Learning (EL)
- Best model: Neural Networks (NN) and Bayesian algorithms (specifically Naïve Bayes) were identified as the most widely used techniques for bug prediction models.
- Runner-up: Omitted (SLR format; exact numerical model performance comparisons across all studies are not aggregated into a single metric)
- The PROMISE (43.3%) and NASA MDP (43.3%) repositories are the most frequently used datasets by past researchers.
- Key limitation acknowledged by authors: The review did not include studies from conference proceedings and only focused on papers from primary journals.
""",

    "jorayeva2022_mobile_defect_prediction": """
FINDINGS (Jorayeva et al., 2022 - Machine Learning-Based Software Defect Prediction for Mobile Applications: A Systematic Literature Review):
- Dataset used: 47 relevant studies selected from 721 retrieved publications
- Models evaluated: Naïve Bayes (NB), Support Vector Machines (SVM), Logistic Regression (LR), Neural Network (NN), Decision Tree (DT), Random Forest (RF), K-nearest Neighbors (KNN), Alpha-beta pruning (AB), K-means, Bayesian Network (BN), Bootstrap aggregating (Bag), Multilayer Perceptron (MLP), Voting Future Intervals (VFI), DTNB, Non-Nested Generalization (NNge), Logistic model tree (LMT), Artificial Neural Network (ANN), Adaptive genetic algorithm (AGA), LSTM, DBN, DNN
- Best model: Support Vector Machines (SVM) was identified 4 times as the best algorithm across the reviewed publications.
- Runner-up: Random Forest (RF) and Multilayer Perceptron (MLP) were reported as the best algorithm in 3 publications.
- 48% of the reviewed studies focused on Android applications, and supervised machine learning was applied in 92% of the studies.
- Key limitation acknowledged by authors: Potential missing papers in electronic databases and missed synonyms in the search criteria.
""",

    "khalid2023_defect_prediction_pso": """
FINDINGS (Khalid et al., 2023 - Software Defect Prediction Analysis Using Machine Learning Techniques):
- Dataset used: CM1 dataset from PROMISE repository (498 modules, 22 features)
- Models evaluated: Support Vector Machine (SVM), Naïve Bayes (NB), Random Forest (RF), Ensemble (Stacking), SVM+PSO, NB+PSO, RF+PSO, Ensemble+PSO
- Best model: SVM+PSO, Accuracy=99.80%, F1=96%, Precision=99.70%, Recall=100%
- Runner-up: RF+PSO, Accuracy=99.50%, F1=91.10%, Precision=100%, Recall=99.50%
- K-means clustering was employed for the categorization of class labels prior to applying classification models.
- Key limitation acknowledged by authors: The models were applied to a limited dataset; future work will increase dataset size and analyze different types of ensemble classifiers with data balancing techniques.
""",

    "hammouri2018_bug_prediction_ml": """
FINDINGS (Hammouri et al., 2018 - Software Bug Prediction using Machine Learning Approach):
- Dataset used: DS1 (46 instances), DS2 (111 instances), and DS3 (110 instances)
- Models evaluated: Naïve Bayes (NB), Decision Tree (DT), Artificial Neural Networks (ANNs)
- Best model: Decision Tree (DT), Accuracy=97.1% (Average), Precision=99.6% (Average), Recall=100% (Average)
- Runner-up: ANNs, Accuracy=95.1% (Average), Precision=99.0% (Average), Recall=99.0% (Average)
- The machine learning classifiers achieved a better average Root-Mean-Square Error (RMSE) value of 0.130 compared to AR (2.783) and POWM (105.701) models.
- Key limitation acknowledged by authors: The study could be extended by involving other ML techniques and adding more software metrics in the learning process to increase accuracy.
""",

    "khleel2021_comprehensive_study": """
FINDINGS (Khleel & Nehéz, 2021 - Comprehensive Study on Machine Learning Techniques for Software Bug Prediction):
- Dataset used: NASA Promise Repository (JM1, PC1, KC1, KC2)
- Models evaluated: Decision Tree (DT), Naïve Bayes (NB), Random Forest (RF), Logistic Regression (LR)
- Best model: Decision Tree (DT) and Random Forest (RF), Accuracy=99% (Maximum achieved across datasets), Precision=99% (Maximum achieved across datasets), Recall=100% (Maximum achieved across datasets), F1=100% (Maximum achieved across datasets)
- Runner-up: Logistic Regression (LR), Accuracy=93% (On PC1 dataset), F1=96% (On PC1 dataset)
- The average value for the accuracy rate in all datasets for both the Decision Tree and Random Forest models is over 98.5%.
- Key limitation acknowledged by authors: Future work plans to introduce other machine learning techniques with data balancing techniques to improve accuracy.
""",

    "hickman2021_predict_future": """
FINDINGS (Hickman & Holmqvist, 2021 - Predict future software defects through machine learning):
- Dataset used: VSCode open source git-repository (7500 data points across 3 branches)
- Models evaluated: Random forest, logistic regression, naive Bayes
- Best model: Logistic regression, Accuracy=83% (Weighted average with resampling), F1=82% (Weighted average with resampling), Precision=82% (Weighted average with resampling), Recall=83% (Weighted average with resampling)
- Runner-up: Random forest, Accuracy=81% (Weighted average with resampling), F1=81% (Weighted average with resampling)
- Resampling (undersampling the dominant class by 10% and oversampling the minority class by 100%) helped reduce classifier biases towards the negative (no defect) class.
- Key limitation acknowledged by authors: The true number of defects is unknown because only defects fixed through a git commit are recognized in the dataset.
""",

    "challagulla2008_empirical_assessment": """
FINDINGS (Challagulla et al., 2008 - Empirical Assessment of Machine Learning Based Software Defect Prediction Techniques):
- Dataset used: NASA MDP data sets (CM1: 506 modules, JM1: 10879 modules, KC1: 2108 modules, PC1: 1108 modules)
- Models evaluated: Support Vector Logistic Regression (SVLR), Neural Networks (NND), Logistic Regression (LoR), Naïve Bayes (NB), Instance Based Learning (IBL), J48 Decision Trees (JDT), 1-Rule (1R)
- Best model: 1-Rule (1R), Mean Absolute Error (MAE)=0.0631 (on PC1 dataset)
- Runner-up: Instance Based Learning (IBL), Mean Absolute Error (MAE)=0.089 (on PC1 dataset)
- Feature subset selection methods like Consistency-based Subset Evaluation (CBS) and Correlation-based Feature Selection (CFS) generally performed better than Principal Component Analysis (PCA) for improving prediction capabilities.
- Key limitation acknowledged by authors: The prediction techniques investigated were limited only by the available techniques in the WEKA tool kit.
""",

    "subbiah2018_software_engineering": """
FINDINGS (Subbiah et al., 2018 - Software Engineering Approach to Bug Prediction Models Using Machine Learning as a Service (MLaaS)):
- Dataset used: "Change metrics (15) plus categorized post-release defects" (Model 1) and "Churn of CK and other 11 object oriented metrics over 91 versions of the system" (Model 2) from Eclipse version release data
- Models evaluated: Two class Averaged Perceptron, Two class Bayes point machine, Two class Boosted decision tree, Two class Decision forest, Two class Decision jungle, Two class Locally deep SVM, Two class Logistic Regression, Two class Neural Network, Two class SVM
- Best model: Two class Averaged Perceptron (Model 1), Accuracy=85.5%, F1=91.5%, Precision=85.8%, Recall=98.0%
- Runner-up: Two class Decision jungle (Model 1), Accuracy=85.1%, F1=91.0%
- The study utilized Microsoft Azure's machine learning platform to propose Bug Prediction as a Service (BPaaS).
- Key limitation acknowledged by authors: Future work may include increasing the accuracy of models using commercial datasets as opposed to the open-sourced datasets used in the experiment.
""",

    "kethireddy2022_software_defects": """
FINDINGS (Kethireddy et al., 2022 - Software Defects Prediction using Machine Learning Algorithms):
- Dataset used: Publicly accessible dataset evaluated using 10-fold cross-validation and percentage splits (Specific dataset name not provided)
- Models evaluated: Artificial Neural Networks (ANN), Random Forest (RF), Random Tree (RT), Decision Table (DT), Linear Regression (LR), Gaussian Processes (GP), SMOreg, M5P
- Best model: SMOreg, Mean Absolute Error (MAE) and Root Mean Square Error (RMSE) indicated lowest error rates compared to other algorithms (Exact Accuracy/F1/Precision/Recall metrics for SMOreg not explicitly detailed in the provided text snippet, but identified as having the best performance results)
- Runner-up: Linear regression (LR) (Produced strong correlation coefficient values alongside SMOreg)
- Using the Correlation-based Feature Selection (CFS) approach, a subset of five metrics (DIT, CBO, RFC, NPM, and LOC) was chosen from a group of eight metrics.
- Key limitation acknowledged by authors: Future work may involve doing research across diverse data sets to provide conclusions usable across many businesses.
""",

    "ali2023_xgboost_review": """
FINDINGS (Ali et al., 2023 - Exploring the Power of eXtreme Gradient Boosting Algorithm in Machine Learning: a Review):
- Dataset used: Not reported
- Models evaluated: eXtreme Gradient Boosting (XGBoost), Support Vector Machine (SVM), Logistic Regression, Random Forest, Artificial Neural Networks (ANNs)
- Best model: XGBoost, Accuracy=Not reported, F1=Not reported, Precision=Not reported, Recall=Not reported
- Runner-up: Not reported
- XGBoost is a parallel tree boosting library identified as a superior machine learning algorithm in terms of prediction accuracy, interpretability, and classification versatility.
- The algorithm incorporates regularization to prevent overfitting and includes a sparsity-aware split finding feature to handle missing data.
""",

    "zheng2021_imbalanced_ensemble": """
FINDINGS (Zheng et al., 2021 - A Novel Imbalanced Ensemble Learning in Software Defect Predication):
- Dataset used: 11 NASA MDP datasets (CM1, JM1, KC1, KC3, MC1, MC2, MW1, PC1, PC3, PC4, PC5)
- Models evaluated: AdaBoost, RUSBoost, SMOTEBoost, IAdaBoost, SWIMBoost
- Best model: IAdaBoost and SWIMBoost, Accuracy=Not reported, F1=Not reported, Precision=Not reported, Recall=Not reported
- Runner-up: RUSBoost, Accuracy=Not reported, F1=Not reported
- IAdaBoost and SWIMBoost achieved better G-mean and AUC measures compared to traditional ensemble learning methods for imbalanced software defect prediction.
- IAdaBoost is more effective for highly imbalanced datasets, while SWIMBoost is more suitable for moderately imbalanced datasets.
""",

    "palanivinayagam2023_text_classification": """
FINDINGS (Palanivinayagam et al., 2023 - Twenty Years of Machine-Learning-Based Text Classification: A Systematic Review):
- Dataset used: 224 papers published between 2003 and 2022 across domains including spam detection, sentiment analysis, and bug reports
- Models evaluated: Support Vector Machines (SVM), Naive Bayes (NB), Random Forest (RF), K-Nearest Neighbors (KNN), Artificial Neural Networks (ANN), Convolutional Neural Networks (CNN), Recurrent Neural Networks (RNN)
- Best model: Support Vector Machines (SVM) was identified as the most frequently used machine learning model for text classification, appearing in 118 surveyed papers.
- Runner-up: Omitted (SLR format; specific runner-up across all studies is not aggregated into a single metric)
- Accuracy (107 papers) and F1-score (99 papers) were the most frequently used performance evaluation metrics in the reviewed literature.
- Key limitation acknowledged by authors: Future research should focus on improving classification speed for long-text information and addressing feature drift.
""",

    "ali2023_feature_selection": """
FINDINGS (Ali et al., 2023 - Analysis of Feature Selection Methods in Software Defect Prediction Models):
- Dataset used: 49 selected primary studies published from 2014 to 2023 (SLR format)
- Models evaluated: Naïve Bayes, Support Vector Machine (SVM), Decision Tree, Random Forest, Bagging, AdaBoost, K-Nearest Neighbor (KNN), Convolutional Neural Network (CNN), Hybrid Deep Neural Network (DNN), Least Square Support Vector Machine (LSSVM)
- Best model: Omitted (SLR format; filtering and hybrid feature selection methods are identified as prevalent across the reviewed studies)
- Runner-up: Omitted (SLR format)
- Tools such as WEKA, MATLAB, and Python are the most commonly used for implementing feature selection in the reviewed literature.
- Key limitation acknowledged by authors: The study focused on specific databases (IEEE Xplore, Science Direct, ACM, Springer Link) and may have missed relevant studies from other sources.
""",

    "saeed2023_cross_project": """
FINDINGS (Saeed & Saleem, 2023 - Cross Project Software Defect Prediction Using Machine Learning: A Review):
- Dataset used: Literature review of studies from 2018 to 2023 using repositories such as PROMISE, NASA, AEEEM, Jureczko, and ReLink
- Models evaluated: Transfer Learning (TCA, JDA), Deep Learning (CNN, RNN, LSTM), Ensemble Learning, Transfer Component Analysis (TCA), Joint Distribution Adaptation (JDA), Kernel Mean Matching (KMM)
- Best model: Omitted (SLR format; highlights Transfer Learning and Deep Learning as key approaches for Cross-Project Defect Prediction)
- Runner-up: Omitted (SLR format)
- Cross-Project Defect Prediction (CPDP) is utilized when a target project lacks sufficient historical defect data for Within-Project Defect Prediction (WPDP).
- Key limitation acknowledged by authors: Future research should address the challenges of data selection, feature extraction, and the "negative transfer" issue in CPDP.
""",

    "meiliana2017_literature_review": """
FINDINGS (Meiliana et al., 2017 - Software Metrics for Fault Prediction Using Machine Learning Approaches: A Literature Review with PROMISE Repository Dataset):
- Dataset used: Primary studies using the PROMISE repository datasets (e.g., CM1, JM1, KC1, KC2, PC1)
- Models evaluated: Artificial Neural Network (ANN), Naïve Bayes, Decision Tree, Support Vector Machine (SVM), Random Forest, K-Nearest Neighbors (KNN), Logistic Regression, Bagging, Boosting
- Best model: Omitted (SLR format; Artificial Neural Networks and Naïve Bayes were reported as the most frequently applied algorithms in the surveyed literature)
- Runner-up: Omitted (SLR format)
- Software metrics utilized for prediction include McCabe metrics (Cyclomatic Complexity), Halstead metrics (Volume, Effort), and CK metrics (WMC, DIT, NOC, CBO, RFC, LCOM).
- Key limitation acknowledged by authors: Testing is a time-consuming activity, and the review suggests the need for better planning and resource management through improved predictive methodologies.
""",

    "mehta2025_class_imbalance": """
FINDINGS (Mehta et al., 2025 - A Review of Software Fault Prediction Techniques in Class Imbalance Scenarios):
- Dataset used: Literature review across datasets including PROMISE, NASA, and Cross Project Defect Prediction (CPDP)
- Models evaluated: Bagging, Boosting, Stacking, Two-Stage Ensembles, Cost-Sensitive Learning, SMOTE, MAHAKIL
- Best model: Omitted (SLR format; hybrid approaches that blend ensemble learning and sampling strategies are identified as providing encouraging outcomes)
- Runner-up: Omitted (SLR format)
- Evaluation criteria such as accuracy, precision, recall, and stability are used to determine the effectiveness of methods in handling imbalanced software failure prediction data.
- Key limitation acknowledged by authors: The evaluation aims to shed light on the advantages and disadvantages of each strategy to help choose the best techniques for unbalanced scenarios.
""",

    "rath2024_reliability_ensemble": """
FINDINGS (Rath et al., 2024 - Software Reliability Prediction Using Ensemble Learning on Selected Features in Imbalanced and Balanced Datasets: A Review):
- Dataset used: Literature review covering standard repositories including PROMISE and NASA.
- Models evaluated: Bagging, Boosting, Stacking, and Extreme Learning Machine (ELM) combined with feature selection techniques.
- Best model: Omitted (Review format; hybrid ensemble models incorporating feature selection are highlighted as the most effective for handling imbalanced datasets).
- Runner-up: Omitted (Review format).
- The study emphasizes that feature selection is critical for removing redundant and irrelevant metrics, which significantly improves the reliability of ensemble classifiers.
- Key limitation acknowledged by authors: The complexity of software metrics and the presence of missing samples continue to challenge the consistency of prediction models across different domains.
""",

    "laradji2014_ensemble_features": """
FINDINGS (Laradji et al., 2014 - Software defect prediction using ensemble learning on selected features):
- Dataset used: 7 NASA MDP datasets (CM1, JM1, KC1, KC3, MC2, MW1, PC1).
- Models evaluated: Random Forest, Bagging, Boosting, Support Vector Machines (SVM), Naive Bayes (NB), Multilayer Perceptron (MLP), J48 Decision Trees.
- Best model: Random Forest and the proposed Ensemble with Feature Selection (Avg. F-measure ~0.7-0.8 depending on the specific dataset).
- Runner-up: Multilayer Perceptron (MLP) and J48 (Performance varied across datasets).
- The combination of feature selection (e.g., Gain Ratio) and ensemble learning consistently outperformed individual classifiers by mitigating the impact of feature redundancy and class imbalance.
- Key limitation acknowledged by authors: The study focused on NASA datasets; further validation on larger industrial datasets is needed to generalize the findings.
""",

    "munir2021_attention_gru_lstm": """
FINDINGS (Munir et al., 2021 - Attention based GRU-LSTM for software defect prediction):
- Dataset used: Code4Bench (119,989 C/C++ programs).
- Models evaluated: Attention-based GRU-LSTM (DP-AGL), CNN, LSTM, GRU, Random Forest, Naive Bayes.
- Best model: DP-AGL (Attention-based GRU-LSTM), Accuracy=97.4%, F1=96.5%, Precision=96.8%, Recall=96.3%.
- Runner-up: Standard LSTM and GRU models (Detailed metrics for runners-up omitted in the specific accuracy comparison but outperformed by DP-AGL).
- The Attention mechanism is utilized to identify important features from the Abstract Syntax Tree (AST) representations of the source code.
- Key limitation acknowledged by authors: The high computational cost associated with building ASTs and training deep learning models on very large source code repositories.
""",

    "akimova2021_deep_learning_survey": """
FINDINGS (Akimova et al., 2021 - A Survey on Software Defect Prediction Using Deep Learning):
- Dataset used: Systematic survey of research papers utilizing NASA, PROMISE, and GitHub repositories.
- Models evaluated: Convolutional Neural Networks (CNN), Recurrent Neural Networks (RNN), Long Short-Term Memory (LSTM), Deep Belief Networks (DBN), Autoencoders.
- Best model: Omitted (Survey format; Deep learning models are identified as superior to traditional ML for automatic feature extraction and handling high-dimensional data).
- Runner-up: Omitted (Survey format).
- Deep learning approaches (especially CNNs and LSTMs) are increasingly preferred due to their ability to capture semantic and structural information from source code that manual metrics (like CK or McCabe) often miss.
- Key limitation acknowledged by authors: The "black box" nature of deep learning models makes interpretability difficult for software engineers in industrial settings.
""",

    "grandvalet_2002_svm_scaling": """
FINDINGS (Grandvalet & Canu, 2002 - Adaptive Scaling for Feature Selection in SVMs):
- Dataset used: Facial expression recognition problem (Japanese Female Facial Expression (JAFFE) database)
- Models evaluated: SVM with adaptive scaling, SVM with Recursive Feature Elimination (RFE)
- Best model: SVM with adaptive scaling, Accuracy=Not reported, F1=Not reported, Precision=Not reported, Recall=Not reported
- Runner-up: SVM with Recursive Feature Elimination (RFE), Accuracy=Not reported, F1=Not reported
- The proposed algorithm performs automatic relevance determination of input variables by scale factors and achieves feature selection by assigning zero weights to irrelevant variables via sparsity constraints.
- Key limitation acknowledged by authors: The selection procedure may be computationally demanding due to the minimization of SVM empirical risk alongside scale factor parameters.
""",

    "mehta_2021_ensemble_defects": """
FINDINGS (Mehta & Patnaik, 2021 - Improved prediction of software defects using ensemble machine learning techniques):
- Dataset used: NASA MDP datasets (CM1: 498 instances, JM1: 10885 instances, KC1: 2109 instances, KC2: 522 instances, PC1: 1109 instances)
- Models evaluated: Logistic Regression, Decision Trees, K-nearest neighbor (KNN), Support Vector Machines (SVM), Naive Bayes, Random Forest, AdaBoost, Bagging, Gradient Boosting
- Best model: Gradient Boosting, Accuracy=91.4%, F1=81%, Precision=Not reported, Recall=Not reported
- Runner-up: Random Forest, Accuracy=91.1%, F1=81%
- Feature selection techniques such as Recursive Feature Elimination (RFE) and Boruta were found to reduce dimensionality and improve performance across imbalanced datasets.
- Key limitation acknowledged by authors: The study focused on NASA datasets; further research across more diverse and business-specific datasets is suggested.
""",

    "wang_2013_imbalance_defects": """
FINDINGS (Wang & Yao, 2013 - Using Class Imbalance Learning for Software Defect Prediction):
- Dataset used: 10 NASA and PROMISE datasets (CM1, JM1, KC1, KC2, PC1, MW1, MC2, PC3, PC4, PC5)
- Models evaluated: Random Under-sampling (RUS), Random Over-sampling (ROS), SMOTE, Threshold Moving, AdaBoost, AdaBoost.NC
- Best model: AdaBoost.NC, Accuracy=Not reported, F1=Not reported, Precision=Not reported, Recall=Not reported
- Runner-up: Not reported
- AdaBoost.NC demonstrates superior performance in metrics such as Balance, G-mean, and AUC by using a penalty term to introduce ensemble diversity during the boosting process.
- Key limitation acknowledged by authors: The penalty parameter in AdaBoost.NC requires careful selection, though a dynamic version was proposed to automate this adjustment.
""",

    "sun2012_coding_ensemble": """
FINDINGS (Sun et al., 2012 - Using Coding-Based Ensemble Learning to Improve Software Defect Prediction):
- Dataset used: 14 NASA datasets (CM1, JM1, KC1, KC2, KC3, MC1, MC2, MW1, PC1, PC2, PC3, PC4, PC5, and MDP)
- Models evaluated: Naive Bayes (NB), C4.5, NBTree, Random Forest (RF)
- Best model: Method with a one-against-one (OAO) coding scheme, Accuracy=Not reported, F1=Not reported, Precision=Not reported, Recall=Not reported
- Runner-up: Method with error-correcting output codes (ECOC) coding scheme, Accuracy=Not reported, F1=Not reported
- The proposed method converts imbalanced binary-class data into balanced multiclass data using coding schemes, which outperforms conventional imbalance-handling methods like sampling and cost-sensitive learning.
- On average, the OAO coding scheme achieved better results in terms of G-mean and Balance across most datasets.
- Key limitation acknowledged by authors: The choice of the base classifier still significantly impacts the final results of the coding-based ensemble method.
""",

# ─── CROSS-PAPER SYNTHESIS SECTIONS ──────────────────────────────
    # Merged from both Gemini chat instances. All bullet points are
    # directly supported by papers in the knowledge base.
    # Duplicates removed, unique insights from both chats combined.
 
    "research_context": """
RESEARCH CONTEXT (Cross-paper analysis):
- SVM, Naive Bayes, and Random Forest have historically dominated the field and remain the most frequently used ML models for defect classification (Palanivinayagam et al., 2023; Saharudin et al., 2020; Meiliana et al., 2017).
- The field has seen a clear progression from traditional ML models like Naive Bayes and Decision Trees toward deep learning architectures like LSTM and CNN, increasingly preferred for capturing semantic information directly from source code (Akimova et al., 2021; Albattah & Alzahrani, 2024).
- The PROMISE and NASA MDP repositories are overwhelmingly the most frequently utilized datasets for benchmarking defect prediction models, each appearing in 43.3% of reviewed studies (Saharudin et al., 2020; Challagulla et al., 2008).
- Class imbalance is universally identified as the primary challenge in defect prediction, with non-buggy classes vastly outnumbering buggy classes in almost all real-world datasets (Albattah & Alzahrani, 2024; Wang & Yao, 2013; Mehta et al., 2025).
- Feature redundancy and irrelevance consistently hinder model accuracy, making feature selection a mandatory preprocessing step to improve ensemble classifier reliability (Rath et al., 2024; Laradji et al., 2014; Challagulla et al., 2008).
- In the specific domain of mobile applications, Android is the overwhelmingly dominant platform for defect prediction research, accounting for 48% of all reviewed studies (Jorayeva et al., 2022).
- The black box nature of deep learning models limits their interpretability in industrial settings, which contrasts with traditional models that can more easily leverage tools like SHAP to increase developer trust (Akimova et al., 2021; Laiq et al., 2024).
- Alternative approaches to class imbalance, such as converting binary-class data into balanced multiclass data using one-against-one coding schemes, have demonstrated superior G-mean and Balance performance compared to standard sampling methods (Sun et al., 2012).
- Cross-Project Defect Prediction (CPDP) using transfer learning is gaining traction to solve the lack of historical data in new projects, but struggles with negative transfer and feature heterogeneity across domains (Saeed & Saleem, 2023).
- Concept drift and feature drift over time cause the accuracy of operational ML models to degrade, representing a major hurdle for long-term production deployment (Laiq et al., 2024; Palanivinayagam et al., 2023).
- The identification of true defects in open-source datasets is often limited by the fact that defects are only recognized if explicitly fixed through a recorded version control commit (Hickman & Holmqvist, 2021).
""",
 
    "practical_insights": """
PRACTICAL INSIGHTS (Synthesised from all papers):
- Start with Random Forest or SVM as strong, general-purpose baselines — they consistently emerge as top performers or runners-up across the majority of empirical studies (Khleel & Nehéz, 2021; Jorayeva et al., 2022).
- Address class imbalance by employing hybrid approaches that blend ensemble learning with data sampling strategies like SMOTE, MAHAKIL, or targeted oversampling and undersampling (Mehta et al., 2025; Hickman & Holmqvist, 2021).
- Always apply feature selection before training to reduce dimensionality and remove redundant metrics — CFS, RFE, and Boruta are highly recommended techniques (Challagulla et al., 2008; Mehta & Patnaik, 2021; Kethireddy et al., 2022; Laradji et al., 2014).
- Use deep learning models like LSTM or CNN when semantic and structural code analysis is required, but use simpler interpretable models paired with SHAP when stakeholder trust is the priority (Akimova et al., 2021; Laiq et al., 2024).
- For maximum accuracy on small clean datasets, combine base classifiers with meta-heuristic optimizers like Particle Swarm Optimization (PSO) — SVM+PSO achieved 99.80% accuracy in one study (Khalid et al., 2023).
- Optimize ensemble diversity during boosting by using modified algorithms like AdaBoost.NC, which introduces a penalty term to improve performance on imbalanced data (Wang & Yao, 2013).
- Use PROMISE and NASA MDP repositories as standard benchmark datasets when developing or validating new defect prediction models (Saharudin et al., 2020).
- Monitor deployed models continuously for concept drift, as prediction accuracy will degrade over time as software and its operational environment evolve (Laiq et al., 2024).
- When a target project lacks sufficient historical defect data, implement Cross-Project Defect Prediction (CPDP) using transfer learning to adapt knowledge from existing projects (Saeed & Saleem, 2023).
- Deep learning models carry high computational cost and black-box complexity — only worth the trade-off when large labelled datasets are available and interpretability is not required (Akimova et al., 2021; Munir et al., 2021).
- Apply K-means clustering to categorize class labels prior to classification, or use PSO to enhance base model accuracy on structured tabular defect datasets (Khalid et al., 2023).
""",
}


SECTION_KEYWORDS = {

    "albattah2024_defect_prediction": [
        "Albattah",
        "Alzahrani",
        "2024",
        "software defect prediction",
        "Unified Bug Dataset",
        "SVM", "Logistic Regression", "Random Forest", "XGBoost", "ANN", "Autoencoder", "DBN", "LSTM",
        "Deep learning",
        "OpenStaticAnalyzer",
        "binary classification",
        "imbalanced data"
    ],

    "laiq2024_invalid_bug_reports": [
        "Laiq",
        "Ali",
        "Börstler",
        "Engström",
        "2024",
        "invalid bug reports",
        "telecommunication company",
        "SVM", "Random forest", "CNN", "XGBoost", "BERT",
        "concept drift",
        "technology transfer model",
        "explainability",
        "SHAP"
    ],

    "saharudin2020_systematic_review": [
        "Saharudin",
        "Wei",
        "Na",
        "2020",
        "systematic review",
        "SLR",
        "PROMISE", "NASA MDP",
        "Bayesian Network", "Neural Network", "SVM", "Clustering", "Feature Selection", "Ensemble Learning",
        "CK Metrics Suite",
        "Halstead metrics",
        "McCabe metrics"
    ],

    "jorayeva2022_mobile_defect_prediction": [
        "Jorayeva",
        "Akbulut",
        "Catal",
        "Mishra",
        "2022",
        "mobile applications",
        "systematic literature review",
        "Android",
        "Naïve Bayes", "SVM", "Logistic Regression", "Neural Network", "Decision Tree", "Random Forest", "LSTM",
        "object-oriented metrics",
        "supervised learning",
        "mobile",
        "mobile defect",
        "mobile apps",
        "app defect",
        "android apps"
    ],

    "khalid2023_defect_prediction_pso": [
        "Khalid",
        "Badshah",
        "Ayub",
        "Shiraz",
        "Ghouse",
        "2023",
        "defect prediction",
        "CM1",
        "PROMISE repository",
        "SVM", "Naïve Bayes", "Random Forest", "Ensemble", "Stacking", "PSO",
        "K-means clustering",
        "Particle Swarm Optimization",
        "Feature selection"
    ],

    "hammouri2018_bug_prediction_ml": [
        "Hammouri",
        "Hammad",
        "Alnabhan",
        "Alsarayrah",
        "2018",
        "software bug prediction",
        "historical data",
        "DS1", "DS2", "DS3",
        "Naïve Bayes", "Decision Tree", "ANNs",
        "Auto-Regression", "AR model",
        "POWM model",
        "RMSE"
    ],

    "khleel2021_comprehensive_study": [
        "Khleel",
        "Nehéz",
        "2021",
        "Comprehensive Study",
        "NASA Promise Repository",
        "JM1", "PC1", "KC1", "KC2",
        "Decision Tree", "Naïve Bayes", "Random Forest", "Logistic Regression",
        "static code analysis",
        "software metrics"
    ],

    "hickman2021_predict_future": [
        "Hickman",
        "Holmqvist",
        "2021",
        "Predict future software defects",
        "VSCode",
        "GitHub",
        "Random forest", "logistic regression", "naive Bayes",
        "CodeScene",
        "project management",
        "resampling",
        "organisational factors"
    ],

    "challagulla2008_empirical_assessment": [
        "Challagulla",
        "Bastani",
        "Yen",
        "Paul",
        "2008",
        "Empirical Assessment",
        "NASA MDP",
        "CM1", "JM1", "KC1", "PC1",
        "Instance Based Learning", "IBL", "1-Rule", "1R", "Neural Networks", "Support Vector Logistic Regression",
        "Feature subset selection", "FSS", "PCA",
        "ISDAT", "WEKA"
    ],

    "subbiah2018_software_engineering": [
        "Subbiah",
        "Ramachandran",
        "Mahmood",
        "2018",
        "MLaaS",
        "Bug Prediction as a Service",
        "BPaaS",
        "Microsoft Azure",
        "Eclipse",
        "Averaged Perceptron", "Decision jungle", "Boosted decision tree", "Bayes point machine",
        "CK metrics",
        "cost of change curve"
    ],

    "kethireddy2022_software_defects": [
        "Kethireddy",
        "Aravind",
        "Kamal",
        "2022",
        "Software Defects Prediction",
        "Artificial Neural Networks", "Random Forest", "Random Tree", "Decision Table", "Linear Regression", "Gaussian Processes", "SMOreg", "M5P",
        "ISTQB",
        "cross-validation",
        "CFS",
        "RMSE", "MAE"
    ],

    "ali2023_xgboost_review": [
        "Ali",
        "Abduljabbar",
        "Taher",
        "Sallow",
        "Almufti",
        "2023",
        "XGBoost",
        "Review",
        "Gradient Boosting",
        "Python",
        "parallel tree boosting",
        "regularization",
        "sparsity-aware",
        "SVM", "Logistic Regression", "Random Forest", "ANNs"
    ],

    "zheng2021_imbalanced_ensemble": [
        "Zheng",
        "Wang",
        "Wei",
        "Chen",
        "Shao",
        "2021",
        "imbalanced ensemble",
        "software defect prediction",
        "NASA MDP",
        "CM1", "JM1", "KC1", "KC3", "MC1", "MC2", "MW1", "PC1", "PC3", "PC4", "PC5",
        "IAdaBoost", "SWIMBoost", "AdaBoost", "RUSBoost", "SMOTEBoost",
        "G-mean", "AUC", "cost-sensitive learning", "oversampling"
    ],

    "palanivinayagam2023_text_classification": [
        "Palanivinayagam",
        "El-Bayeh",
        "Damaševičius",
        "2023",
        "text classification",
        "systematic review",
        "PRISMA",
        "SVM", "NB", "RF", "KNN", "ANN", "CNN", "RNN",
        "bug reports", "spam detection", "sentiment analysis",
        "feature drift", "NLP"
    ],

    "ali2023_feature_selection": [
        "Ali",
        "Mazhar",
        "Shahzad",
        "Ghadi",
        "Mohsin",
        "Akber",
        "2023",
        "feature selection",
        "software fault prediction",
        "systematic literature review",
        "filtering",
        "hybrid feature selection",
        "WEKA", "MATLAB", "Python",
        "AUC", "F-measure",
        "LSSVM", "DNN"
    ],

    "saeed2023_cross_project": [
        "Saeed",
        "Saleem",
        "2023",
        "Cross Project Software Defect Prediction",
        "CPDP",
        "WPDP",
        "transfer learning",
        "deep learning",
        "PROMISE", "NASA", "AEEEM", "ReLink",
        "TCA", "JDA", "KMM",
        "feature extraction"
    ],

    "meiliana2017_literature_review": [
        "Meiliana",
        "Karim",
        "Warnars",
        "Gaol",
        "Abdurachman",
        "2017",
        "Software Metrics",
        "fault prediction",
        "PROMISE repository",
        "McCabe", "Halstead", "CK metrics",
        "ANN", "Naive Bayes", "Decision Tree"
    ],

    "mehta2025_class_imbalance": [
        "Mehta",
        "Kaur",
        "2025",
        "Class Imbalance",
        "software fault prediction",
        "ensemble strategies",
        "SMOTE", "MAHAKIL",
        "Cost-Sensitive Learning",
        "Bagging", "Boosting", "Stacking",
        "PROMISE", "NASA", "CPDP"
    ],

    "rath2024_reliability_ensemble": [
        "Rath",
        "Sahu",
        "2024",
        "Software Reliability",
        "Ensemble Learning",
        "imbalanced datasets",
        "balanced datasets",
        "feature selection",
        "ELM",
        "Extreme Learning Machine",
        "Stacking",
        "Bagging"
    ],

    "laradji2014_ensemble_features": [
        "Laradji",
        "Alshayeb",
        "2014",
        "ensemble learning",
        "feature selection",
        "NASA MDP",
        "CM1", "JM1", "KC1", "KC3", "MC2", "MW1", "PC1",
        "Random Forest",
        "F-measure",
        "redundancy"
    ],

    "munir2021_attention_gru_lstm": [
        "Munir",
        "Ren",
        "2021",
        "Attention mechanism",
        "GRU",
        "LSTM",
        "DP-AGL",
        "Code4Bench",
        "AST",
        "Abstract Syntax Tree",
        "statement-level",
        "C++ programs"
    ],

    "akimova2021_deep_learning_survey": [
        "Akimova",
        "Bersenev",
        "2021",
        "Deep Learning",
        "Survey",
        "CNN", "RNN",
        "Autoencoders",
        "DBN",
        "feature extraction",
        "semantic information",
        "high-dimensional data"
    ],

    "grandvalet_2002_svm_scaling": [
        "Grandvalet",
        "Canu",
        "2002",
        "SVM",
        "feature selection",
        "adaptive scaling",
        "sparsity",
        "JAFFE",
        "facial expression recognition",
    ],

    "mehta_2021_ensemble_defects": [
        "Mehta",
        "Patnaik",
        "2021",
        "software defect prediction",
        "ensemble machine learning",
        "NASA MDP",
        "Gradient Boosting",
        "Random Forest",
        "feature selection",
        "Boruta",
        "RFE",
    ],

    "wang_2013_imbalance_defects": [
        "Wang",
        "Yao",
        "2013",
        "class imbalance",
        "software defect prediction",
        "AdaBoost.NC",
        "resampling",
        "SMOTE",
        "NASA",
        "PROMISE",
        "G-mean",
        "AUC",
    ],

    "sun2012_coding_ensemble": [
        "Sun", "Song", "Zhu", "2012", "coding-based ensemble learning",
        "NASA datasets", "CM1", "JM1", "KC1", "KC2", "KC3",
        "MC1", "MC2", "MW1", "PC1", "PC2", "PC3", "PC4", "PC5", "MDP",
        "Naive Bayes", "C4.5", "NBTree", "Random Forest",
        "one-against-one", "OAO", "one-against-all", "OAA", "ECOC",
        "multiclass data", "G-mean", "Balance"
    ], 

        "research_context": [
        "trend", "trends", "history", "evolution", "over time",
        "when did", "how has", "timeline", "recent", "modern",
        "traditional", "deep learning adoption", "explainability",
        "how has the field", "changed over", "past years"
    ],
 
    "practical_insights": [
        "recommend", "should i use", "best practice", "advice",
        "production", "real world", "industry", "which model should",
        "imbalanced", "feature selection", "baseline", "start with",
        "concept drift", "deploy", "practical", "where do i start",
        "getting started", "what should i do"
    ],   

}