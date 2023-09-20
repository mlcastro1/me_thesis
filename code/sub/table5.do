/*******************************************************************************
********************************************************************************
Purpose: 				Create Table 5: State Repression, Impressionable Years 
						and Mobility during Lockdown days
						
						Author: Leonor Castro
						Last Edited: 16 Sept 2023

Overview
	- Load county x week-level data
	- Create additional variables specific to this dofile
	- Set variable labels
	- Run regressions 
	- Create and export table
	
*******************************************************************************
 Load county x week-level data
********************************************************************************/

	use 				"${data_clean}\movilidad_final.dta", clear
	keep				if semana > 10											// restrict sample to relevant period

/*******************************************************************************
 Create additional variables specific to this dofile
********************************************************************************/

	gen					strep_aux = .											// to be replaced with each of the st. rp. vars in the loop
	
/*******************************************************************************
 Set variable labels
********************************************************************************/

	label 				var shVictims_70_10 "\specialcell{Victims per \twoback 1,000 inhab.}"
	label 				var DVictims "\specialcell{Any \twoback victims}" 
	label 				var DCentroDetencion "\specialcell{Any det. \twoback centers}" 
	label 				var ln_centro_det "\specialcell{Ln(1 + \twoback det. centers)}"
	label 				var ln_dist_mil_fac "Ln(dist. to \twoback military facility)}"
	label				var strep_aux "\specialcell{State repression $\times$ County Imp. \twobac Years (1973-1976) $\times$ Lockdown}"
	
/*******************************************************************************
 Run regressions 
********************************************************************************/

	eststo				clear

	foreach 			var in $strep_vars_all {
		
		replace				strep_aux = `var'_f1_impy2
		
		acreg 				var_salidas strep_aux `var'_f1 f1_impy2 fase_1 ///
								i.semana i.code [pw = ${W}], ${conley_se} 
		eststo
		
		distinct			code if e(sample)
		estadd				scalar N_counties = `r(ndistinct)'
		sum					var_salidas if e(sample) 
		estadd				scalar ymean = `r(mean)'
		sum					`var' if e(sample)
		estadd				scalar xmean = `r(mean)'
		local 				vname : var label `var'					
		estadd				local strepvar "`vname'"
	}

/*******************************************************************************
 Create and export table
********************************************************************************/

	esttab			using "${results}/Table5.tex", ///
						replace nocons b(4) se(4) label nonotes nomtitles ///	
						keep(strep_aux) ///
						star(* .05 ** .01 *** .001) ///
						mgroups("Mobility", ///
						pattern(1 0 0 0 0) ///
						prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
						stats( N N_counties ymean xmean strepvar, ///
						labels("\# observations" "\# counties" "Mean outcome" "Mean state repression measure" "State repression measure") ///
						fmt(%4.0f %4.0f %9.4f %9.4f 0)) ///
						postfoot("\hline\hline \multicolumn{@span}{p{25cm}}{\footnotesize @note}\\ \end{tabular} } % Generated on $S_DATE at $S_TIME.") ///
						note(* p$<$0.05, ** p$<$0.01, *** p$<$0.001. Note: Unit of observation: county $\times$ week. This table reports OLS coefficient estimates of exposure to state repression over mobility during lockdown days from equation (\ref{eq:2}), which includes county and week fixed-effects. All estimations use the number of years between 18 and 25 lived between 1973 and 1976 as impressionable years indicators and state repression indicators for each column are indicated in the last row. Observations are weighted by 2020 county population size. Conley standard errors in parentheses.) 
