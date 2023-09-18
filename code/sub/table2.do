/*******************************************************************************
********************************************************************************
Purpose: 				Create Table 2: Military Presence and Pre-Dictatorship 
						Health Outcomes
						
						Author: Leonor Castro
						Last Edited: 16 Sept 2023

Overview
	- Load county-level data
	- Run regressions for county-level outcomes
	- Load area-level data
	- Run regressions for area-level outcomes
	- Create and export table
	
*******************************************************************************
 Load county-level data
********************************************************************************/

	use 			"${data_clean}\Health1970_county_final.dta", clear

/*******************************************************************************
 Set locals with specification details
********************************************************************************/
	
	local			weights [pw=Pop70]
	local			fmt "%9.3f"
	local			fmt2 "%5.3f"
	local			se_area vce(robust)
	
/*******************************************************************************
 Generate summary statistics for county-level outcomes
********************************************************************************/
	
	foreach 		var of varlist $health_balance_vars_county {				// loop over county-level variables
		
		local 			vname_`var' : var label `var'							// store variable label
		
		reg				`var' [pw = ${W_70}]
				
		local 			mean_`var': display `fmt' e(b)[1,1]						// store mean
		local 			sdev_`var': display `fmt' e(V)[1,1]^0.5					// store standard deviation
		local 			obs_`var': display  e(N)								// store sample size
		
	*Regression military presence, no controls
		acreg 			`var' ln_dist_mil_fac [pw = ${W_70}], ${conley_se}
		
		local			diff_`var': display `fmt' e(b)[1,1]						// store coefficient
		
		test			ln_dist_mil_fac
		if 				r(p) <= 0.001 {											// store significance stars
			 local 			star_`var' "\sym{***}"
		}
		else 			if r(p) <= 0.01 {
		     local 			star_`var' "\sym{**}"
		}
		else if 		r(p) <= 0.05 {
		     local 			star_`var' "\sym{*}"
		}
		else {
		     local 		star_`var' " "
		}
		local			pval_`var': display `fmt2' r(p) 						// store p-value
		
	*Refression military presence, with controls
		acreg 		`var' ln_dist_mil_fac ///
						${controls} i.IDProv [pw = ${W_70}], ${conley_se}
		
		local			diffc_`var': display `fmt' e(b)[1,1]					// store coefficient
		
		test			ln_dist_mil_fac
		if 				r(p) <= 0.001 {											// store significance stars
			 local 			starc_`var' "\sym{***}"
		}
		else 			if r(p) <= 0.01 {
		     local 			starc_`var' "\sym{**}"
		}
		else if 		r(p) <= 0.05 {
		     local 			starc_`var' "\sym{*}"
		}
		else {
		     local 		starc_`var' " "
		}
		local			pvalc_`var': display `fmt2' r(p) 						// store p-value

	} // end of var

/*******************************************************************************
 Load area-level data
********************************************************************************/

	use 				"${clean_data}\Health1970_area_final.dta", clear

/*******************************************************************************
 Generate summary statistics for area-level outcomes
********************************************************************************/
	
	foreach 		var of varlist $health_balance_vars_area {					// loop over area-level variables
		
		local 			vname_`var' : var label `var'							// store variable label
		
		reg				`var' [pw = ${W_70}]
				
		local 			mean_`var': display `fmt' e(b)[1,1]						// store mean
		local 			sdev_`var': display `fmt' e(V)[1,1]^0.5					// store standard deviation
		local 			obs_`var': display  e(N)								// store sample size
		
	*Regression military presence, no controls
		reg 			`var' ln_dist_mil_fac [pw = ${W_70}], `se_area'
		
		local			diff_`var': display `fmt' e(b)[1,1]						// store coefficient
		
		test			ln_dist_mil_fac
		if 				r(p) <= 0.001 {											// store significance stars
			 local 			star_`var' "\sym{***}"
		}
		else 			if r(p) <= 0.01 {
		     local 			star_`var' "\sym{**}"
		}
		else if 		r(p) <= 0.05 {
		     local 			star_`var' "\sym{*}"
		}
		else {
		     local 		star_`var' " "
		}
		local			pval_`var': display `fmt2' r(p) 						// store p-value
		
	*Refression military presence, with controls
		reg 		`var' ln_dist_mil_fac ///
						${controls} [pw = ${W_70}], `se_area'
		
		local			diffc_`var': display `fmt' e(b)[1,1]					// store coefficient
		
		test			ln_dist_mil_fac
		if 				r(p) <= 0.001 {											// store significance stars
			 local 			starc_`var' "\sym{***}"
		}
		else 			if r(p) <= 0.01 {
		     local 			starc_`var' "\sym{**}"
		}
		else if 		r(p) <= 0.05 {
		     local 			starc_`var' "\sym{*}"
		}
		else {
		     local 		starc_`var' " "
		}
		local			pvalc_`var': display `fmt2' r(p) 						// store p-value

	} // end of var
	
/*******************************************************************************
 Create and export table
********************************************************************************/

	capture 		file close balance_table

	file 			open balance_table using "${results}\Table2.tex", text write replace
	file 			write balance_table ///
	_n 				"\begin{tabular}{l*{7}{c}}" ///
	_n 				"\hline\hline" ///
	_n 				" & \multicolumn{3}{c}{(1)} & \multicolumn{2}{c}{(2)} & \multicolumn{2}{c}{(3)} \\" ///
	_n 				" & & & & \multicolumn{4}{c}{Ln(distance to military facility)} \\" ///
	_n 				" & \multicolumn{3}{c}{Full Sample} & \multicolumn{2}{c}{No Controls} & \multicolumn{2}{c}{Controls} \\" ///
	_n 				" & Mean & SD & Obs. & Coeff. & P-Value & Coeff. & P-Value \\" ///
	_n 				"\hline" ///
	_n 				"\multicolumn{8}{l}{\textbf{Panel A: county-level variables}} \\" ///
	_n				"\hline"
	
	use 			"${clean_data}\Health1970_county_final.dta", clear
	
	foreach 		var of varlist $health_balance_vars_county {				// loop over county-level variables
		
		file 			write balance_table ///
		_n 				"`vname_`var'' & `mean_`var'' & `sdev_`var'' & `obs_`var'' & `diff_`var'' & `pval_`var''`star_`var'' & `diffc_`var'' & `pvalc_`var''`starc_`var'' \\"	
						
	} // end of var
	
	file 			write balance_table ///
	_n				"\hline" ///
	_n 				"\multicolumn{8}{l}{\textbf{Panel B: area-level variables}} \\" ///
	_n				"\hline" 
	
	use 			"${clean_data}\Health1970_area_final.dta", clear
	
	foreach 		var of varlist $health_balance_vars_area {					// loop over area-level variables
		
		file 			write balance_table ///
						_n "`vname_`var'' & `mean_`var'' & `sdev_`var'' & `obs_`var'' & `diff_`var'' & `pval_`var''`star_`var'' & `diffc_`var'' & `pvalc_`var''`starc_`var'' \\"	
						
	} // end of var
	
	file 		    write balance_table ///
	_n 				"\hline\hline" ///
	_n 				"\multicolumn{8}{l}{\footnotesize \sym{*} \(p<.05\), \sym{**} \(p<.01\), \sym{***} \(p<.001\)}\\" ///
	_n 				"\multicolumn{8}{p{20cm}}{\footnotesize Note: Unit of observation: county in Panel A and area in Panel B. Column (1) reports the mean and standard deviation of each variable stated in the first column. Column (2) reports the OLS coefficients and corresponding p-value obtained when estimating each variable stated in the first column on the logarithmic distance to the closest military facility. Column (3) reports the OLS coefficients and corresponding p-values resulted from estimating each variable stated in the first column on the logarithmic distance to the closest military facility, controlling for population in 1970, urban share in 1970, logarithmic distance to Santiago and to the regional capital, and the vote shares obtained by Allende and Alessandri in the 1970 elections. Additionally, estimations in Panel A, column (3), include province fixed effects. Note that missing values in the control variables are imputed with the sample mean, and indicator variables for these cases are added as controls. P-values in columns (2) and (3) are estimated using Conley standard errors in Panel A, and heterokedasticity-robust standard errors in Panel B. Observations are weighted by the 1970 population size.}\\" ///
	_n 				"\end{tabular}" 
	file 			close balance_table

	
	