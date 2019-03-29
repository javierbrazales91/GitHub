
clear all

global Path "C:\Users\CEMFI\Dropbox\00_S5\GitHub\Development-Economics\HWK01"
global DataPath "$Path\Data"
global CodesPath "$Path\Codes"
global DocPathPath "$Path\DocPath"

cd "$DataPath"

use "$DataPath/CIW.dta", clear

// 1. plot the level (Log)

use "$DataPath/CIW.dta", clear

collapse (mean) Total_LS log_C log_I log_W, by(district_code)

twoway scatter Total_LS log_I || lfit Total_LS log_I, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean Hours Worked") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District1_LS", replace)
twoway scatter log_C log_I || lfit log_C log_I, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("log(Mean Consumption)") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District1_Consumption", replace)
twoway scatter log_W log_I || lfit log_W log_I, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("log(Mean Wealth)") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District1_Wealth", replace)


// 2. Plot the inequality


use "$DataPath/CIW.dta", clear

collapse (sd) logTotal_LS log_C log_I log_W (mean) I, by(district_code)

gen Var_LogTotal_LS = logTotal_LS^2
gen Var_log_C = log_C^2
gen Var_log_I = log_I^2
gen Var_log_W = log_W^2


replace I = log(I)



twoway scatter Var_LogTotal_LS I || lfit Var_LogTotal_LS I, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Var of Log Hours Worked") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District2_LS", replace)
twoway scatter Var_log_C I || lfit Var_log_C I, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Var of Log Consumption") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District2_Consumption", replace)
twoway scatter Var_log_I I || lfit Var_log_I I, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Var of Log Income") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District2_Income", replace)
twoway scatter Var_log_W log_I || lfit Var_log_W log_I, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Var of Log Wealth") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District2_Wealth", replace)




// 3. Plot the covariances of CIW and labor supply by zone (or district) against
*    the level of household income by zone.
use "$DataPath/CIW.dta", clear

bysort district_code: egen Corr_C_I = corr(log_C log_I)
bysort district_code: egen Corr_C_W = corr(log_C log_W)
bysort district_code: egen Corr_W_I = corr(log_I log_W)
bysort district_code: egen Corr_I_LS = corr(log_I logTotal_LS)

collapse (mean) Corr_C_I Corr_C_W Corr_W_I Corr_I_LS I, by(district_code)

gen income = log(I)

twoway scatter Corr_I_LS income || lfit Corr_I_LS income, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Corr. Hours Worked and Income") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District3_LaborInc", replace)
twoway scatter Corr_C_I income || lfit Corr_C_I income, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Corr. Consumption and Income") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District3_Consumption and Income", replace)
twoway scatter Corr_C_W income || lfit Corr_C_W income, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Corr. Consumption and Wealth") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District3_Consumption and Wealth", replace)
twoway scatter Corr_W_I income || lfit Corr_W_I income, ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Corr. Wealth and Income") ///
	   xtitle("log(Mean Income)") ///
	   legend(label(1 "Districts")) ///
	   saving("$DocPath/District3_Income and Wealth", replace)


// 4. Reproduce the Bick et. al (2018) 
use "$DataPath/CIW.dta", clear

bysort district_code: egen hoursWorked_Dist = sum(LS)
bysort district_code: egen Income_Dist = sum(I)

gen log_I_Hourly = log(Income_Dist/hoursWorked_Dist)

gen age2 = age^2

* Regressions
xi: reg logLS log_I_Hourly age age2, vce(cluster district_code)

xi: reg logLS Wage age age2, vce(cluster district_code)


xi: reg logLS Wage log_I_Hourly age age2, vce(cluster district_code)

xi: reg logLS Wage log_I_Hourly i.district_code age age2, vce(cluster district_code)



