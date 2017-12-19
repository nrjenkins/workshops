--------------------------------------------------------------------------------
/* 
We will be learning how to estimate an IV regression with TSLS, useful 
postestimation commands, as well as how to use outreg2 as an easy way to make
our result semi-presentable.

These questions are from Stock, James H., and Mark W. Watson. Introduction to 
Econometrics. 3rd ed. Boston: Addison-Wesley, 2011.

For help on IV Regression in STATA, go to the help menu and search, "ivregress."
--------------------------------------------------------------------------------

Use the data in Wage2 for this exercise.

(a) We want to estimate the return to education for men using the following 
equation:

ln(wage) = β0 + β1educ + ui  
 
Consider the problem of unobserved ability. Since our model omits ability, its 
effects will show up in the error term. Of course, if we estimate our model 
with OLS we will obtain a biased and inconsistent estimator of β1 if educ and 
ability are correlated. What we need is an instrument for educ. Use sibs as an 
instrument for educ. 

First, verify that sibs and educ are correlated. 
*/

pwcorr sibs educ, star(.05)

/* 
Second, estimate the model using OLS (Don't forget to specify 
heteroskedasticty-robust standard error calculations by typing ",r") 
*/

reg lwage educ, r

/* 
To export our results in a semi-presentable way, lets use "outreg2". First, 
type the command, "outreg2 using." Then name your file and specify the file 
type, "IVRegression.doc." If it is the first table you are outregging, then
type ", word." Your final code will look like this:   

outreg2 using IVRegression.doc, word

However, lets add other elements to our outreg table, like Root MSE.  
*/

ssc install outreg2

outreg2 using IVRegression.doc, word addstat(SER, e(rmse))

/* 
Third, use sibs as instrument 
for educ and estimate the model above using IV regression. Compare with the 
OLS results. 
*/

ivregress 2sls lwage (educ=sibs),r

/* 
Now we can outreg our second regression and append it to the first. You can
append your new results to your existing results by replacing ", word" with
", append." 
*/

outreg2 using IVRegression.doc, append addstat(SER, e(rmse))

/*
To see if our instrument is relevant, lets look at the first-stage 
F-Statistic
*/

estat firststage

/*
(b) To convince yourself that using sibs as an IV for educ is not the same 
as just plugging in sibs for educ and running an OLS regression, run the 
regression of ln(wage) on sibs and explain your findings.  
*/

reg lwage sibs,r
outreg2 using IVRegression.doc, append addstat(SER, e(rmse))

/*
(c) The variable brthord is birth order (brthord is one for a first-born child, 
two for a second-born child, and so on). Research by Gary-Bobo Prieto and 
Picard (2006) shows that educ and brthord are negatively correlated. 
We can replicate this statistically significant negative correlation using 
"pwcorr." 
*/

pwcorr brthord educ, star(.05)

/*
(d) Use brthord as an IV for educ in the model in part (a). Report and 
interpret the results.
*/

ivregress 2sls lwage (educ=brthord),r 
outreg2 using IVRegression.doc, append addstat(SER, e(rmse))

estat firststage

/*
(e) Now add exper, tenure, and black as control variables to the linear 
regression on wages on education.
*/

reg lwage educ exper tenure black,r
outreg2 using IVRegression.doc, append addstat(Adjusted R-squared, e(r2_a),SER, e(rmse))

/*
Next, use TSLS to estimate the effect of education on wages. 
In this case, use both sibs and brthord as instruments for educ. Compare your 
results.
*/

ivregress 2sls lwage exper tenure black (educ=sibs brthord),r  
outreg2 using IVRegression.doc, append addstat(Adjusted R-squared, e(r2_a),SER, e(rmse))

/*
Ensure your instruments are relevant using the first-stage F-statistic.
*/

estat firststage

/*
Notice that because our model is now overidentified, we can use the 
overidentifying restrictions test to test for instrument exogeneity. Remember,
failing to reject the null hypothesis means that our instruments are probably 
vaild.
*/

estat overid

/*
(f) Manually carry out TSLS for the regression in (e). That is, run the 
first-stage and second-stage regressions individually. Is this what you would 
expect?
*/

/* First-stage */

reg educ exper tenure black sibs brthord,r

/* 
Now, we need to save the predicted value of education. 
*/

predict educ_hat

/*
Finally, regress lwage on educ_hat and all other exogenous variables.
*/

reg lwage educ_hat exper tenure black,r


/*
For comparison, we can re-run the IV regression and compare it to our 
second-stage results.
*/

ivregress 2sls lwage exper tenure black (educ=sibs brthord),r  

/* In practice, it's not a good idea to manually carryout the two-stage process 
because the standard errors will not be calculated correctly(if you look 
closely you'll notice that the standard error are slightly bigger). This means
that you could easily run into issues making statistical inferences. 
Nevertheless, this is a good learning exercise.
*/
