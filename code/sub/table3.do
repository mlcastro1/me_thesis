use "$path\FinalDataset_Vaccination_collapsed.dta", clear

foreach strep_var in shVictims_70_10 DVictims DCentroDetencion ln_centro_det {
	acreg `strep_var' ln_dist_mil_fac [pw=Pop70] if latitud!=., $se_vac
	eststo
	acreg `strep_var' ln_dist_mil_fac $controls i.IDProv [pw=Pop70], $se_vac
	eststo
}
esttab using Table3.tex, b(%9.4f) se(%9.2f) nocons keep(ln_dist_mil_fac) indicate(Controls = $controls) label replace
eststo clear 