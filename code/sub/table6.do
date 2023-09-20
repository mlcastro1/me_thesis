/*******************************************************************************
********************************************************************************
Purpose: 				Create Table 6: State Repression, Impressionable Years 
						and Mistrust: Latinobarometro
						
						Author: Leonor Castro
						Last Edited: 16 Sept 2023

Overview:
	- Load county-level data
	- Label variables
	- Run regressions 
	- Estimate q-values
	- Add q-values to stored estimations
	- Create and export table
	
Additional notes:
	- This code generates BKY (2006) sharpened two-stage q-values as described in 
	Anderson (2008), "Multiple Inference and Gender Differences in the Effects of 
	Early Intervention: A Reevaluation of the Abecedarian, Perry Preschool, and 
	Early Training Projects", Journal of the American Statistical Association, 
	103(484), 1481-1495
	- BKY (2006) sharpened two-stage q-values are introduced in Benjamini, 
	Krieger, and Yekutieli (2006), "Adaptive Linear Step-up Procedures that 
	Control the False Discovery Rate", Biometrika, 93(3), 491-507

*******************************************************************************
 Load county-level data
********************************************************************************/

	use 				"${data_clean}\latinobarometro_final.dta", clear

/*******************************************************************************
 Create remaining variables specific to this dofile
********************************************************************************/

	gen					ln_dist_mil_fac_impy2 = impy2*ln_dist_mil_fac

	foreach 			var of varlist $latinob_vars {							// loop over outcomes
		
		egen 				z_`var'_v2 = std(`var'_v2)							// standardize version of outcomes
	
	} // end of var

/*******************************************************************************
 Label variables
********************************************************************************/
     
	label var			z_sp21_v2 "Interpersonal"
	label var 			z_sp63a_v2 "Church"
	label var 			z_sp63b_v2 "Armed Forces"
	label var 			z_sp63d_v2 "President"
	label var 			z_sp63e_v2 "Police"
	label var 			z_sp63g_v2 "Pol. Parties"
	label var 			z_P20ST_I_v2  "State" 
	label var 			z_P16ST_G_v2 "Natl. Gov." 
	label var 			z_p63stc_v2 "Local Gov."
	label var 			ln_dist_mil_fac "\specialcell{Ln(dist. to military facility) \twoback $\times$ Imp. \twoback Years (1973-1976)}"

/*******************************************************************************
 Run regressions
********************************************************************************/

	foreach 			var of varlist $latinob_vars {							// loop over outcomes
	
		acreg 				z_`var'_v2 ln_dist_mil_fac_impy2 ///
								i.cohort i.code i.numinves s1 ///
								if cohort>30 [pw = wt], ${conley_se}
		eststo				`var'
		
		qui: test			ln_dist_mil_fac_impy2
		local 				`var'_pv = `r(p)'									// store p-value to then estimate q-values
		
		distinct			code if e(sample)
		estadd				scalar N_counties = `r(ndistinct)'
		sum					z_`var'_v2 if e(sample) 
		estadd				scalar ymean = `r(mean)'
		sum					ln_dist_mil_fac if e(sample)
		estadd				scalar xmean = `r(mean)'
		
	} // end of var

/*******************************************************************************
 Estimate q-values
********************************************************************************/

	preserve
		clear
		set 			obs 9
		gen 			pval = .
		replace 		pval = `sp21_pv' in 1
		replace 		pval = `sp63a_pv' in 2
		replace 		pval = `sp63b_pv' in 3
		replace 		pval = `sp63d_pv' in 4
		replace 		pval = `sp63e_pv' in 5
		replace 		pval = `sp63g_pv' in 6
		replace 		pval = `P20ST_I_pv' in 7
		replace 		pval = `P16ST_G_pv' in 8
		replace 		pval = `p63stc_pv' in 9

		* Collect the total number of p-values tested
		qui: sum 		pval
		local 			totalpvals = `r(N)'

		* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
		qui:			gen int original_sorting_order = _n
		qui:			sort pval
		qui:			gen int rank = _n if pval~=.

		* Set the initial counter to 1 
		local 			qval = 1

		* Generate the variable that will contain the BKY (2006) sharpened q-values
		gen 			bky06_qval = 1 if pval~=.

		* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.
		while 			`qval' > 0 {
			
		* First Stage
			* Generate the adjusted first stage q level we are testing: q' = q/1+q
			local 			qval_adj = `qval'/(1+`qval')
			* Generate value q'*r/M
			gen 			fdr_temp1 = `qval_adj'*rank/`totalpvals'
			* Generate binary variable checking condition p(r) <= q'*r/M
			gen 			reject_temp1 = (fdr_temp1>=pval) if pval~=.
			* Generate variable containing p-value ranks for all p-values that meet above condition
			gen 			reject_rank1 = reject_temp1*rank
			* Record the rank of the largest p-value that meets above condition
			egen 			total_rejected1 = max(reject_rank1)

		* Second Stage
			* Generate the second stage q level that accounts for hypotheses rejected in first stage: q_2st = q'*(M/m0)
			local 			qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
			* Generate value q_2st*r/M
			gen 			fdr_temp2 = `qval_2st'*rank/`totalpvals'
			* Generate binary variable checking condition p(r) <= q_2st*r/M
			gen 			reject_temp2 = (fdr_temp2>=pval) if pval~=.
			* Generate variable containing p-value ranks for all p-values that meet above condition
			gen 			reject_rank2 = reject_temp2*rank
			* Record the rank of the largest p-value that meets above condition
			egen 			total_rejected2 = max(reject_rank2)

			* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
			replace 		bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
			* Reduce q by 0.001 and repeat loop
			drop 			fdr_temp* reject_temp* reject_rank* total_rejected*
			local 			qval = `qval' - .001
			
		} // `qval' <= 0
		
		qui: 			sort original_sorting_order

		local 			sp21_apv = bky06_qval[1]
		local 			sp63a_apv = bky06_qval[2] 
		local 			sp63b_apv = bky06_qval[3]
		local 			sp63d_apv = bky06_qval[4]
		local 			sp63e_apv = bky06_qval[5]
		local 			sp63g_apv = bky06_qval[6]
		local 			P20ST_I_apv = bky06_qval[7] 
		local 			P16ST_G_apv = bky06_qval[8] 
		local 			p63stc_apv = bky06_qval[9]

	restore
	
/*******************************************************************************
 Add q-values to stored estimations
********************************************************************************/

	foreach 		var of varlist $latinob_vars {								// loop over etsimations
		
		estadd 			scalar adjusted_pv ``var'_apv': `var'
		
	} // end of var
	
/*******************************************************************************
 Create and export table
********************************************************************************/

	esttab			using "${results}/Table6.tex", ///
						replace nocons b(4) se(4) label nonotes ///	
						keep(ln_dist_mil_fac_impy2) ///
						star(* .05 ** .01 *** .001) ///
						prehead("\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \\ \begin{tabular}{l*{9}{c}} \\ \hline\hline &\multicolumn{9}{c}{Mistrust in} \\") ///
						stats( N N_counties ymean xmean adjusted_pv, ///
						labels("\# observations" "\# counties" "Mean outcome" "Mean state repression measure" "Adjusted p-values") ///
						fmt(%4.0f %4.0f %9.4f %9.4f %9.4f)) ///
						postfoot("\hline\hline \multicolumn{@span}{p{25cm}}{\footnotesize @note}\\ \end{tabular} } % Generated on $S_DATE at $S_TIME.") ///
						note(* p$<$0.05, ** p$<$0.01, *** p$<$0.001. Note: Unit of observation: respondent. This table reports OLS coefficient estimates of military presence before 1973 over self-reported trust on different institutions, by estimating equation (\ref{eq:3}), which includes county, cohort, and survey-year fixed-effects. Outcomes correspond to standardize versions of constructed mistrust indicators, where 1 indicates no trust and 0 at least some level of trust. All estimations use the number of years between ages 18 and 25 lived between 1973 and 1976 as impressionable years indicators and use the logarithmic distance to the closest military facility as a proxy for state repression. Conley standard errors in parentheses. Last row reports the corresponding adjusted for multiple hypothesis testing p-values, following Westfall and Young (1993), are reported in brackets.) 
						