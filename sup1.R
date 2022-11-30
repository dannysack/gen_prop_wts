# This code runs the example in Supplement 1: Formulas and Example Code — Inverse Probability Weights for Quasi-Continuous Ordinal Exposures with a Binary Outcome: Method Comparison and Case Study
# Authors: Sack, Daniel E, Shepherd, Bryan E, Audet, Carolyn M, De Schacht, Caroline, Samuels, Lauren R

# For each sIPW method, we have provided some example R code with citations for the appropriate package. In each example scenario, Y is the binary outcome, X is the exposure, C1, C2, C3 and are the confounders, and data is the dataframe containing the data. We show example code in WeightIt (version 0.12.0)1 for OLS, CBGPS, and npCGBPS and our own code (available at https://github.com/dannysack/gen_prop_wts/blob/main/orm.wt.R) for QB and CPM. We show both how to generate the weights and then use them with survey (version 4.1-1) to generate an effect estimate for X.

# load required libraries
library(Hmisc)
library(rms)
library(WeightIt)
library(survey)
source("/Users/sackd/Library/CloudStorage/Box-Box/Vanderbilt University/PhD/Publications/Continuous Propensity Scores/Code/orm.wt.R")

# We generate the data from the simulation data for one outcome

# Data generation for one exposure (X1 in the manuscript)
set.seed(1111)
n <- 1500
# draw maternal age from normal distribution
mage <- rnorm(n, 29.84, sqrt(21.60))

# draw paternal age from normal distribution
page <- rnorm(n, 32.52, sqrt(30.45))

# establish parity with same parameters as Naimi et al.
parityA <- runif(n)
parity <- ifelse(parityA <= 0.24, 2,
                 ifelse(parityA <= 0.24 + 0.07, 3,
                        ifelse(parityA <= 0.24 + 0.07 + 0.02, 4,
                               ifelse(parityA <= 0.24 + 0.07 + 0.02 + 0.02, 5, 1))))
parity2 <- ifelse(parity == 2, 1, 0)
parity3 <- ifelse(parity == 3, 1, 0)
parity4 <- ifelse(parity == 4, 1, 0)
parity5 <- ifelse(parity == 5, 1, 0)

# mu w/o strong correlation with maternal age
mu_un <- (0.025 * mage) + (0.0025 * page) + (0.00125 * mage * page) - 
  (0.21 * parity2) - (0.22 * parity3) - (0.45 * parity4) - (0.45 * parity5)

# normal exposure distribution, but round so it's ordinal to nearest 0.1
x1 <- round(15 + mu_un + rnorm(n, 0, sqrt(2)), 1)

# outcome normal exposure distribution, uncorrelated with maternal age
y1 <- rbinom(n, 1, (1  + exp(-(-11.5 + log(1.25) * x1 + log(1.7) * sqrt(mage) + log(1.5) * sqrt(page) +
                                 log(0.75) * parity2 + log(0.8) * parity3 + log(0.85) * parity4 + log(0.9) *parity5)))^(-1))

# create df with all covariates as output
data <- data.frame(mage, page, parity2, parity3, parity4, parity5, x1, y1)

## Ordinary Least Squares R Code (Robins JM, Hernán MÁ, Brumback B. Marginal Structural Models and Causal Inference in Epidemiology. Epidemiology. 2000;11(5):550-560.):

# add column of weights to dataframe
data$ols_wts <- weightit(x1 ~ mage + page + parity2 + parity3 + parity4 + parity5, data, method = "ps")$weights

## Covariate Balancing Generalized Propensity Scores R Code (Fong C, Hazlett C, Imai K. Covariate balancing propensity score for a continuous treatment: Application to the efficacy of political advertisements. Ann Appl Stat. 2018;12(1):156-177. doi:10.1214/17-AOAS1101):

# add column of weights to dataframe
data$cbgps_wts <- weightit(x1 ~ mage + page + parity2 + parity3 + parity4 + parity5, method = "cbps", over = FALSE)$weights

# Non-Parametric Covariate Balancing Generalized Propensity Scores R Code (Fong C, Hazlett C, Imai K. Covariate balancing propensity score for a continuous treatment: Application to the efficacy of political advertisements. Ann Appl Stat. 2018;12(1):156-177. doi:10.1214/17-AOAS1101):

# add column of weights to dataframe
data$npcbgps_wts <- weightit(x1 ~ mage + page + parity2 + parity3 + parity4 + parity5, data, method = "npcbps", over = FALSE)$weights

# Quantile Binning R Code (	Naimi AI, Moodie EEM, Auger N, Kaufman JS. Constructing inverse probability weights for continuous exposures: a comparison of methods. Epidemiology. 2014;25(2):292-299. doi:10.1097/EDE.0000000000000053): 

# make exposure into deciles
data$x10 <- as.numeric(Hmisc::cut2(x1, g = 10))

# create a model with the new exposure
mod_qb <- orm(x10 ~ mage + page + parity2 + parity3 + parity4 + parity5, data = data)

# get the predicted probabilities at each exposure level
pred_prob_qb <- predict(mod_qb, type = "fitted.ind")

# calculate the numerator
num_qb <- rep(NA, length(data$x10))
for(i in 1:length(data$x10)){
  num_qb[i] <- sum(data$x10 == data$x10[i]) / sum(!is.na(data$x10))
}

# calculate the denominator
denom_qb <- rep(NA, nrow(data))
for(i in 1:nrow(pred_prob_qb)){
  denom_qb[i] <- as.numeric(pred_prob_qb[i, paste0("x10", "=", data$x10[i])])
}

# calculate weights
data$qb10_wts <- num_qb / denom_qb

# add column of weights to dataframe using our code available at https://github.com/dannysack/gen_prop_wts/blob/main/orm.wt.R
data$qb10_wts1 <- orm.wt(object = data, exposure = "x10", cov_form = "~ mage + page + parity2 + parity3 + parity4 + parity5") %>% unlist()

# compare weights
sum(data$qb10_wts == data$qb10_wts1)

## Cumulative Probability Model R Code:
  
# create a model with the exposure
mod_cpm <- orm(x1 ~ mage + page + parity2 + parity3 + parity4 + parity5, data = data)

# get the predicted probabilities at each exposure level
pred_prob_cpm <- predict(mod_cpm, type = "fitted.ind")

# calculate the numerator
num_cpm <- rep(NA, length(data$x1))
for(i in 1:length(data$x1)){
  num_cpm[i] <- sum(data$x1 == data$x1[i]) / sum(!is.na(data$x1))
}

# calculate the denominator
denom_cpm <- rep(NA, nrow(data))
for(i in 1:nrow(pred_prob_cpm)){
  denom_cpm[i] <- as.numeric(pred_prob_cpm[i, paste0("x1", "=", data$x1[i])])
}

# calculate weights
data$cpm_wts <- num_cpm / denom_cpm

# add column of weights to dataframe using our code available at https://github.com/dannysack/gen_prop_wts/blob/main/orm.wt.R
data$cpm_wts1 <- orm.wt(object = data, exposure = "x1", cov_form = '~ mage + page + parity2 + parity3 + parity4 + parity5') %>% unlist()

# compare weights
sum(data$cpm_wts == data$cpm_wts1)

## Create survey design and run model with desired weights:
  
# generate survey design with cpm as an example
design <- svydesign(~1, weights = data$cpm_wts, data = data)

# run model with cpm weights
model <- svyglm(y1 ~ x1, design = design, family = binomial)
summary(model)
