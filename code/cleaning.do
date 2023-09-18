/*******************************************************************************
********************************************************************************
Purpose: 				Prepare data for analysis
						
						Author: Leonor Castro
						Last Edited: 14 Jan 2023

Overview
	1. Data on the number of vaccinated people per date and cohort 
		- with first shot
		- with unique shot
		- combine both data
	2. Data on the number of vaccination centers per county
	3. Data on population projections for 2020
	4. Data on the "Plan Paso a Paso" and lockdowns
	5. Numer of fatalities per day and county 
	6. Numer of fatalities per cohort, day, and county 
	7. Number of COVID cases per day and county
	8. Mobility data
	9. Data on the 2020 influenza vaccination campaign
	10. Legal entities registration
	11. Turnout
		- 2017
		- 2020
	12. Survey data from Latinobarometro (1995-2018)
	13. Final Main Dataset
	14. Final Secondary Datasets
		- Latinobarometro
		- 1970 Health Statistics (county level)
		- 1970 Health Statistics (area level)
		- Mobility
		- Fatalities
 
*******************************************************************************
 1. Data on the number of vaccinated people per date and cohort 
 Extracted from: https://github.com/MinCiencia/Datos-COVID19 (product 81)
********************************************************************************/

	clear 			all 
	
	local 			list_dates_1 mar2 mar3 mar4 mar5 mar6 mar7 mar8 mar9 mar10 ///
						mar11 mar12 mar13 mar14 mar15 mar16 mar17 mar18 mar19 mar20 ///
						mar21 mar22 mar23 mar24 mar25 mar26 mar27 mar28 mar29 mar30 ///
						mar31 abr1 abr2 abr3 abr4 abr5 abr6 abr7 abr9 abr10 abr11 ///
						abr12 abr13 abr14 abr16 abr17 abr19 abr20 abr21 abr22 abr24 ///
						abr25 abr27 abr28 abr29 may1 may3 may4 may5 may7 may8 may9 ///
						may11 may12 may13 may14 may15 may16 may18 may19 may20 may21 ///
						may22 may23 may24 may26 may28 may31 jun1 jun2 jun4 jun5 jun6 ///
						jun7 jun8 jun9 jun10 jun11 jun12 jun13 jun14 jun15 jun16 ///
						jun17 jun19 jun22 jun23 jun24 jun25 jun26 jun27 jun29 jun30 ///
						jul1 jul2 jul3 jul5 jul6 jul7 jul8 jul9 jul10 jul11 jul12 ///
						jul14 jul17 jul19 jul20 jul23 jul25 jul26 jul29 jul30 ago1 ///
						ago2 ago4 ago10 ago12
						
	local 			list_dates_u jun12 jun13 jun14 jun15 jun16 jun17 jun19 jun22 ///
						jun23 jun24 jun25 jun26 jun27 jun29 jun30 jul1 jul2 jul3 ///
						jul5 jul6 jul7 jul8 jul9 jul10 jul11 jul12 jul14 jul17 ///
						jul19 jul20 jul23 jul25 jul26 jul29 jul30 ago1 ago2 ago4 ///
						ago10 ago12

* FIRST SHOT
* For each DB (corresponding to each date where data on covid vaccination has been updated)

	foreach 			date of local list_dates_1 {							// loop over dates
	
		import 				delimited "${data_raw}\vaccination\vacunacion_comuna_edad_1eraDosis_`date'.txt", clear
		
	*Correct variable names
		forvalues 			i = 15/80 {											// loop over age
			local 				j = `i' - 9
			cap rename 			v`j' vac1_acc_`date'`i'
		} // end of i
		
		rename 				codigocomuna code 
		*Drop observations from unknown counties
		drop 				if code==.
		*The data is reshaped so every observation corresponds to a county, cohort
		reshape 			long vac1_acc_`date' , i(code comuna) j(cohort)
		*Variable labels 
		label var 			vac1_acc_`date' "Population vaccinated with first dose at `date' (DEIS)"
		*Save each dataset
		keep 				code cohort vac1_* comuna
		save 				"${data_clean}\vacunacion_comuna_edad_1eraDosis_`date'.dta", replace
		
	}	// end of date
	
* Merge datasets
	use 				"${data_clean}\vacunacion_comuna_edad_1eraDosis_mar2.dta"
	
	foreach 			date of local list_dates_1 {							// loop over dates
	
		if				"`date'" != "mar2" {
			merge 				1:1 code cohort using ///
									"${data_clean}\vacunacion_comuna_edad_1eraDosis_`date'.dta", ///
									nogen
			erase				"${data_clean}\vacunacion_comuna_edad_1eraDosis_`date'.dta"
			
		}
	} // end of date
	
	save 				"${data_clean}\vacunacion_comuna_edad_1eraDosis.dta", replace
	erase				"${data_clean}\vacunacion_comuna_edad_1eraDosis_mar2.dta"

* UNIQUE SHOT
* For each DB (corresponding to each date where data on covid vaccination has been updated)

	foreach 			date of local list_dates_u {							// loop over dates
	
		import 				delimited "${data_raw}\vaccination\vacunacion_comuna_edad_UnicaDosis_`date'.txt", clear
		*Correct variable names 
		forvalues 			i = 15/80 {
			local 				j = `i' - 9
			cap rename 			v`j' vacu_acc_`date'`i'
		}
		
		rename 				codigocomuna code 
		*Drop observations from unknown counties
		drop 			if code==.
		*The data is reshaped so every observation corresponds to a county, cohort
		reshape 		long vacu_acc_`date' , i(code comuna) j(cohort)
		*Variable labels
		label var 		vacu_acc_`date' "Population vaccinated with unique dose at `date' (DEIS)"
		*Save each dataset
		keep 			code cohort vacu_* comuna
		save 			"${data_clean}\vacunacion_comuna_edad_UnicaDosis_`date'.dta", replace
		clear
		
	} // end of date

* Merge datasets
	use 				"${data_clean}\vacunacion_comuna_edad_UnicaDosis_jun12.dta"
	
	foreach 			date of local list_dates_u {							// loop over dates
	
		if					"`date'" != "jun12" {
			merge 			1:1 code cohort using "${data_clean}\vacunacion_comuna_edad_UnicaDosis_`date'.dta", nogen
			erase				"${data_clean}\vacunacion_comuna_edad_UnicaDosis_`date'.dta"
			}
	} // end of date

	save 				"${data_clean}\vacunacion_comuna_edad_UnicaDosis.dta", replace
	erase				"${data_clean}\vacunacion_comuna_edad_UnicaDosis_jun12.dta"

* COMBINE DATA FOR FIRST AND UNIQUE SHOTS

	use 				"${data_clean}\vacunacion_comuna_edad_1eraDosis.dta", clear
	merge 				1:1 code cohort comuna using ///
							"${data_clean}\vacunacion_comuna_edad_UnicaDosis.dta", nogen

	foreach 			date of local list_dates_u {							// loop over dates
		egen 				vac_acc_`date' = rowtotal(vac1_acc_`date' vacu_acc_`date')
	} // end of date
	
	foreach 			date of local list_dates_1 {							// loop over dates
		cap	clonevar		vac_acc_`date' = vac1_acc_`date'
		cap drop 			vac1_acc_`date' vacu_acc_`date'
		label var 			vac_acc_`date' ///
								"Population vaccinated with 1st or unique dose at `date' (DEIS)"
	} // end of date

*Variables of the number of pleople vaccinated on time are created
	gen 				vac_ontime4 = .
	replace 			vac_ontime4 = vac_acc_mar2 if inlist(cohort, 80, 79, 78)
	replace 			vac_ontime4 = vac_acc_mar3 if inlist(cohort, 77, 76, 75)
	replace 			vac_ontime4 = vac_acc_mar4 if inlist(cohort, 74, 73)
	replace 			vac_ontime4 = vac_acc_mar5 if inlist(cohort, 72, 71)
	replace 			vac_ontime4 = vac_acc_mar8 if inlist(cohort, 70, 69)
	replace 			vac_ontime4 = vac_acc_mar7 if cohort == 68
	replace 			vac_ontime4 = vac_acc_mar10 if cohort == 67
	replace 			vac_ontime4 = vac_acc_mar11 if cohort == 66
	replace 			vac_ontime4 = vac_acc_mar12 if cohort == 65
	replace 			vac_ontime4 = vac_acc_mar22 if cohort == 64
	replace 			vac_ontime4 = vac_acc_mar23 if cohort == 63
	replace 			vac_ontime4 = vac_acc_mar24 if cohort == 62
	replace 			vac_ontime4 = vac_acc_mar25 if cohort == 61
	replace 			vac_ontime4 = vac_acc_mar26 if cohort == 60
	replace 			vac_ontime4 = vac_acc_abr19 if inlist(cohort, 59, 58, 57, 56) 
	replace 			vac_ontime4 = vac_acc_abr20 if cohort == 55
	replace 			vac_ontime4 = vac_acc_abr21 if cohort == 54
	replace 			vac_ontime4 = vac_acc_abr22 if cohort == 53
	replace 			vac_ontime4 = vac_acc_abr27 if inlist(cohort, 52, 51)
	replace 			vac_ontime4 = vac_acc_abr28 if cohort == 50
	replace 			vac_ontime4 = vac_acc_may4 if cohort == 49
	replace 			vac_ontime4 = vac_acc_may7 if cohort == 48
	replace 			vac_ontime4 = vac_acc_may8 if cohort == 47
	replace 			vac_ontime4 = vac_acc_may18 if cohort == 46
	replace 			vac_ontime4 = vac_acc_may20 if cohort == 45
	replace 			vac_ontime4 = vac_acc_may26 if inlist(cohort, 44, 43, 42)
	replace 			vac_ontime4 = vac_acc_may28 if inlist(cohort, 41, 40)
	replace 			vac_ontime4 = vac_acc_may31 if cohort == 39
	replace			 	vac_ontime4 = vac_acc_jun1 if cohort == 38
	replace 			vac_ontime4 = vac_acc_jun2 if cohort == 37
	replace 			vac_ontime4 = vac_acc_jun4 if inlist(cohort, 36, 35)
	replace 			vac_ontime4 = vac_acc_jun8 if inlist(cohort, 34, 33, 32)
	replace 			vac_ontime4 = vac_acc_jun9 if cohort == 31
	replace 			vac_ontime4 = vac_acc_jun10 if cohort == 30
	replace 			vac_ontime4 = vac_acc_jun14 if cohort == 29
	replace 			vac_ontime4 = vac_acc_jun15 if cohort == 28
	replace 			vac_ontime4 = vac_acc_jun16 if cohort == 27
	replace 			vac_ontime4 = vac_acc_jun17 if cohort == 26
	replace 			vac_ontime4 = vac_acc_jun22 if inlist(cohort, 25, 24)
	replace 			vac_ontime4 = vac_acc_jun23 if cohort == 23
	replace 			vac_ontime4 = vac_acc_jul2 if cohort == 22
	replace 			vac_ontime4 = vac_acc_jul6 if cohort == 21
	replace 			vac_ontime4 = vac_acc_jul9 if cohort == 20
	replace 			vac_ontime4 = vac_acc_jul14 if cohort == 19
	replace 			vac_ontime4 = vac_acc_jul17 if cohort == 18
	replace 			vac_ontime4 = vac_acc_ago2 if inlist(cohort, 17, 16)
	replace 			vac_ontime4 = vac_acc_ago4 if cohort == 15

*Variable labels 
	label 				var vac_ontime4 "Pop. vaccinated on time with 1st or unique dose acc. to nat. schedule + 21 days"

*Clean county names so then the data can be merged with other datasets
	replace 			comuna = upper(comuna)
	replace 			comuna = usubinstr(comuna, "ñ", "N", .)
	replace 			comuna = usubinstr(comuna, "á", "A", .)
	replace 			comuna = usubinstr(comuna, "é", "E", .)
	replace 			comuna = usubinstr(comuna, "í", "I", .)
	replace 			comuna = usubinstr(comuna, "ó", "O", .)
	replace 			comuna = usubinstr(comuna, "ú", "U", .)
	replace 			comuna = usubinstr(comuna, "Ñ", "N", .)
	replace 			comuna = usubinstr(comuna, "Á", "A", .)
	replace 			comuna = usubinstr(comuna, "É", "E", .)
	replace 			comuna = usubinstr(comuna, "Í", "I", .)
	replace 			comuna = usubinstr(comuna, "Ó", "O", .)
	replace 			comuna = usubinstr(comuna, "Ú", "U", .)
	replace 			comuna = "AISEN" if comuna == "AYSEN"
	replace 			comuna = "CABO HORNOS" if comuna == "CABO DE HORNOS"
	replace 			comuna = "LA CALERA" if comuna == "CALERA"
	replace 			comuna = "LLAY-LLAY" if comuna == "LLAILLAY"
	replace 			comuna = "PAIHUANO" if comuna == "PAIGUANO"
	replace 			comuna = "TREHUACO" if comuna == "TREGUACO"

	drop 				if cohort==.
	keep 				comuna code cohort vac_ontime4 vac_acc_may23
	save 				"${data_clean}\vacunacion.dta", replace

/*******************************************************************************
 2. Data on the number of vaccination centers per county
********************************************************************************/

	use 				"${data_raw}\establecimientos_direcc.dta", clear

*Adjust county names so then the data can be merged with other datasets
	replace 			comuna = "CHOLCHOL" if comuna == "CHOL-CHOL"
	replace 			comuna = "CONCON" if comuna == "CON CON"
	replace 			comuna = "LLAY-LLAY" if comuna == "LLAYLLAY"
	replace 			comuna = "MARCHIHUE" if comuna == "MARCHIGUE"
	replace 			comuna = "NUEVA IMPERIAL" if comuna == "IMPERIAL"
	replace 			comuna = "QUINTA DE TILCOCO" if comuna == "QUINTA TILCOCO"
	replace 			comuna = "SAAVEDRA" if comuna == "PUERTO SAAVEDRA"
	replace 			comuna = "TILTIL" if comuna == "TIL TIL"
	replace 			comuna = "TEODORO SCHMIDT" if comuna == "TEDORO SCHMIDT"

	label var 			n_locales "Number of vaccination centers per county"

	merge 				1:m comuna using "${data_clean}\vacunacion.dta", ///
							keep(match using) nogen

	save 				"${data_clean}\vacunacion.dta", replace

/*******************************************************************************
 3. Data on population projections for 2020 
 Extracted from: https://www.ine.cl/estadisticas/sociales/demografia-y-vitales/proyecciones-de-poblacion
********************************************************************************/
	
	import 				delimited "${data_raw}\poblacion_comuna_edad.txt", clear
	
*Correct variable names 
	drop v6 v7 v8
	
	forvalues 			i = 15/80 {
		local 				j = `i' - 6
		rename 				v`j' p_proj`i'
	}
		
	rename 				codigocomuna code
	keep 				code p_proj*
	drop 				if code==.

	reshape 			long p_proj, i(code) j(cohort)

*Variable labels
	label var 			p_proj "Population projection for 2020 (INE)"

	save 				"${data_clean}\proyecciones_getario.dta", replace

/*******************************************************************************
 4. Data on the "Plan Paso a Paso" and lockdowns
 Extracted from: https://github.com/MinCiencia/Datos-COVID19 (PRODUCT 74 & 29)
********************************************************************************/

*PLAN PASO A PASO
	import 				delimited "${data_raw}\paso_a_paso.txt", clear

*Correct variable names
	foreach 			var of varlist v* {
		local 			varlabel : var label `var'
		*Variable labels
		label var 		`var' "Fase Plan Paso a Paso al `varlabel' (DEIS)"
		local 			newname = subinstr("`varlabel'","-","_",.)
		rename 			`var' fase1_`newname'
		*Create dummy where 1 is full lockdown
		replace 		fase1_`newname' = 0 if fase1_`newname' != 1
	}

	drop 				codigo_region region_residencia
	rename 				codigo_comuna code
	rename 				comuna_residencia comuna

*Total number of days under lockdown
	egen 				fase1_total = rowtotal(fase1_*)
	egen 				fase1_prevac = rowtotal(fase1_2020_07_28-fase1_2020_12_23)
	keep 				code comuna zona fase1_prevac fase1_total

* Collapse data so each observation corresponds to a county (instead of a zone)
* Note that, when there is more than 1 zone per county, we are left with the average days under lockdown
	collapse 			(mean) fase1_prevac fase1_total, by(code)

*Variable labels
	label var 			fase1_total "Total days on phase 1 (DEIS)"
	label var 			fase1_prevac "Numbers of days on phase 1 until start of vaccination campaign (DEIS)"

	save 				"${data_clean}\paso_a_paso.dta", replace

*LOCKDOWNS (PRE-PLAN PASO A PASO)
	import 				delimited "${data_raw}\cuarentenas_historicas.txt", clear

	rename 				fechadetérmino fechadetermino
	rename 				códigocutcomuna code

	gen 				fechai_aux = substr(fechadeinicio, 1,10)
	gen 				fechat_aux = substr(fechadetermino, 1,10)
	gen 				fechai = date(fechai_aux, "YMD")
	gen 				fechat = date(fechat_aux, "YMD")

*Obtain the total number of days under lockdown
	gen 				cuaren = fechat-fechai

* Collapse data so each observation corresponds to a county (instead of a zone)
* Note that, when there is more than 1 zone per county, we are left with the average days under lockdown
	collapse 			(mean) cuaren, by(code)

*Variable labels
	label var 			cuaren "Numbers of days under lockdown until start of Plan Paso a Paso (DEIS)"

* COMBINE DATA
	merge 				1:1 code using "${data_clean}\paso_a_paso.dta", nogen
	
*Total number of days under lockdown
	egen 				lockd_prevac=rowtotal(cuaren fase1_prevac)
	egen 				lockd_total=rowtotal(cuaren fase1_total)

*Variable labels
	label var 			lockd_prevac "Days under lockdown or phase 1 until start of vaccination campaign (DEIS)"
	label var 			lockd_total "Total days under lockdown or phase 1 (DEIS)"

	save 				"${data_clean}\fase1.dta", replace

	erase				"${data_clean}\paso_a_paso.dta"
	
/*******************************************************************************
 5. Numer of fatalities per day and county 
 Extracted from: https://github.com/MinCiencia/Datos-COVID19
********************************************************************************/

	import 			delimited "${data_raw}\fallecidos.txt", clear

* Correct variable names
	foreach 		var of varlist v* {
		local 			varlabel : var label `var'
		*Variable labels
		label 			var `var' "Fallecidos al `varlabel' (DEIS)"
		local 			newname = subinstr("`varlabel'","-","_",.)
		rename 			`var' fall_`newname'
	}

	drop 			codigoregion
	rename 			codigocomuna code
	drop 			if code==.

* Total number of fatalities per county until the start of the vaccination process as a share of the total population
* Note that the most updated data before 24-12-2020 is from 2020_12_21
	gen 			fall_prevac=fall_2020_12_21
	gen 			sh_fall_prevac=(fall_prevac/poblacion)*1000
	drop 			poblacion

*Variable labels
	label var 		fall_prevac "Fatalities until start of vaccination campaign (DEIS)"

	keep 			code sh_fall_prevac fall_prevac

	save 			"${data_clean}\fallecidos.dta", replace

/*******************************************************************************
 6. Numer of fatalities cohort, per day, and county 
 Extracted from: https://github.com/MinCiencia/Datos-COVID19 (product 84)
********************************************************************************/
	
	import 			delimited "${data_raw}\fallecidos_comuna_edad.txt", clear

* Correct variable names
	foreach 		var of varlist v* {
		local 			varlabel : var label `var'
		*Variable labels
		label var 		`var' "Fallecidos al `varlabel' (DEIS)"
		local 			newname = subinstr("`varlabel'","-","_",.)
		rename 			`var' fall_`newname'
	}

* Number of fatalities until the start of the vaccination process
	egen 			fall_prevac_cohort = rowtotal(fall_2020_03_16-fall_2020_12_21)

* Variable labels
	label var 		fall_prevac_cohort "Fatalities until start of vaccination campaign per age group (DEIS)"

	rename 			codigocomuna code
	keep 			code edad fall_prevac_cohort 

	replace 		edad = "menos40" if edad == "<=39"
	replace 		edad = "40a49" if edad == "40-49"
	replace 		edad = "50a59" if edad == "50-59"
	replace 		edad = "60a69" if edad == "60-69"
	replace 		edad = "70a79" if edad == "70-79"
	replace 		edad = "80a89" if edad == "80-89"
	replace 		edad = "mas89" if edad == ">=90"

	rename 			edad age_group

	encode 			age_group, gen(IDage_group)

	save 			"${data_clean}\fallecidos_comuna_edad.dta", replace

/*******************************************************************************
 7. Number of COVID cases per day and county
 Extracted from: https://github.com/MinCiencia/Datos-COVID19
********************************************************************************/

	import 			delimited "${data_raw}\casos_incrementales.txt", clear

* Correct variable names
	foreach 		var of varlist v* {
		local			varlabel : var label `var'
		*Variable labels
		label var 		`var' "Casos totales al `varlabel' (DEIS)"
		local 			newname = subinstr("`varlabel'","-","_",.)
		rename 			`var' casos_`newname'
	}

	drop 			codigoregion poblacion
	rename 			codigocomuna code
	drop 			if code==.

* Total number of COVID cases per county until the start of the vaccination process as a share of the total population
* Note that the most updated data before 24-12-2020 is from 2020_12_21
	gen 			casos_prevac = casos_2020_12_21

	*Se crean las labels para las variables
	label var 		casos_prevac "Number of cases until start of vaccination campaign (DEIS)"

	*Dejamos solos las variables a utilizar
	keep 			code casos_prevac 

	save 			"${data_clean}\casos_incrementales.dta", replace

/*******************************************************************************
 8. Mobility data
 Extracted from: https://github.com/MinCiencia/Datos-COVID19/tree/master/output/producto33
********************************************************************************/

	import 			delimited "${data_raw}\movilidad_isci.csv", clear
	keep 			semana paso nom_comuna fecha* var_salidas
	rename 			nom_comuna comuna

*Clean county names so then the data can be merged with other datasets
	replace 		comuna = usubinstr(comuna, "MARÃA", "MARIA", .)
	replace 		comuna = usubinstr(comuna, "RÃO", "RIO", .)
	replace 		comuna = usubinstr(comuna, "CHILLÃN", "CHILLAN", .)
	replace 		comuna = "AISEN" if comuna == "AYSÃN"
	replace 		comuna = "ALHUE" if comuna == "ALHUÃ"
	replace 		comuna = "CABO HORNOS" if comuna == "CABO DE HORNOS"
	replace 		comuna = "LA CALERA" if comuna == "CALERA"
	replace 		comuna = "CANETE" if comuna == "CAÃETE"
	replace 		comuna = "CHAITEN" if comuna == "CHAITÃN"
	replace 		comuna = "CANETE" if comuna == "CAÃETE"
	replace 		comuna = "CHANARAL" if comuna == "CHAÃARAL"
	replace 		comuna = "CHEPICA" if comuna == "CHÃPICA"
	replace 		comuna = "COLBUN" if comuna == "COLBÃN"
	replace 		comuna = "COMBARBALA" if comuna == "COMBARBALÃ"
	replace 		comuna = "CONCEPCION" if comuna == "CONCEPCIÃN"
	replace 		comuna = "CONCHALI" if comuna == "CONCHALÃ"
	replace 		comuna = "CONCON" if comuna == "CONCÃN"
	replace 		comuna = "COPIAPO" if comuna == "COPIAPÃ"
	replace 		comuna = "CURACAUTIN" if comuna == "CURACAUTÃN"
	replace 		comuna = "CURACAVI" if comuna == "CURACAVÃ"
	replace 		comuna = "CURACO DE VELEZ" if comuna == "CURACO DE VÃLEZ"
	replace 		comuna = "CURICO" if comuna == "CURICÃ"
	replace 		comuna = "DONIHUE" if comuna == "DOÃIHUE"
	replace 		comuna = "ESTACION CENTRAL" if comuna == "ESTACIÃN CENTRAL"
	replace 		comuna = "FUTALEUFU" if comuna == "FUTALEUFÃ"
	replace 		comuna = "HUALAIHUE" if comuna == "HUALAIHUÃ"
	replace 		comuna = "HUALANE" if comuna == "HUALAÃÃ"
	replace 		comuna = "HUALPEN" if comuna == "HUALPÃN"
	replace 		comuna = "LA UNION" if comuna == "LA UNIÃN"
	replace 		comuna = "LICANTEN" if comuna == "LICANTÃN"
	replace 		comuna = "LLAY-LLAY" if comuna == "LLAILLAY"
	replace 		comuna = "LONGAVI" if comuna == "LONGAVÃ"
	replace 		comuna = "LOS ALAMOS" if comuna == "LOS ÃLAMOS"
	replace 		comuna = "LOS ANGELES" if comuna == "LOS ÃNGELES"
	replace 		comuna = "MACHALI" if comuna == "MACHALÃ"
	replace 		comuna = "MAIPU" if comuna == "MAIPÃ"
	replace 		comuna = "MAULLIN" if comuna == "MAULLÃN"
	replace 		comuna = "MULCHEN" if comuna == "MULCHÃN"
	replace 		comuna = "MAFIL" if comuna == "MÃFIL"
	replace 		comuna = "OLMUE" if comuna == "OLMUÃ"
	replace 		comuna = "PENAFLOR" if comuna == "PEÃAFLOR"
	replace 		comuna = "PENALOLEN" if comuna == "PEÃALOLÃN"
	replace 		comuna = "PITRUFQUEN" if comuna == "PITRUFQUÃN"
	replace 		comuna = "PUCHUNCAVI" if comuna == "PUCHUNCAVÃ"
	replace 		comuna = "PUCON" if comuna == "PUCÃN"
	replace 		comuna = "PUREN" if comuna == "PURÃN"
	replace 		comuna = "QUEILEN" if comuna == "QUEILÃN"
	replace 		comuna = "QUELLON" if comuna == "QUELLÃN"
	replace 		comuna = "QUILLON" if comuna == "QUILLÃN"
	replace 		comuna = "QUILPUE" if comuna == "QUILPUÃ"
	replace 		comuna = "REQUINOA" if comuna == "REQUÃNOA"
	replace 		comuna = "RANQUIL" if comuna == "RÃNQUIL"
	replace 		comuna = "SAN FABIAN" if comuna == "SAN FABIÃN"
	replace 		comuna = "SAN JOAQUIN" if comuna == "SAN JOAQUÃN"
	replace 		comuna = "SAN JOSE DE MAIPO" if comuna == "SAN JOSÃ DE MAIPO"
	replace 		comuna = "SAN NICOLAS" if comuna == "SAN NICOLÃS"
	replace 		comuna = "SAN RAMON" if comuna == "SAN RAMÃN"
	replace 		comuna ="SANTA BARBARA" if comuna == "SANTA BÃRBARA"
	replace 		comuna = "TIRUA" if comuna == "TIRÃA"
	replace 		comuna = "TOLTEN" if comuna == "TOLTÃN"
	replace 		comuna = "TOME" if comuna == "TOMÃ"
	replace 		comuna = "TRAIGUEN" if comuna == "TRAIGUÃN"
	replace 		comuna = "TREHUACO" if comuna == "TREGUACO"
	replace 		comuna = "VALPARAISO" if comuna == "VALPARAÃSO"
	replace 		comuna = "VICHUQUEN" if comuna == "VICHUQUÃN"
	replace 		comuna = "VICUNA" if comuna == "VICUÃA"
	replace 		comuna = "VILCUN" if comuna == "VILCÃN"
	replace 		comuna = "VINA DEL MAR" if comuna == "VIÃA DEL MAR"
	replace 		comuna = "NUNOA" if comuna == "ÃUÃOA"
	replace 		comuna = "NIQUEN" if comuna == "ÃIQUÃN"
	replace 		comuna = "COMBARBALA" if comuna == "COMBARBALÃ"
	replace 		comuna = "CONSTITUCION" if comuna == "CONSTITUCIÃN"

	save 			"${data_clean}\movilidad_isci.dta", replace

/*******************************************************************************
 9. Data on the 2020 influenza vaccination campaign
*Extracted form: http://cognos.deis.cl/ibmcognos/cgi-bin/cognos.cgi?b_action=cognosViewer&ui.action=run&ui.object=%2fcontent%2ffolder%5b%40name%3d%27PUB%27%5d%2ffolder%5b%40name%3d%27REPORTES%27%5d%2ffolder%5b%40name%3d%27Inmunizacion%20Influenza%27%5d%2freport%5b%40name%3d%27Campa%c3%b1a%202020%20-%20Cobertura%27%5d&ui.name=Campa%c3%b1a%202020%20-%20Cobertura&cv.toolbar=false&cv.header=false&run.outputFormat=&run.prompt=false
********************************************************************************/

	foreach 			region in I II III IV V VI VII VIII IX X XI XII RM XIV XV XVI {
	* Import data from excel, where each sheet corresponds to a region
		import 				excel "${data_raw}\camp_inf_nacional.xlsx", ///
								sheet("`region'") firstrow clear

		drop 				if missing(B)
		drop 				Cobertura
		destring 			VacunasAdministradas, replace
	* Correct group names to later reshape data
		replace 			B = "total" if B == "Resumen"
		replace 			B = "otros" if B == "Otras prioridades"
		replace 			B = "psaludpriv" if B == "Privado , personal de salud"
		replace 			B = "psaludpub" if B == "Público, personal de salud"
		replace 			B = "total" if B == "Resumen"
		replace 			B = "embarazadas" if B == "Embarazadas"
		replace 			B = "enfcron" if B == "Enfermos Cronicos de 11 a 64 años"
		replace 			B = "mas65a" if B == "Personas de 65 años y más"
		replace 			B = "1eroa5to" if B == "Niños(as) de 1ero a 5to básico"
		replace 			B = "6ma5a" if B == "Niños(as) de 6 meses a 5 años de edad"
		replace 			B = "trabaviycer" if B == "Trabajadores de avícolas y de criaderos de cerdo"
		rename 				Poblaciónobjetivo p_obj_inf
		rename 				VacunasAdministradas vac_inf
		gen 				sh_vac_inf=vac_inf/p_obj_inf
		drop 				if missing(A)
	* Reshape dataset so each observation corresponds to a county
		rename 				A comuna
		rename 				B group
		encode 				group, gen(IDgroup)
	* Save datasets
		save 				"${data_clean}\camp_inf`region'.dta", replace
	}

	*Combine datasets
	use 					"${data_clean}\camp_infI.dta", clear
	foreach 				region in II III IV V VI VII VIII IX X XI XII RM XIV XV XVI {
		append 				using "${data_clean}\camp_inf`region'.dta", force
		erase 				"${data_clean}\camp_inf`region'.dta"
	}
	erase 				"${data_clean}\camp_infI.dta"

* Clean county names so then the data can be merged with other datasets
	replace 				comuna = upper(comuna)
	replace 				comuna = usubinstr(comuna, "ñ", "N", .)
	replace 				comuna = usubinstr(comuna, "á", "A", .)
	replace 				comuna = usubinstr(comuna, "é", "E", .)
	replace 				comuna = usubinstr(comuna, "í", "I", .)
	replace 				comuna = usubinstr(comuna, "ó", "O", .)
	replace 				comuna = usubinstr(comuna, "ú", "U", .)
	replace 				comuna = usubinstr(comuna, "Ñ", "N", .)
	replace 				comuna = usubinstr(comuna, "Á", "A", .)
	replace 				comuna = usubinstr(comuna, "É", "E", .)
	replace 				comuna = usubinstr(comuna, "Í", "I", .)
	replace 				comuna = usubinstr(comuna, "Ó", "O", .)
	replace 				comuna = usubinstr(comuna, "Ú", "U", .)
	replace 				comuna = "OHIGGINS" if comuna == "O'HIGGINS"
	replace 				comuna = "OLLAGUE" if comuna == "OLLAGüE"
	replace 				comuna = "AISEN" if comuna == "AYSEN"
	replace 				comuna = "COYHAIQUE" if comuna == "COIHAIQUE"
	replace 				comuna = "CABO HORNOS" if comuna == "CABO DE HORNOS"
	replace 				comuna = "LA CALERA" if comuna == "CALERA"
	replace 				comuna = "LLAY-LLAY" if comuna == "LLAILLAY"
	replace 				comuna = "PAIHUANO" if comuna == "PAIGUANO"
	replace 				comuna = "TREHUACO" if comuna == "TREGUACO"

* Variable labels
	label var				p_obj "P. objetivo camp. vacunacion influenza 2020 (DEIS)"
	label var				vac_inf "Vac. adm. camp. vacunacion influenza 2020 (DEIS)"

	save 					"${data_clean}\camp_inf_nacional.dta", replace

/*******************************************************************************
 10. Legal entities registration
********************************************************************************/

	foreach 				region in Tarapaca Antofagasta Atacama Coquimbo ///
								Valparaiso Ohiggins Maule Biobio Araucania LosLagos ///
								Aysen Magallanes Metropolitana LosRios AricaParinacota Ñuble {
		* Import data from excel, where each sheet corresponds to a region
		import 					excel "${data_raw}\personas_juridicas.xlsx", ///
									sheet("`region'") firstrow clear
		keep 					COMUNA
		rename 					COMUNA comuna
		gen 					p_jur = 1
		* Collapse data so each observation corresponds to a county, and calculate total number of legal entities
		collapse 				(sum) p_jur, by(comuna)
		save 					"${data_clean}\personas_juridicas_`region'.dta", replace
	}

* Combine data
	use 					"${data_clean}\personas_juridicas_Tarapaca.dta", clear
	foreach 				region in Antofagasta Atacama Coquimbo Valparaiso Ohiggins ///
								Maule Biobio Araucania LosLagos Aysen Magallanes ///
								Metropolitana LosRios AricaParinacota Ñuble {
		append 					using "${data_clean}\personas_juridicas_`region'.dta"
		erase					"${data_clean}\personas_juridicas_`region'.dta"
	}
	drop 					if comuna == ""
	erase					"${data_clean}\personas_juridicas_Tarapaca.dta"

* Clean county names so then the data can be merged with other datasets
	replace 				comuna = trim(comuna)
	replace 				comuna = upper(comuna)
	replace 				comuna = usubinstr(comuna, "ñ", "N", .)
	replace 				comuna = usubinstr(comuna, "á", "A", .)
	replace 				comuna = usubinstr(comuna, "é", "E", .)
	replace 				comuna = usubinstr(comuna, "í", "I", .)
	replace 				comuna = usubinstr(comuna, "ó", "O", .)
	replace 				comuna = usubinstr(comuna, "ú", "U", .)
	replace 				comuna = usubinstr(comuna, "Ñ", "N", .)
	replace 				comuna = usubinstr(comuna, "Á", "A", .)
	replace 				comuna = usubinstr(comuna, "É", "E", .)
	replace 				comuna = usubinstr(comuna, "Í", "I", .)
	replace 				comuna = usubinstr(comuna, "Ó", "O", .)
	replace 				comuna = usubinstr(comuna, "Ú", "U", .)
	replace 				comuna = "CABO HORNOS" if comuna == "CABO DE HORNOS"
	replace 				comuna = "LA CALERA" if comuna == "CALERA"
	replace 				comuna = "LLAY-LLAY" if comuna == "LLAILLAY" | comuna == "LLAY LLAY"
	replace 				comuna = "OHIGGINS" if comuna == "O'HIGGINS"
	replace 				comuna = "OLLAGUE" if comuna == "OLLAGÜE"
	replace 				comuna = "TREHUACO" if comuna == "TREGUACO"

	collapse 				(sum) p_jur, by(comuna)
	
	save 					"${data_clean}\personas_juridicas.dta", replace

/*******************************************************************************
 11. Turnout
********************************************************************************/
/*
Note: had to run this section and store original turnout dataset off Github 
because of raw dataset is too large and can't be store on Github 

* 2017
	import 					delimited "${data_raw}\turnout_2017.csv", clear
	gen 					turnout_2017=0
	replace					turnout_2017=1 if sufragio=="sufragó"
	collapse 				(mean) turnout_2017, by(comuna edad)
	replace 				edad=edad+3
	keep 					if edad<=80
	rename 					edad cohort
	save 					"${data_clean}\turnout.dta", replace

* 2020
	import 					delimited "${data_raw}\turnout_2020.csv", clear
	gen 					turnout_2020=0
	replace 				turnout_2020=1 if sufragio=="sufragÃ³"
	collapse 				(mean) turnout_2020, by(comuna edad)
	keep 					if edad<=80
	rename 					edad cohort
	
* Clean county names so then the data can be merged with other datasets
	replace 				comuna = "Ñiquen" if comuna == "Ãiquen"
	replace 				comuna = "Ñuñoa" if comuna == "ÃuÃ±oa"
	replace 				comuna = "Viña Del Mar" if comuna == "ViÃ±a Del Mar"
	replace 				comuna = "Vicuña" if comuna == "VicuÃ±a"
	replace 				comuna = "Treguaco" if comuna == "Trehuaco"
	replace 				comuna = "Rio Ibañez" if comuna == "Rio IbaÃ±ez"
	replace 				comuna = "Peñaflor" if comuna == "PeÃ±aflor"
	replace 				comuna = "Peñalolen" if comuna == "PeÃ±alolen"
	replace 				comuna = "Paihuano" if comuna == "Paiguano"
	replace 				comuna = "Llay-Llay" if comuna == "Llaillay"
	replace 				comuna = "Hualañe" if comuna == "HualaÃ±e"
	replace 				comuna = "Doñihue" if comuna == "DoÃ±ihue"
	replace 				comuna = "Chañaral" if comuna == "ChaÃ±aral"
	replace 				comuna = "Cañete" if comuna == "CaÃ±ete"
	replace 				comuna = "Camiña" if comuna == "CamiÃ±a"
	replace 				comuna = "Cabo De Hornos" if comuna == "Cabo De Hornos(Ex-Navarino)"
	replace 				comuna = "Aisen" if comuna == "Aysen"

	merge 					1:1 comuna cohort using "${data_clean}\turnout.dta", nogen

* Clean county names so then the data can be merged with other datasets
	replace 				comuna = upper(comuna)
	replace 				comuna = usubinstr(comuna, "ñ", "N", .)
	replace 				comuna = usubinstr(comuna, "á", "A", .)
	replace 				comuna = usubinstr(comuna, "é", "E", .)
	replace 				comuna = usubinstr(comuna, "í", "I", .)
	replace 				comuna = usubinstr(comuna, "ó", "O", .)
	replace 				comuna = usubinstr(comuna, "ú", "U", .)
	replace 				comuna = usubinstr(comuna, "Ñ", "N", .)
	replace 				comuna = usubinstr(comuna, "Á", "A", .)
	replace 				comuna = usubinstr(comuna, "É", "E", .)
	replace 				comuna = usubinstr(comuna, "Í", "I", .)
	replace 				comuna = usubinstr(comuna, "Ó", "O", .)
	replace 				comuna = usubinstr(comuna, "Ú", "U", .)
	replace 				comuna = "TREHUACO" if comuna == "TREGUACO"
	replace 				comuna = "OHIGGINS" if comuna == "O'HIGGINS"
	replace 				comuna = "MARCHIHUE" if comuna == "MARCHIGUE"
	replace 				comuna = "CABO HORNOS" if comuna == "CABO DE HORNOS"
	replace 				comuna = "LA CALERA" if comuna == "CALERA"

* Variable labels
	label 					var turnout_2017 "2017 turnout rate"
	label 					var turnout_2020 "2020 turnout rate"

	save 					"${data_clean}\turnout.dta", replace
*/

/*******************************************************************************
 12. Survey data from Latinobarometro (1995-2018)
********************************************************************************/

* 1997
	use 					"${data_raw}\latinobarometro\Latinobarometro_1997.dta", clear
	keep 					if idenpa==152
	keep 					numinves ciudad s1 sp21 sp31 sp32 sp63a sp63b ///
								sp63c sp63d sp63e sp63f sp63g s2 wt tamciud sp37 s5 s16
	foreach 				var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 					"${data_clean}\Latinobarometro_1997_final.dta", replace

* 1998
	use 					"${data_raw}\latinobarometro\Latinobarometro_1998.dta", clear
	keep 					if idenpa==152
	keep 					numinves s1 ciudad sp20 sp28 sp29 sp38a sp38b ///
								sp38c sp38d sp38e sp38f sp38g s2 pondera tamciud ///
								sp34 s5 s18
	rename 					sp20 sp21 
	rename 					sp28 sp31 
	rename 					sp29 sp32 
	rename 					sp38a sp63a
	rename 					sp38b sp63b 
	rename 					sp38c sp63c 
	rename 					sp38d sp63d 
	rename 					sp38e sp63e 
	rename 					sp38f sp63f
	rename 					sp38g sp63g 
	rename 					pondera wt
	rename 					sp34 sp37
	rename 					s18 s16
	foreach 				var of varlist _all {
		if						"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode					`var', gen(`var'_string)
			drop 					`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_1998_final.dta", replace

* 2000
	use 				"${data_raw}\latinobarometro\Latinobarometro_2000.dta", clear
	keep 				if idenpa==152
	keep 				numinves S1 ciudad P17ST P29ST P30ST P35ST_A P35ST_B ///
							P35ST_C P35ST_D P35ST_E P35ST_F P35ST_G S2 wt tamciud ///
							S4 S16
	rename 				P17ST sp21 
	rename 				P29ST sp31 
	rename 				P30ST sp32 
	rename 				P35ST_A sp63a
	rename 				P35ST_B sp63b 
	rename 				P35ST_C sp63c 
	rename 				P35ST_D sp63d 
	rename 				P35ST_E sp63e 
	rename 				P35ST_F sp63f
	rename 				P35ST_G sp63g 
	rename 				S2 s2 
	rename 				S4 s5
	rename 				S16 s16
	rename 				S1 s1
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2000_final.dta", replace

* 2001
	use 				"${data_raw}\latinobarometro\Latinobarometro_2001.dta", clear
	keep 				if idenpa==152
	keep 				numinves s1 ciudad p42st p46st p45st p61sta p61stb p61stc ///
							p61std p61ste p61stf p61stg p63stc s2 wt tamciud s4 s16a
	rename 				p42st sp21 
	rename 				p46st sp31 
	rename 				p45st sp32 
	rename 				p61sta sp63a
	rename 				p61stb sp63b 
	rename 				p61stc sp63c 
	rename 				p61std sp63d 
	rename 				p61ste sp63e 
	rename 				p61stf sp63f
	rename 				p61stg sp63g 
	rename 				s4 s5
	rename 				s16a s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 			"${data_clean}\Latinobarometro_2001_final.dta", replace

* 2002
	use 				"${data_raw}\latinobarometro\Latinobarometro_2002.dta", clear
	keep 				if idenpa==152
	keep 				numinves s1 ciudad p29st p32st p33st p34sta p36stb p34stc ///
							p36ste p36std p34stf p34std s2 wt tamciud s4 s20
	rename 				p29st sp21 
	rename 				p32st sp31 
	rename 				p33st sp32 
	rename 				p34sta sp63a
	rename 				p36stb sp63b 
	rename 				p34stc sp63c 
	rename 				p36ste sp63e 
	rename 				p36std sp63f
	rename 				p34stf sp63g 
	rename 				s4 s5
	rename 				s20 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2002_final.dta", replace

* 2003
	use 				"${data_raw}\latinobarometro\Latinobarometro_2003.dta", clear
	keep 				if idenpa==152
	keep 				numinves s1 ciudad p20st p14st p15st p21sta p21stg p21ste ///
							p23stc p21stb p21stf p21std p23stg s2 wt tamciud ///
							p58st s4 s16
	rename 				p20st sp21 
	rename 				p14st sp31 
	rename 				p15st sp32 
	rename 				p21sta sp63a
	rename 				p21stg sp63b 
	rename 				p21ste sp63c 
	rename 				p23stc sp63d 
	rename 				p21stb sp63e 
	rename 				p21stf sp63f
	rename 				p21std sp63g 
	rename 				p23stg p34std
	rename 				p58st sp37
	rename 				s4 s5
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2003_final.dta", replace

* 2004
	use 				"${data_raw}\Latinobarometro\Latinobarometro_2004.dta", clear
	keep 				if idenpa==152
	keep 				numinves s1 Ciudad p43st p13st p14st p32stc p32stg p34stb ///
							p34stc p32stb p34stf p34std p34sth p32std s2 wt tamciud ///
							p28st s4 s18
	rename 				Ciudad ciudad
	rename 				p43st sp21 
	rename 				p13st sp31 
	rename 				p14st sp32 
	rename 				p32stc sp63a
	rename 				p32stg sp63b 
	rename 				p34stb sp63c 
	rename 				p34stc sp63d 
	rename 				p32stb sp63e 
	rename 				p34stf sp63f
	rename 				p34std sp63g 
	rename 				p34sth p63stc
	rename 				p32std p34std
	rename 				p28st sp37
	rename 				s4 s5
	rename 				s18 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2004_final.dta", replace

* 2005
	use 				"${data_raw}\latinobarometro\Latinobarometro_2005.dta", clear
	keep 				if idenpa==152
	keep 				numinves ciudad p14st p16st p18st p42sta p42stb p42std ///
							p47stf p42stf p45sta p47stb p45stc s7 wt tamciud p50st ///
							s9 s24
	rename 				p14st sp21 
	rename 				p16st sp31 
	rename 				p18st sp32 
	rename 				p42sta sp63a
	rename 				p42stb sp63b 
	rename 				p42std sp63c 
	rename 				p47stf sp63d 
	rename 				p42stf sp63e 
	rename 				p45sta sp63f
	rename 				p47stb sp63g 
	rename 				p45stc p34std
	rename 				s7 s2 
	rename 				p50st sp37
	rename 				s9 s5
	rename 				s24 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2005_final.dta", replace

* 2006 
	use 				"${data_raw}\latinobarometro\Latinobarometro_2006.dta", clear
	keep 				if idenpa==152
	keep 				numinves sexo ciudad p45st p17st p21st p32st_d p32st_e ///
							p24st_a p24st_b p24st_d p24st_f p24st_c p32st_a s7 ///
							wt tamciud s9 s24
	rename 				sexo s1
	rename 				p45st sp21 
	rename 				p17st sp31 
	rename 				p21st sp32 
	rename 				p32st_d sp63a
	rename 				p32st_e sp63b 
	rename 				p24st_a sp63c 
	rename 				p24st_b sp63d 
	rename 				p24st_d sp63e 
	rename 				p24st_f sp63f
	rename 				p24st_c sp63g 
	rename 				p32st_a p34std
	rename 				s7 s2 
	rename 				s9 s5
	rename 				s24 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2006_final.dta", replace

* 2007
	use 				"${data_raw}\latinobarometro\Latinobarometro_2007.dta", clear
	keep 				if idenpa==152
	keep 				numinves s10 ciudad p23st p9st p12st p27st_c p27st_d p24st_d ///
							p24st_e p27st_f p24st_f p27st_e p24st_a edad wt tamciud ///
							s13 s28
	rename 				s10 s1
	rename 				p23st sp21 
	rename 				p9st sp31 
	rename 				p12st sp32 
	rename 				p27st_c sp63a
	rename 				p27st_d sp63b 
	rename 				p24st_d sp63c 
	rename 				p24st_e sp63d 
	rename 				p27st_f sp63e 
	rename 				p24st_f sp63f
	rename 				p27st_e sp63g 
	rename 				p24st_a p34std
	rename 				edad s2 
	rename 				s13 s5
	rename 				s28 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2007_final.dta", replace

* 2008
	use 				"${data_raw}\latinobarometro\Latinobarometro_2008.dta", clear
	keep 				if idenpa==152
	keep 				numinves s8 ciudad p21wvsst p13st p22st_a p28st_g p28st_d ///
							p28st_b p31st_c p28st_a p28st_c p28st_f p31s_ta s9 ///
							wt tamciud s3 s26
	rename 				s8 s1
	rename 				p21wvsst sp21 
	rename 				p13st sp31 
	rename 				p22st_a sp32 
	rename 				p28st_g  sp63a
	rename 				p28st_d sp63b 
	rename 				p28st_b sp63c 
	rename 				p31st_c sp63e 
	rename 				p28st_a sp63f
	rename 				p28st_c sp63g 
	rename 				p28st_f p63stc
	rename 				p31s_ta p34std
	rename 				s9 s2 
	rename 				s3 s5
	rename 				s26 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2008_final.dta", replace

* 2009
	use 				"${data_raw}\latinobarometro\Latinobarometro_2009.dta", clear
	keep 				if idenpa==152
	keep 				numinves ciudad s5 p58st p10st p12st_a p26st_g p26st_d ///
							p26st_b p24st_c p26st_a p26st_c p26st_f p24st_a s6 wt ///
							tamciud p38st s3 s26
	rename 				s5 s1
	rename 				p58st sp21 
	rename 				p10st sp31 
	rename 				p12st_a sp32 
	rename 				p26st_g sp63a
	rename 				p26st_d sp63b 
	rename 				p26st_b sp63c 
	rename 				p24st_c sp63e 
	rename 				p26st_a sp63f
	rename 				p26st_c sp63g 
	rename 				p26st_f p63stc
	rename 				p24st_a p34std
	rename 				s6 s2 
	rename 				p38st sp37
	rename 				s3 s5
	rename 				s26 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2009_final.dta", replace

* 2010
	use 				"${data_raw}\latinobarometro\Latinobarometro_2010.dta", clear
	keep 				if idenpa==152
	keep 				numinves S7 ciudad P55ST P10ST P11ST_A P20ST_G P20ST_D P20ST_B ///
							P18ST_C P20ST_A P20ST_C P20ST_F P20ST_I P18ST_A S8 wt ///
							tamciud S5 S28
	rename 				S7 s1
	rename 				P55ST sp21 
	rename 				P10ST sp31 
	rename 				P11ST_A sp32 
	rename 				P20ST_G sp63a
	rename 				P20ST_D sp63b 
	rename 				P20ST_B sp63c 
	rename 				P18ST_C sp63e 
	rename 				P20ST_A sp63f
	rename 				P20ST_C sp63g 
	rename 				P20ST_F p63stc
	rename 				P18ST_A p34std
	rename 				S8 s2 
	rename 				S5 s5
	rename 				S28 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2010_final.dta", replace

* 2011
	use 				"${data_raw}\latinobarometro\Latinobarometro_2011.dta", clear
	keep 				if idenpa==152
	keep 				numinves ciudad S16 P25ST P22ST_G P22ST_D P22ST_B P20ST_C ///
							P22ST_A P22ST_C reedad wt tamciud  S15 S34
	rename 				S16 s1
	rename 				P25ST sp21 
	rename 				P22ST_G sp63a
	rename 				P22ST_D sp63b 
	rename 				P22ST_B sp63c 
	rename 				P20ST_C sp63e 
	rename 				P22ST_A sp63f
	rename 				P22ST_C sp63g 
	rename 				reedad s2 
	rename 				S15 s5
	rename 				S34 s16
	replace				numinves=2011
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2011_final.dta", replace

* 2015
	use 				"${data_raw}\latinobarometro\Latinobarometro_2015.dta", clear
	keep 				if idenpa==152
	keep 				numinves S12 ciudad P15STGBS P11STGBS P12TG_A P16ST_E ///
							P16TGB_A P16ST_H P16TGB_B P16ST_F P19ST_C P19ST_F ///
							P16ST_G S13 wt tamciud S11 S29
	rename 				S12 s1
	rename 				P15STGBS sp21 
	rename 				P11STGBS sp31 
	rename 				P12TG_A sp32 
	rename 				P16ST_E sp63a
	rename 				P16TGB_A sp63b 
	rename 				P16ST_H sp63c 
	rename 				P16TGB_B sp63e 
	rename 				P16ST_F sp63f
	rename 				P19ST_C sp63g 
	rename 				P19ST_F P20ST_I
	rename 				S13 s2 
	rename 				S11 s5
	rename 				S29 s16
	replace				numinves=2015
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2015_final.dta", replace

* 2016
	use 				"${data_raw}\latinobarometro\Latinobarometro_2016.dta", clear
	keep 				if idenpa==152
	keep 				numinves sexo ciudad P12STGBS P8STGBS P9STGBSA P13STC ///
							P13STGBSA P13STF P13STGBSB P13STD P13STG edad wt ///
							tamciud S5 S22
	rename 				sexo s1
	rename 				P12STGBS sp21 
	rename 				P8STGBS sp31 
	rename 				P9STGBSA sp32 
	rename 				P13STC sp63a
	rename 				P13STGBSA sp63b 
	rename 				P13STF sp63c 
	rename 				P13STGBSB sp63e 
	rename 				P13STD sp63f
	rename 				P13STG sp63g 
	rename 				edad s2 
	rename 				S5 s5
	rename 				S22 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2016_final.dta", replace

* 2017
	use 				"${data_raw}\latinobarometro\Latinobarometro_2017.dta", clear
	keep 				if idenpa==152
	keep 				numinves sexo ciudad P13STGBS P8STGBS P9STGBSC_A P14ST_C ///
							P14STGBS_A P14ST_F P14STGBS_B P14ST_D P14ST_G P14ST_E ///
							edad wt tamciud  S6 S22
	rename 				sexo s1
	rename 				P13STGBS sp21 
	rename 				P8STGBS sp31 
	rename 				P9STGBSC_A sp32 
	rename 				P14ST_C sp63a
	rename 				P14STGBS_A sp63b 
	rename 				P14ST_F sp63c 
	rename 				P14STGBS_B sp63e 
	rename 				P14ST_D sp63f
	rename 				P14ST_G sp63g 
	rename 				P14ST_E p34std
	rename 				edad s2 
	rename 				S6 s5
	rename 				S22 s16
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2017_final.dta", replace

* 2018
	use 				"${data_raw}\latinobarometro\Latinobarometro_2018.dta", clear
	keep 				if IDENPA==152
	keep 				NUMINVES SEXO CIUDAD P11STGBS P12STGBS P13STGBS* P15STGBSC* ///
							P15STGBSC* P15STGBSC*  P15STGBSC* P15STGBSC* P15STGBSC* ///
							P15STGBSC* EDAD WT TAMCIUD  S23 S26
	*There is a problem with the var name because they contain "."
	local 				i 0
	foreach 			varname of varlist _all {
		local 				++i
		if 					( "`varname'" != ustrtoname("`varname'") ) {
			mata : 			st_varrename(`i', ustrtoname("`varname'") )
		}
	}
	rename 				WT wt
	rename 				SEXO s1
	rename 				NUMINVES numinves
	rename 				CIUDAD ciudad
	rename 				P11STGBS sp21 
	rename 				P12STGBS sp31 
	rename 				P13STGBS_A sp32 
	rename 				P15STGBSC_C sp63a
	rename 				P15STGBSC_A sp63b 
	rename 				P15STGBSC_F sp63c 
	rename 				P15STGBSC_B sp63e 
	rename 				P15STGBSC_D sp63f
	rename 				P15STGBSC_G sp63g 
	rename 				P15STGBSC_E P16ST_G
	rename 				EDAD s2 
	rename 				S23 s5
	rename 				S26 s16
	rename 				TAMCIUD tamciud
	foreach 			var of varlist _all {
		if					"`var'" != "wt" & "`var'" != "s1" & "`var'" != "s2" & "`var'" != "numinves" {
			decode				`var', gen(`var'_string)
			drop 				`var'
		}
	}
	save 				"${data_clean}\Latinobarometro_2018_final.dta", replace

* COMBINE DATA FOR ALL YEARS
	use 				"${data_clean}\Latinobarometro_1997_final.dta", clear
	foreach 			y in 1998 2000 2001	2002 2003 2004 2005 2006 2007 2008 ///
							2009 2010 2011 2015 2016 2017 2018 {
		append 				using "${data_clean}\Latinobarometro_`y'_final.dta"
		erase				"${data_clean}\Latinobarometro_`y'_final.dta"
	}
	save 				"${data_clean}\Latinobarometro_final.dta", replace
	erase				"${data_clean}\Latinobarometro_1997_final.dta"

*Create a dummy version of each variable 
	gen 				s5 = .
	replace	 			s5 = 1 if s5_string == "Casado/ Conviviente" | ///
							s5_string == "Married/Living with partner"
	replace 			s5 = 2 if s5_string == "Separado/Divorciado/Viudo" | ///
							s5_string == "Separated/Divorced/Widow/er"
	replace 			s5 = 3 if s5_string == "Single" | s5_string == "Soltero"
	replace 			s5 = 4 if s5 == .

	gen 				s16 = .
	replace 			s16 = 1 if s16_string == "Very bad" | s16_string == "Muy malo"
	replace 			s16 = 2 if s16_string == "Bad" | s16_string == "Malo"
	replace 			s16 = 3 if s16_string == "Average" | s16_string == "Regular" | ///
							s16_string == "Not bad"
	replace 			s16 = 4 if s16_string == "Good" | s16_string == "Bueno"
	replace 			s16 = 5 if s16_string == "Very good" | s16_string == "Muy  bueno"

	gen 				sp21 = .
	replace 			sp21 = 1 if sp21_string == "Most people can be trusted" | ///
							sp21_string == "You can trust most people"
	replace 			sp21 = 0 if sp21_string == "One can never be too careful when dealing with others" | ///
							sp21_string == "You can never be too careful when dealing with others"

	gen 				sp31 = .
	replace 			sp31 = 1 if sp31_string == "Democracy is preferable to any other kind of government"
	replace 			sp31 = 0 if sp31_string == "For people like me, it does not matter whether we have a dem" | ///
							sp31_string=="For people like me, it doesn’t matter whether we have a demo" | ///
							sp31_string=="Under some circumstances, an authoritarian government can be"

	gen 				sp32 = .
	replace 			sp32 = 1 if sp32_string == "Mas bien satisfecho" | ///
							sp32_string == "Muy satisfecho" | ///
							sp32_string == "Quite satisfied" | ///
							sp32_string == "Rather satisfied" | ///
							sp32_string == "Very satisfied"
	replace 			sp32 = 0 if sp32_string == "Nada satisfecho" | ///
							sp32_string == "Not at all satisfied" | ///
							sp32_string == "Not very satisfied"

	gen 				sp63a = .
	replace 			sp63a = 1 if sp63a_string == "A lot of confidence" | ///
							sp63a_string == "Lot" | ///
							sp63a_string == "Mucha" | ///
							sp63a_string == "Algo" | ///
							sp63a_string == "Some" | ///
							sp63a_string == "Some confidence"
	replace 			sp63a = 0 if sp63a_string == "Little" | ///
							sp63a_string=="Little confidence" | ///
							sp63a_string=="Ninguna" | ///
							sp63a_string=="No confidence at all" | ///
							sp63a_string=="Nothing" | ///
							sp63a_string=="Poca" 

	gen 				sp63b = .
	replace 			sp63b = 1 if sp63b_string == "A lot of confidence" | ///
							sp63b_string == "Lot" | ///
							sp63b_string == "Mucha" | ///
							sp63b_string == "Algo" | ///
							sp63b_string == "Some" | ///
							sp63b_string == "Some confidence"
	replace 			sp63b = 0 if sp63b_string == "Little" | ///
							sp63b_string == "Little confidence" | ///
							sp63b_string == "Ninguna" | ///
							sp63b_string == "No confidence at all" | ///
							sp63b_string == "Nothing" | ///
							sp63b_string == "Poca" 

	gen 				sp63c = .
	replace 			sp63c = 1 if sp63c_string == "A lot of confidence" | ///
							sp63c_string == "Lot" | ///
							sp63c_string == "Mucha" | ///
							sp63c_string == "Algo" | ///
							sp63c_string == "Some" | ///
							sp63c_string == "Some confidence"
	replace 			sp63c = 0 if sp63c_string == "A little" | ///
							sp63c_string == "Little" | ///
							sp63c_string == "Little confidence" | ///
							sp63c_string == "Ninguna" | ///
							sp63c_string == "No confidence at all" | ///
							sp63c_string == "Nothing" | ///
							sp63c_string == "Poca" 

	gen 				sp63d = .
	replace 			sp63d = 1 if sp63d_string == "A lot of confidence" | ///
							sp63d_string == "Lot" | ///
							sp63d_string == "Mucha" | ///
							sp63d_string == "Algo" | ///
							sp63d_string == "Some" | ///
							sp63d_string == "Some confidence"
	replace 			sp63d = 0 if sp63d_string == "A little" | ///
							sp63d_string == "Little" | ///
							sp63d_string == "Little confidence" | ///
							sp63d_string == "Ninguna" | ///
							sp63d_string == "No confidence at all" | ///
							sp63d_string == "Nothing" | ///
							sp63d_string == "Poca"  | ///
							sp63d_string == "No trust"

	gen 				sp63e = .
	replace 			sp63e = 1 if sp63e_string == "A lot of confidence" | ///
							sp63e_string == "Lot" | ///
							sp63e_string == "Mucha" | ///
							sp63e_string == "Algo" | ///
							sp63e_string == "Some" | ///
							sp63e_string == "Some confidence"
	replace 			sp63e = 0 if sp63e_string == "A little" | ///
							sp63e_string == "Little" | ///
							sp63e_string == "Little confidence" | ///
							sp63e_string == "Ninguna" | ///
							sp63e_string == "No confidence at all" | ///
							sp63e_string == "Nothing" | ///
							sp63e_string == "Poca"  | ///
							sp63e_string == "No trust"

	gen 				sp63f = .
	replace 			sp63f = 1 if sp63f_string == "A lot of confidence" | ///
							sp63f_string == "Lot" | ///
							sp63f_string == "Mucha" | ///
							sp63f_string == "Algo" | ///
							sp63f_string == "Some" | ///
							sp63f_string == "Some confidence"
	replace 			sp63f = 0 if sp63f_string == "A little" | ///
							sp63f_string == "Little" | ///
							sp63f_string == "Little confidence" | ///
							sp63f_string == "Ninguna" | ///
							sp63f_string == "No confidence at all" | ///
							sp63f_string == "Nothing" | ///
							sp63f_string == "Poca"  | ///
							sp63f_string == "No trust"

	gen 				sp63g = .
	replace 			sp63g = 1 if sp63g_string == "A lot of confidence" | ///
							sp63g_string == "Lot" | ///
							sp63g_string == "Mucha" | ///
							sp63g_string == "Algo" | ///
							sp63g_string == "Some" | ///
							sp63g_string == "Some confidence"
	replace 			sp63g = 0 if sp63g_string == "A little" | ///
							sp63g_string == "Little" | ///
							sp63g_string == "Little confidence" | ///
							sp63g_string == "Ninguna" | ///
							sp63g_string == "No confidence at all" | ///
							sp63g_string == "Nothing" | ///
							sp63g_string == "Poca"  | ///
							sp63g_string == "No trust"

	gen 				p63stc = .
	replace 			p63stc = 1 if p63stc_string == "A lot of confidence" | ///
							p63stc_string=="Lot" | ///
							p63stc_string=="A lot" | ///
							p63stc_string=="Mucha" | ///
							p63stc_string=="Algo" | ///
							p63stc_string=="Some" | ///
							p63stc_string=="Some confidence"
	replace 			p63stc = 0 if p63stc_string == "A little" | ///
							p63stc_string=="Little" | ///
							p63stc_string=="Little confidence" | ///
							p63stc_string=="Ninguna" | ///
							p63stc_string=="No confidence at all" | ///
							p63stc_string=="Nothing" | ///
							p63stc_string=="Poca"  | ///
							p63stc_string=="No trust" | ///
							p63stc_string=="None"

	gen 				p34std = .
	replace 			p34std = 1 if p34std_string == "A lot of confidence" | ///
							p34std_string=="Lot" | ///
							p34std_string=="A lot" | ///
							p34std_string=="Mucha" | ///
							p34std_string=="Algo" | ///
							p34std_string=="Some" | ///
							p34std_string=="Some confidence"
	replace 			p34std = 0 if p34std_string == "A little" | ///
							p34std_string=="Little" | ///
							p34std_string=="Little confidence" | ///
							p34std_string=="Ninguna" | ///
							p34std_string=="No confidence at all" | ///
							p34std_string=="Nothing" | ///
							p34std_string=="Poca"  | ///
							p34std_string=="No trust" | ///
							p34std_string=="None"

	gen 				P20ST_I = .
	replace 			P20ST_I = 1 if P20ST_I_string == "A lot of confidence" | ///
							P20ST_I_string == "Lot" | ///
							P20ST_I_string == "A lot" | ///
							P20ST_I_string == "Mucha" | ///
							P20ST_I_string == "Algo" | ///
							P20ST_I_string == "Some" | ///
							P20ST_I_string == "Some confidence"
	replace 			P20ST_I = 0 if P20ST_I_string == "A little" | ///
							P20ST_I_string == "Little" | ///
							P20ST_I_string == "Little confidence" | ///
							P20ST_I_string == "Ninguna" | ///
							P20ST_I_string == "No confidence at all" | ///
							P20ST_I_string == "Nothing" | ///
							P20ST_I_string == "Poca"  | ///
							P20ST_I_string == "No trust" | ///
							P20ST_I_string == "None" | ///
							P20ST_I_string == "No confidence"

	gen 				P16ST_G = .
	replace 			P16ST_G = 1 if P16ST_G_string == "A lot of confidence" | ///
							P16ST_G_string=="Lot" | ///
							P16ST_G_string=="A lot" | ///
							P16ST_G_string=="Mucha" | ///
							P16ST_G_string=="Algo" | ///
							P16ST_G_string=="Some" | ///
							P16ST_G_string=="Some confidence"
	replace 			P16ST_G = 0 if P16ST_G_string == "A little" | ///
							P16ST_G_string=="Little" | ///
							P16ST_G_string=="Little confidence" | ///
							P16ST_G_string=="Ninguna" | ///
							P16ST_G_string=="No confidence at all" | ///
							P16ST_G_string=="Nothing" | ///
							P16ST_G_string=="Poca" | ///
							P16ST_G_string=="No trust" | ///
							P16ST_G_string=="None" | ///
							P16ST_G_string=="No confidence"

	gen 				sp37 = .
	replace 			sp37 = 1 if sp37_string == "The way you vote can change the way things will be in the fu"
	replace 			sp37 = 0 if sp37_string == "No matter how you vote, things will not improve in the futur"

	gen 				sp21_v2 = .
	replace 			sp21_v2 = 1 if sp21_string == "One can never be too careful when dealing with others" | ///
							sp21_string == "You can never be too careful when dealing with others"
	replace 			sp21_v2 = 0 if sp21_string == "Most people can be trusted" | ///
							sp21_string == "You can trust most people"

	gen 				sp31_v2 = .
	replace 			sp31_v2 = 1 if sp31_string == "For people like me, it does not matter whether we have a dem" | ///
							sp31_string == "For people like me, it doesn’t matter whether we have a demo" 
	replace 			sp31_v2 = 0 if sp31_string == "Democracy is preferable to any other kind of government" | ///
							sp31_string == "Under some circumstances, an authoritarian government can be"

	gen 				sp32_v2 = .
	replace 			sp32_v2 = 1 if sp32_string == "Nada satisfecho" | ///
							sp32_string == "Not at all satisfied" 
	replace 			sp32_v2 = 0 if sp32_string == "Mas bien satisfecho" | ///
							sp32_string == "Muy satisfecho" | ///
							sp32_string == "Quite satisfied" | ///
							sp32_string == "Rather satisfied" | ///
							sp32_string == "Very satisfied" | ///
							sp32_string == "Not very satisfied"

	gen 				sp63a_v2 = .
	replace 			sp63a_v2 = 1 if sp63a_string == "Ninguna" | ///
							sp63a_string == "No confidence at all" | ///
							sp63a_string == "Nothing" 
	replace 			sp63a_v2 = 0 if sp63a_string == "A lot of confidence" | ///
							sp63a_string == "Lot" | ///
							sp63a_string == "Mucha" | ///
							sp63a_string == "Algo" | ///
							sp63a_string == "Some" | ///
							sp63a_string == "Some confidence" | ///
							sp63a_string == "Little" | ///
							sp63a_string == "Little confidence" | ///
							sp63a_string == "Poca" 

	gen 				sp63b_v2 = .
	replace 			sp63b_v2 = 1 if sp63b_string == "Ninguna" | ///
							sp63b_string=="No confidence at all" | ///
							sp63b_string=="Nothing" 
	replace 			sp63b_v2 = 0 if sp63b_string == "A lot of confidence" | ///
							sp63b_string=="Lot" | ///
							sp63b_string=="Mucha" | ///
							sp63b_string=="Algo" | ///
							sp63b_string=="Some" | ///
							sp63b_string=="Some confidence" | ///
							sp63b_string=="Little" | ///
							sp63b_string=="Little confidence" | ///
							sp63b_string=="Poca" 

	gen 				sp63c_v2 = .
	replace 			sp63c_v2 = 1 if sp63c_string == "Ninguna" | ///
							sp63c_string == "No confidence at all" | ///
							sp63c_string == "Nothing" 
	replace 			sp63c_v2 = 0 if sp63c_string == "A lot of confidence" | ///
							sp63c_string == "Lot" | ///
							sp63c_string == "Mucha" | ///
							sp63c_string == "Algo" | ///
							sp63c_string == "Some" | ///
							sp63c_string == "Some confidence" | ///
							sp63c_string == "A little" | ///
							sp63c_string == "Little" | ///
							sp63c_string == "Little confidence" | ///
							sp63c_string == "Poca" 

	gen 				sp63d_v2 = .
	replace 			sp63d_v2 = 1 if sp63d_string == "Ninguna" | ///
							sp63d_string == "No confidence at all" | ///
							sp63d_string == "Nothing" | ///
							sp63d_string == "No trust"
	replace 			sp63d_v2 = 0 if sp63d_string == "A lot of confidence" | ///
							sp63d_string == "Lot" | ///
							sp63d_string == "Mucha" | ///
							sp63d_string == "Algo" | ///
							sp63d_string == "Some" | ///
							sp63d_string == "Some confidence" | ///
							sp63d_string == "A little" | ///
							sp63d_string == "Little" | ///
							sp63d_string == "Little confidence" | ///
							sp63d_string == "Poca"  

	gen 				sp63e_v2 = .
	replace 			sp63e_v2 = 1 if sp63e_string == "Ninguna" | ///
							sp63e_string == "No confidence at all" | ///
							sp63e_string == "Nothing" | ///
							sp63e_string == "No trust"
	replace 			sp63e_v2 = 0 if sp63e_string == "A lot of confidence" | ///
							sp63e_string == "Lot" | ///
							sp63e_string == "Mucha" | ///
							sp63e_string == "Algo" | ///
							sp63e_string == "Some" | ///
							sp63e_string == "Some confidence" | ///
							sp63e_string == "A little" | ///
							sp63e_string == "Little" | ///
							sp63e_string == "Little confidence" | ///
							sp63e_string == "Poca"  

	gen 				sp63f_v2 = .
	replace 			sp63f_v2 = 1 if sp63f_string == "Ninguna" | ///
							sp63f_string == "No confidence at all" | ///
							sp63f_string == "Nothing" | ///
							sp63f_string == "No trust"
	replace 			sp63f_v2 = 0 if sp63f_string == "A lot of confidence" | ///
							sp63f_string == "Lot" | ///
							sp63f_string == "Mucha" | ///
							sp63f_string == "Algo" | ///
							sp63f_string == "Some" | ///
							sp63f_string == "Some confidence" | ///
							sp63f_string == "A little" | ///
							sp63f_string == "Little" | ///
							sp63f_string == "Little confidence" | ///
							sp63f_string == "Poca"  

	gen 				sp63g_v2 = .
	replace 			sp63g_v2 = 1 if sp63g_string == "Ninguna" | ///
							sp63g_string == "No confidence at all" | ///
							sp63g_string == "Nothing" | ///
							sp63g_string == "No trust"
	replace 			sp63g_v2 = 0 if sp63g_string == "A lot of confidence" | ///
							sp63g_string == "Lot" | ///
							sp63g_string == "Mucha" | ///
							sp63g_string == "Algo" | ///
							sp63g_string == "Some" | ///
							sp63g_string == "Some confidence" | ///
							sp63g_string == "A little" | ///
							sp63g_string == "Little" | ///
							sp63g_string == "Little confidence" | ///
							sp63g_string == "Poca"  

	gen 				p63stc_v2 = .
	replace 			p63stc_v2 = 1 if p63stc_string == "Ninguna" | ///
							p63stc_string == "No confidence at all" | ///
							p63stc_string == "Nothing" | ///
							p63stc_string == "No trust" | ///
							p63stc_string == "None"
	replace 			p63stc_v2 = 0 if p63stc_string == "A lot of confidence" | ///
							p63stc_string == "Lot" | ///
							p63stc_string == "A lot" | ///
							p63stc_string == "Mucha" | ///
							p63stc_string == "Algo" | ///
							p63stc_string == "Some" | ///
							p63stc_string == "Some confidence" | ///
							p63stc_string == "A little" | ///
							p63stc_string == "Little" | ///
							p63stc_string == "Little confidence" | ///
							p63stc_string == "Poca"  

	gen 				p34std_v2 = .
	replace 			p34std_v2 = 1 if p34std_string == "Ninguna" | ///
							p34std_string == "No confidence at all" | ///
							p34std_string == "Nothing" | ///
							p34std_string == "No trust" | ///
							p34std_string == "None"
	replace 			p34std_v2 = 0 if p34std_string == "A lot of confidence" | ///
							p34std_string == "Lot" | ///
							p34std_string == "A lot" | ///
							p34std_string == "Mucha" | ///
							p34std_string == "Algo" | ///
							p34std_string == "Some" | ///
							p34std_string == "Some confidence" | ///
							p34std_string == "A little" | ///
							p34std_string == "Little" | ///
							p34std_string == "Little confidence" | ///
							p34std_string == "Poca"  

	gen 				P20ST_I_v2 = .
	replace 			P20ST_I_v2 = 1 if P20ST_I_string == "Ninguna" | ///
							P20ST_I_string == "No confidence at all" | ///
							P20ST_I_string == "Nothing" | ///
							P20ST_I_string == "No trust" | ///
							P20ST_I_string == "None" | ///
							P20ST_I_string == "No confidence"
	replace 			P20ST_I_v2 = 0 if P20ST_I_string == "A lot of confidence" | ///
							P20ST_I_string == "Lot" | ///
							P20ST_I_string == "A lot" | ///
							P20ST_I_string == "Mucha" | ///
							P20ST_I_string == "Algo" | ///
							P20ST_I_string == "Some" | ///
							P20ST_I_string == "Some confidence" | ///
							P20ST_I_string == "A little" | ///
							P20ST_I_string == "Little" | ///
							P20ST_I_string == "Little confidence" | ///
							P20ST_I_string == "Poca"  

	gen 				P16ST_G_v2 = .
	replace 			P16ST_G_v2 = 1 if P16ST_G_string == "Ninguna" | ///
							P16ST_G_string == "No confidence at all" | ///
							P16ST_G_string == "Nothing" | ///
							P16ST_G_string == "No trust" | ///
							P16ST_G_string == "None" | ///
							P16ST_G_string == "No confidence"
	replace 			P16ST_G_v2=0 if P16ST_G_string == "A lot of confidence" | ///
							P16ST_G_string == "Lot" | ///
							P16ST_G_string == "A lot" | ///
							P16ST_G_string == "Mucha" | ///
							P16ST_G_string == "Algo" | ///
							P16ST_G_string == "Some" | ///
							P16ST_G_string == "Some confidence" | ///
							P16ST_G_string == "A little" | ///
							P16ST_G_string == "Little" | ///
							P16ST_G_string == "Little confidence" | ///
							P16ST_G_string == "Poca"

	gen 				sp37_v2 = .
	replace 			sp37_v2 = 1 if sp37_string == "No matter how you vote, things will not improve in the futur"
	replace 			sp37_v2 = 0 if sp37_string == "The way you vote can change the way things will be in the fu"

* Create county variable from city names
	gen 				comuna = ""
	replace 			ciudad_string = upper(ciudad_string)
	replace 			ciudad_string = usubinstr(ciudad_string, "ñ", "N", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "á", "A", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "é", "E", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "í", "I", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "ó", "O", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "ú", "U", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "Ñ", "N", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "Á", "A", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "É", "E", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "Í", "I", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "Ó", "O", .)
	replace 			ciudad_string = usubinstr(ciudad_string, "Ú", "U", .)

	replace 			comuna = "ANTOFAGASTA" if ciudad_string == "CL: ANTOFAGASTA-ANTOFAGASTA"
	replace 			comuna = "CALAMA" if ciudad_string == "CL: ANTOFAGASTA-CALAMA"
	replace 			comuna = "MARIA ELENA" if ciudad_string == "CL: ANTOFAGASTA-MARIA ELENA"
	replace 			comuna = "MEJILLONES" if ciudad_string == "CL: ANTOFAGASTA-MEJILLONES"
	replace 			comuna = "ANTOFAGASTA" if ciudad_string == "CL: ANTOFAGASTA-PAPOSO"
	replace 			comuna = "TALTAL" if ciudad_string == "CL: ANTOFAGASTA-SANTA LUISA"
	replace 			comuna = "SIERRA GORDA" if ciudad_string == "CL: ANTOFAGASTA-SIERRA GORDA"
	replace 			comuna = "TOCOPILLA" if ciudad_string == "CL: ANTOFAGASTA-TOCOPILLA"
	replace 			comuna = "ARICA" if ciudad_string == "CL: ARICA Y PARINACOTA-ARICA"
	replace 			comuna = "PUTRE" if ciudad_string == "CL: ARICA Y PARINACOTA-PUTRE"
	replace 			comuna = "ARICA" if ciudad_string == "CL: ARICA Y PARINACOTA-VILLA FRONTERA"
	replace 			comuna = "CHANARAL" if ciudad_string == "CL: ATACAMA-CHANARAL"
	replace 			comuna = "COPIAPO" if ciudad_string == "CL: ATACAMA-COPIAPO"
	replace 			comuna = "COPIAPO" if ciudad_string == "CL: ATACAMA-COPIAPO"
	replace 			comuna = "COPIAPO" if ciudad_string == "CL: ATACAMA-COPIAP�"
	replace 			comuna = "TIERRA AMARILLA" if ciudad_string == "CL: ATACAMA-TIEERA AMARILLA"
	replace 			comuna = "VALLENAR" if ciudad_string == "CL: ATACAMA-VALLENAR"
	replace 			comuna = "COYHAIQUE" if ciudad_string == "CL: AYSEN DEL GENERAL CARLOS IBANEZ DEL CAMPO-BALMACEDA"
	replace 			comuna = "CHILE CHICO" if ciudad_string == "CL: AYSEN DEL GENERAL CARLOS IBANEZ DEL CAMPO-CHILE CHICO"
	replace 			comuna = "COYHAIQUE" if ciudad_string == "CL: AYSEN DEL GENERAL CARLOS IBANEZ DEL CAMPO-COIHAIQUE"
	replace 			comuna = "COYHAIQUE" if ciudad_string == "CL: AYSEN DEL GENERAL CARLOS IBANEZ DEL CAMPO-EL BLANCO"
	replace 			comuna = "AISEN" if ciudad_string == "CL: AYS�N DEL GENERAL CARLOS IB��EZ DEL CAMPO-AYS�N"
	replace 			comuna = "COYHAIQUE" if ciudad_string == "CL: AYS�N DEL GENERAL CARLOS IB��EZ DEL CAMPO-COIHAIQUE"
	replace 			comuna = "LOS ALAMOS" if ciudad_string == "CL: BIO BIO-ANTIHUALA"
	replace 			comuna = "ARAUCO" if ciudad_string == "CL: BIO BIO-ARAUCO"
	replace 			comuna = "ARAUCO" if ciudad_string == "CL: BIO BIO-ARAUCO-RAMADILLAS"
	replace 			comuna = "BULNES" if ciudad_string == "CL: BIO BIO-BULNES"
	replace 			comuna = "CONTULMO" if ciudad_string == "CL: BIO BIO-CALEBU"
	replace 			comuna = "YUNGAY" if ciudad_string == "CL: BIO BIO-CAMPANARIO"
	replace 			comuna = "CHIGUAYANTE" if ciudad_string == "CL: BIO BIO-CHIGUAYANTE"
	replace 			comuna = "CHILLAN" if ciudad_string == "CL: BIO BIO-CHILLAN"
	replace 			comuna = "COELEMU" if ciudad_string == "CL: BIO BIO-COELEMU"
	replace 			comuna = "CONCEPCION" if ciudad_string == "CL: BIO BIO-CONCEPCION"
	replace 			comuna = "CONTULMO" if ciudad_string == "CL: BIO BIO-CONTULMO"
	replace 			comuna = "FLORIDA" if ciudad_string == "CL: BIO BIO-COPIULEMU"
	replace 			comuna = "CORONEL" if ciudad_string == "CL: BIO BIO-CORONEL"
	replace 			comuna = "EL CARMEN" if ciudad_string == "CL: BIO BIO-EL CARMEN"
	replace 			comuna = "YUMBEL" if ciudad_string == "CL: BIO BIO-EL LITRE"
	replace 			comuna = "" if ciudad_string == "CL: BIO BIO-EL RECURSO"
	replace 			comuna = "FLORIDA" if ciudad_string == "CL: BIO BIO-FLORIDA"
	replace 			comuna = "HUALPEN" if ciudad_string == "CL: BIO BIO-HUALPEN"
	replace 			comuna = "HUALQUI" if ciudad_string == "CL: BIO BIO-HUALQUI"
	replace 			comuna = "LOS ANGELES" if ciudad_string == "CL: BIO BIO-LA VICTORIA"
	replace 			comuna = "ARAUCO" if ciudad_string == "CL: BIO BIO-LARAQUETE"
	replace 			comuna = "LEBU" if ciudad_string == "CL: BIO BIO-LEBU"
	replace 			comuna = "LOS ANGELES" if ciudad_string == "CL: BIO BIO-LLANO BLANCO"
	replace 			comuna = "LOS ANGELES" if ciudad_string == "CL: BIO BIO-LOS ANGELES"
	replace 			comuna = "LOTA" if ciudad_string == "CL: BIO BIO-LOTA"
	replace 			comuna = "" if ciudad_string == "CL: BIO BIO-MANZANAL"
	replace 			comuna = "LOS ANGELES" if ciudad_string == "CL: BIO BIO-MILLANTU"
	replace 			comuna = "NACIMIENTO" if ciudad_string == "CL: BIO BIO-NACIMIENTO"
	replace 			comuna = "PEMUCO" if ciudad_string == "CL: BIO BIO-PEMUCO"
	replace 			comuna = "PENCO" if ciudad_string == "CL: BIO BIO-PENCO"
	replace 			comuna = "CURANILAHUE" if ciudad_string == "CL: BIO BIO-PICHIARAUCO"
	replace 			comuna = "ARAUCO" if ciudad_string == "CL: BIO BIO-PICHILO"
	replace 			comuna = "PINTO" if ciudad_string == "CL: BIO BIO-PINTO"
	replace 			comuna = "HUALPEN" if ciudad_string == "CL: BIO BIO-PUERTO SUR"
	replace 			comuna = "TOME" if ciudad_string == "CL: BIO BIO-PUNTA DE PARRA"
	replace 			comuna = "CHILLAN" if ciudad_string == "CL: BIO BIO-QUINCHAMALI"
	replace 			comuna = "SAN CARLOS" if ciudad_string == "CL: BIO BIO-SAN CARLOS"
	replace 			comuna = "SAN IGNACIO" if ciudad_string == "CL: BIO BIO-SAN IGNACIO"
	replace 			comuna = "SAN NICOLAS" if ciudad_string == "CL: BIO BIO-SAN NICOLAS"
	replace 			comuna = "SAN PEDRO DE LA PAZ" if ciudad_string == "CL: BIO BIO-SAN PEDRO DE LA PAZ"
	replace 			comuna = "SAN ROSENDO" if ciudad_string == "CL: BIO BIO-SAN ROSENDO"
	replace 			comuna = "LOS ANGELES" if ciudad_string == "CL: BIO BIO-SANTA FE"
	replace 			comuna = "SANTA JUANA" if ciudad_string == "CL: BIO BIO-SANTA JUANA"
	replace 			comuna = "LOS ALAMOS" if ciudad_string == "CL: BIO BIO-SARA DE LEBU"
	replace 			comuna = "TALCAHUANO" if ciudad_string == "CL: BIO BIO-TALCAHUANO"
	replace 			comuna = "HUALQUI" if ciudad_string == "CL: BIO BIO-TALCAMAVIDA"
	replace 			comuna = "TIRUA" if ciudad_string == "CL: BIO BIO-TIRUA"
	replace 			comuna = "TOME" if ciudad_string == "CL: BIO BIO-TOME"
	replace 			comuna = "CONCEPCION" if ciudad_string == "CL: BIO BIO-VILLA VERDE"
	replace 			comuna = "YUMBEL" if ciudad_string == "CL: BIO BIO-YUMBEL"
	replace 			comuna = "CHILLAN VIEJO" if ciudad_string == "CL: BIO BIO-NUBLE-CHILLAN VIEJO"
	replace 			comuna = "CHIGUAYANTE" if ciudad_string == "CL: B�O B�O-CHIGUAYANTE"
	replace 			comuna = "CHILLAN" if ciudad_string == "CL: B�O B�O-CHILL�N"
	replace 			comuna = "CONCEPCION" if ciudad_string == "CL: B�O B�O-CONCEPCI�N"
	replace 			comuna = "CORONEL" if ciudad_string == "CL: B�O B�O-CORONEL"
	replace 			comuna = "HUALPEN" if ciudad_string == "CL: B�O B�O-HUALP�N"
	replace 			comuna = "SAN PEDRO DE LA PAZ" if ciudad_string == "CL: B�O B�O-HUERTOS FAMILIARES"
	replace 			comuna = "LOS ANGELES" if ciudad_string == "CL: B�O B�O-LOS �NGELES"
	replace 			comuna = "LOTA" if ciudad_string == "CL: B�O B�O-LOTA"
	replace 			comuna = "PENCO" if ciudad_string == "CL: B�O B�O-PENCO"
	replace 			comuna = "QUILACO" if ciudad_string == "CL: B�O B�O-QUILACO"
	replace 			comuna = "QUIRIHUE" if ciudad_string == "CL: B�O B�O-QUIRIHUE"
	replace 			comuna = "CURANILAHUE" if ciudad_string == "CL: B�O B�O-SAN JOS� DE COLICO"
	replace 			comuna = "SAN PEDRO DE LA PAZ" if ciudad_string == "CL: B�O B�O-SAN PEDRO DE LA PAZ"
	replace 			comuna = "SANTA BARBARA" if ciudad_string == "CL: B�O B�O-SANTA B�RBARA"
	replace 			comuna = "TALCAHUANO" if ciudad_string == "CL: B�O B�O-TALCAHUANO"
	replace 			comuna = "TOME" if ciudad_string == "CL: B�O B�O-TOM�"
	replace 			comuna = "TUCAPEL" if ciudad_string == "CL: B�O B�O-TUCAPEL"
	replace 			comuna = "CONCEPCION" if ciudad_string == "CL: B�O B�O-VILLA VERDE"
	replace 			comuna = "LA SERENA" if ciudad_string == "CL: COQUIMBO-CERES"
	replace 			comuna = "COMBARBALA" if ciudad_string == "CL: COQUIMBO-COMBARBAL�"
	replace 			comuna = "COQUIMBO" if ciudad_string == "CL: COQUIMBO-COQUIMBO"
	replace 			comuna = "VICUNA" if ciudad_string == "CL: COQUIMBO-EL TAMBO"
	replace 			comuna = "ILLAPEL" if ciudad_string == "CL: COQUIMBO-ILLAPEL"
	replace 			comuna = "OVALLE" if ciudad_string == "CL: COQUIMBO-LA CHIMBA"
	replace 			comuna = "LA SERENA" if ciudad_string == "CL: COQUIMBO-LA SERENA"
	replace 			comuna = "LA SERENA" if ciudad_string == "CL: COQUIMBO-LA SERENA-ISLON"
	replace 			comuna = "VICUNA" if ciudad_string == "CL: COQUIMBO-LAS CA�AS"
	replace 			comuna = "LOS VILOS" if ciudad_string == "CL: COQUIMBO-LOS VILOS"
	replace 			comuna = "MONTE PATRIA" if ciudad_string == "CL: COQUIMBO-MONTE PATRIA"
	replace 			comuna = "COQUIMBO" if ciudad_string == "CL: COQUIMBO-NUEVA VIDA"
	replace 			comuna = "OVALLE" if ciudad_string == "CL: COQUIMBO-OVALLE"
	replace 			comuna = "PAIHUANO" if ciudad_string == "CL: COQUIMBO-PAIGUANO"
	replace 			comuna = "PUNITAQUI" if ciudad_string == "CL: COQUIMBO-PUNITAQUI"
	replace 			comuna = "SALAMANCA" if ciudad_string == "CL: COQUIMBO-SALAMANCA"
	replace 			comuna = "COQUIMBO" if ciudad_string == "CL: COQUIMBO-TONGOY"
	replace 			comuna = "VICUNA" if ciudad_string == "CL: COQUIMBO-VICUNA"
	replace 			comuna = "ANGOL" if ciudad_string == "CL: LA ARAUCANIA-ANGOL"
	replace 			comuna = "VILCUN" if ciudad_string == "CL: LA ARAUCANIA-CAJON"
	replace 			comuna = "CHOLCHOL" if ciudad_string == "CL: LA ARAUCANIA-CHOLCHOL"
	replace 			comuna = "CUNCO" if ciudad_string == "CL: LA ARAUCANIA-CUNCO"
	replace 			comuna = "ERCILLA" if ciudad_string == "CL: LA ARAUCANIA-ERCILLA"
	replace 			comuna = "FREIRE" if ciudad_string == "CL: LA ARAUCANIA-FREIRE"
	replace 			comuna = "FREIRE" if ciudad_string == "CL: LA ARAUCANIA-FREIRE-EL RADAL"
	replace 			comuna = "GORBEA" if ciudad_string == "CL: LA ARAUCANIA-GORBEA"
	replace 			comuna = "GORBEA" if ciudad_string == "CL: LA ARAUCANIA-GORBEA-LASTARRIA"
	replace 			comuna = "LONCOCHE" if ciudad_string == "CL: LA ARAUCANIA-LA PAZ"
	replace 			comuna = "TEMUCO" if ciudad_string == "CL: LA ARAUCANIA-LABRANZA"
	replace 			comuna = "VILCUN" if ciudad_string == "CL: LA ARAUCANIA-LAS VIOLETAS"
	replace 			comuna = "LAUTARO" if ciudad_string == "CL: LA ARAUCANIA-LAUTARO"
	replace 			comuna = "LONCOCHE" if ciudad_string == "CL: LA ARAUCANIA-LONCOLECHE"
	replace 			comuna = "PADRE LAS CASAS" if ciudad_string == "CL: LA ARAUCANIA-METRENCO"
	replace 			comuna = "NUEVA IMPERIAL" if ciudad_string == "CL: LA ARAUCANIA-NUEVA IMPERIAL"
	replace 			comuna = "PADRE LAS CASAS" if ciudad_string == "CL: LA ARAUCANIA-PADRE DE LAS CASAS"
	replace 			comuna = "PERQUENCO" if ciudad_string == "CL: LA ARAUCANIA-PERQUENCO"
	replace 			comuna = "PITRUFQUEN" if ciudad_string == "CL: LA ARAUCANIA-PITRUFQUEN"
	replace 			comuna = "FREIRE" if ciudad_string == "CL: LA ARAUCANIA-QUEPE"
	replace 			comuna = "RENAICO" if ciudad_string == "CL: LA ARAUCANIA-RENAICO"
	replace 			comuna = "SAN RAMON" if ciudad_string == "CL: LA ARAUCANIA-SAN RAMON"
	replace 			comuna = "TEMUCO" if ciudad_string == "CL: LA ARAUCANIA-TEMUCO"
	replace 			comuna = "TEODORO SCHMIDT" if ciudad_string == "CL: LA ARAUCANIA-TEODORO SCHMIDT"
	replace 			comuna = "VILCUN" if ciudad_string == "CL: LA ARAUCANIA-VILCUN"
	replace 			comuna = "TEMUCO" if ciudad_string == "CL: LA ARAUCANIA-VILLA SANTA LUISA"
	replace 			comuna = "ANGOL" if ciudad_string == "CL: LA ARAUCAN�A-ANGOL"
	replace 			comuna = "LUMACO" if ciudad_string == "CL: LA ARAUCAN�A-CAPITAN PASTENE"
	replace 			comuna = "COLLIPULLI" if ciudad_string == "CL: LA ARAUCAN�A-ESPERANZA"
	replace 			comuna = "PITRUFQUEN" if ciudad_string == "CL: LA ARAUCAN�A-MAHUIDANCHE"
	replace 			comuna = "MELIPEUCO" if ciudad_string == "CL: LA ARAUCAN�A-MELIPEUCO"
	replace 			comuna = "PADRE LAS CASAS" if ciudad_string == "CL: LA ARAUCAN�A-PADRE DE LAS CASAS"
	replace 			comuna = "TEMUCO" if ciudad_string == "CL: LA ARAUCAN�A-TEMUCO"
	replace 			comuna = "GRANEROS" if ciudad_string == "CL: LIBERTADOR BERNARDO OHIGGINS-GRANEROS"
	replace 			comuna = "NANCAGUA" if ciudad_string == "CL: LIBERTADOR BERNARDO O�HIGGINS-APALTA"
	replace 			comuna = "QUINTA DE TILCOCO" if ciudad_string == "CL: LIBERTADOR BERNARDO O�HIGGINS-EL CARRIZAL"
	replace 			comuna = "LAS CABRAS" if ciudad_string == "CL: LIBERTADOR BERNARDO O�HIGGINS-LAS CABRAS"
	replace 			comuna = "PALMILLA" if ciudad_string == "CL: LIBERTADOR BERNARDO O�HIGGINS-PALMILLA"
	replace 			comuna = "RANCAGUA" if ciudad_string == "CL: LIBERTADOR BERNARDO O�HIGGINS-RANCAGUA"
	replace 			comuna = "SAN FERNANDO" if ciudad_string == "CL: LIBERTADOR BERNARDO O�HIGGINS-SAN FERNANDO"
	replace 			comuna = "" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-CHAMAVIDA SOTO"
	replace 			comuna = "CODEGUA" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-CODEGUA"
	replace 			comuna = "CODEGUA" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-CODEGUA-LA BLANQUINA"
	replace 			comuna = "COINCO" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-COINCO"
	replace 			comuna = "DONIHUE" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-DONIHUE"
	replace 			comuna = "REQUINOA" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-EL ABRA"
	replace 			comuna = "" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-EL MEDIO"
	replace 			comuna = "" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-FLOR DEL VALLE"
	replace 			comuna = "GRANEROS" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-GRANEROS"
	replace 			comuna = "OLIVAR" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-GULTRO"
	replace 			comuna = "" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-LA CHICA"
	replace 			comuna = "RENGO" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-LA PUNTA"
	replace 			comuna = "PLACILLA" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-LA TUNA"
	replace 			comuna = "" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-LA YANINA"
	replace 			comuna = "LAS CABRAS" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-LAS CABRAS"
	replace 			comuna = "PLACILLA" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-LO MOSCOSO"
	replace 			comuna = "MACHALI" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-MACHALI"
	replace 			comuna = "MOSTAZAL" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-MOSTAZAL"
	replace 			comuna = "NANCAGUA" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-NANCAGUA"
	replace 			comuna = "OLIVAR" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-OLIVAR"
	replace 			comuna = "MALLOA" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-PELEQUEN"
	replace 			comuna = "RANCAGUA" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-RANCAGUA"
	replace 			comuna = "RENGO" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-RENGO"
	replace 			comuna = "REQUINOA" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-REQUINOA"
	replace 			comuna = "SAN FERNANDO" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-SAN FERNANDO"
	replace 			comuna = "MOSTAZAL" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-SAN FRANCISCO DE MOSTAZAL"
	replace 			comuna = "SAN VICENTE" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-SAN VICENTE DE TAGUA"
	replace 			comuna = "" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-SANTA ANITA"
	replace 			comuna = "SANTA CRUZ" if ciudad_string == "CL: LIBERTADOR BERNARDO O´HIGGINS-SANTA CRUZ"
	replace 			comuna = "PUERTO MONTT" if ciudad_string == "CL: LOS LAGOS-ALERCE"
	replace 			comuna = "OSORNO" if ciudad_string == "CL: LOS LAGOS-CAIPULLI"
	replace 			comuna = "PURRANQUE" if ciudad_string == "CL: LOS LAGOS-CONCORDIA"
	replace 			comuna = "MAULLIN" if ciudad_string == "CL: LOS LAGOS-EL CARRIZO"
	replace 			comuna = "PUYEHUE" if ciudad_string == "CL: LOS LAGOS-ENTRELAGOS"
	replace 			comuna = "FRESIA" if ciudad_string == "CL: LOS LAGOS-FRESIA"
	replace 			comuna = "FRUTILLAR" if ciudad_string == "CL: LOS LAGOS-FRUTILLAR"
	replace 			comuna = "PURRANQUE" if ciudad_string == "CL: LOS LAGOS-FRUTILLAR-CORTE ALTO"
	replace 			comuna = "PUERTO MONTT" if ciudad_string == "CL: LOS LAGOS-HUELMO"
	replace 			comuna = "LA UNION" if ciudad_string == "CL: LOS LAGOS-LA UNION"
	replace 			comuna = "PUERTO OCTAY" if ciudad_string == "CL: LOS LAGOS-LAS GAVIOTAS"
	replace 			comuna = "LLANQUIHUE" if ciudad_string == "CL: LOS LAGOS-LLANQUIHUE"
	replace 			comuna = "LOS MUERMOS" if ciudad_string == "CL: LOS LAGOS-LOS MUERMOS"
	replace 			comuna = "MAULLIN" if ciudad_string == "CL: LOS LAGOS-MAULLIN"
	replace 			comuna = "MAULLIN" if ciudad_string == "CL: LOS LAGOS-MAULLIN-QUENUIR"
	replace 			comuna = "OSORNO" if ciudad_string == "CL: LOS LAGOS-OSORNO"
	replace 			comuna = "PAILLACO" if ciudad_string == "CL: LOS LAGOS-PICHIRROPULLI"
	replace 			comuna = "PUYEHUE" if ciudad_string == "CL: LOS LAGOS-PILMAIQUEN"
	replace 			comuna = "PUYEHUE" if ciudad_string == "CL: LOS LAGOS-PILMAIQU�N"
	replace 			comuna = "PUERTO MONTT" if ciudad_string == "CL: LOS LAGOS-PUERTO MONTT"
	replace 			comuna = "PUERTO MONTT" if ciudad_string == "CL: LOS LAGOS-PUERTO MONTT-PIEDRA AZUL"
	replace 			comuna = "PUERTO VARAS" if ciudad_string == "CL: LOS LAGOS-PUERTO VARAS"
	replace 			comuna = "PURRANQUE" if ciudad_string == "CL: LOS LAGOS-PURRANQUE"
	replace 			comuna = "RIO NEGRO" if ciudad_string == "CL: LOS LAGOS-RIO NEGRO"
	replace 			comuna = "LLANQUIHUE" if ciudad_string == "CL: LOS LAGOS-SAN JUAN"
	replace 			comuna = "SAN PABLO" if ciudad_string == "CL: LOS LAGOS-SAN PABLO"
	replace 			comuna = "CORRAL" if ciudad_string == "CL: LOS RIOS-CORRAL"
	replace 			comuna = "LAGO RANCO" if ciudad_string == "CL: LOS RIOS-LAGO RANCO"
	replace 			comuna = "SAN JAVIER" if ciudad_string == "CL: LOS RIOS-SAN JAVIER"
	replace 			comuna = "VALDIVIA" if ciudad_string == "CL: LOS RIOS-VALDIVIA"
	replace 			comuna = "VALDIVIA" if ciudad_string == "CL: LOS RIOS-VALDIVIA-LANCO"
	replace 			comuna = "VALDIVIA" if ciudad_string == "CL: LOS RIOS-VALDIVIA-MEHUIN"
	replace 			comuna = "VALDIVIA" if ciudad_string == "CL: LOS RIOS-VALDIVIA-NIEBLA"
	replace 			comuna = "VALDIVIA" if ciudad_string == "CL: LOS RIOS-VALDIVIA-PAILLACO"
	replace 			comuna = "LAGO RANCO" if ciudad_string == "CL: LOS R�OS-LAGO RANCO"
	replace 			comuna = "VALDIVIA" if ciudad_string == "CL: LOS R�OS-VALDIVIA"
	replace 			comuna = "PORVENIR" if ciudad_string == "CL: MAGALLANES Y LA ANTARTIDA CHILENA-PORVENIR"
	replace 			comuna = "NATALES" if ciudad_string == "CL: MAGALLANES Y LA ANTARTIDA CHILENA-PUERTO NATALES"
	replace 			comuna = "PUNTA ARENAS" if ciudad_string == "CL: MAGALLANES Y LA ANTARTIDA CHILENA-PUNTA ARENAS"
	replace 			comuna = "PUNTA ARENAS" if ciudad_string == "CL: MAGALLANES Y LA ANT�RTIDA CHILENA-PUNTA ARENAS"
	replace 			comuna = "CAUQUENES" if ciudad_string == "CL: MAULE-CAUQUENES"
	replace 			comuna = "CAUQUENES" if ciudad_string == "CL: MAULE-CAUQUENES-LA VEGA"
	replace 			comuna = "COLBUN" if ciudad_string == "CL: MAULE-COLBUN"
	replace 			comuna = "TENO" if ciudad_string == "CL: MAULE-COMALLE"
	replace 			comuna = "CUREPTO" if ciudad_string == "CL: MAULE-CUREPTO"
	replace 			comuna = "CURICO" if ciudad_string == "CL: MAULE-CURICO"
	replace 			comuna = "CURICO" if ciudad_string == "CL: MAULE-CURIC�"
	replace 			comuna = "SAN CLEMENTE" if ciudad_string == "CL: MAULE-EL COLORADO"
	replace 			comuna = "" if ciudad_string == "CL: MAULE-EL ORIENTE"
	replace 			comuna = "HUALANE" if ciudad_string == "CL: MAULE-HUALANE"
	replace 			comuna = "HUALANE" if ciudad_string == "CL: MAULE-LA HUERTA"
	replace 			comuna = "CONSTITUCION" if ciudad_string == "CL: MAULE-LA VI�ILLA"
	replace 			comuna = "CONSTITUCION" if ciudad_string == "CL: MAULE-LAS CANAS"
	replace 			comuna = "LICANTEN" if ciudad_string == "CL: MAULE-LICANT�N"
	replace 			comuna = "LINARES" if ciudad_string == "CL: MAULE-LINARES"
	replace 			comuna = "LONGAVI" if ciudad_string == "CL: MAULE-LONGAVI"
	replace 			comuna = "" if ciudad_string == "CL: MAULE-LOS BALTROS"
	replace 			comuna = "SAN JAVIER" if ciudad_string == "CL: MAULE-MARIMAURA"
	replace 			comuna = "MAULE" if ciudad_string == "CL: MAULE-MAULE"
	replace 			comuna = "MOLINA" if ciudad_string == "CL: MAULE-MOLINA"
	replace 			comuna = "PALMILLA" if ciudad_string == "CL: MAULE-PALMILLA"
	replace 			comuna = "TALCA" if ciudad_string == "CL: MAULE-PANGUILEMO"
	replace 			comuna = "PARRAL" if ciudad_string == "CL: MAULE-PARRAL"
	replace 			comuna = "PENCAHUE" if ciudad_string == "CL: MAULE-PENCAHUE"
	replace 			comuna = "QUIRIHUE" if ciudad_string == "CL: MAULE-POCILLAS"
	replace 			comuna = "RAUCO" if ciudad_string == "CL: MAULE-RAUCO"
	replace 			comuna = "ROMERAL" if ciudad_string == "CL: MAULE-ROMERAL"
	replace 			comuna = "SAGRADA FAMILIA" if ciudad_string == "CL: MAULE-SAGRADA FAMILIA"
	replace 			comuna = "SAN CLEMENTE" if ciudad_string == "CL: MAULE-SAN CLEMENTE"
	replace 			comuna = "SAN CLEMENTE" if ciudad_string == "CL: MAULE-SAN DIEGO NORTE"
	replace 			comuna = "TALCA" if ciudad_string == "CL: MAULE-SAN VALENTIN"
	replace 			comuna = "YERBAS BUENAS" if ciudad_string == "CL: MAULE-SANTA ANA DE QUERI"
	replace 			comuna = "CAUQUENES" if ciudad_string == "CL: MAULE-SANTA SOFIA"
	replace 			comuna = "TALCA" if ciudad_string == "CL: MAULE-TALCA"
	replace 			comuna = "TALCA" if ciudad_string == "CL: MAULE-TALCA-CUMPEO"
	replace 			comuna = "TALCA" if ciudad_string == "CL: MAULE-TALCA-LO FIGUEROA"
	replace 			comuna = "TENO" if ciudad_string == "CL: MAULE-TENO"
	replace 			comuna = "SAN JAVIER" if ciudad_string == "CL: MAULE-VAQUERIA"
	replace 			comuna = "TENO" if ciudad_string == "CL: MAULE-VENTANA EL ALTO"
	replace 			comuna = "CURICO" if ciudad_string == "CL: MAULE-VILLA LOS NICHES"
	replace 			comuna = "CALERA DE TANGO" if ciudad_string == "CL: METROPOLITANA-BAJOS DE SAN AGUSTIN"
	replace 			comuna = "LO BARNECHEA" if ciudad_string == "CL: METROPOLITANA-BARNECHEA"
	replace 			comuna = "BUIN" if ciudad_string == "CL: METROPOLITANA-BUIN"
	replace 			comuna = "BUIN" if ciudad_string == "CL: METROPOLITANA-BUIN"
	replace 			comuna = "BUIN" if ciudad_string == "CL: METROPOLITANA-BUIN-ALTO JAHUEL"
	replace 			comuna = "BUIN" if ciudad_string == "CL: METROPOLITANA-BU�N"
	replace 			comuna = "CALERA DE TANGO" if ciudad_string == "CL: METROPOLITANA-CALERA DE TANGO"
	replace 			comuna = "" if ciudad_string == "CL: METROPOLITANA-CAMINO COQUIMBO"
	replace 			comuna = "PAINE" if ciudad_string == "CL: METROPOLITANA-CAMPUSANO"
	replace 			comuna = "CERRILLOS" if ciudad_string == "CL: METROPOLITANA-CERRILLOS"
	replace 			comuna = "CERRILLOS" if ciudad_string == "CL: METROPOLITANA-CERRILLOS RURAL"
	replace 			comuna = "CERRO NAVIA" if ciudad_string == "CL: METROPOLITANA-CERRONAVIA"
	replace 			comuna = "COLINA" if ciudad_string == "CL: METROPOLITANA-COLINA"
	replace 			comuna = "PENAFLOR" if ciudad_string == "CL: METROPOLITANA-COLONIA ALEMANA"
	replace 			comuna = "CONCHALI" if ciudad_string == "CL: METROPOLITANA-CONCHALI"
	replace 			comuna = "CURACAVI" if ciudad_string == "CL: METROPOLITANA-CURACAVI"
	replace 			comuna = "CURACAVI" if ciudad_string == "CL: METROPOLITANA-CURACAVI"
	replace 			comuna = "EL BOSQUE" if ciudad_string == "CL: METROPOLITANA-EL BOSQUE"
	replace 			comuna = "EL CARMEN" if ciudad_string == "CL: METROPOLITANA-EL CARMEN"
	replace 			comuna = "PUENTE ALTO" if ciudad_string == "CL: METROPOLITANA-EL PERAL"
	replace 			comuna = "TILTIL" if ciudad_string == "CL: METROPOLITANA-EL ROBLE"
	replace 			comuna = "ESTACION CENTRAL" if ciudad_string == "CL: METROPOLITANA-ESTACION CENTRAL"
	replace 			comuna = "" if ciudad_string == "CL: METROPOLITANA-HOSPITAL"
	replace 			comuna = "HUECHURABA" if ciudad_string == "CL: METROPOLITANA-HUECHURABA"
	replace 			comuna = "TILTIL" if ciudad_string == "CL: METROPOLITANA-HUERTOS FAMILIARES"
	replace 			comuna = "INDEPENDENCIA" if ciudad_string == "CL: METROPOLITANA-INDEPENDENCIA"
	replace 			comuna = "LA CISTERNA" if ciudad_string == "CL: METROPOLITANA-LA CISTERNA"
	replace 			comuna = "LA FLORIDA" if ciudad_string == "CL: METROPOLITANA-LA FLORIDA"
	replace 			comuna = "LA GRANJA" if ciudad_string == "CL: METROPOLITANA-LA GRANJA"
	replace 			comuna = "LA PINTANA" if ciudad_string == "CL: METROPOLITANA-LA PINTANA"
	replace 			comuna = "LA REINA" if ciudad_string == "CL: METROPOLITANA-LA REINA"
	replace 			comuna = "LAS CONDES" if ciudad_string == "CL: METROPOLITANA-LAS CONDES"
	replace 			comuna = "SAN JOSE DE MAIPO" if ciudad_string == "CL: METROPOLITANA-LAS VERTIENTES"
	replace 			comuna = "ESTACION CENTRAL" if ciudad_string == "CL: METROPOLITANA-LEYDA"
	replace 			comuna = "LO ESPEJO" if ciudad_string == "CL: METROPOLITANA-LO ESPEJO"
	replace 			comuna = "LO PRADO" if ciudad_string == "CL: METROPOLITANA-LO PRADO"
	replace 			comuna = "MACUL" if ciudad_string == "CL: METROPOLITANA-LOS ESPINOS"
	replace 			comuna = "MACUL" if ciudad_string == "CL: METROPOLITANA-MACUL"
	replace 			comuna = "MAIPU" if ciudad_string == "CL: METROPOLITANA-MAIPU"
	replace 			comuna = "MELIPILLA" if ciudad_string == "CL: METROPOLITANA-MELIPILLA"
	replace 			comuna = "EL MONTE" if ciudad_string == "CL: METROPOLITANA-PAICO ALTO"
	replace 			comuna = "PAINE" if ciudad_string == "CL: METROPOLITANA-PAINE"
	replace 			comuna = "PEDRO AGUIRRE CERDA" if ciudad_string == "CL: METROPOLITANA-PEDRO AGUIRRE CERDA"
	replace 			comuna = "PENAFLOR" if ciudad_string == "CL: METROPOLITANA-PENAFLOR"
	replace 			comuna = "PENALOLEN" if ciudad_string == "CL: METROPOLITANA-PENALOLEN"
	replace 			comuna = "PENAFLOR" if ciudad_string == "CL: METROPOLITANA-PE�AFLOR"
	replace 			comuna = "PIRQUE" if ciudad_string == "CL: METROPOLITANA-PIRQUE"
	replace 			comuna = "PROVIDENCIA" if ciudad_string == "CL: METROPOLITANA-PROVIDENCIA"
	replace 			comuna = "PUDAHUEL" if ciudad_string == "CL: METROPOLITANA-PUDAHUEL"
	replace 			comuna = "PUENTE ALTO" if ciudad_string == "CL: METROPOLITANA-PUENTE ALTO"
	replace 			comuna = "QUILICURA" if ciudad_string == "CL: METROPOLITANA-QUILICURA"
	replace 			comuna = "QUINTA NORMAL" if ciudad_string == "CL: METROPOLITANA-QUINTA NORMAL"
	replace 			comuna = "RECOLETA" if ciudad_string == "CL: METROPOLITANA-RECOLETA"
	replace 			comuna = "RENCA" if ciudad_string == "CL: METROPOLITANA-RENCA"
	replace 			comuna = "SAN BERNARDO" if ciudad_string == "CL: METROPOLITANA-SAN BERNARDO"
	replace 			comuna = "SAN JOAQUIN" if ciudad_string == "CL: METROPOLITANA-SAN JOAQUIN"
	replace 			comuna = "SAN JOSE DE MAIPO" if ciudad_string == "CL: METROPOLITANA-SAN JOS� DE MAIPO"
	replace 			comuna = "SAN MIGUEL" if ciudad_string == "CL: METROPOLITANA-SAN MIGUEL"
	replace 			comuna = "SANTIAGO" if ciudad_string == "CL: METROPOLITANA-SAN RAMON"
	replace 			comuna = "SANTIAGO" if ciudad_string == "CL: METROPOLITANA-SANTA LUZ"
	replace 			comuna = "SANTIAGO" if ciudad_string == "CL: METROPOLITANA-SANTA RITA"
	replace 			comuna = "SANTIAGO" if ciudad_string == "CL: METROPOLITANA-SANTIAGO ,"
	replace 			comuna = "SANTIAGO" if ciudad_string == "CL: METROPOLITANA-SANTIAGO-CUEVAS"
	replace 			comuna = "EL MONTE" if ciudad_string == "CL: METROPOLITANA-SANTIAGO-EL MONTE"
	replace 			comuna = "LAMPA" if ciudad_string == "CL: METROPOLITANA-SANTIAGO-LAMPA"
	replace 			comuna = "SANTIAGO" if ciudad_string == "CL: METROPOLITANA-SANTIAGO-RIOMAR"
	replace 			comuna = "TALAGANTE" if ciudad_string == "CL: METROPOLITANA-TALAGANTE"
	replace 			comuna = "TALAGANTE" if ciudad_string == "CL: METROPOLITANA-TALAGANTE-PADRE HUR"
	replace 			comuna = "TILTIL" if ciudad_string == "CL: METROPOLITANA-TIL TIL"
	replace 			comuna = "PAINE" if ciudad_string == "CL: METROPOLITANA-VALDIVIA DE PAINE"
	replace 			comuna = "LA FLORIDA" if ciudad_string == "CL: METROPOLITANA-VILLA LAS MERCEDES"
	replace 			comuna = "VITACURA" if ciudad_string == "CL: METROPOLITANA-VITACURA"
	replace 			comuna = "NUNOA" if ciudad_string == "CL: METROPOLITANA-NUNOA"
	replace 			comuna = "ALTO HOSPICIO" if ciudad_string == "CL: TARAPACA-ALTO HOSPICIO"
	replace 			comuna = "IQUIQUE" if ciudad_string == "CL: TARAPACA-IQUIQUE"
	replace 			comuna = "ALTO HOSPICIO" if ciudad_string == "CL: TARAPACA-ALTO HOSPICIO"
	replace 			comuna = "CAMINA" if ciudad_string == "CL: TARAPACA-CAMINA"
	replace 			comuna = "IQUIQUE" if ciudad_string == "CL: TARAPACA-IQUIQUE"
	replace 			comuna = "POZO ALMONTE" if ciudad_string == "CL: TARAPACA-POZO ALMONTE"
	replace 			comuna = "ALTO HOSPICIO" if ciudad_string == "CL: TARAPAC�-ALTO HOSPICIO"
	replace 			comuna = "IQUIQUE" if ciudad_string == "CL: TARAPAC�-IQUIQUE"
	replace 			comuna = "CALLE LARGA" if ciudad_string == "CL: VALPARAISO-CALLE LARGA"
	replace 			comuna = "CONCON" if ciudad_string == "CL: VALPARAISO-CONCON"
	replace 			comuna = "HIJUELAS" if ciudad_string == "CL: VALPARAISO-HIJUELAS"
	replace 			comuna = "LA CALERA" if ciudad_string == "CL: VALPARAISO-LA CALERA"
	replace 			comuna = "LOS ANDES" if ciudad_string == "CL: VALPARAISO-LOS ANDES"
	replace 			comuna = "LOS ANDES" if ciudad_string == "CL: VALPARAISO-LOS ANDES-SANTA TEREZA"
	replace 			comuna = "OLMUE" if ciudad_string == "CL: VALPARAISO-OLMUE"
	replace 			comuna = "" if ciudad_string == "CL: VALPARAISO-PUEBLO DE INDIOS"
	replace 			comuna = "QUILLOTA" if ciudad_string == "CL: VALPARAISO-QUILLOTA"
	replace 			comuna = "QUILPUE" if ciudad_string == "CL: VALPARAISO-QUILPUE"
	replace 			comuna = "SAN ANTONIO" if ciudad_string == "CL: VALPARAISO-SAN ANTONIO"
	replace 			comuna = "SAN FELIPE" if ciudad_string == "CL: VALPARAISO-SAN FELIPE"
	replace 			comuna = "VALPARAISO" if ciudad_string == "CL: VALPARAISO-VALPARAISO"
	replace 			comuna = "VILLA ALEMANA" if ciudad_string == "CL: VALPARAISO-VILLA ALEMANA"
	replace 			comuna = "VINA DEL MAR" if ciudad_string == "CL: VALPARAISO-VINA DEL MAR"
	replace 			comuna = "ALGARROBO" if ciudad_string == "CL: VALPARAISO-ALGARROBO"
	replace 			comuna = "SANTO DOMINGO" if ciudad_string == "CL: VALPARAISO-BARRANCAS"
	replace 			comuna = "CABILDO" if ciudad_string == "CL: VALPARAISO-CABILDO"
	replace 			comuna = "CALLE LARGA" if ciudad_string == "CL: VALPARAISO-CALLE LARGA"
	replace 			comuna = "PUCHUNCAVI" if ciudad_string == "CL: VALPARAISO-CAMPICHE"
	replace 			comuna = "CASABLANCA" if ciudad_string == "CL: VALPARAISO-CASABLANCA"
	replace 			comuna = "CATEMU" if ciudad_string == "CL: VALPARAISO-CATEMU"
	replace 			comuna = "CONCON" if ciudad_string == "CL: VALPARAISO-CONCON"
	replace 			comuna = "PUCHUNCAVI" if ciudad_string == "CL: VALPARAISO-EL RINCON"
	replace 			comuna = "EL TABO" if ciudad_string == "CL: VALPARAISO-EL TABO"
	replace 			comuna = "CARTAGENA" if ciudad_string == "CL: VALPARAISO-EL TURCO"
	replace 			comuna = "" if ciudad_string == "CL: VALPARAISO-GUALCAPE"
	replace 			comuna = "HIJUELAS" if ciudad_string == "CL: VALPARAISO-HIJUELAS"
	replace 			comuna = "CALLE LARGA" if ciudad_string == "CL: VALPARAISO-LA CALDERA"
	replace 			comuna = "LA CALERA" if ciudad_string == "CL: VALPARAISO-LA CALERA"
	replace 			comuna = "LA CRUZ" if ciudad_string == "CL: VALPARAISO-LA CRUZ"
	replace 			comuna = "" if ciudad_string == "CL: VALPARAISO-LA PLAYA"
	replace 			comuna = "EL TABO" if ciudad_string == "CL: VALPARAISO-LAS CRUCES"
	replace 			comuna = "CASABLANCA" if ciudad_string == "CL: VALPARAISO-LAS DICHAS"
	replace 			comuna = "LIMACHE" if ciudad_string == "CL: VALPARAISO-LIMACHE"
	replace 			comuna = "LLAY-LLAY" if ciudad_string == "CL: VALPARAISO-LLAYLLAY"
	replace 			comuna = "CASABLANCA" if ciudad_string == "CL: VALPARAISO-LO VASQUEZ"
	replace 			comuna = "LOS ANDES" if ciudad_string == "CL: VALPARAISO-LOS ANDES"
	replace 			comuna = "NOGALES" if ciudad_string == "CL: VALPARAISO-NOGALES"
	replace 			comuna = "OLMUE" if ciudad_string == "CL: VALPARAISO-OLMUE"
	replace 			comuna = "PANQUEHUE" if ciudad_string == "CL: VALPARAISO-PANQUEHUE"
	replace 			comuna = "VALPARAISO" if ciudad_string == "CL: VALPARAISO-PLACILLA DE PENUELAS"
	replace 			comuna = "PUCHUNCAVI" if ciudad_string == "CL: VALPARAISO-PUCHUNCAVI"
	replace 			comuna = "QUILLOTA" if ciudad_string == "CL: VALPARAISO-PUEBLO DE INDIOS"
	replace 			comuna = "QUILLOTA" if ciudad_string == "CL: VALPARAISO-QUILLOTA"
	replace 			comuna = "QUILPUE" if ciudad_string == "CL: VALPARAISO-QUILPUE"
	replace 			comuna = "QUINTERO" if ciudad_string == "CL: VALPARAISO-QUINTERO"
	replace 			comuna = "RINCONADA" if ciudad_string == "CL: VALPARAISO-RINCONADA"
	replace 			comuna = "SAN ANTONIO" if ciudad_string == "CL: VALPARAISO-SAN ANTONIO"
	replace 			comuna = "SAN ESTEBAN" if ciudad_string == "CL: VALPARAISO-SAN ESTEBAN"
	replace 			comuna = "SAN FELIPE" if ciudad_string == "CL: VALPARAISO-SAN FELIPE"
	replace 			comuna = "EL QUISCO" if ciudad_string == "CL: VALPARAISO-SAN ISIDRO"
	replace 			comuna = "QUINTERO" if ciudad_string == "CL: VALPARAISO-SANTA ADELA"
	replace 			comuna = "QUILPUE" if ciudad_string == "CL: VALPARAISO-TRINIDAD"
	replace 			comuna = "VALPARAISO" if ciudad_string == "CL: VALPARAISO-VALPARAISO"
	replace 			comuna = "VILLA ALEMANA" if ciudad_string == "CL: VALPARAISO-VILLA ALEMANA"
	replace 			comuna = "VINA DEL MAR" if ciudad_string == "CL: VALPARAISO-VINA DEL MAR"
	replace 			comuna = "LOS ANDES" if ciudad_string == "CL: VALPARA�SO-CARACOLES"
	replace 			comuna = "CASABLANCA" if ciudad_string == "CL: VALPARA�SO-CASABLANCA"
	replace 			comuna = "EL QUISCO" if ciudad_string == "CL: VALPARA�SO-EL QUISCO"
	replace 			comuna = "LA CALERA" if ciudad_string == "CL: VALPARA�SO-LA CALERA"
	replace 			comuna = "PUTAENDO" if ciudad_string == "CL: VALPARA�SO-LO HIDALGO"
	replace 			comuna = "LOS ANDES" if ciudad_string == "CL: VALPARA�SO-LOS ANDES"
	replace 			comuna = "PAPUDO" if ciudad_string == "CL: VALPARA�SO-PAPUDO"
	replace 			comuna = "VALPARAISO" if ciudad_string == "CL: VALPARA�SO-PLACILLA DE PE�UELAS"
	replace 			comuna = "LOS ANDES" if ciudad_string == "CL: VALPARA�SO-PLAZA VIEJA"
	replace 			comuna = "QUILLOTA" if ciudad_string == "CL: VALPARA�SO-QUILLOTA"
	replace 			comuna = "QUILPUE" if ciudad_string == "CL: VALPARA�SO-QUILPU�"
	replace 			comuna = "SAN ANTONIO" if ciudad_string == "CL: VALPARA�SO-SAN ANTONIO"
	replace 			comuna = "SAN FELIPE" if ciudad_string == "CL: VALPARA�SO-SAN FELIPE"
	replace 			comuna = "SANTA MARIA" if ciudad_string == "CL: VALPARA�SO-SANTA MAR�A"
	replace 			comuna = "VALPARAISO" if ciudad_string == "CL: VALPARA�SO-VALPARA�SO"
	replace 			comuna = "VILLA ALEMANA" if ciudad_string == "CL: VALPARA�SO-VILLA ALEMANA"
	replace 			comuna = "VINA DEL MAR" if ciudad_string == "CL: VALPARA�SO-VI�A DEL MAR"
	replace 			comuna = "SANTIAGO" if ciudad_string == "CL: METROPOLITANA-SANTIAGO"
	replace 			comuna = "CERRO NAVIA" if ciudad_string == "CL: METROPOLITANA-CERRO  NAVIA"

* Create cleaned cohort variable (adjust by survey year)
	gen 				cohort = .
	replace 			cohort = s2 + 2020 - numinves

	save 				"${data_clean}\latinobarometro_final.dta", replace

/*******************************************************************************
 13. Final Main Dataset
********************************************************************************/

* The created DB are merged
	use 				"${data_clean}\vacunacion.dta", clear
	merge 				1:1 code cohort using "${data_clean}\proyecciones_getario.dta", nogen
	merge 				m:1 code using "${data_clean}\fase1.dta", nogen
	merge 				m:1 code using "${data_clean}\fallecidos.dta", nogen
	merge 				m:1 code using "${data_clean}\casos_incrementales.dta", nogen
	merge 				m:1 comuna using "${data_clean}\personas_juridicas.dta", keep(master match) nogen
	merge 				1:1 comuna cohort using "${data_clean}\turnout.dta", keep(master match) nogen
	merge 				m:1 comuna using "${data_clean}\state_repression.dta"

* Create impressionable years indicators 
	gen 				impy1 = 0
	replace 			impy1 = 1 if cohort == 49 | cohort == 73
	replace 			impy1 = 2 if cohort == 50 | cohort == 72
	replace 			impy1 = 3 if cohort == 51 | cohort == 71
	replace 			impy1 = 4 if cohort == 52 | cohort == 70
	replace 			impy1 = 5 if cohort == 53 | cohort == 69
	replace 			impy1 = 6 if cohort == 54 | cohort == 68
	replace 			impy1 = 7 if cohort == 55 | cohort == 67
	replace 			impy1 = 8 if cohort > 55 & cohort < 67
	gen 				impy2 = 0
	replace 			impy2 = 1 if cohort == 63 | cohort == 73
	replace 			impy2 = 2 if cohort == 64 | cohort == 72
	replace 			impy2 = 3 if cohort == 65 | cohort == 71
	replace 			impy2 = 4 if cohort > 65 & cohort<71

* Create share variables
	gen 				sh_vac_may23=vac_acc_may23/p_proj
	gen 				sh_vac_ontime4=vac_ontime4/p_proj
	gen 				shVictims_70_10=shVictims_70/10

* Create main sample indicator
	gen 				main_sample = 1
	bysort 				comuna: egen vac_acc_may23_comuna = total(vac_acc_may23) if cohort > 30
	bysort 				comuna: egen p_proj_comuna = total(p_proj) if cohort > 30
	gen 				sh_vac_may23_comuna = vac_acc_may23_comuna/p_proj_comuna 
	replace 			main_sample = 0 if sh_vac_may23_comuna > 1
	drop 				vac_acc_may23_comuna p_proj_comuna sh_vac_may23_comuna

* Rename/clean main state repression variales
	drop 				Dregimientos
	rename 				Dregimientos_Revised1 Dregimientos
	rename 				ln_dist_to_closest_mil_fac2_rev ln_dist_mil_fac
	gen 				DMilfac50 = dist_to_closest_mil_fac2 <= 50
	gen 				DMilfac100 = dist_to_closest_mil_fac2 <= 100
	sum 				dist_to_closest_mil_fac2
	gen 				DMilfacmean = dist_to_closest_mil_fac2 <= `r(mean)'
	gen 				ln_centro_det = ln(1+CentroDetencion)

* Create interaction variables
	foreach 			var of varlist shVictims_70 shVictims_70_10 DVictims ///
							DCentroDetencion CentroDetencion ln_centro_det Dregimientos ///
							ln_dist_mil_fac DMilfac50 DMilfac100 {
		gen 				`var'_impy1 = `var'*impy1
		gen 				`var'_impy2 = `var'*impy2
	}
	
* Clean missing values in control variables
	foreach				var of varlist Pop70 sh_rural_70 ///
							share_allende70 share_alessandri70 {
		gen					`var'_cond = `var'
		gen					`var'_miss = missing(`var')
		sum					`var'
		replace				`var'_cond = `r(mean)' if `var'_miss == 1
	}

* Variabel labels
	label var 			sh_vac_may23 "Vaccination rate at May 23"
	label var 			sh_vac_ontime4 "On-Time vaccination rate"
	label var 			ln_dist_mil_fac "Ln distance to military facility"
	label var 			DCentroDetencion "Any detention centers"
	label var 			ln_centro_det "Ln 1 + detention centers"
	label var 			ln_dist_mil_fac_impy1 "Ln distance to military facility $\times$ Imp. Years (1973-1990)"
	label var 			ln_dist_mil_fac_impy2 "Ln distance to military facility $\times$ Imp. Years (1973-1976)"
	label var 			Dregimientos_impy1 "Indicator military presence $\times$ Imp. Years (1973-1990)"
	label var 			Dregimientos_impy2 "Indicator military presence $\times$ Imp. Years (1973-1976)"
	label var 			shVictims_70_impy1 "Victims per 10,000 inhab $\times$ Imp. Years (1973-1990)"
	label var 			shVictims_70_impy2 "Victims per 10,000 inhab $\times$ Imp. Years (1973-1976)"
	label var 			shVictims_70_10_impy1 "Victims per 1,000 inhab $\times$ Imp. Years (1973-1990)"
	label var 			shVictims_70_10_impy2 "Victims per 1,000 inhab $\times$ Imp. Years (1973-1976)"
	label var 			DVictims_impy1 "Any victims $\times$ Imp. Years (1973-1990)"
	label var 			DVictims_impy2 "Any victims $\times$ Imp. Years (1973-1976)"
	label var 			DCentroDetencion_impy1 "Any detention centers $\times$ Imp. Years (1973-1990)"
	label var 			DCentroDetencion_impy2 "Any detention centers $\times$ Imp. Years (1973-1976)"
	label var 			ln_centro_det_impy1 "Ln 1 + detention centers $\times$ Imp. Years (1973-1990)"
	label var 			ln_centro_det_impy2 "Ln 1 + detention centers $\times$ Imp. Years (1973-1976)"
	label var 			CentroDetencion_impy1 "Detention centers $\times$ Imp. Years (1973-1990)"
	label var 			CentroDetencion_impy2 "Detention centers $\times$ Imp. Years (1973-1976)"

	save 				"${data_clean}\finaldataset_main.dta", replace
	
/*******************************************************************************
 15. Final Secondary Datasets
********************************************************************************/

	use 				"${data_clean}\finaldataset_main.dta", clear

*Create agregated impressionable year variables (at county level) 
	bysort 				comuna: egen p_proj_county=total(p_proj)
	gen 				impy1_county=impy1*p_proj/p_proj_county
	gen 				impy2_county=impy2*p_proj/p_proj_county

*Collapse data at county x cohort level
	collapse 			(sum) p_proj vac_acc_may23 vac_ontime4 ///
							(max) impy1 impy2 impy1_county impy2_county ///
							shVictims_70 shVictims_70_10 DVictims ///
							DCentroDetencion CentroDetencion ln_centro_det Dregimientos ///
							ln_dist_mil_fac Pop70 sh_rural_70 lnDistStgo lnDistRegCapital ///
							IDProv share_allende70 share_alessandri70 Turnout70 ///
							landlocked Pop70_pthousands Houses_pc ///
							SocialOrg_pop70 churches_pop70 sh_educ_12more densidad_1970 ///
							sh_econactivepop_70 sh_women_70 TV ari_1973 index1b ///
							latitud longitud code casos_prevac p_jur DMilfac50 ///
							DMilfac100 DMilfacmean n_locales fall_prevac, ///
							by(comuna cohort)
							
* Clean missing values in control variables
	foreach				var of varlist Pop70 sh_rural_70 ///
							share_allende70 share_alessandri70 {
		gen					`var'_cond = `var'
		gen					`var'_miss = missing(`var')
		sum					`var'
		replace				`var'_cond = `r(mean)' if `var'_miss == 1
	}
							
	tempfile        	main_countycohort
	save            	`main_countycohort'
	
*Collapse data at county level
	collapse 			(sum) p_proj vac_acc_may23 vac_ontime4 impy1_county impy2_county  ///
							(max) shVictims_70 shVictims_70_10 DVictims ///
							DCentroDetencion CentroDetencion ln_centro_det Dregimientos ///
							ln_dist_mil_fac Pop70 sh_rural_70 lnDistStgo lnDistRegCapital ///
							IDProv share_allende70 share_alessandri70 Turnout70 ///
							landlocked Pop70_pthousands Houses_pc ///
							SocialOrg_pop70 churches_pop70 sh_educ_12more densidad_1970 ///
							sh_econactivepop_70 sh_women_70 TV ari_1973 index1b ///
							latitud longitud code casos_prevac p_jur DMilfac50 ///
							DMilfac100 DMilfacmean n_locales fall_prevac, ///
							by(comuna)

* Create interaction variables
	foreach 			var of varlist shVictims_70 shVictims_70_10 DVictims ///
							DCentroDetencion ln_centro_det CentroDetencion ///
							Dregimientos ln_dist_mil_fac DMilfac50 DMilfac100{
		gen 				`var'_impy1_county = `var'*impy1_county 
		gen 				`var'_impy2_county = `var'*impy2_county 
	}

* Create share variables
	gen 				sh_p_jur=(p_jur/p_proj)*1000
	gen 				sh_locales=(n_locales/p_proj)*1000
	gen 				sh_fall_prevac=fall_prevac/p_proj
	gen 				sh_casos_prevac=casos_prevac/p_proj
	
* Clean missing values in control variables
	foreach				var of varlist Pop70 sh_rural_70 ///
							share_allende70 share_alessandri70 {
		gen					`var'_cond = `var'
		gen					`var'_miss = missing(`var')
		sum					`var'
		replace				`var'_cond = `r(mean)' if `var'_miss == 1
	}
	
* Variabel labels
	label var 			ln_dist_mil_fac_impy1_county "Ln distance to military facility $\times$ County Imp. Years (1973-1990)"
	label var 			ln_dist_mil_fac_impy2_county "Ln distance to military facility $\times$ County Imp. Years (1973-1976)"
	label var 			Dregimientos_impy1_county "Indicator military presence $\times$ County Imp. Years (1973-1990)"
	label var 			Dregimientos_impy2_county "Indicator military presence $\times$ County Imp. Years (1973-1976)"
	label var 			sh_p_jur "Legal entities per 1,000 inhab."

	save 				"${data_clean}\finaldataset_countylevel.dta", replace

* LATINOBAROMETRO
	use 				"${data_clean}\latinobarometro_final.dta", clear
	merge 				m:1 comuna cohort using `main_countycohort', ///
							keep(match using) nogen
	
	save 				"${data_clean}\latinobarometro_final.dta", replace

* 1970 HEALTH STATISTICS (county level)
	import 				excel "${data_raw}\salud_1971.xlsx", sheet("Sheet3") firstrow clear
	merge 				m:1 comuna using "${data_clean}\finaldataset_countylevel", ///
							keep(match using) nogen
							
* Collapse data at county level
	collapse 			(sum) consultas leche ///
							(max) Dregimientos ln_dist_mil_fac Pop70 sh_rural_70 ///
							lnDistStgo lnDistRegCapital share_allende70 share_alessandri70 ///
							IDProv latitud longitud antivariolica antitifica ///
							antidifterica mixta antipoliomielitica ///
							antisarampionosa antiinlfuenza, ///
							by(comuna area)
* Create share variables 
	gen 				sh_consultas=consultas/Pop70
	gen 				sh_leche=leche/Pop70
		
* Variable labels 
	label var 			sh_consultas "Medical appointments per capita in 1971"
	label var 			sh_leche "Kg of milk distributed per capita in 1971"
	
	save 				"${data_clean}\health1970_county_final.dta", replace

* 1970 HEALTH STATISTICS (area level)

* Create share variables 
	bysort area:		egen Pop70_area=total(Pop70)
	gen 				Dregimientos_area=(Dregimientos*Pop70)/Pop70_area
	gen 				ln_dist_mil_fac_area=(ln_dist_mil_fac*Pop70)/Pop70_area
	gen 				sh_rural_70_area=(sh_rural_70*Pop70)/Pop70_area
	gen 				lnDistStgo_area=(lnDistStgo*Pop70)/Pop70_area
	gen 				lnDistRegCapital_area=(lnDistRegCapital*Pop70)/Pop70_area
	gen 				share_allende70_area=(share_allende70*Pop70)/Pop70_area
	gen 				share_alessandri70_area=(share_alessandri70*Pop70)/Pop70_area

* Collapse data at area level
	collapse 			(sum) Dregimientos_area ln_dist_mil_fac_area Pop70 ///
							sh_rural_70_area lnDistStgo_area lnDistRegCapital_area ///
							share_allende70_area share_alessandri70_area ///
							(max) antivariolica antitifica antidifterica mixta ///
							antipoliomielitica antisarampionosa antiinlfuenza, ///
							by(area)
							
*Create share variables 
	foreach 			var in antivariolica antitifica antidifterica mixta ///
							antipoliomielitica antisarampionosa antiinlfuenza {
		gen 				sh_`var'=`var'/Pop70
	}
	
* Variable labels 
	label var 			sh_antivariolica "Share of vaccinated pop. for variola in 1971"
	label var 			sh_antitifica "Share of vaccinated pop. for typhoid fever in 1971"
	label var 			sh_antidifterica "Share of vaccinated pop. for diphtheria in 1971"
	label var 			sh_mixta "Share of vaccinated pop. with mixed vaccine in 1971"
	label var 			sh_antipoliomielitica "Share of vaccinated pop. for poliomyelitis in 1971"
	label var 			sh_antisarampionosa "Share of vaccinated pop. for measles in 1971"
	label var 			sh_antiinlfuenza "Share of vaccinated pop. for influenza in 1971"
	
	save 				"${data_clean}\health1970_area_final.dta", replace

* MOBILITY
	use 				"${data_clean}\movilidad_isci.dta", clear
	merge 				m:1 comuna using "${data_clean}\finaldataset_countylevel", nogen
	
* Create lockdown, critic periods indicators, and interactions
	gen 				fase_1 = 0
	replace 			fase_1 = 1 if paso == 1
	gen 				critic_period = 0
	replace 			critic_period = 1 if semana >= 23 & semana < 35
	gen 				critic_period1 = 0
	replace 			critic_period1 = 1 if semana >= 23 & semana < 29
	gen 				critic_period2 = 0
	replace 			critic_period2 = 1 if semana >= 29 & semana <35
	gen 				f1_impy2=impy2_county*fase_1
	gen 				f1_impy1=impy1_county*fase_1
	gen 				impy2_cp1 = impy2_county*critic_period1
	gen 				impy2_cp2 = impy2_county*critic_period2
	gen 				impy2_cp = impy2_county*critic_period
	
	foreach 			milfac_var in shVictims_70_10 DVictims DCentroDetencion ///
							ln_centro_det ln_dist_mil_fac Dregimientos {
		gen 				`milfac_var'_f1 = `milfac_var'*fase_1
		gen 				`milfac_var'_f1_impy2 = `milfac_var'_impy2_county*fase_1
		gen 				`milfac_var'_f1_impy1 = `milfac_var'_impy1_county*fase_1
		gen 				`milfac_var'_impy2cp1=`milfac_var'_impy2_county*critic_period1
		gen 				`milfac_var'_impy2cp2=`milfac_var'_impy2_county*critic_period2
		gen 				`milfac_var'_impy2cp=`milfac_var'_impy2_county*critic_period
		gen 				`milfac_var'_cp1=`milfac_var'*critic_period1
		gen 				`milfac_var'_cp2=`milfac_var'*critic_period2
		gen 				`milfac_var'_cp=`milfac_var'*critic_period
	}
	
* Variable labels 
	label var 			ln_dist_mil_fac_f1 "Ln distance to military facility $\times$ Phase 1"
	label var 			Dregimientos_f1 "Indicator military presence $\times$ Phase 1"
	label var 			ln_dist_mil_fac_f1_impy2 "Ln distance to military facility $\times$ Phase 1 $\times$ County Imp. Years (1973-1976)"
	label var 			Dregimientos_f1_impy2 "Indicator military presence $\times$ Phase 1 $\times$ County County Imp. Years (1973-1976)"
	label var 			f1_impy2 "Phase 1 $\times$ Imp. Years (1973-1976)"
	label var 			f1_impy1 "Phase 1 $\times$ Imp. Years (1973-1990)"
	label var 			ln_dist_mil_fac_impy2cp1 "Ln distance to military facility $\times$ County Imp. Years (1973-1976) $\times$ Critical Period 1"
	label var 			Dregimientos_impy2cp1 "Indicator military presence $\times$ County Imp. Years (1973-1976) $\times$ Critical Period 1"
	label var 			ln_dist_mil_fac_impy2cp2 "Ln distance to military facility $\times$ County Imp. Years (1973-1976) $\times$ Critical Period 2"
	label var 			Dregimientos_impy2cp2 "Indicator military presence $\times$ County Imp. Years (1973-1976) $\times$ Critical Period 2"
	label var 			ln_dist_mil_fac_impy2cp "Ln distance to military facility $\times$ County Imp. Years (1973-1976) $\times$ Critical Period"
	label var 			Dregimientos_impy2cp "Indicator military presence $\times$ County Imp. Years (1973-1976) $\times$ Critical Period"
	label var 			ln_dist_mil_fac_cp1 "Ln distance to military facility $\times$ Critical Period 1"
	label var 			Dregimientos_cp1 "Indicator military presence $\times$ Critical Period 1"
	label var 			ln_dist_mil_fac_cp2 "Ln distance to military facility $\times$ Critical Period 2"
	label var 			Dregimientos_cp2 "Indicator military presence $\times$ Critical Period 2"
	label var 			ln_dist_mil_fac_cp "Ln distance to military facility $\times$ Critical Period"
	label var 			Dregimientos_cp "Indicator military presence $\times$ Critical Period"
	label var 			fase_1 "Phase 1"
	label var 			impy2_cp1 "County Imp. Years (1973-1976) $\times$ Critical Period 1"
	label var 			impy2_cp2 "County Imp. Years (1973-1976) $\times$ Critical Period 2"
	label var 			impy2_cp "County Imp. Years (1973-1976) $\times$ Critical Period"
	label var 			var_salidas "Mobility"
	label var 			sh_casos_prevac "Sh. COVID cases"
	label var 			sh_fall_prevac "Sh. COVID deaths"
	
	save 				"${data_clean}\movilidad_final.dta", replace

* FATALITIES
	use 				"${data_clean}\finaldataset_main.dta"
	gen 				age_group=""
	replace 			age_group="40a49" if cohort>=40 & cohort<50
	replace 			age_group="50a59" if cohort>=50 & cohort<60
	replace 			age_group="60a69" if cohort>=60 & cohort<70
	replace 			age_group="70a79" if cohort>=70 & cohort<80
	drop if 			age_group==""
	
* Collapse data at age group level
	collapse 			(sum) p_proj ///
							(max) code Dregimientos ln_dist_mil_fac latitud longitud, ///
							by(age_group comuna)
	merge 				1:1 age_group code using "${data_clean}\fallecidos_comuna_edad.dta", ///
							keep(match) nogen

* Create share variables
	gen 				sh_fall_prevac_cohort=fall_prevac_cohort/p_proj
	egen 				mean_sh_fall_prevac_cohort = mean(sh_fall_prevac_cohort), by(age_group)
	egen 				sd_sh_fall_prevac_cohort = sd(sh_fall_prevac_cohort), by(age_group)
	gen 				z_fall_prevac_cohort = (sh_fall_prevac_cohort - mean_sh_fall_prevac_cohort) / sd_sh_fall_prevac_cohort
	save 				"${data_clean}\fallecidos_final.dta", replace

* INFLUENZA VACCINATION CAMPAING
	use 				"${data_clean}\camp_inf_nacional.dta", clear
	merge 				m:1 comuna using "${data_clean}\finaldataset_countylevel", nogen

* Variable labels
	label 				var ln_dist_mil_fac_impy2_county "Ln distance to military facility $\times$ County Imp. Years (1973-1976)"
	label 				var ln_dist_mil_fac "Ln distance to military facility"
	label 				var sh_vac_inf "Influenza vaccination rate"

	save 				"${data_clean}\camp_inf_final.dta", replace
