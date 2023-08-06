/*******************************************************************************
********************************************************************************
Purpose: 				Set settings for analysis

						Author: Leonor Castro, 
						Last Edited: Leonor Castro, 6 August, 2023

Do-file overview:
  
********************************************************************************
 Set paths
********************************************************************************/

	global				gh_me_thesis "C:\Users\lc429\Documents\GitHub\me_thesis"
	
	global				raw_data "${gh_me_thesis}\data\raw"
	
	global				raw_data "${gh_me_thesis}\data\clean"

	global 				results "${gh_me_thesis}\results"

/*******************************************************************************
 Globals with specification details
********************************************************************************/

	global 				strep_vars shVictims_70_10 DVictims DCentroDetencion ///
							ln_centro_det ln_dist_mil_fac
							
	global 				controls Pop70 sh_rural_70 lnDistStgo lnDistRegCapital ///
							share_allende70 share_alessandri70
							
	global 				W p_proj
	
	global 				se_vac spatial latitude(latitud) longitude(longitud) ///
							distcutoff(75)
							
	global 				se_mob spatial latitude(latitud) longitude(longitud) ///
							distcutoff(75)
							
	global 				balance_vars Turnout70 landlocked Houses_pc SocialOrg_pop70 ///
							churches_pop70 sh_educ_12more densidad_1970 ///
							sh_econactivepop_70 sh_women_70 TV ari_1973 index1b 
							
	global 				health_balance_vars_county consultas leche 
	
	global 				health_balance_vars_area antivariolica antitifica ///
							antidifterica mixta antipoliomielitica antisarampionosa ///
							antiinlfuenza

/*******************************************************************************
 Figure settings
********************************************************************************/

	set 				scheme uncluttered   
	graph set window 	fontface "Times New Roman"



