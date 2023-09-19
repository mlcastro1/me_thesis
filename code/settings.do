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
	
	global				data_raw "${gh_me_thesis}\data\raw"
	
	global				data_clean "${gh_me_thesis}\data\clean"

	global 				results "${gh_me_thesis}\results"

/*******************************************************************************
 Globals with specification details
********************************************************************************/

	global 				strep_vars shVictims_70_10 DVictims DCentroDetencion ///
							ln_centro_det 
							
	global				strep_vars_all ${strep_vars} ln_dist_mil_fac
							
	global 				controls Pop70_cond sh_rural_70_cond lnDistStgo lnDistRegCapital ///
							share_allende70_cond share_alessandri70_cond ///
							Pop70_miss sh_rural_70_miss share_allende70_miss ///
							share_alessandri70_miss
							
	global 				W p_proj
	
	global				W_70 Pop70
	
	global 				conley_se spatial latitude(latitud) longitude(longitud) ///
							distcutoff(75)
														
	global 				balance_vars Turnout70 landlocked Houses_pc SocialOrg_pop70 ///
							churches_pop70 sh_educ_12more densidad_1970 ///
							sh_econactivepop_70 sh_women_70 TV ari_1973 index1b 
							
	global 				health_balance_vars_county sh_consultas sh_leche 
	
	global 				health_balance_vars_area sh_antivariolica sh_antitifica ///
							sh_antidifterica sh_mixta sh_antipoliomielitica ///
							sh_antisarampionosa sh_antiinlfuenza

/*******************************************************************************
 Figure settings
********************************************************************************/

	set 				scheme uncluttered   
	graph set window 	fontface "Times New Roman"



