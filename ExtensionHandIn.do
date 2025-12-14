*Extension Triple Differences

*Change only this line
global proj "D:\Policy Project\My attempt\Hand in"

*Set working directory
cd "$proj"

*Create results folder if it doesn't exist
cap mkdir "$proj/results"
global results "$proj/results"

*Bringing data in
use "CPS cleaned2.dta", clear
set matsize 500

*Sample editing
keep if ageyrs>=22 & yob>=1935 & yob<=1958 
*Drop 15 observations 1995 with weights of unknown function
drop if weight==0
*Editing the 112 observations with inconsistent coding of marital status 
generate evermarried=1-nevermarried
drop if evermarried==0 & femstat==1 & insupp==1
drop if evermarried==1 & femstat>=2 & femstat<=3 & insupp==1
assert age_1mar==. if nevermarried==1, rc0 
assert age_1mar!=. if nevermarried==0 & insupp==1, rc0

*Fixed effects and trends
global stateyear "i.state i.yob"
global trend1 "state1trend-state51trend"

*Additional control variables
global control0 "black other hispanic"
global control18 "black other hispanic eabortion_reformlegal18 eabortion_reformconsent18 eepl18 erd18 enofault18"
global control19 "black other hispanic eabortion_reformlegal19 eabortion_reformconsent19 eepl19 erd19 enofault19"


*****************************************************************************

* Create quartiles of family income
xtile finc_q = famincfs, nq(4)

* High income = top quartile
gen highinc = (finc_q == 4)
label variable highinc "High family income (top quartile)"

*Model 1
quietly: regress firstbirth18 ///
    c.epilllegal18##i.highinc ///
    epillconsent18 ///
    $control0 $stateyear $trend1 ///
    [pweight=weight], cluster(state)
eststo model1_high

* Marginal effect of pill policy for high-income group
margins, dydx(epilllegal18) at(highinc = 1)
matrix rb = r(b)
scalar marginpill_high = rb[1,1]
estadd scalar Adjusted_prediction = marginpill_high

*Model 2
quietly: regress firstbirth18 ///
    c.epilllegal18##i.highinc ///
    c.eabortionlegal18##i.highinc ///
    c.epilllegal18##c.eabortionlegal18##i.highinc ///
    epillconsent18 eabortionconsent18 ///
    $control0 $stateyear $trend1 ///
    [pweight=weight], cluster(state)
eststo model2_high

margins, dydx(epilllegal18) at(highinc = 1 eabortionlegal18 = 0)
matrix rb = r(b)
scalar marginabort_high = rb[1,1]
estadd scalar Adjusted_prediction = marginabort_high

*Model 3
quietly: regress firstbirth18 ///
    c.epilllegal18##i.highinc ///
    c.eabortionlegal18##i.highinc ///
    c.epilllegal18##c.eabortionlegal18##i.highinc ///
    epillconsent18 eabortionconsent18 ///
    $control18 $stateyear $trend1 ///
    [pweight=weight], cluster(state)
eststo model3_high

margins, dydx(epilllegal18) at(highinc = 1 eabortionlegal18 = 0)
matrix rb = r(b)
scalar margincontrols_high = rb[1,1]
estadd scalar Adjusted_prediction = margincontrols_high

*Model 4
quietly: regress firstbirth18 ///
    c.epilllegal18##i.highinc ///
    c.eabortionlegal18##i.highinc ///
    c.epilllegal18##c.eabortionlegal18##i.highinc ///
    c.pxal18##i.highinc c.pxac18##i.highinc ///
    epillconsent18 eabortionconsent18 ///
    $control18 $stateyear $trend1 ///
    [pweight=weight], cluster(state)
eststo model4_high

margins, dydx(epilllegal18) ///
    at(highinc = 1 eabortionlegal18 = 0 pxal18 = 0 pxac18 = 0)
matrix rb = r(b)
scalar marginint_high = rb[1,1]
estadd scalar Adjusted_prediction = marginint_high


*Writing estimates to a table
esttab model1_high model2_high model3_high model4_high, ///
    scalars(Adjusted_prediction "Adjusted prediction") ///
    b(4) se(4) nodepvars noobs alignment(r) ///
    keep(epilllegal18 epillconsent18 eabortionlegal18 eabortionconsent18 ///
	1.highinc 1.highinc#c.epilllegal18 ///
         1.highinc#c.eabortionlegal18 ///
         c.epilllegal18#c.eabortionlegal18 ///
         1.highinc#c.epilllegal18#c.eabortionlegal18) ///
    order(epilllegal18 1.highinc 1.highinc#c.epilllegal18 ///
          eabortionlegal18 1.highinc#c.eabortionlegal18 ///
          c.epilllegal18#c.eabortionlegal18 ///
          1.highinc#c.epilllegal18#c.eabortionlegal18) ///
    coeflabels(epilllegal18 "Pill legal" epillconsent18 "Consent pill" ///
          eabortionlegal18 "Abortion legal" eabortionconsent18 "Consent abortion" ///
          1.highinc "High income" 1.highinc#c.epilllegal18 "High income × Pill legal" ///
          1.highinc#c.eabortionlegal18 "High income × Abortion legal" ///
          c.epilllegal18#c.eabortionlegal18 "Pill legal × Abortion legal" ///
          1.highinc#c.epilllegal18#c.eabortionlegal18 "High inc × Pill × Abortion") ///
    mtitles("Model 1" "Model 2" "Model 3" "Model 4") ///
    title("Probability of First Birth Before age 19: High-Income Heterogeneity") ///
    nonotes
 
*Writing estimates to tex file
esttab model1_high model2_high model3_high model4_high using "$results/extension.tex", ///
    scalars(Adjusted_prediction "Adjusted prediction") ///
    b(4) se(4) nodepvars noobs booktabs ///
	alignment(D{.}{.}{-1}) replace ///
    keep(epilllegal18 epillconsent18 eabortionlegal18 eabortionconsent18 ///
	1.highinc 1.highinc#c.epilllegal18 ///
         1.highinc#c.eabortionlegal18 ///
         c.epilllegal18#c.eabortionlegal18 ///
         1.highinc#c.epilllegal18#c.eabortionlegal18) ///
    order(epilllegal18 1.highinc 1.highinc#c.epilllegal18 ///
          eabortionlegal18 1.highinc#c.eabortionlegal18 ///
          c.epilllegal18#c.eabortionlegal18 ///
          1.highinc#c.epilllegal18#c.eabortionlegal18) ///
    coeflabels(epilllegal18 "Pill legal" epillconsent18 "Consent pill" ///
          eabortionlegal18 "Abortion legal" eabortionconsent18 "Consent abortion" ///
          1.highinc "High income" 1.highinc#c.epilllegal18 "High income × Pill legal" ///
          1.highinc#c.eabortionlegal18 "High income × Abortion legal" ///
          c.epilllegal18#c.eabortionlegal18 "Pill legal × Abortion legal" ///
          1.highinc#c.epilllegal18#c.eabortionlegal18 "High inc × Pill × Abortion") ///
    mtitles("Model 1" "Model 2" "Model 3" "Model 4") ///
    title("Probability of First Birth Before age 19: High-Income Heterogeneity") ///
    addnotes("Standard errors clustered at state level in parentheses." ///
             "All models include state FE, year FE, and state-specific trends." ///
             "Models weighted by probability weights." ///
             "* p<0.10, ** p<0.05, *** p<0.01")