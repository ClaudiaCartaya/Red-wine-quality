# Red-wine-quality
### Comparison of the logistic regression, decision tree, and random forest models to predict red wine quality in R

In the following project, I applied three different machine learning algorithms to predict the quality of a wine. The dataset I used for the project is called Wine Quality Data Set (specifically the “winequality-red.csv” file), taken from the UCI Machine Learning Repository.

The dataset contains 1,599 observations and 12 attributes related to the red variants of the Portuguese “Vinho Verde” wine. Each row describes the physicochemical properties of one bottle of wine. The first 11 independent variables display numeric information about these characteristics, and the last dependent variable revels the quality of the wine on a scale from 0 (bad quality wine) to 10 (good quality wine) based on sensory data.
Since the outcome variable is ordinal, I chose logistic regression, decision trees, and random forest classification algorithms to answer the following questions:
1. Which machine learning algorithm will enable the most accurate prediction of wine quality from its physicochemical properties?
2. What physicochemical properties of red wine have the highest impact on its quality?
