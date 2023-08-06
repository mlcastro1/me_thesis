use "$path\movilidad_final.dta", clear

foreach strep_var in $strep_vars {
	acreg var_salidas `strep_var'_f1_impy2 `strep_var'_f1 f1_impy2 fase_1 i.semana i.code if semana>10 [pw=$W], $se_vac 
	eststo
}
esttab using Table5v2.tex, b(%9.4f) se(%9.4f) drop(*_f1 f1_impy2 fase_1 *.semana *.code) se rename(shVictims_70_10_f1_impy2 strep_f1_impy2 DVictims_f1_impy2 strep_f1_impy2 DCentroDetencion_f1_impy2 strep_f1_impy2 ln_centro_det_f1_impy2 strep_f1_impy2 ln_dist_mil_fac_f1_impy2 strep_f1_impy2) coeflabels(strep_f1_impy2 "State repression $\times$ Imp. Years (1973-1976) $\times$ Lockdown") replace
eststo clear 