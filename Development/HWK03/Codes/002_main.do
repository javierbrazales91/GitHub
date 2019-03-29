clear all
set more off
set matsize 11000
set maxvar 20000

global path "F:\Dropbox\00_S5\GitHub\Development-Economics\HWK03\Codes"
global output "$path\Output"
cd "$path"

use "dataUGA.dta", clear

replace year = 2009 if wave == "2009-2010"
replace year = 2010 if wave == "2010-2011"
replace year = 2011 if wave == "2011-2012"
replace year = 2013 if wave == "2013-2014"

* Define panel years
xtset hh year
sort hh year

move hh age
bysort hh: gen t = year - year[_n-1]
move t age
move year age

drop if ctotal==0 | ctotal==.
drop if inctotal==0 |inctotal==.
gen Log_Cons = log(ctotal)
gen Log_Inc = log(inctotal)

bysort region year urban: egen Agg_Cons = total(ctotal)
gen Log_Agg_Cons = log(Agg_Cons)

reg Log_Cons age age_sq familysize i.year i.ethnic i.female i.urban
predict Res_Cons, residuals

reg Log_Inc age age_sq familysize i.year i.ethnic i.female i.urban
predict Res_Inc, residuals

sort hh year
by hh: gen Con_Growth = (Res_Cons - Res_Cons[_n-1])
by hh: gen Inc_Growth = (Res_Inc - Res_Inc[_n-1])
by hh: gen Agg_Con_Growth = (Log_Agg_Cons - Log_Agg_Cons[_n-1])

* Annualize the growth rates
replace Con_Growth = Con_Growth/t
replace Inc_Growth = Inc_Growth/t
replace Agg_Con_Growth = Agg_Con_Growth/t


xtset hh year

* Compute Beta and Phi
if "$check" == "urban" {
	drop if urban == 0
}
else if "$check" == "rural" {
	drop if urban == 1
}
save "$path/temp.dta", replace
statsby, by(hh) : regress Con_Growth Inc_Growth Agg_Con_Growth, noconst

rename _b_Inc_Growth Beta
rename _b_Agg_Con_Growth Phi
label variable Beta "Beta" 
label variable Phi "Phi" 
*ssc install  winsor2

winsor2 Beta Phi, replace cuts(1 99)

histogram(Beta), xtitle("Beta") saving("$output/Beta_$check", replace)
histogram(Phi), xtitle("Phi") saving("$output/Phi_$check", replace)

estpost tabstat Beta Phi, statistics(mean median) columns(statistics) 
merge 1:m hh using "$path/temp.dta"





* Question 2
* (a) income
preserve

collapse (mean) Beta Phi inctotal, by(hh)

xtile qnt = inctotal, n(5)
label define qntLab 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5"
label values qnt qntLab  

bysort qnt: egen BetaMean = mean(Beta)
bysort qnt: egen BetaMedian = median(Beta)
label variable BetaMean "Mean Beta" 
label variable BetaMedian "Median Beta" 

estpost tabstat BetaMean BetaMedian, by(qnt) statistics(mean) columns(statistics) listwise nototal

restore  
	   

* (c) income
preserve

collapse (mean) Beta inctotal, by(hh)

gen Abs_Beta = abs(Beta)
xtile qnt = Abs_Beta, n(5)
label define qntLab 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5"
label values qnt qntLab  

bysort qnt: egen Inc_Mean = mean(inctotal)
bysort qnt: egen Inc_Median = median(inctotal)
label variable Inc_Mean "Mean Income" 
label variable Inc_Median "Median Income" 

estpost tabstat Inc_Mean Inc_Median, by(qnt) statistics(mean) columns(statistics) listwise nototal

restore

* Question 3

regress Con_Growth Inc_Growth Agg_Con_Growth, noconst


