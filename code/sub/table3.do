/*******************************************************************************
********************************************************************************
Purpose: 				Create Table 3: Military Presence and State Repression
						
						Author: Leonor Castro
						Last Edited: 16 Sept 2023

Overview
	- Load county-level data
	- Run regressions 
	- Create and export table
	
*******************************************************************************
 Load county-level data
********************************************************************************/

	use 			"${data_clean}\finaldataset_countylevel.dta", clear
	
/*******************************************************************************
 Run regressions
********************************************************************************/

	foreach 		var of varlist $strep_vars {								// loop over outcomes
	
	* No controls
		acreg 			`var' ln_dist_mil_fac ///
							[pw = ${W_70}], ${conley_se}
		eststo
		
		sum				`var' if e(sample)
		estadd			scalar ymean = `r(mean)'
		sum				ln_dist_mil_fac if e(sample)
		estadd			scalar xmean = `r(mean)'
		estadd			local controls "No"
		
	* With controls and Province FEs
		acreg 			`var' ln_dist_mil_fac ///
							${controls} i.IDProv ///
							[pw = ${W_70}], ${conley_se}
		eststo
		
		sum				`var' if e(sample)
		estadd			scalar ymean = `r(mean)'
		sum				ln_dist_mil_fac if e(sample)
		estadd			scalar xmean = `r(mean)'
		estadd			local controls "Yes"
		
	}

/*******************************************************************************
 Create and export table
********************************************************************************/

	esttab			using "${results}/Table3.tex", ///
						replace nocons b(4) se(4) label nonotes nomtitles ///	
						keep(ln_dist_mil_fac) ///
						star(* .0.05 ** .01 *** .001) ///
						mgroups("Victims per 1,000 inhab." "Any victims" "Any detention centers" "Ln(1 + detention centers)", ///
						pattern(1 0 1 0 1 0 1 0) ///
						prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
						stats( N ymean xmean controls, ///
						labels("\# observations" "Mean outcome" "Mean ln(distance to military facility)" "Controls") ///
						fmt(%4.0f %9.4f %9.4f 0)) ///
						postfoot("\hline\hline \multicolumn{@span}{p{25cm}}{\footnotesize @note}\\ \end{tabular} } % Generated on $S_DATE at $S_TIME.") ///
						note(* p$<$0.05, ** p$<$0.01, *** p$<$0.001. Note: Unit of observation: county. This Table reports OLS coefficient estimates of military presence before 1973 over state repression during the dictatorship, by using the logarithmic distance to the closest military facility as independent variable. Dependent variables are the number of fatal victims per 1,000 inhabitants (columns (1) and (2)), a dummy indicating any victims (columns (3) and (4)), a dummy indicating any detention centers (columns (5) and (6)), and the logarithmic of the number of detention centers plus one (columns (7) and (8)). Even-numbered columns include province fixed effects, and control for population in 1970, urban share in 1970, logarithmic distance to Santiago and to the regional capital, and the vote shares obtained by Allende and Alessandri in the 1970 elections. Note that missing values in the control variables are imputed with the sample mean, and indicator variables for these cases are added as controls. Observations are weighted by 1970 county population size. Conley standard errors in parentheses.) 