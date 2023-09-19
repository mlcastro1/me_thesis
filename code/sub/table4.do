/*******************************************************************************
********************************************************************************
Purpose: 				Create Table 4: State Repression, Impressionable Years 
						and Vaccination Rates
						
						Author: Leonor Castro
						Last Edited: 16 Sept 2023

Overview
	- Load county x cohort-level data
	- Create additional variables specific to this dofile
	- Run regressions 
	- Create and export table
	
*******************************************************************************
 Load county x cohort-level data
********************************************************************************/

	use 				"${data_clean}\finaldataset_main.dta", clear
	
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
	label				var strep_aux "\specialcell{State repression $\times$ \twoback Imp. Years (1973-1976)}"
	
/*******************************************************************************
 Run regressions 
********************************************************************************/

	eststo				clear

	foreach 			var of varlist $strep_vars_all {
		
		replace				strep_aux = `var'_impy2
		
		acreg 				sh_vac_may23 strep_aux ///
								i.cohort i.code if main_sample == 1 ///
								[pw = ${W}], ${conley_se}
		eststo
		
		distinct			code if e(sample)
		estadd				scalar N_counties = `r(ndistinct)'
		sum					sh_vac_may23 if e(sample)
		estadd				scalar ymean = `r(mean)'
		sum					`var' if e(sample)
		estadd				scalar xmean = `r(mean)'
		local 				vname : var label `var'					
		estadd				local strepvar "`vname'"
	}

/*******************************************************************************
 Create and export table
********************************************************************************/

	esttab			using "${results}/Table4.tex", ///
						replace nocons b(4) se(4) label nonotes nomtitles ///	
						keep(strep_aux) ///
						star(* .05 ** .01 *** .001) ///
						mgroups("Vaccination rate", ///
						pattern(1 0 0 0 0) ///
						prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
						stats( N N_counties ymean xmean strepvar, ///
						labels("\# observations" "\# counties" "Mean outcome" "Mean state repression measure" "State repression measure") ///
						fmt(%4.0f %4.0f %9.4f %9.4f 0)) ///
						postfoot("\hline\hline \multicolumn{@span}{p{25cm}}{\footnotesize @note}\\ \end{tabular} } % Generated on $S_DATE at $S_TIME.") ///
						note(* p$<$0.05, ** p$<$0.01, *** p$<$0.001. Note: Unit of observation: county $\times$ cohort. This table reports OLS coefficient estimates of exposure to state repression over accumulated vaccination rates until May 23, 2021 from equation (\ref{eq:1}), which includes cohort and county fixed-effects. All estimations use the number of years between 18 and 25 lived between 1973 and 1976 as the impressionable years indicator, and state repression indicators for each column are indicated in the bottom row. Observations are weighted by 2020 county-cohort population size, and observations from counties with aggregated vaccination rates greater than one are dropped. Conley standard errors in parentheses.) 
