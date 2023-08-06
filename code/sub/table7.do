clear
use "$path\movilidad_final.dta"

acreg var_salidas ln_dist_mil_fac_impy2cp ln_dist_mil_fac_cp impy2_cp i.semana i.code i.paso [pw=$W] if semana>10 & semana<34, $se_vac 
eststo
acreg var_salidas ln_dist_mil_fac_impy2cp1 ln_dist_mil_fac_impy2cp2 ln_dist_mil_fac_cp1 ln_dist_mil_fac_cp2 impy2_cp1 impy2_cp2 i.semana i.code i.paso [pw=$W] if semana>10 & semana<34, $se_vac 
eststo
esttab using Table7v2.tex, b(%9.4f) se(%9.4f) keep(ln_dist_mil_fac_impy2cp ln_dist_mil_fac_impy2cp1 ln_dist_mil_fac_impy2cp2 ) nocons se label replace
eststo clear