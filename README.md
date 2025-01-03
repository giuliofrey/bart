# BART Project

![Mean Squared Error for different number of trees](outputs/mse_plot.pdf)

This repository contains the code and the paper for the project "BART". This project was part of the course "Bayesian Statistical Methods" at Bocconi University.

## Authors

- [Vincenzo Dorrello](https://github.com/vincenzodorrello)
- [Giulio Frey](https://github.com/giuliofrey)
- [Guido Rossettini](https://github.com/guidorossettini)
- [Giovanni Scarpato](https://github.com/giovanniscarpato)

## Abstract

This paper provides a comprehensive comparison between Bayesian Additive Regression
Trees (BART) and traditional non-Bayesian tree-based methods for regression problems.
We begin by examining the theoretical foundations of decision trees and various ensemble
methods, including bagging, random forests, and boosting. We then present BART as a
Bayesian nonparametric approach that combines the flexibility of regression trees with the
formal uncertainty quantification of Bayesian inference. The paper details BART’s probabil-
ity model, its regularization prior, and the Bayesian backfitting MCMC algorithm used for
posterior inference. Through both simulated and real-world data applications, we demon-
strate BART’s effectiveness in capturing non-linear relationships and compare its predictive
performance against other ensemble methods. Using the UCI Abalone dataset, we show
that BART achieves superior prediction accuracy compared to random forests, boosting,
and bagging when using sufficient numbers of trees, though at a higher computational cost.
Our findings suggest that BART’s automatic prior-based regularization and ability to quan-
tify uncertainty make it a valuable addition to the tree-based regression toolkit, particularly
for complex non-linear modeling tasks.

## Contents

- `code/`: contains the code and the dataset used in the analysis
- `paper/`: contains the paper in PDF and TeX format
