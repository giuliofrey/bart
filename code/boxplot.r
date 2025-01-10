# Package names
packages <- c(
    "ggplot2", 
    "dplyr",
    "tree",
    "xtable",
    "tidyr",
    "BART",
    "gbm", # For Generalized Boosted Regression Models
    "randomForest", # For Random Forest,
    "ucimlrepo" # For the Abalone age prediction dataset,
)
# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE, warn.conflicts = FALSE))

# Settting the seed
set.seed(123)

#load the crab dataset
abalone <- fetch_ucirepo(name = "Abalone")

abalone_df <- abalone$data$original


#convert the categorical variables to factors
abalone_df$Sex <- as.factor(abalone_df$Sex)

#convert rings to age
abalone_df$Age <- abalone_df$Rings + 1.5
#remove the rings column
abalone_df <- abalone_df[, setdiff(names(abalone_df), "Rings")]


train <- sample(1:nrow(abalone_df), nrow(abalone_df) / 2)
x <- abalone_df[,  setdiff(names(abalone_df), "Age")]
y <- abalone_df[, "Age"]
xtrain <- x[train, ]
ytrain <- y[train]
xtest <- x[-train, ]
ytest <- y[-train]


bart <- gbart(xtrain, ytrain, x.test = xtest, ntree = 500, mc.cores = 4)
bart.mse <- mean((bart$yhat.test.mean - ytest)^2)

ii <- order(bart$yhat.train.mean)

# Select a subset of the training data to make the plot less crowded
subset_indices <- seq(1, length(ii), length.out = 100)
pdf("outputs/bart_boxplot.pdf")
boxplot(bart$yhat.train[, ii[subset_indices]], ylim = range(ytrain), xlab = "Ordered Indices", ylab = "Predicted Values", main = "BART Model Training Predictions")
dev.off()