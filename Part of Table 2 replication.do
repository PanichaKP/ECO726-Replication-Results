*Table 2 replication

*Project root (CHANGE ONLY THIS LINE PATH on your lovely laptop)
global proj "D:\Policy Project\My attempt"

*Derived directories
global analysis "$proj/Analysis"
global data     "$proj/Data"
global results  "$analysis/results"

*Changing directory
cd "$analysis"

*Makes sure there's a result folder within the analysis folder
cap mkdir "$results"

*Bringing data in
use "$data/CPS cleaned2", clear
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
*Panel A: Probability of First Birth Before 19

*model 1 (pill policy only)
regress firstbirth18 epilllegal18 epillconsent18 $control0 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model1
margins, at(epilllegal18==0 epillconsent18==0)
  matrix rb=r(b)
  scalar marginpill=rb[1,1]
  estadd scalar Adjusted_prediction = marginpill
	
*model 2 (add abortion policy)
regress firstbirth18 epilllegal18 epillconsent18 eabortionlegal18 eabortionconsent18 $control0 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model2
margins, at(epilllegal18==0 epillconsent18==0 eabortionlegal18==0 eabortionconsent18==0)
  matrix rb=r(b)
  scalar marginabort=rb[1,1]
  estadd scalar Adjusted_prediction = marginabort
  
*model 3 (add even more controls)
regress firstbirth18 epilllegal18 epillconsent18 eabortionlegal18 eabortionconsent18 $control18 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model3
margins, at(epilllegal18==0 epillconsent18==0 eabortionlegal18==0 eabortionconsent18==0)
  matrix rb=r(b)
  scalar margincontrols=rb[1,1]
  estadd scalar Adjusted_prediction = margincontrols
  
*model 4 (add interactions)
regress firstbirth18 epilllegal18 epillconsent18 eabortionlegal18 eabortionconsent18 pxal18 pxac18 $control18 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model4
margins, at(epilllegal18==0 epillconsent18==0 eabortionlegal18==0 eabortionconsent18==0 pxal18==0 pxac18==0)
  matrix rb=r(b)
  scalar marginint=rb[1,1]
  estadd scalar Adjusted_prediction = marginint
  
*Writing estimates to a table
esttab model1 model2 model3 model4, ///
scalars(Adjusted_prediction "Adjusted prediction") ///
nodepvars noobs alignment(r) ///
title("Probability of First Birth Before Age 19") ///
mtitles("Model 1" "Model 2" "Model 3" "Model 4") varwidth(24) ///
b(4) se(4) keep(epilllegal18 epillconsent18 eabortionlegal18 eabortionconsent18) ///
coeflabels (epilllegal18 "Pill legal" epillconsent18 "Consent pill" ///
eabortionlegal18 "Abortion legal" eabortionconsent18 "Consent abortion") ///
nonotes

*Writing the regression table to a tex file
esttab model1 model2 model3 model4 using results/PanelATable2.tex, ///
scalars(Adjusted_prediction "Adjusted prediction") ///
nodepvars noobs booktabs ///
alignment(D{.}{.}{-1}) replace ///
title("Probability of First Birth Before Age 19") ///
mtitles("Model 1" "Model 2" "Model 3" "Model 4") varwidth(24) ///
b(4) se(4) keep(epilllegal18 epillconsent18 eabortionlegal18 eabortionconsent18) ///
coeflabels (epilllegal18 "Pill legal" epillconsent18 "Consent pill" ///
eabortionlegal18 "Abortion legal" eabortionconsent18 "Consent abortion" ///
Adjusted_prediction "Adjusted prediction") ///
nonotes

****************************************************************************  
*Panel B: Probability of First Marriage Before 19

*model 1 (pill policy only)
regress firstmar18 epilllegal19 epillconsent19 $control0 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model1B
margins, at(epilllegal19==0 epillconsent19==0)
  matrix rb=r(b)
  scalar marginpillB=rb[1,1]
  estadd scalar Adjusted_prediction = marginpillB
 
*model 2 (add abortion policy)
regress firstmar18 epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19 $control0 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model2B
margins, at(epilllegal19==0 epillconsent19==0 eabortionlegal19==0 eabortionconsent19==0) 
  matrix rb=r(b)
  scalar marginabortB=rb[1,1]
  estadd scalar Adjusted_prediction = marginabortB
  
*model 3 (add even more controls)
regress firstmar18 epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19 $control19 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model3B
margins, at(epilllegal19==0 epillconsent19==0 eabortionlegal19==0 eabortionconsent19==0)
  matrix rb=r(b)
  scalar margincontrolsB=rb[1,1]
  estadd scalar Adjusted_prediction = margincontrolsB
  
*model 4 (add interactions)
regress firstmar18 epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19 pxal19 pxac19 $control19 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model4B
margins, at(epilllegal19==0 epillconsent19==0 eabortionlegal19==0 eabortionconsent19==0 pxal19==0 pxac19==0)
  matrix rb=r(b)
  scalar marginintB=rb[1,1]
  estadd scalar Adjusted_prediction = marginintB
  
*Writing estimates to a table panel B
esttab model1B model2B model3B model4B, ///
scalars(Adjusted_prediction "Adjusted prediction") ///
no depvars noobs alignment(r) ///
title("Probability of First Marriage Before Age 19") ///
mtitles("Model 1" "Model 2" "Model 3" "Model 4") varwidth(24) ///
b(4) se(4) keep(epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19) ///
coeflabels (epilllegal19 "Pill legal" epillconsent19 "Consent pill" ///
eabortionlegal19 "Abortion legal" eabortionconsent19 "Consent abortion") ///
nonotes
  
*Writing estimates to a tex file
esttab model1B model2B model3B model4B using results/PanelBTable2.tex, ///
scalars(Adjusted_prediction "Adjusted prediction") ///
nodepvars noobs booktabs ///
alignment(D{.}{.}{-1}) replace ///
title("Probability of First Marriage Before Age 19") ///
mtitles("Model 1" "Model 2" "Model 3" "Model 4") varwidth(24) ///
b(4) se(4) keep(epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19) ///
coeflabels (epilllegal19 "Pill legal" epillconsent19 "Consent pill" ///
eabortionlegal19 "Abortion legal" eabortionconsent19 "Consent abortion") ///
nonotes

****************************************************************************
*Panel C: Probability of Shotgun Marriage 

*model 1 (pill policy only)
regress shotgun18 epilllegal19 epillconsent19 $control0 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model1C
margins, at(epilllegal19==0 epillconsent19==0)
  matrix rb=r(b)
  scalar marginpillC=rb[1,1]
  estadd scalar Adjusted_prediction = marginpillC
  
*model 2 (add abortion policy)
regress shotgun18 epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19 $control0 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model2C
margins, at(epilllegal19==0 epillconsent19==0 eabortionlegal19==0 eabortionconsent19==0)
  matrix rb=r(b)
  scalar marginabortC=rb[1,1]
  estadd scalar Adjusted_prediction = marginabortC
  
*model 3 (add even more controls)
regress shotgun18 epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19 $control19 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model3C
margins, at(epilllegal19==0 epillconsent19==0 eabortionlegal19==0 eabortionconsent19==0)
  matrix rb=r(b)
  scalar margincontrolsC=rb[1,1]
  estadd scalar Adjusted_prediction = margincontrolsC
  
*model 4 (add interactions)
regress shotgun18 epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19 pxal19 pxac19 $control19 $stateyear $trend1 [pweight=weight], cluster(state)
  eststo model4C
margins, at(epilllegal19==0 epillconsent19==0 eabortionlegal19==0 eabortionconsent19==0 pxal19==0 pxac19==0)
  matrix rb=r(b)
  scalar marginintC=rb[1,1]
  estadd scalar Adjusted_prediction = marginintC

*Writing estimates to a table panel B
esttab model1C model2C model3C model4C, ///
scalars(Adjusted_prediction "Adjusted prediction") ///
nodepvars noobs alignment(r) ///
title("Probability of Shotgun Marriage Before Age 19") ///
mtitles("Model 1" "Model 2" "Model 3" "Model 4") varwidth(24) ///
b(4) se(4) keep(epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19) ///
coeflabels (epilllegal19 "Pill legal" epillconsent19 "Consent pill" ///
eabortionlegal19 "Abortion legal" eabortionconsent19 "Consent abortion") ///
addnotes("Notes;")

*Writing estimates to a tex file
esttab model1C model2C model3C model4C using results/PanelCTable2.tex, ///
scalars(Adjusted_prediction "Adjusted prediction") ///
nodepvars noobs booktabs ///
alignment(D{.}{.}{-1}) replace ///
title("Probability of Shotgun Marriage Before Age 19") ///
mtitles("Model 1" "Model 2" "Model 3" "Model 4") varwidth(24) ///
b(4) se(4) keep(epilllegal19 epillconsent19 eabortionlegal19 eabortionconsent19) ///
coeflabels (epilllegal19 "Pill legal" epillconsent19 "Consent pill" ///
eabortionlegal19 "Abortion legal" eabortionconsent19 "Consent abortion") ///
addnotes("Notes;")