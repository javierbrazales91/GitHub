
clear all

global Path "C:\Users\CEMFI\Dropbox\00_S5\GitHub\Development-Economics\HWK01"
global DataPath "$Path\Data"
global CodesPath "$Path\Codes"
global DocPath "$Path\Doc"

cd "$DataPath"

use "$DataPath/CIW.dta", clear


// 1. Report average CIW per household separately for rural and urban areas.

* Compute means by urban and rural areas
estpost tabstat C I W, by(urban) statistics(mean) 


// 2. CIW inequality:
// 					 (1) Show histogram for CIW separately for rural and urban areas						 areas; 
//					 (2)  Report the variance of logs for CIW separately for rural and urban areas.


*  Generate histograms for CIW 

twoway (histogram log_C if urban==0, fcolor(ltblue) lcolor(white)) ///
       (histogram log_C if urban==1,  ///
	   fcolor(none) lcolor(red)), legend(order(1 "Rural" 2 "Urban" )) ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   xsc(r(0 15)) ///
	   xlabel(0(2)15) ///
	   saving("$DocPath/2_1_Consumption_Hist", replace)

twoway (histogram log_I if urban==0, fcolor(ltblue) lcolor(white)) ///
       (histogram log_I if urban==1,  ///
	   fcolor(none) lcolor(red)), legend(order(1 "Rural" 2 "Urban" )) ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   xsc(r(0 15)) ///
	   xlabel(0(2)15) ///
	   saving("$DocPath/2_1_Income_Hist", replace)

twoway (histogram log_W if urban==0, fcolor(ltblue) lcolor(white)) ///
       (histogram log_W if urban==1,  ///
	   fcolor(none) lcolor(red)), legend(order(1 "Rural" 2 "Urban" )) ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   xsc(r(0 15)) ///
	   xlabel(0(2)15) ///
	   saving("$DocPath/2_1_Wealth_Hist", replace)

* Compute variances of logs by urban and rural areas
estpost tabstat log_C log_I log_W, by(urban) statistics(variance)


// 3. Describe the joint cross-sectional behavior of CIW
correlate log_C log_I log_W
correlate log_C log_I log_W if urban==0 
correlate log_C log_I log_W if urban==1 



// 4. Describe the CIW level, inequality, and covariances over the lifecycle.

* Mean
preserve
collapse (mean) log_C, by(age)
keep if age>=20 & age <= 70
twoway (line log_C age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of log Consumption") ///
	   saving("$DocPath/4_Mean_Cons", replace)		
restore

preserve
collapse (mean) log_I, by(age)
keep if age>=20 & age <= 70
twoway (line log_I age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of log Income") ///
	   saving("$DocPath/4_Mean_Income", replace)	
restore

preserve
collapse (mean) log_W, by(age)
keep if age>=20 & age <= 70
twoway (line log_W age), ///
	   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ///
	   ytitle("Mean of log Wealth") ///
	   saving("$DocPath/4_Mean_Wealth", replace)	
restore



//  5. Rank your households by income, and dicuss the behavior of the top and 
*	 bottom of the consumption and wealth distributions conditional on income.

