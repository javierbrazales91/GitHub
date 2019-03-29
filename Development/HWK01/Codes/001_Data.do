/*---------------------------------------------------------------------

Notice that:
** All the monetary terms are converted into US Dollars (2013)
** We convert all the variables in annual term
** The Unit of Price is eithrt KG or Liter

---------------------------------------------------------------------*/

clear all

global Path "C:\Users\CEMFI\Dropbox\00_S5\GitHub\Development-Economics\HWK01"
global DataPath "$Path\Data"
global CodesPath "$Path\Codes"
global DocPath "$Path\Doc"

cd "$DataPath\UGA_2013_UNPS"


use "UNPS 2013-14 Consumption Aggregate.dta", clear
duplicates drop
merge 1:1 HHID using "$DataPath/Income.dta"
drop _merge
merge 1:1 HHID using "$DataPath/Wealth.dta"
drop _merge
merge 1:m HHID using "GSEC2.dta"
drop _merge
merge 1:1 HHID PID using "GSEC4.dta"
drop _merge


rename h2q3 sex
rename h2q8 age
rename h4q7 educ
rename h2q4 relHead
keep if relHead == 1 // Only keep household heads

gen education = .
replace education = 1 if educ < 17 // less than primary school completed
replace education = 2 if educ >= 17 & educ < 34 // primary school completed
replace education = 3 if educ >= 34 // secondary school completed or higher


* Define the exhange rate to USD
local shillingToUSD 0.0004 // Exhcange rate in December 2013

* Convert main variables to USD
gen C = cpexp30 * 12 * `shillingToUSD' // cpexp30 is in monthly terms
replace income = income * `shillingToUSD'
replace wealth = wealth * `shillingToUSD'
replace Wage   = Wage  * `shillingToUSD'
rename income I
rename wealth W
* Define the three measures in logs
gen log_C = log(C)
gen log_I = log(I)
gen log_W = log(W)

* Add missing label for rural area
label define urban 0 "Rural", add

* Variables to keep
keep HHID C I W log_C log_I log_W ea region ///
     regurb urban wgt_X age sex education relHead Hours_Year Hours_Year2 hsize equiv ///
	   district_code  Wage

* Check for duplicates in the list of housheolds
duplicates report
duplicates list
duplicates drop HHID, force

* Save dataset
save "$DataPath/CIW.dta", replace

* Compute labor supply in agriculture per year
use "AGSEC3A.dta", clear
append using "AGSEC3B.dta", generate(visit2) // second visit


gen WorkDays_S1 = cond(missing(a3aq33a_1), 0, a3aq33a_1) + /// replace missing values by 0 when summing
						cond(missing(a3aq33b_1), 0, a3aq33b_1) + ///
						cond(missing(a3aq33c_1), 0, a3aq33c_1) + ///
						cond(missing(a3aq33d_1), 0, a3aq33d_1) + ///
						cond(missing(a3aq33e_1), 0, a3aq33e_1)

gen WorkDays_S2 = cond(missing(a3bq33a_1), 0, a3bq33a_1) + /// replace missing values by 0 when summing
						cond(missing(a3bq33b_1), 0, a3bq33b_1) + ///
						cond(missing(a3bq33c_1), 0, a3bq33c_1) + ///
						cond(missing(a3bq33d_1), 0, a3bq33d_1) + ///
						cond(missing(a3bq33e_1), 0, a3bq33e_1)

gen WorkDays_S1_Mean = WorkDays_S1
gen WorkDays_S2_Mean = WorkDays_S2


* Sum variables per housholds
collapse (sum) WorkDays_S1 WorkDays_S2 ///
		(mean) WorkDays_S1_Mean WorkDays_S2_Mean, by(hh)

rename hh HHID

* Sum days worked per season and houshehold
gen WorkDays_Agriculture = WorkDays_S1 + WorkDays_S2
gen WorkDays_Agriculture_Mean = WorkDays_S1_Mean + WorkDays_S2_Mean

* Merge with existing dataset
merge 1:1 HHID using "$DataPath/CIW.dta"
drop _merge

* Generate labor supply variables (intensive margin)
gen LS = Hours_Year + Hours_Year2
gen LSFamily = 8*WorkDays_Agriculture // Assuming 10 hours per day
gen Total_LS = LS + LSFamily

drop Hours_Year*
drop WorkDays_Agriculture

* Generate labor supply variables (extensive margin)
gen LS_Extensive = (LS>0)*100
gen LSFamily_Extensive = (LSFamily>0)*100
gen Total_LS_Extensive = (Total_LS>0)*100


* Compute log labor supply
gen logLS = log(LS)
gen logLSFamily = log(LSFamily)
gen logTotal_LS = log(Total_LS)


* Generate the Final dataset
save "$DataPath/CIW.dta", replace

