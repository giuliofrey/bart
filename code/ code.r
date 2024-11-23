# Package names
packages <- c(
    "ggplot2", 
    "dplyr",
    "BayesTree", # For Bayesian Additive Regression Trees
    "gbm", # For Generalized Boosted Regression Models
    "randomForest" # For Random Forest
)
# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))