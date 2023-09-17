/*******************************************************************************
********************************************************************************
Purpose: 				Create Figure 1: Vaccination Rate per Cohort
						
						Author: Leonor Castro
						Last Edited: 15 Sept 2023

Overview
	- Load sata and select sample
	- Collapse data at cohort level and generate summary stats per cohort
	- Create variable to control colors in graph
	- Create and export figure
	
*******************************************************************************
 Load data and select sample
********************************************************************************/

	use 			"${clean_data}\finaldataset_main.dta", clear
	keep			if main_sample == 1

/*******************************************************************************
 Collapse data at cohort level and generate summary stats per cohort
********************************************************************************/

	collapse		(mean) sh_vac_may23_mean = sh_vac_may23 ///
						(sd) sh_vac_may23_sd = sh_vac_may23 [ fw = ${W} ], by(cohort)
					
	gen				sh_vac_may23_u = sh_vac_may23_mean + ( 1.96*sh_vac_may23_sd )
	gen				sh_vac_may23_l = sh_vac_may23_mean - ( 1.96*sh_vac_may23_sd )

/*******************************************************************************
 Create variable to control colors in graph
********************************************************************************/

	gen				color = .
	replace			color = 1 if cohort < 64 | cohort > 74
	replace			color = 2 if inlist(cohort,64,74)
	replace			color = 3 if inlist(cohort,65,73)
	replace			color = 4 if inlist(cohort,66,72)
	replace			color = 5 if inrange(cohort,65,71)

/*******************************************************************************
 Create and export figure
********************************************************************************/

	twoway 			(scatter sh_vac_may23_mean cohort if color == 1, ///
						msize(medium) mcolor(black*0.3)) ///
						(scatter sh_vac_may23_mean cohort if color == 2, ///
						msize(medium) mcolor(black*0.35)) ///
						(scatter sh_vac_may23_mean cohort if color == 3, ///
						msize(medium) mcolor(black*0.4)) ///
						(scatter sh_vac_may23_mean cohort if color == 4, ///
						msize(medium) mcolor(black*0.55)) ///
						(scatter sh_vac_may23_mean cohort if color == 5, ///
						msize(medium) mcolor(black*0.7)) ///
						(rcap sh_vac_may23_u sh_vac_may23_l cohort if color == 1, ///
						lc(black*0.3) lw(medthin)) ///
						(rcap sh_vac_may23_u sh_vac_may23_l cohort if color == 2, ///
						lc(black*0.35) lw(medthin)) ///
						(rcap sh_vac_may23_u sh_vac_may23_l cohort if color == 3, ///
						lc(black*0.4) lw(medthin)) ///
						(rcap sh_vac_may23_u sh_vac_may23_l cohort if color == 4, ///
						lc(black*0.55) lw(medthin)) ///
						(rcap sh_vac_may23_u sh_vac_may23_l cohort if color == 5, ///
						lc(black*0.7) lw(medthin)), ///
						yscale(r(0 1)) ylabel(, format(%2.1fc)) ///
						ytitle("Vaccination Rate") xtitle("Cohort") ///
						note("Note: This figure displays the mean vaccination rates for each cohort as of May 23, 2021, across counties, along with their 95% confidence intervals. Counties" "with aggregated vaccination rates exceeding one have been excluded from the analysis. Cohorts that experienced their impressionable years between 1973" "and 1976 are highlighted in darker colors.", span size(vsmall))
						
	graph 			export "${results}\Figure1.png", replace
