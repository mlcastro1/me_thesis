/*******************************************************************************
********************************************************************************
********************************************************************************
Purpose: 				Create Figure 1: Mobility per Week
						
						Author: Leonor Castro
						Last Edited: 15 Sept 2023

Overview
	- Load sata and select sample
	- Collapse data at week level and generate summary stats per week
	- Create and export figure
	
*******************************************************************************
 Load data and select sample
********************************************************************************/

	use 			"${clean_data}\movilidad_final.dta", clear
	
/*******************************************************************************
 Clean date variable to be used as label in x axis
********************************************************************************/

	replace			fecha_inicio = subinstr(fecha_inicio,"-","/",.)
	encode			fecha_inicio, gen(date)
	
/*******************************************************************************
 Collapse data at week level and generate summary stats per week
********************************************************************************/

	collapse		(mean) var_salidas_mean = var_salidas ///
						(sd) var_salidas_sd = var_salidas [ fw = ${W} ], by(date)

	gen				var_salidas_u = var_salidas_mean + ( 1.96*var_salidas_sd )
	gen				var_salidas_l = var_salidas_mean - ( 1.96*var_salidas_sd )
	
/*******************************************************************************
 Create and export figure
********************************************************************************/

	twoway 			(scatter var_salidas_mean date, ///
						msize(small) mcolor(black*0.55)) ///
						(rcap var_salidas_u var_salidas_l date, ///
						lc(black*0.55) lw(medthin)), ///
						ylabel(, format(%2.1fc)) ///
						xscale(r(0 82) titlegap(8pt)) xlabel(1 20 40 60 80, valuelabel labsize(small)) ///
						ytitle("Mobility") xtitle("Week") ///
						note("Note: This figure displays the mean of the mobility measure across counties for each week spanning from March 2020 to September 2021, along with their" "95% confidence interval.", span size(vsmall))
						
	graph 			export "${results}\Figure2.png", replace
