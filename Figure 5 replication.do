*Figure 5 replication

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

*****************************************************************
*Figure 5: Birth and mar probs by state policy*
*****************************************************************
	
keep if ageyrs>=22 & yob>=1935 & yob<=1960
*Same sample restrictions I use prior to analysis:
drop if weight==0
generate evermarried=1-nevermarried
drop if evermarried==0 & femstat==1 & insupp==1
drop if evermarried==1 & femstat>=2 & femstat<=3 & insupp==1
assert age_1mar==. if nevermarried==1, rc0 
assert age_1mar!=. if nevermarried==0 & insupp==1, rc0 

*"Treatment" is states where MCL policy allowed minors to consent to abortion in 1973
gen treatment=state==1|state==18|state==20|state==24|state==27|state==28|state==34|state==42|state==30
replace treatment=. if repeal==1
drop if state==33|state==38|state==39|state==41
drop if state==8|state==12|state==18|state==21|state==29|state==31|state==37|state==45 /*passed an MCL 1974-1975*/

*Repeal states not in this sample-- too hard to see what's going on
drop if repeal==1

*Can't collapse with pweights for se, so doing the following to get confidence intervals
*Surely there's an easier way(?)
svyset [pweight=weight]
foreach var in firstbirth17 firstmar17 shotgun17{
quietly svy: prop `var', over(treatment yob)
matrix `var'=(e(b)',vecdiag(e(V))')
}
matrix results=firstbirth17, firstmar17, shotgun17
matrix list results
clear
svmat results

drop if _n<=52 /*These are proportiosn of ones*/
gen treatment=_n>26
bysort treatment: gen yob=1934+_n
order yob treatment 
rename (results1-results6) (birth17 birth17se mar17 mar17se shotgun17 shotgun17se)
foreach x in birth17 mar17 shotgun17{
replace `x'se=`x'se^0.5
}


foreach var in birth17 mar17 shotgun17{
generate `var'_lci=`var'-1.96*(`var'se)
generate `var'_uci=`var'+1.96*(`var'se)
}

drop if yob<1950

tempfile birth1
tempfile mar1

# delimit ;
set scheme s1mono;
twoway 
	(connect birth17 yob if treatment==1, lwidth(medthick) msymbol(square) lcolor(black) mcolor(black))
	(connect birth17 yob if treatment==0, lwidth(medthick) msymbol(circle) lcolor(black) mcolor(black))
	(connect birth17_lci yob if treatment==0, msymbol(circle_hollow) lpattern(dash) lwidth(thin) lcolor(gs6) mcolor(gs6)) 
	(connect birth17_uci yob if treatment==0, msymbol(circle_hollow) lpattern(dash) lwidth(thin) lcolor(gs6) mcolor(gs6)),
	plotregion(style(none))
	xline(1956, lstyle(dash) lcolor(black))
	xline(1959, lstyle(dash) lcolor(black))
	title("Panel a: Probability of first birth prior to age 18", position(11))
	xtitle(Year of birth)
	xlabel(1950(1)1961) 
	ylabel(0.07(0.01)0.13)
	legend(off)
	text(.12 1956.005 "16 when" "Roe" "decided", place(ne))
	text(.12 1959.005 "16 when" "Danforth" "decided", place(ne))
	saving(`birth1'.gph, replace);	 

# delimit ;
twoway
	(connect mar17 yob if treatment==1, lwidth(medthick) msymbol(square) lcolor(black) mcolor(black))
	(connect mar17 yob if treatment==0, lwidth(medthick) msymbol(circle) lcolor(black) mcolor(black))
	(connect mar17_lci yob if treatment==0, msymbol(circle_hollow) lpattern(dash) lwidth(thin) lcolor(gs6) mcolor(gs6)) 
	(connect mar17_uci yob if treatment==0, msymbol(circle_hollow) lpattern(dash) lwidth(thin) lcolor(gs6) mcolor(gs6)),
	plotregion(style(none))
	xline(1956, lstyle(dash) lcolor(black))
	xline(1959, lstyle(dash) lcolor(black))
	title("Panel b: Probability of first marriage prior to age 18", position(11))
	xtitle(Year of birth, size(small) margin(small))
	xlabel(1950(1)1961, labsize(small))
	legend(on col(1) order(1 "MCL policy permitted minors to consent in 1973" 2 "Minors could not consent 1973-1975" "with 95% C.I.") size(small))
	text(.15 1956.005 "16 years old when" "Roe decided", place(ne) size(vsmall))
	text(.15 1959.005 "16 years old when" "Danforth decided", place(ne) size(vsmall))
	saving(`mar1'.gph, replace);
	
	
*Combined Graph
# delimit ;
set scheme s1mono;
graph combine `birth1'.gph `mar1'.gph,
	col(1)
	ysize(8);
graph export "Results\Figure5.pdf", replace;
graph export "Results\Figure5.eps", replace mag(80);
	# delimit cr