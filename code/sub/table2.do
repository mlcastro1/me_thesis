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