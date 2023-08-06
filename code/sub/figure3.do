use "$path\victimsbyyear.dta", clear
	
twoway connected Victims year, msymbol(i) xlabel(1973(3)1988) ytitle("Number of Victims") xtitle("Year") mlabel(Victims) mlabposition(1) mlabsize(vsmall)
graph export "Figure3.pdf", as(pdf) name("Graph") replace