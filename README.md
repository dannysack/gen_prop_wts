# gen_prop_wts
This repository contains the codes to generate and analyze the data presented in "Inverse Probability Weights for Quasi-Continuous Ordinal Exposures with a Binary Outcome: Method Comparison and Case Study", currently in preperation.

File Directory:

`orm.wt.R` - code to generate OLR weights as described in the manuscript. This works with datasets with no missing data and imputed datasets via the `mice` package, but can be edited as needed to work with other data classes.

`TBD` - code to generate supplement 1, the simulation component of the manuscript

`sims.rda` - the data generated from the simulation in supplement 1 - please note this file is too large to push to github at this time, so is available at: https://vanderbilt.box.com/s/rnowe00icp1bxpkstm4pmhat8w4imwj1. Please feel free to reach out if the link does not work!

`msm_truths.rda` - the data generated from calculating the "truth" from the simulation data in supplement 1

`covbal.rda` - the data generated from calculating the covariate balance across weighting strategies from the simulation data in supplement 1

`bias.rda` - the data generated from calculating the bias across weighting strategies from the simulation data in supplement 1

`TBD` - the code to generate supplement 2, the case study component of the manuscript


Please note that the case study data includes data from the following clinical trial (https://clinicaltrials.gov/ct2/show/NCT03149237?term=Audet&cntry=MZ&draw=2&rank=3). As such, data sharing will be subject to the study protocol. Please reach out if you'd like access to these data so we can get the process started!