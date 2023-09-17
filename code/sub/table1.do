/*******************************************************************************
********************************************************************************
Purpose: 				Create Table 1: Military Presence and Pre-Dictatorship 
						County Characteristics
						
						Author: Leonor Castro
						Last Edited: 15 Sept 2023

Overview
	- Load sata and select sample
	- Generate summary statistics
	- Create and export table
	
*******************************************************************************
 Load data and select sample
********************************************************************************/

	use 			"${clean_data}\finaldataset_main.dta", clear

/*******************************************************************************
 Clean remaining variable labels
********************************************************************************/

	label			var Pop70_pthousands "Population (in 100,000s)"
	label			var sh_rural_70 "Share rural"
	label			var lnDistStgo "Ln(Distance to Santiago)"
	label			var lnDistRegCapital "Ln(Distance to regional capital)"
	label			var share_allende70 "Vote share Allende"
	label			var share_alessandri70 "Vote share Alessandri"
	label			var Turnout70 "Turnout"
	label			var SocialOrg_pop70 "Community organizations"
	label			var churches_pop70 "Churches per capita"
	label			var sh_educ_12more "Share with 12+ years of education"
	label			var densidad_1970 "Population density"
	label			var sh_econactivepop_70 "Share economically active"
	label			var sh_women_70 "Share female"
	label			var TV "Share own TV (1987)"
	label			var ari_1973 "Agr. land share expropriated before 1973"
	label			var index1b "Exposure to trade liberalization"
	
/*******************************************************************************
 Set locals with specification details
********************************************************************************/
	
	local			controls Pop70_pthousands sh_rural_70 lnDistStgo ///
						lnDistRegCapital share_allende70 share_alessandri70		// change Pop70 for Pop70_pthousands
	local			weights [pw=Pop70]
	local			fmt "%9.3f"
	local			fmt2 "%5.3f"
	
/*******************************************************************************
 Generate summary statistics
********************************************************************************/

	foreach 		var of varlist `controls' {									// loop over control variables
		
		local 			vname_`var' : var label `var'							// store variable label
		
		reg				`var' `weights'
				
		local 			mean_`var': display `fmt' e(b)[1,1]						// store mean
		local 			sdev_`var': display `fmt' e(V)[1,1]^0.5					// store standard deviation
		local 			obs_`var': display  e(N)								// store sample size
		
	*Regression military presence, no controls
		acreg 			`var' ln_dist_mil_fac `weights', ${conley_se}
		
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

	} // end of var
	
	
	foreach 		var of varlist $balance_vars {								// loop over additional balance variables
		
		local 			vname_`var' : var label `var'							// store variable label
		
		reg				`var' `weights'
				
		local 			mean_`var': display `fmt' e(b)[1,1]						// store mean
		local 			sdev_`var': display `fmt' e(V)[1,1]^0.5					// store standard deviation
		local 			obs_`var': display  e(N)								// store sample size
		
	*Regression military presence, no controls
		acreg 			`var' ln_dist_mil_fac `weights', ${conley_se}
		
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
						${controls} i.IDProv `weights', ${conley_se}
		
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

	file 			open balance_table using "${results}\Table1.tex", text write replace
	file 			write balance_table ///
	_n 				"\begin{tabular}{l*{7}{c}}" ///
	_n 				"\hline\hline" ///
	_n 				" & \multicolumn{3}{c}{(1)} & \multicolumn{2}{c}{(2)} & \multicolumn{2}{c}{(3)} \\" ///
	_n 				" & & & & \multicolumn{4}{c}{Ln(distance to military facility)} \\" ///
	_n 				" & \multicolumn{3}{c}{Full Sample} & \multicolumn{2}{c}{No Controls} & \multicolumn{2}{c}{Controls} \\" ///
	_n 				" & Mean & SD & Obs. & Coeff. & P-Value & Coeff. & P-Value \\" ///
	_n 				"\hline" 
	
	foreach 		var of varlist `controls' $balance_vars {					// loop over controls and additional balance variables
		
		file 			write balance_table ///
		_n 				"`vname_`var'' & `mean_`var'' & `sdev_`var'' & `obs_`var'' & `diff_`var'' & `pval_`var''`star_`var'' & `diffc_`var'' & `pvalc_`var''`starc_`var'' \\"	
						
	} // end of var
	
	file 		    write balance_table ///
	_n 				"\hline\hline" ///
	_n 				"\multicolumn{8}{l}{\footnotesize \sym{*} \(p<.0.05\), \sym{**} \(p<.01\), \sym{***} \(p<.001\)}\\" ///
	_n 				"\multicolumn{8}{p{17cm}}{\footnotesize Note: Column (1) reports mean and standard deviation of each variable stated in the first column. Column (2) reports the OLS coefficients estimates of military presence over each variable stated in the first column, by using the logarithmic distance to the closest military facility as independent variable, and corresponding p-value. Column (3) reports the OLS coefficients and corresponding p-values including province fixed effects, population in 1970, urban share in 1970, logarithmic distance to Santiago and to the regional capital, and the vote shares obtained by Allende and Alessandri in the 1970 elections as control variables. Observations are weighted by 1970 county population size. Conley standard errors in parentheses.}\\" ///
	_n 				"\end{tabular}" 
	file 			close balance_table
