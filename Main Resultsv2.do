****************************************************
****************************************************
***State Repression and Vaccination: Main Results***
****************************************************
****************************************************
clear all

set scheme s1mono   
graph set window fontface "Times New Roman"

*Establish path where DB are stored
global path "C:\Users\56962\Dropbox\Tesis\Vaccination and State Repression\Data"

*Establish path where results will be stored
cd "C:\Users\56962\Dropbox\Tesis\Vaccination and State Repression\Estimations\Main Results"

global strep_vars shVictims_70_10 DVictims DCentroDetencion ln_centro_det ln_dist_mil_fac
global controls Pop70 sh_rural_70 lnDistStgo lnDistRegCapital share_allende70 share_alessandri70
global W p_proj
global se_vac spatial latitude(latitud) longitude(longitud) distcutoff(75)
global se_mob spatial latitude(latitud) longitude(longitud) distcutoff(75)
global balance_vars Turnout70 landlocked Houses_pc SocialOrg_pop70 churches_pop70 sh_educ_12more densidad_1970 sh_econactivepop_70 sh_women_70 TV ari_1973 index1b 
global health_balance_vars_county consultas leche 
global health_balance_vars_area antivariolica antitifica antidifterica mixta antipoliomielitica antisarampionosa antiinlfuenza

********************************************************************************
*Figure 1: Vaccination Rates 
********************************************************************************
use "$path\FinalDataset_Vaccination.dta", clear

forval y = 30/80 {
	if mod(`y', 5) {
		label def cohort_label `y' "`:di "`=uchar(28)'"'", add
	}
}
label value cohort cohort_label
graph box sh_vac_may23 if main_sample==1 [pw=$W], over(cohort) noout ytitle("Vaccination Rate") b1title("Cohorts") note("") ylabel(, nogrid) ascategory asyvars box(1, color(gs11)) box(2, color(gs11)) box(3, color(gs11)) box(4, color(gs11)) box(5, color(gs11)) box(6, color(gs11)) box(7, color(gs11)) box(8, color(gs11)) box(9, color(gs11)) box(10, color(gs11)) box(11, color(gs11)) box(12, color(gs11)) box(13, color(gs11)) box(14, color(gs11)) box(15, color(gs11)) box(16, color(gs11)) box(17, color(gs11)) box(18, color(gs11)) box(19, color(gs11)) box(20, color(gs11)) box(21, color(gs11)) box(22, color(gs11)) box(23, color(gs11)) box(24, color(gs11)) box(25, color(gs11)) box(26, color(gs11)) box(27, color(gs11)) box(28, color(gs11)) box(29, color(gs11)) box(30, color(gs11)) box(31, color(gs11)) box(32, color(gs11)) box(33, color(gs11)) box(34, color(gs8)) box(35, color(gs6)) box(36, color(gs4)) box(37, color(gs2)) box(38, color(gs2)) box(39, color(gs2)) box(40, color(gs2)) box(41, color(gs2)) box(42, color(gs4)) box(43, color(gs6)) box(44, color(gs8)) box(45, color(gs11)) box(46, color(gs11)) box(47, color(gs11)) box(48, color(gs11)) box(49, color(gs11)) box(50, color(gs11)) box(51, color(gs11)) 
graph export "Figure1.pdf", as(pdf) name("Graph") replace

********************************************************************************
*Figure 2: Mobility
********************************************************************************
use "$path\movilidad_final.dta", clear

graph box var_salidas [pw=$W], over(semana, relabel(1 "2020/03/02" 2 " " 3 " " 4 " " 5 " " 6 " " 7 " " 8 " " 9 " " 10 "2020/04/27" 11 " " 12 " " 13 " " 14 " " 15 " " 16 " " 17 " " 18 " " 19 " " 20 "2020/07/06" 21 " " 22 " " 23 " " 24 " " 25 " " 26 " " 27 " " 28 " " 29 " " 30 "2020/09/21" 31 " " 32 " " 33 " " 34 " " 35 " " 36 " " 37 " " 38 " " 39 " " 40 "2020/11/30" 41 " " 42 " " 43 " " 44 " " 45 " " 46 " " 47 " " 48 " " 49 " " 50 "2021/02/08" 51 " " 52 " " 53 " " 54 " " 55 " " 56 " " 57 " " 58 " " 59 " " 60 "2021/04/26" 61 " " 62 " " 63 " " 64 " " 65 " " 66 " " 67 " " 68 " " 69 " " 70 "2021/07/05" 71 " " 72 " " 73 " " 74 " " 75 " " 76 " " 77 " " 78 " " 79 " " 80 "2021/09/20") label(labsize(vsmall))) noout ytitle("Mobility") b1title("Week") note("") ylabel(, nogrid) 
graph export "Figure2.pdf", as(pdf) name("Graph") replace

********************************************************************************
*Figure 3: Victims by Year
********************************************************************************
use "$path\victimsbyyear.dta", clear
	
twoway connected Victims year, msymbol(i) xlabel(1973(3)1988) ytitle("Number of Victims") xtitle("Year") mlabel(Victims) mlabposition(1) mlabsize(vsmall)
graph export "Figure3.pdf", as(pdf) name("Graph") replace

********************************************************************************
*Table 1, 2 & 3: Location of Military Bases 
********************************************************************************

*Table 1: Balance (county characteristics)
use "$path\FinalDatasetforReplication.dta", clear

foreach var in Pop70_pthousands sh_rural_70 lnDistStgo lnDistRegCapital share_allende70  {
	*Mean
	mean `var' [pw=Pop70]
	eststo
	*Regression military presence, no controls
	acreg `var' ln_dist_mil_fac [pw=Pop70], $se_vac
	eststo
	esttab using Table1.tex, b(%9.4f) se(%9.2f) noobs rename(ln_dist_mil_fac `var') keep(`var') mtitles("Mean" "No Controls") label append
	eststo clear 
}

foreach var in $balance_vars {
	*Mean
	mean `var'
	eststo
	*Regression military presence, no controls
	acreg `var' ln_dist_mil_fac [pw=Pop70], $se_vac
	eststo
	*Refression military presence, controls
	acreg `var' ln_dist_mil_fac $controls i.IDProv [pw=Pop70], $se_vac
	eststo
	esttab using Table1.tex, b(%9.4f) se(%9.2f) noobs rename(ln_dist_mil_fac `var') keep(`var') mtitles("Mean" "No Controls" "Controls") label append
	eststo clear 
}

*Table 2: Balance (1971 health statistics)
use "$path\Health1970_county_final.dta", clear

foreach var in $health_balance_vars_county {
	*Mean
	mean sh_`var' [pw=Pop70]
	eststo
	*Regression military presence, no controls
	acreg sh_`var' ln_dist_mil_fac [pw=Pop70], $se_vac
	eststo
	*Refression military presence, controls
	acreg sh_`var' ln_dist_mil_fac $controls i.IDProv [pw=Pop70], $se_vac
	eststo
	esttab using Table2.tex, b(%9.4f) se(%9.2f) noobs rename(ln_dist_mil_fac sh_`var') keep(sh_`var') mtitles("Mean" "No Controls" "Controls") label append
	eststo clear 
}

use "$path\Health1970_area_final.dta", clear

foreach var in $health_balance_vars_area {
	*Mean
	mean sh_`var' [pw=Pop70]
	eststo
	*Regression military presence, no controls
	reg sh_`var' ln_dist_mil_fac [pw=Pop70], vce(robust)
	eststo
	*Refression military presence, controls
	reg sh_`var' ln_dist_mil_fac $controls [pw=Pop70], vce(robust)
	eststo
	esttab using Table2.tex, b(%9.4f) se(%9.2f) noobs rename(ln_dist_mil_fac_area sh_`var') keep(sh_`var') mtitles("Mean" "No Controls" "Controls") label append
	eststo clear 
}

*Table 3: Military Presence and State Repression
use "$path\FinalDataset_Vaccination_collapsed.dta", clear

foreach strep_var in shVictims_70_10 DVictims DCentroDetencion ln_centro_det {
	acreg `strep_var' ln_dist_mil_fac [pw=Pop70] if latitud!=., $se_vac
	eststo
	acreg `strep_var' ln_dist_mil_fac $controls i.IDProv [pw=Pop70], $se_vac
	eststo
}
esttab using Table3.tex, b(%9.4f) se(%9.2f) nocons keep(ln_dist_mil_fac) indicate(Controls = $controls) label replace
eststo clear 

********************************************************************************
*Table 4: State Repression and Vaccination Rates
********************************************************************************
use "$path\FinalDataset_Vaccination.dta", clear

foreach strep_var in $strep_vars {
	acreg sh_vac_may23 `strep_var'_impy2 i.cohort i.code if main_sample==1 [pw=$W], $se_vac
	eststo
}
esttab using Table4.tex, b(%9.4f) se(%9.4f) drop(*.cohort *.code _cons) se rename(shVictims_70_10_impy2 strep_impy2 DVictims_impy2 strep_impy2 DCentroDetencion_impy2 strep_impy2 ln_centro_det_impy2 strep_impy2 ln_dist_mil_fac_impy2 strep_impy2)  coeflabels(strep_impy2 "State repression $\times$ Imp. Years (1973-1976)") replace
eststo clear 

********************************************************************************
*Table 5: State Repression and Mobility
********************************************************************************
use "$path\movilidad_final.dta", clear

foreach strep_var in $strep_vars {
	acreg var_salidas `strep_var'_f1_impy2 `strep_var'_f1 f1_impy2 fase_1 i.semana i.code if semana>10 [pw=$W], $se_vac 
	eststo
}
esttab using Table5v2.tex, b(%9.4f) se(%9.4f) drop(*_f1 f1_impy2 fase_1 *.semana *.code) se rename(shVictims_70_10_f1_impy2 strep_f1_impy2 DVictims_f1_impy2 strep_f1_impy2 DCentroDetencion_f1_impy2 strep_f1_impy2 ln_centro_det_f1_impy2 strep_f1_impy2 ln_dist_mil_fac_f1_impy2 strep_f1_impy2) coeflabels(strep_f1_impy2 "State repression $\times$ Imp. Years (1973-1976) $\times$ Lockdown") replace
eststo clear 

********************************************************************************
*Table 6: Latinobarometro
********************************************************************************
clear
use "$path\Latinobarometro_final.dta"

global latinob_vars sp21 sp63a sp63b sp63d sp63e sp63g P20ST_I P16ST_G p63stc

foreach latinob_var of varlist $latinob_vars {
	acreg z_`latinob_var'_v2 ln_dist_mil_fac_impy2 i.cohort i.code i.numinves s1 if cohort>30 [pw=wt], $se_vac
	qui test ln_dist_mil_fac_impy2
	return list
	global `latinob_var'_pv=`r(p)'
}

* This code generates BKY (2006) sharpened two-stage q-values as described in Anderson (2008), "Multiple Inference and Gender Differences in the Effects of Early Intervention: A Reevaluation of the Abecedarian, Perry Preschool, and Early Training Projects", Journal of the American Statistical Association, 103(484), 1481-1495

* BKY (2006) sharpened two-stage q-values are introduced in Benjamini, Krieger, and Yekutieli (2006), "Adaptive Linear Step-up Procedures that Control the False Discovery Rate", Biometrika, 93(3), 491-507

* Last modified: M. Anderson, 11/20/07
* Test Platform: Stata/MP 10.0 for Macintosh (Intel 32-bit), Mac OS X 10.5.1
* Should be compatible with Stata 10 or greater on all platforms
* Likely compatible with with Stata 9 or earlier on all platforms (remove "version 10" line below)
clear
set obs 9
gen pval=.
replace pval=$sp21_pv in 1
replace pval=$sp63a_pv in 2
replace pval=$sp63b_pv in 3
replace pval=$sp63d_pv in 4
replace pval=$sp63e_pv in 5
replace pval=$sp63g_pv in 6
replace pval=$P20ST_I_pv in 7
replace pval=$P16ST_G_pv in 8
replace pval=$p63stc_pv in 9

* Collect the total number of p-values tested
quietly sum pval
local totalpvals = r(N)

* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
quietly gen int original_sorting_order = _n
quietly sort pval
quietly gen int rank = _n if pval~=.

* Set the initial counter to 1 
local qval = 1

* Generate the variable that will contain the BKY (2006) sharpened q-values
gen bky06_qval = 1 if pval~=.

* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.
while `qval' > 0 {
	* First Stage
	* Generate the adjusted first stage q level we are testing: q' = q/1+q
	local qval_adj = `qval'/(1+`qval')
	* Generate value q'*r/M
	gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q'*r/M
	gen reject_temp1 = (fdr_temp1>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank1 = reject_temp1*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected1 = max(reject_rank1)

	* Second Stage
	* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
	local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
	* Generate value q_2st*r/M
	gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
	* Generate binary variable checking condition p(r) <= q_2st*r/M
	gen reject_temp2 = (fdr_temp2>=pval) if pval~=.
	* Generate variable containing p-value ranks for all p-values that meet above condition
	gen reject_rank2 = reject_temp2*rank
	* Record the rank of the largest p-value that meets above condition
	egen total_rejected2 = max(reject_rank2)

	* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
	replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
	* Reduce q by 0.001 and repeat loop
	drop fdr_temp* reject_temp* reject_rank* total_rejected*
	local qval = `qval' - .001
}
quietly sort original_sorting_order

global sp21_apv=bky06_qval[1]
global sp63a_apv=bky06_qval[2] 
global sp63b_apv=bky06_qval[3]
global sp63d_apv=bky06_qval[4]
global sp63e_apv=bky06_qval[5]
global sp63g_apv=bky06_qval[6]
global P20ST_I_apv=bky06_qval[7] 
global P16ST_G_apv=bky06_qval[8] 
global p63stc_apv=bky06_qval[9]

clear
use "$path\Latinobarometro_final.dta"

foreach latinob_var of varlist $latinob_vars {
	acreg z_`latinob_var'_v2 ln_dist_mil_fac_impy2 i.cohort i.code i.numinves s1 if cohort>30 [pw=wt], $se_vac
	eststo
	estadd scalar adjusted_pv $`latinob_var'_apv
}
esttab using Table6.tex, b(%9.4f) se(%9.4f) nocons keep(ln_dist_mil_fac_impy2) mtitles("Interpersonal" "Church" "Armed Forces" "President" "Police" "Pol Parties" "State" "Nat. Gov." "Local Gov.") s(adjusted_pv) se label replace
eststo clear

********************************************************************************
*Table 7: Mobility during critical periods
********************************************************************************
clear
use "$path\movilidad_final.dta"

acreg var_salidas ln_dist_mil_fac_impy2cp ln_dist_mil_fac_cp impy2_cp i.semana i.code i.paso [pw=$W] if semana>10 & semana<34, $se_vac 
eststo
acreg var_salidas ln_dist_mil_fac_impy2cp1 ln_dist_mil_fac_impy2cp2 ln_dist_mil_fac_cp1 ln_dist_mil_fac_cp2 impy2_cp1 impy2_cp2 i.semana i.code i.paso [pw=$W] if semana>10 & semana<34, $se_vac 
eststo
esttab using Table7v2.tex, b(%9.4f) se(%9.4f) keep(ln_dist_mil_fac_impy2cp ln_dist_mil_fac_impy2cp1 ln_dist_mil_fac_impy2cp2 ) nocons se label replace
eststo clear

    