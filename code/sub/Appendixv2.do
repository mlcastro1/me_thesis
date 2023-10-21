*****************************************************
*****************************************************
*State Repression and Vaccination: Robustness Checks*
*****************************************************
*****************************************************
clear all

set scheme s1mono   
graph set window fontface "Times New Roman"

*Establish path where DB are stored
global path "C:\Users\56962\Dropbox\Tesis\Vaccination and State Repression\Data"

*Establish path where results will be stored
cd "C:\Users\56962\Dropbox\Tesis\Vaccination and State Repression\Estimations\Appendix"

global strep_vars shVictims_70_10 DVictims DCentroDetencion ln_centro_det ln_dist_mil_fac
global controls Pop70 sh_rural_70 lnDistStgo lnDistRegCapital share_allende70 share_alessandri70
global W p_proj
global se spatial latitude(latitud) longitude(longitud) distcutoff(75)
global N 1000

********************************************************************************
*Figure A1: Randomization
********************************************************************************
use "$path\FinalDataset_Vaccination.dta", clear

forvalues i=1/$N {
	shufflevar ln_dist_mil_fac
	gen ln_dist_mil_fac_impy2_placebo=ln_dist_mil_fac_shuffled*impy2
	qui: reg sh_vac_may23 ln_dist_mil_fac_impy2_placebo i.cohort i.code if main_sample==1 [pw=$W], r
	gen b_ln_dist_mil_fac_placebo=_b[ln_dist_mil_fac_impy2_placebo]
	
	gen Draw=`i'
	preserve
		keep Draw b_ln_dist_mil_fac_placebo
		duplicates drop
		save "placebos_ln_dist_mil_fac_`i'.dta", replace
	restore
	drop ln_dist_mil_fac_impy2_placebo Draw b_ln_dist_mil_fac_placebo
}

use "placebos_ln_dist_mil_fac_1.dta", clear
forvalues i=2(1)$N {
	append using "placebos_ln_dist_mil_fac_`i'.dta"
}
save "placebos_ln_dist_mil_fac_final.dta", replace
kdensity b_ln_dist_mil_fac_placebo, xline(0.0039, lc(black) lp(dash)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) lcolor(black) legend(off) title("") xtitle("Ln distance to military facility coefficient") xscale(range(-0.0004 0.0015)) xlab(-0.0012(0.0005)0.004) note("")
graph export "FigureA1.pdf", as(pdf) name("Graph") replace

use "$path\movilidad_final.dta", clear
forvalues i=1/$N {
	shufflevar ln_dist_mil_fac
	gen ln_dist_mil_fac_f1_impy2_placebo=ln_dist_mil_fac_shuffled*fase_1*impy2_county
	gen ln_dist_mil_fac_f1_placebo=ln_dist_mil_fac_shuffled*fase_1
	qui: reg var_salidas ln_dist_mil_fac_f1_impy2_placebo ln_dist_mil_fac_f1_placebo f1_impy2 fase_1 i.semana i.code if semana>10 [pw=$W]
	gen b_ln_dist_mil_fac_placebo=_b[ln_dist_mil_fac_f1_impy2_placebo]
	
	gen Draw=`i'
	preserve
		keep Draw b_ln_dist_mil_fac_placebo
		duplicates drop
		save "placebos_ln_dist_mil_fac_`i'.dta", replace
	restore
	drop ln_dist_mil_fac_f1_impy2_placebo ln_dist_mil_fac_f1_placebo Draw b_ln_dist_mil_fac_placebo
}

clear
use "placebos_ln_dist_mil_fac_1.dta"
forvalues i=2(1)$N {
	append using "placebos_ln_dist_mil_fac_`i'.dta"
}
save "placebos_ln_dist_mil_fac_final.dta", replace
kdensity b_ln_dist_mil_fac_placebo, xline(0.0393, lc(black) lp(dash)) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) plotregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) lcolor(black) legend(off) title("") xtitle("Ln distance to military facility coefficient") note("")
graph export "FigureA2v2.pdf", as(pdf) name("Graph") replace

********************************************************************************
*Table A1, A2 & A3, Figure A2: other impressionable years and military presence indicators, other vaccination measure
********************************************************************************
use "${data_clean}\finaldataset_main.dta", clear
/*
preserve
	collapse (mean) sh_vac_may23 sh_vac_ontime4 if main_sample==1 [pw=$W], by(cohort)
	twoway connected sh_vac_may23 sh_vac_ontime4 cohort, yline(1) msymbol(i i) xtitle("Cohort") ytitle("Vaccination Rate") legend(label(1 "Vaccination rate at May 23")) legend(label(2 "On-time vaccination rate"))
	graph export "FigureA4.pdf", as(pdf) name("Graph") replace
restore

use "$path\FinalDataset_Vaccination.dta", clear
foreach strep_var in $strep_vars {
	acreg sh_vac_ontime4 `strep_var'_impy2 i.cohort i.code if main_sample==1 [pw=$W], $se
	eststo
}
esttab using TableA1.tex, b(%9.4f) se(%9.4f) drop(*.cohort *.code _cons) se rename(shVictims_70_10_impy2 strep_impy2 DVictims_impy2 strep_impy2 CentroDetencion_impy2 strep_impy2 ln_dist_mil_fac_impy2 strep_impy2) coeflabels(strep_impy2 "State repression $\times$ Imp. Years (1973-1976)")  replace
eststo clear 
*/
foreach strep_var in $strep_vars {
	acreg sh_vac_may23 `strep_var'_impy1 i.cohort i.code if main_sample==1 [pw=$W], $se
	eststo
}
esttab using TableA2.tex, b(%9.4f) se(%9.4f) drop(*.cohort *.code _cons) se rename(shVictims_70_10_impy1 strep_impy1 DVictims_impy1 strep_impy1 CentroDetencion_impy1 strep_impy1 ln_dist_mil_fac_impy1 strep_impy1) coeflabels(strep_impy1 "State repression $\times$ Imp. Years (1973-1976)") replace
eststo clear 
/*
use "$path\movilidad_final.dta", clear
foreach strep_var in $strep_vars {
	acreg var_salidas `strep_var'_f1_impy1 `strep_var'_f1 f1_impy1 fase_1 i.semana i.code if semana>10 [pw=$W], $se 
	eststo
}
esttab using TableA3v2.tex, b(%9.4f) se(%9.4f) drop(*_f1 f1_impy1 fase_1 *.semana *.code) se rename(shVictims_70_10_f1_impy1 strep_f1_impy1 DVictims_f1_impy1 strep_f1_impy1 DCentroDetencion_f1_impy1 strep_f1_impy1 ln_centro_det_f1_impy1 strep_f1_impy1 ln_dist_mil_fac_f1_impy1 strep_f1_impy1) coeflabels(strep_f1_impy1 "State repression $\times$ Imp. Years (1973-1976) $\times$ Lockdown") replace
eststo clear 

use "$path\FinalDataset_Vaccination.dta", clear
acreg sh_vac_may23 Dregimientos_impy2 i.cohort i.code if main_sample==1 [pw=$W], $se
eststo
use "$path\movilidad_final.dta", clear
acreg var_salidas Dregimientos_f1_impy2 Dregimientos_f1 f1_impy1 fase_1 i.semana i.code if semana>10 [pw=$W], $se 
eststo
esttab using TableA4v2.tex, b(%9.4f) se(%9.4f) keep(Dregimientos_impy2 Dregimientos_f1_impy2) se coeflabels(Dregimientos_impy2 "Indicator mil. presence $\times$ Imp. Years (1973-1976)" Dregimientos_f1_impy2 "Indicator mil. presence $\times$ Imp. Years (1973-1976) $\times$ Lockdown") replace
eststo clear 

********************************************************************************
*Table A6 & A7: full sampel & dfbeta
********************************************************************************
use "$path\FinalDataset_Vaccination.dta", clear
foreach strep_var in $strep_vars {
	acreg sh_vac_may23 `strep_var'_impy2 i.cohort i.code if cohort>30 [pw=$W], $se
	eststo
}
esttab using TableA6.tex, b(%9.4f) se(%9.4f) drop(*.cohort *.code _cons) se rename(shVictims_70_10_impy2 strep_impy2 DVictims_impy2 strep_impy2 DCentroDetencion_impy2 strep_impy2 ln_centro_det_impy2 strep_impy2 ln_dist_mil_fac_impy2 strep_impy2)  coeflabels(strep_impy2 "State repression $\times$ Imp. Years (1973-1976)") replace
eststo clear 

preserve
	keep if cohort>30

	reg sh_vac_may23 ln_dist_mil_fac_impy2 i.cohort i.code 
	dfbeta(ln_dist_mil_fac_impy2)

	drop if abs(_dfbeta_1) > 2/sqrt(16533)
	foreach strep_var in $strep_vars {
		acreg sh_vac_may23 `strep_var'_impy2 i.cohort i.code [pw=$W], $se
		eststo
	}
restore
esttab using TableA7.tex, b(%9.4f) se(%9.4f) drop(*.cohort *.code _cons) se rename(shVictims_70_10_impy2 strep_impy2 DVictims_impy2 strep_impy2 DCentroDetencion_impy2 strep_impy2 ln_centro_det_impy2 strep_impy2 ln_dist_mil_fac_impy2 strep_impy2)  coeflabels(strep_impy2 "State repression $\times$ Imp. Years (1973-1976)") replace
eststo clear 

********************************************************************************
*Table A9: Conley s.e. (different thresholds)
********************************************************************************
use "$path\FinalDataset_Vaccination.dta", clear
forval i=25(25)150 {
	foreach strep_var in $strep_vars {
		acreg sh_vac_may23 `strep_var'_impy2 i.cohort i.code if main_sample==1 [pw=$W], spatial latitude(latitud) longitude(longitud) distcutoff(`i')
		eststo
	}
	esttab using TableA9.tex, b(%9.4f) se(%9.4f) drop(*.cohort *.code _cons) se rename(shVictims_70_10_impy2 strep_impy2 DVictims_impy2 strep_impy2 DCentroDetencion_impy2 strep_impy2 ln_centro_det_impy2 strep_impy2 ln_dist_mil_fac_impy2 strep_impy2)  coeflabels(strep_impy2 "State repression $\times$ Imp. Years (1973-1976)") append
	eststo clear
}

use "$path\movilidad_final.dta", clear
forval i=25(25)150 {
	foreach strep_var in $strep_vars {
		acreg var_salidas `strep_var'_f1_impy2 `strep_var'_f1 f1_impy2 fase_1 i.semana i.code if semana>10 [pw=$W],  spatial latitude(latitud) longitude(longitud) distcutoff(`i')
		eststo
	}
	esttab using TableA10v2.tex, b(%9.4f) se(%9.4f) drop(*_f1 f1_impy2 fase_1 *.semana *.code) se rename(shVictims_70_10_f1_impy2 strep_f1_impy2 DVictims_f1_impy2 strep_f1_impy2 DCentroDetencion_f1_impy2 strep_f1_impy2 ln_centro_det_f1_impy2 strep_f1_impy2 ln_dist_mil_fac_f1_impy2 strep_f1_impy2) coeflabels(strep_f1_impy2 "State repression $\times$ Imp. Years (1973-1976) $\times$ Lockdown") append
	eststo clear
}

