/*******************************************************************************
********************************************************************************
Purpose: 				Create Figure 3: Victims per Year
						
						Author: Leonor Castro
						Last Edited: 16 Sept 2023

Overview
	- Load sata and select sample
	- Create and export figure
	
*******************************************************************************
 Load data and select sample
********************************************************************************/

	use 			"${clean_data}\victimsbyyear.dta", clear

/*******************************************************************************
 Create and export figure
********************************************************************************/
	
	twoway 			connected Victims year, ///
						msymbol(i) xlabel(1973(3)1988) lcolor(black*0.7) ///
						ytitle("Number of Victims") xtitle("Year") ///
						mlabel(Victims) mlabposition(1) mlabsize(vsmall) mlabcolor(black*0.7) ///
						note("Note: This figure displays the annual count of killings or forced disappearances attributed to the military regime. Extracted from Bautista et al. (2021).", span size(vsmall))
						
	graph 			export "${results}\Figure3.png", replace
