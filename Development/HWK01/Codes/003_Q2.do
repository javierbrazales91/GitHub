
clear all

global Path "C:\Users\CEMFI\Dropbox\00_S5\GitHub\Development-Economics\HWK01"
global DataPath "$Path\Data"
global CodesPath "$Path\Codes"
global DocPath "$Path\Doc"

cd "$DataPath"

use "$DataPath/CIW.dta", clear


// 2.1. Redo Question 1 for intensive and extensive margins of labor supply

// 1. Averages

estpost tabstat LS LSFamily Total_LS, by(urban) statistics(mean)

estpost tabstat LS_Extensive LSFamily_Extensive Total_LS_Extensive, by(urban) statistics(mean)

estpost tabstat logLS logLSFamily logTotal_LS, by(urban) statistics(variance)

estpost tabstat LS_Extensive LSFamily_Extensive Total_LS_Extensive, by(urban)  statistics(variance)


// 2. Histogram

twoway (histogram logLS if urban==0, fcolor(ltblue) lcolor(white)) ///
       (histogram logLS if urban==1,  ///
	   fcolor(none) lcolor(red)), legend(order(1 "Rural" 2 "Urban" )) ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   saving("$DocPath/2_1_LS_Hist", replace)

twoway (histogram logLSFamily if urban==0, fcolor(ltblue) lcolor(white)) ///
       (histogram logLSFamily if urban==1,  ///
	   fcolor(none) lcolor(red)), legend(order(1 "Rural" 2 "Urban" )) ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   saving("$DocPath/2_1_LSFamily_Hist", replace)


// 3. Lifecycle

preserve
collapse (mean) LS, by(age)
keep if age>=20 & age <= 70
twoway (line LS age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of Hours Worked (Job)") ///
	   saving("$DocPath/4_Mean_LS", replace)
restore



preserve
collapse (mean) Total_LS, by(age)
keep if age>=20 & age <= 70
twoway (line Total_LS age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of Hours Worked (Total)") ///
	   saving("$DocPath/4_Mean_LSTotal", replace)
restore



preserve
collapse (mean) LS_Extensive, by(age)
keep if age>=20 & age <= 70
twoway (line LS_Extensive age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Percentage of housholds with a Job (Extensive Margin)") ///
	   saving("$DocPath/4_Mean_LS_Extensive", replace)
restore



preserve
collapse (mean) Total_LS_Extensive, by(age)
keep if age>=20 & age <= 70
twoway (line Total_LS_Extensive age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Percentage of housholds doing Family Labor or Job (Extensive Margin)") ///
	   saving("$DocPath/4_Mean_LSTotaExt", replace)
restore


// 2.2. Redo separately for women and men, and by education groups (less than
*    primary school completed, primary school completed, and secondary school
*    completed or higher)

** Women and Men
estpost tabstat LS LSFamily Total_LS, by(sex) statistics(mean)

estpost tabstat LS_Extensive LSFamily_Extensive Total_LS_Extensive, by(sex) statistics(mean)

estpost tabstat logLS logLSFamily logTotal_LS, by(sex) statistics(variance)

* Lifecycle

preserve
collapse (mean) Total_LS, by(age sex)
keep if age>=20 & age <= 70 & sex == 1
twoway (line Total_LS age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of Hours Worked (Total)") ///
	   title("Male") ///
	   saving("$DocPath/4_Mean_LSTotal_Male", replace)
restore

preserve
collapse (mean) Total_LS, by(age sex)
keep if age>=20 & age <= 70 & sex == 2
twoway (line Total_LS age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of Hours Worked (Total)") ///
	   title("Female") ///
	   saving("$DocPath/4_Mean_LSTotal_Female", replace)
restore

preserve
collapse (mean) LS_Extensive, by(age sex)
keep if age>=20 & age <= 70 & sex == 1
twoway (line LS_Extensive age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Percentage of housholds with a Job (Extensive Margin)") ///
	   title("Male") ///
	   saving("$DocPath/4_Mean_LS_Extensive_Male", replace)
restore

preserve
collapse (mean) LS_Extensive, by(age sex)
keep if age>=20 & age <= 70 & sex == 2
twoway (line LS_Extensive age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Percentage of housholds with a Job (Extensive Margin)") ///
	   title("Female") ///
	   saving("$DocPath/4_Mean_LS_Extensive_Female", replace)
restore

** Education

estpost tabstat LS LSFamily Total_LS, by(education) statistics(mean)

estpost tabstat LS_Extensive LSFamily_Extensive Total_LS_Extensive, by(education) statistics(mean)

estpost tabstat logLS logLSFamily logTotal_LS, by(education) statistics(variance)

preserve
collapse (mean) Total_LS, by(age education)
keep if age>=20 & age <= 70 & education == 1
twoway (line Total_LS age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of Hours Worked (Total)") ///
	   title("Less than primary") ///
	   saving("$DocPath/4_Mean_LSTotal_Educ1", replace)
restore

preserve
collapse (mean) Total_LS, by(age education)
keep if age>=20 & age <= 68 & education == 2
twoway (line Total_LS age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of Hours Worked (Total)") ///
	   title("Secondary completed") ///
	   saving("$DocPath/4_Mean_LSTotal_Educ2", replace)
restore

preserve
collapse (mean) Total_LS, by(age education)
keep if age>=20 & age <= 70 & education == 3
twoway (line Total_LS age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of Hours Worked (Total)") ///
	   title("Secondary or higher") ///
	   title("Secondary or higher") ///
	   saving("$DocPath/4_Mean_LSTotal_Educ3", replace)
restore

** Extensive Margin

preserve
collapse (mean) LS_Extensive, by(age education)
keep if age>=20 & age <= 70 & education == 1
twoway (line LS_Extensive age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Percentage of housholds with a Job (Extensive Margin)") ///
	   title("Less than primary") ///
	   saving("$DocPath/4_Mean_LS_Extensive_Educ1", replace)
restore

preserve
collapse (mean) LS_Extensive, by(age education)
keep if age>=20 & age <= 70 & education == 2
twoway (line LS_Extensive age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Percentage of housholds with a Job (Extensive Margin)") ///
	   title("Secondary completed") ///
	   saving("$DocPath/4_Mean_LS_Extensive_Educ2", replace)
restore

preserve
collapse (mean) LS_Extensive, by(age education)
keep if age>=20 & age <= 70 & education == 3
twoway (line LS_Extensive age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Percentage of housholds with a Job (Extensive Margin)") ///
	   title("Secondary or higher") ///
	   saving("$DocPath/4_Mean_LS_Extensive_Educ3", replace)
restore
