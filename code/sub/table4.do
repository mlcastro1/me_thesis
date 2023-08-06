use "$path\FinalDataset_Vaccination.dta", clear

foreach strep_var in $strep_vars {
	acreg sh_vac_may23 `strep_var'_impy2 i.cohort i.code if main_sample==1 [pw=$W], $se_vac
	eststo
}
esttab using Table4.tex, b(%9.4f) se(%9.4f) drop(*.cohort *.code _cons) se rename(shVictims_70_10_impy2 strep_impy2 DVictims_impy2 strep_impy2 DCentroDetencion_impy2 strep_impy2 ln_centro_det_impy2 strep_impy2 ln_dist_mil_fac_impy2 strep_impy2)  coeflabels(strep_impy2 "State repression $\times$ Imp. Years (1973-1976)") replace
eststo clear 
