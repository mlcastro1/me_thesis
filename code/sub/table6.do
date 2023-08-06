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