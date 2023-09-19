/*******************************************************************************
********************************************************************************
Purpose: 				Create Table 7: State Repression, Impressionable Years 
						and Mobility during Critical Periods
						
						Author: Leonor Castro
						Last Edited: 18 Sept 2023

Overview
	- Load county-level data
	- Set variable labels
	- Run regressions 
	- Create and export table
	
*******************************************************************************
 Load county x week-level data
********************************************************************************/

	use 				"${data_clean}\movilidad_final.dta", clear
	keep				if semana > 10 & semana < 34							// restrict to relevant period
	
/*******************************************************************************
 Set variable labels
********************************************************************************/

/*******************************************************************************
 Run regressions
********************************************************************************/
	
	eststo				clear

	acreg 				var_salidas ln_dist_mil_fac_impy2cp ln_dist_mil_fac_cp impy2_cp ///
							i.semana i.code i.paso ///
							[pw = ${W}], ${conley_se} 
	eststo

	distinct			code if e(sample)
	estadd				scalar N_counties = `r(ndistinct)'
	sum					var_salidas if e(sample) 
	estadd				scalar ymean = `r(mean)'
	
	acreg 				var_salidas ln_dist_mil_fac_impy2cp1 ln_dist_mil_fac_impy2cp2 ///
							ln_dist_mil_fac_cp1 ln_dist_mil_fac_cp2 impy2_cp1 impy2_cp2 ///
							i.semana i.code i.paso ///
							[pw = ${W}], ${conley_se} 
	eststo

	distinct			code if e(sample)
	estadd				scalar N_counties = `r(ndistinct)'
	sum					var_salidas if e(sample) 
	estadd				scalar ymean = `r(mean)'

/*******************************************************************************
 Create and export table
********************************************************************************/

	esttab			using "${results}/Table7.tex", ///
						replace nocons b(4) se(4) label nonotes nomtitles ///	
						keep(ln_dist_mil_fac_impy2cp ln_dist_mil_fac_impy2cp1 ln_dist_mil_fac_impy2cp2 ) ///
						star(* .05 ** .01 *** .001) ///
						mgroups("Mobility", ///
						pattern(1 0) ///
						prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
						stats( N N_counties ymean, ///
						labels("\# observations" "\# counties" "Mean outcome") ///
						fmt(%4.0f %4.0f %9.4f)) ///
						postfoot("\hline\hline \multicolumn{@span}{p{25cm}}{\footnotesize @note}\\ \end{tabular} } % Generated on $S_DATE at $S_TIME.") ///
						note(* p$<$0.05, ** p$<$0.01, *** p$<$0.001. Note: Unit of observation: county $\times$ week. This table reports OLS coefficient estimates of exposure to state repression over mobility during critical periods. Column (1) reports the main coefficient of interest from equation (\ref{eq:4}), which includes county and week fixed-effects. Column (2) reports the main coefficients of interest from a variation of equation (\ref{eq:4}) which also distinguishes the start of the second critical period. All estimations use the number of years between 18 and 25 lived between 1973 and 1976 as impressionable years indicators and the logarithmic distance to the closest military facility as a proxy for state repression. Observations are weighted by county population size. Conley standard errors in parentheses.) 

