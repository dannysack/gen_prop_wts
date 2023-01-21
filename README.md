# gen_prop_wts
This repository contains the code to generate and analyze the data presented in "Inverse Probability Weights for Quasi-Continuous Ordinal Exposures with a Binary Outcome: Method Comparison and Case Study", currently in press with the American Journal of Epidemiology.

File Directory:

`sup1.R` - reproducible example code from supplement 1 demonstrating how to use all types of weighting approaches described in the manuscript.

`orm.wt.R` - code to generate OLR weights as described in the manuscript. This works with datasets with no missing data and imputed datasets via the `mice` package, but can be edited as needed to work with other data classes.

`ogps_sim_pdf.Rmd` - code to generate supplement 2, the simulation component of the manuscript

`sims.rda` - the data generated from the simulation in supplement 2 - please note this file is too large to push to github at this time, so is available at: https://filen.io/f/29e83834-a3eb-405b-a241-7a0e02677d1a#!9BnaFbaiPUT4tg21qoStj05P0rYx6jdb. Please feel free to reach out if the link does not work!

`msm_truths.rda` - the data generated from calculating the "truth" from the simulation data in supplement 2

`covbal.rda` - the data generated from calculating the covariate balance across weighting strategies from the simulation data in supplement 2

`bias.rda` - the data generated from calculating the bias across weighting strategies from the simulation data in supplement 2

`ogps_ap_pdf.Rmd` - the code to generate supplement 3, the case study component of the manuscript


Please note that the case study data includes data from the following clinical trial (https://clinicaltrials.gov/ct2/show/NCT03149237?term=Audet&cntry=MZ&draw=2&rank=3). As such, data sharing will be subject to the study protocol. Please reach out if you'd like access to these data so we can get the process started!
