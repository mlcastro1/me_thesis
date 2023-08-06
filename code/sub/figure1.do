use "$path\FinalDataset_Vaccination.dta", clear

forval y = 30/80 {
	if mod(`y', 5) {
		label def cohort_label `y' "`:di "`=uchar(28)'"'", add
	}
}
label value cohort cohort_label
graph box sh_vac_may23 if main_sample==1 [pw=$W], over(cohort) noout ytitle("Vaccination Rate") b1title("Cohorts") note("") ylabel(, nogrid) ascategory asyvars box(1, color(gs11)) box(2, color(gs11)) box(3, color(gs11)) box(4, color(gs11)) box(5, color(gs11)) box(6, color(gs11)) box(7, color(gs11)) box(8, color(gs11)) box(9, color(gs11)) box(10, color(gs11)) box(11, color(gs11)) box(12, color(gs11)) box(13, color(gs11)) box(14, color(gs11)) box(15, color(gs11)) box(16, color(gs11)) box(17, color(gs11)) box(18, color(gs11)) box(19, color(gs11)) box(20, color(gs11)) box(21, color(gs11)) box(22, color(gs11)) box(23, color(gs11)) box(24, color(gs11)) box(25, color(gs11)) box(26, color(gs11)) box(27, color(gs11)) box(28, color(gs11)) box(29, color(gs11)) box(30, color(gs11)) box(31, color(gs11)) box(32, color(gs11)) box(33, color(gs11)) box(34, color(gs8)) box(35, color(gs6)) box(36, color(gs4)) box(37, color(gs2)) box(38, color(gs2)) box(39, color(gs2)) box(40, color(gs2)) box(41, color(gs2)) box(42, color(gs4)) box(43, color(gs6)) box(44, color(gs8)) box(45, color(gs11)) box(46, color(gs11)) box(47, color(gs11)) box(48, color(gs11)) box(49, color(gs11)) box(50, color(gs11)) box(51, color(gs11)) 
graph export "Figure1.pdf", as(pdf) name("Graph") replace
