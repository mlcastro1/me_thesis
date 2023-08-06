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