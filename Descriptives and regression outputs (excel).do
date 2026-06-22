				/*------------------------------------------------------------------------------*
				| Title: 			Header .do file - Master code								|
				| Project: 			IDEA Bangladesh					   							|
				| Authors:			Rishabh Bhattacharya										|
				| 					  									                        |
				|																				|
				| Description:		This .do defines the directory and relevant folder paths,	|
				|					and runs the codes to prepare the data, and run the 	 	|
				|										analysis								|
				|                                                                               |
				| Date created: May 24, 2024	 					                      	    |										          
				|																			    |
				| Version: Stata 16.1 	                    							 	    |
				*-------------------------------------------------------------------------------*/


  


			//File
			use "${folder}/baseline_endline/data/Baseline_Endline merged data/BL_El_merged_final", clear
	
						
						
						/*-------------------------------\
						|           table 3			 	  |	
						\-------------------------------*/
						
						
						tabstat f_resp_age bl_fem_resp_edu m_resp_age bl_male_resp_edu  bl_hhsize bl_muslim bl_bangali bl_harv bl_sold bl_cons bl_sis_prod bl_nsis_prod bl_prod bl_tot_exp_equip_pdec bl_tot_exp_service_pdec bl_tot_exp_inputs_pdec bl_tot_exp_labor_pdec bl_tot_exp_aqua_pdec bl_hh_inc , by(treat) stat(mean sd)
						
						
						
							local vars f_resp_age bl_fem_resp_edu m_resp_age bl_male_resp_edu bl_hhsize bl_muslim bl_bangali bl_harv bl_sold bl_cons bl_sis_prod bl_nsis_prod bl_prod bl_tot_exp_equip_pdec bl_tot_exp_service_pdec bl_tot_exp_inputs_pdec bl_tot_exp_labor_pdec bl_tot_exp_aqua_pdec bl_hh_inc
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(25,18,2) 
				matrix colnames desc  =  total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  Difference(T1:LSP-C) se p-value Difference(T2:NGO-C) se p-value
				matrix rownames desc  =    f_resp_age bl_fem_resp_edu m_resp_age bl_male_resp_edu bl_hhsize bl_muslim bl_bangali bl_harv bl_sold bl_cons bl_sis_prod bl_nsis_prod bl_prod bl_tot_exp_equip_pdec bl_tot_exp_service_pdec bl_tot_exp_inputs_pdec bl_tot_exp_labor_pdec bl_tot_exp_aqua_pdec bl_hh_inc										
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						reg `x' i.treat, cl(union)
						matrix desc[`i',13] = _b[1.treat]
						matrix desc[`i',14] = _se[1.treat]
						matrix desc[`i',15] =  2 * ttail(e(df_r), abs(_b[1.treat] / _se[1.treat]))
						reg `x' i.treat, cl(union)
						matrix desc[`i',16] = _b[2.treat]
						matrix desc[`i',17] = _se[2.treat]
						matrix desc[`i',18] = 2 * ttail(e(df_r), abs(_b[2.treat] / _se[2.treat]))
					}
					 
				matrix list desc

				//Exporting to excel


				cd "${tables}" //Change directory
				putexcel set table_3, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						


						/*-------------------------------\
						|           table 4			 	  |	
						\-------------------------------*/

						foreach x in sis_prod nsis_prod prod sold_pdec aq_inc_pdec hh_inc {	
							reg `x'  i.treat bl_`x', cl(unionid)
							est sto reg`x'
						}



						estout reg* using "${tables}/Table_4.xls" , replace cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons constant) stats(N r2) starlevels(* 0.1 ** 0.05 *** 0.01)
									
									est drop *





						/*-------------------------------\
						|           table 5			 	  |	
						\-------------------------------*/

						foreach x in tot_regex_equip_pdec tot_capex_equip_pdec tot_exp_equip_pdec tot_exp_inputs_pdec tot_exp_service_pdec tot_exp_labor_pdec tot_exp_aqua_pdec {
							reg ln_`x'  i.treat ln_bl_`x', cl(unionid)
							est sto reg`x'
						}



						estout reg* using "${tables}/Table_5.xls", replace cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons constant) stats(N r2) starlevels(* 0.1 ** 0.05 *** 0.01)
									
									est drop *
									
									
									
							
						/*-------------------------------\
						|           table 7			 	  |	
						\-------------------------------*/
							
							local vars f_aqknow_1 f_aqknow_2 f_aqknow_3 f_aqknow_4 f_aqknow_5 f_aqknow_6 f_aqknow_7
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(7,9,2)  
				matrix colnames desc  =  bl_sample bl_mean bl_sd el_sample el_mean el_sd  Difference(EL-BL) se p-value 
				matrix rownames desc  =    f_aqknow_1 f_aqknow_2 f_aqknow_3 f_aqknow_4 f_aqknow_5 f_aqknow_6 f_aqknow_7										
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum bl_`x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						ttest  bl_`x' == `x'
						matrix desc[`i',7] =r(mu_2) - r(mu_1) 
						matrix desc[`i',8] =r(se)
						matrix desc[`i',9] =r(p)

					}
					 
				matrix list desc

				//Exporting to excel


				cd "${tables}" //Change directory
				putexcel set table_7, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
				
				
				
				
				
				
				
						/*-------------------------------\
						|           table 6			 	  |	
						\-------------------------------*/						
							
							local vars m_aqknow_1 m_aqknow_2 m_aqknow_3 m_aqknow_4 m_aqknow_5 m_aqknow_6 m_aqknow_7	
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(7,9,2)  
				matrix colnames desc  =  bl_sample bl_mean bl_sd el_sample el_mean el_sd  Difference(EL-BL) se p-value 
				matrix rownames desc  =    m_aqknow_1 m_aqknow_2 m_aqknow_3 m_aqknow_4 m_aqknow_5 m_aqknow_6 m_aqknow_7										
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum bl_`x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						ttest  bl_`x' == `x'
						matrix desc[`i',7] =r(mu_2) - r(mu_1) 
						matrix desc[`i',8] =r(se)
						matrix desc[`i',9] =r(p)

					}
					 
				matrix list desc

				//Exporting to excel


				cd "${tables}" //Change directory
				putexcel set table_6, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
						
						
						
							
							



						/*-------------------------------\
						|           table 12		 	  |	
						\-------------------------------*/


						foreach x in f_dec_aqua_part f_dec_aqua_prod f_decinp_aqua_prod f_dec_aqua_sale  f_decinp_aqua_sale f_decinp_hh_incprod f_market_link {
							reg `x'  i.treat bl_`x', cl(unionid)
							est sto reg`x'
						}

						estout reg* using "${tables}/Table_12.xls", replace cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons constant) stats(N r2) starlevels(* 0.1 ** 0.05 *** 0.01)
									
									est drop *




						/*-------------------------------\
						|           table 13		 	  |	
						\-------------------------------*/
						
						
								local vars f_ta_pondprep f_ta_purff f_ta_purflings f_ta_prepff f_ta_ff f_ta_pmain f_ta_harvsis f_ta_harvmainfish f_ta_fsale_nb f_ta_fsale_lm f_ta_pmonitor f_ta_oth f_ta_total	
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(14,9,2)  
				matrix colnames desc  =  bl_sample bl_mean bl_sd el_sample el_mean el_sd  Difference(EL-BL) se p-value 
				matrix rownames desc  =    f_ta_pondprep f_ta_purff f_ta_purflings f_ta_prepff f_ta_ff f_ta_pmain f_ta_harvsis f_ta_harvmainfish f_ta_fsale_nb f_ta_fsale_lm f_ta_pmonitor f_ta_oth f_ta_total										
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum bl_`x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						ttest  bl_`x' == `x'
						matrix desc[`i',7] =r(mu_2) - r(mu_1) 
						matrix desc[`i',8] =r(se)
						matrix desc[`i',9] =r(p)

					}
					 
				matrix list desc
				
				
								//Exporting to excel


				cd "${tables}" //Change directory
				putexcel set table_13, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						

						/*-------------------------------\
						|           table 14_15		 	  |	
						\-------------------------------*/	
	
	
						
						
						foreach x in f_ta_pondprep f_ta_purff f_ta_purflings f_ta_prepff f_ta_ff f_ta_pmain f_ta_harvsis f_ta_harvmainfish f_ta_fsale_nb f_ta_fsale_lm f_ta_pmonitor f_ta_oth f_ta_total {
							reg `x' bl_`x', cl(unionid)
							est sto reg`x'
						}

						estout reg* using "${tables}/Table_14_15.xls", replace cells(b(star fmt(3)) se(par fmt(2)))  legend label varlabels(_cons constant) stats(N r2) starlevels(* 0.1 ** 0.05 *** 0.01)
									
									est drop *	
									
									
									
									
									
						/*-------------------------------\
						|           table 23		 	  |	
						\-------------------------------*/
							
							local vars pondcult prod harv sold cons aq_inc hh_inc tot_exp_aqua
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(10,9,.)  
				matrix colnames desc  =  bl_sample bl_mean bl_sd el_sample el_mean el_sd  Difference(EL-BL) se p-value 
				matrix rownames desc  =    pondcult prod harv sold cons aq_inc hh_inc tot_exp_aqua										
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum bl_`x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						ttest  bl_`x' == `x'
						matrix desc[`i',7] =r(mu_2) - r(mu_1) 
						matrix desc[`i',8] =r(se)
						matrix desc[`i',9] =r(p)

					}
					 
				matrix list desc

				//Exporting to excel


				cd "${tables}" //Change directory
				putexcel set table_23, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
						
						

									
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						
						/*-------------------------------\
						|           fig 3			 	  |	
						\-------------------------------*/	
						
						
						
						local vars bl_sold sold bl_harv harv	
							
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(10,12,.) 
				matrix colnames desc  =  total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc  =    bl_sold sold bl_harv harv										
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_3, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
						
						
						
						//Figure 4
						
						/*-------------------------------\
						|           fig 4			 	  |	
						\-------------------------------*/	
						
						
						
						local vars prod sis_prod nsis_prod bl_prod bl_sis_prod bl_nsis_prod	
							
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(10,12,.) 
				matrix colnames desc  =  total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc  =    prod sis_prod nsis_prod bl_prod bl_sis_prod bl_nsis_prod										
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_4, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
					
						
						//Figure 5
						/*-------------------------------\
						|           fig 5			 	  |	
						\-------------------------------*/	
						
				
				local vars  dff_home dff_comm bl_dff_home bl_dff_comm
							
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(10,12,.) 
				matrix colnames desc = total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc = dff_home dff_comm bl_dff_home bl_dff_comm									
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_5, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
						
						
						
						
						
						
						//Figure 6
						/*-------------------------------\
						|           fig 6			 	  |	
						\-------------------------------*/	
						
				
				local vars   bl_exp_fertcomm bl_exp_ffcomm exp_fertcomm exp_ffcomm
							
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(7,12,.) 
				matrix colnames desc = total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc =  bl_exp_fertcomm bl_exp_ffcomm exp_fertcomm exp_ffcomm								
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_6, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
						
						
					
						
					
						
						
							
						//Figure 7
						/*-------------------------------\
						|           fig 7			 	  |	
						\-------------------------------*/	
						
				
				local vars bl_allvar allvar  bl_sisvar sisvar  bl_nsisvar nsisvar
							
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(7,12,.) 
				matrix colnames desc = total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc =  bl_allvar allvar  bl_sisvar sisvar  bl_nsisvar nsisvar								
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_7, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
						
						
						
						//Figure 8
						/*-------------------------------\
						|           fig 8			 	  |	
						\-------------------------------*/	
						
				
				local vars bl_fishvar1 bl_fishvar2 bl_fishvar3 bl_fishvar4 bl_fishvar5 bl_fishvar6 bl_fishvar7 bl_fishvar8 bl_fishvar9 bl_fishvar10 bl_fishvar11 bl_fishvar12 bl_fishvar13 bl_fishvar14 bl_fishvar15 bl_fishvar16 bl_fishvar17 bl_fishvar18 bl_fishvar19 bl_fishvar20 bl_fishvar21 bl_fishvar22 bl_fishvar23 bl_fishvar24 bl_fishvar25 bl_fishvar26 bl_fishvar27 bl_fishvar28 bl_fishvar29 bl_fishvar30 bl_fishvar31 bl_fishvar32 bl_fishvar33 bl_fishvar34 bl_fishvar35 bl_fishvar36 bl_fishvar37 bl_fishvar38 bl_fishvar39 bl_fishvar40 bl_fishvar41 bl_fishvar42 bl_fishvar43 bl_fishvar44 bl_fishvar45 bl_fishvar46 bl_fishvar47 bl_fishvar48 bl_fishvar49 bl_fishvar50 bl_fishvar51 bl_fishvar52 bl_fishvar53 bl_fishvar54 bl_fishvar55 bl_fishvar56 bl_fishvar57 bl_fishvar58 bl_fishvar59 bl_fishvar60 bl_fishvar61 bl_fishvar62 bl_fishvar63 bl_fishvar64 bl_fishvar65 bl_fishvar66 bl_fishvar67 bl_fishvar68 bl_fishvar69 bl_fishvar70 bl_fishvar71 bl_fishvar72 bl_fishvar73 bl_fishvar74 bl_fishvar75 bl_fishvar76 bl_fishvar77 bl_fishvar78 bl_fishvar79 bl_fishvar80 bl_fishvar81 bl_fishvar82 bl_fishvar83 bl_fishvar84 bl_fishvar85 bl_fishvar86 bl_fishvar87 bl_fishvar88 bl_fishvar89 bl_fishvar90 bl_fishvar91 bl_fishvar92 bl_fishvar93 bl_fishvar94 bl_fishvar95 bl_fishvar96 bl_fishvar97 bl_fishvar98 bl_fishvar99 bl_fishvar100 bl_fishvar101 bl_fishvar102 bl_fishvar103 bl_fishvar104 bl_fishvar105 bl_fishvar106 bl_fishvar107 bl_fishvar108 bl_fishvar109 bl_fishvar110 bl_fishvar111 bl_fishvar112 bl_fishvar113 bl_fishvar114 bl_fishvar115 bl_fishvar116 bl_fishvar117 bl_fishvar118 bl_fishvar119 bl_fishvar_222 bl_fishvarother fishvar1 fishvar2 fishvar3 fishvar4 fishvar5 fishvar6 fishvar7 fishvar8 fishvar9 fishvar10 fishvar11 fishvar12 fishvar13 fishvar14 fishvar15 fishvar16 fishvar17 fishvar18 fishvar19 fishvar20 fishvar21 fishvar22 fishvar23 fishvar24 fishvar25 fishvar26 fishvar27 fishvar28 fishvar29 fishvar30 fishvar31 fishvar32 fishvar33 fishvar34 fishvar35 fishvar36 fishvar37 fishvar38 fishvar39 fishvar40 fishvar41 fishvar42 fishvar43 fishvar44 fishvar45 fishvar46 fishvar47 fishvar48 fishvar49 fishvar50 fishvar51 fishvar52 fishvar53 fishvar54 fishvar55 fishvar56 fishvar57 fishvar58 fishvar59 fishvar60 fishvar61 fishvar62 fishvar63 fishvar64 fishvar65 fishvar66 fishvar67 fishvar68 fishvar69 fishvar70 fishvar71 fishvar72 fishvar73 fishvar74 fishvar75 fishvar76 fishvar77 fishvar78 fishvar79 fishvar80 fishvar81 fishvar82 fishvar83 fishvar84 fishvar85 fishvar86 fishvar87 fishvar88 fishvar89 fishvar90 fishvar91 fishvar92 fishvar93 fishvar94 fishvar95 fishvar96 fishvar97 fishvar98 fishvar99 fishvar100 fishvar101 fishvar102 fishvar103 fishvar104 fishvar105 fishvar106 fishvar107 fishvar108 fishvar109 fishvar110 fishvar111 fishvar112 fishvar113 fishvar114 fishvar115 fishvar116 fishvar117 fishvar118 fishvar119
							
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(300,12,.) 
				matrix colnames desc = total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc =  bl_fishvar1 bl_fishvar2 bl_fishvar3 bl_fishvar4 bl_fishvar5 bl_fishvar6 bl_fishvar7 bl_fishvar8 bl_fishvar9 bl_fishvar10 bl_fishvar11 bl_fishvar12 bl_fishvar13 bl_fishvar14 bl_fishvar15 bl_fishvar16 bl_fishvar17 bl_fishvar18 bl_fishvar19 bl_fishvar20 bl_fishvar21 bl_fishvar22 bl_fishvar23 bl_fishvar24 bl_fishvar25 bl_fishvar26 bl_fishvar27 bl_fishvar28 bl_fishvar29 bl_fishvar30 bl_fishvar31 bl_fishvar32 bl_fishvar33 bl_fishvar34 bl_fishvar35 bl_fishvar36 bl_fishvar37 bl_fishvar38 bl_fishvar39 bl_fishvar40 bl_fishvar41 bl_fishvar42 bl_fishvar43 bl_fishvar44 bl_fishvar45 bl_fishvar46 bl_fishvar47 bl_fishvar48 bl_fishvar49 bl_fishvar50 bl_fishvar51 bl_fishvar52 bl_fishvar53 bl_fishvar54 bl_fishvar55 bl_fishvar56 bl_fishvar57 bl_fishvar58 bl_fishvar59 bl_fishvar60 bl_fishvar61 bl_fishvar62 bl_fishvar63 bl_fishvar64 bl_fishvar65 bl_fishvar66 bl_fishvar67 bl_fishvar68 bl_fishvar69 bl_fishvar70 bl_fishvar71 bl_fishvar72 bl_fishvar73 bl_fishvar74 bl_fishvar75 bl_fishvar76 bl_fishvar77 bl_fishvar78 bl_fishvar79 bl_fishvar80 bl_fishvar81 bl_fishvar82 bl_fishvar83 bl_fishvar84 bl_fishvar85 bl_fishvar86 bl_fishvar87 bl_fishvar88 bl_fishvar89 bl_fishvar90 bl_fishvar91 bl_fishvar92 bl_fishvar93 bl_fishvar94 bl_fishvar95 bl_fishvar96 bl_fishvar97 bl_fishvar98 bl_fishvar99 bl_fishvar100 bl_fishvar101 bl_fishvar102 bl_fishvar103 bl_fishvar104 bl_fishvar105 bl_fishvar106 bl_fishvar107 bl_fishvar108 bl_fishvar109 bl_fishvar110 bl_fishvar111 bl_fishvar112 bl_fishvar113 bl_fishvar114 bl_fishvar115 bl_fishvar116 bl_fishvar117 bl_fishvar118 bl_fishvar119 bl_fishvar_222 bl_fishvarother fishvar1 fishvar2 fishvar3 fishvar4 fishvar5 fishvar6 fishvar7 fishvar8 fishvar9 fishvar10 fishvar11 fishvar12 fishvar13 fishvar14 fishvar15 fishvar16 fishvar17 fishvar18 fishvar19 fishvar20 fishvar21 fishvar22 fishvar23 fishvar24 fishvar25 fishvar26 fishvar27 fishvar28 fishvar29 fishvar30 fishvar31 fishvar32 fishvar33 fishvar34 fishvar35 fishvar36 fishvar37 fishvar38 fishvar39 fishvar40 fishvar41 fishvar42 fishvar43 fishvar44 fishvar45 fishvar46 fishvar47 fishvar48 fishvar49 fishvar50 fishvar51 fishvar52 fishvar53 fishvar54 fishvar55 fishvar56 fishvar57 fishvar58 fishvar59 fishvar60 fishvar61 fishvar62 fishvar63 fishvar64 fishvar65 fishvar66 fishvar67 fishvar68 fishvar69 fishvar70 fishvar71 fishvar72 fishvar73 fishvar74 fishvar75 fishvar76 fishvar77 fishvar78 fishvar79 fishvar80 fishvar81 fishvar82 fishvar83 fishvar84 fishvar85 fishvar86 fishvar87 fishvar88 fishvar89 fishvar90 fishvar91 fishvar92 fishvar93 fishvar94 fishvar95 fishvar96 fishvar97 fishvar98 fishvar99 fishvar100 fishvar101 fishvar102 fishvar103 fishvar104 fishvar105 fishvar106 fishvar107 fishvar108 fishvar109 fishvar110 fishvar111 fishvar112 fishvar113 fishvar114 fishvar115 fishvar116 fishvar117 fishvar118 fishvar119								
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_8, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
						
							
							
						
						
						
						
						//Figure 9
						/*-------------------------------\
						|           fig 9			 	  |	
						\-------------------------------*/	
						
				
				local vars m_aqknow_8 m_aqknow_9 m_aqknow_10 m_aqknow_11 m_aqknow_12 m_aqknow_13 m_aqknow_14 m_aqknow_15 m_aqknow_16 m_aqknow_17 m_aqknow_18 m_aqknow_19 m_aqknow_20 m_aqknow_21 m_aqknow_22 m_aqknow_23 m_aqknow_24 m_aqknow_25 m_aqknow_26 m_aqknow_27
							
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(30,12,.) 
				matrix colnames desc = total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc =  m_aqknow_8 m_aqknow_9 m_aqknow_10 m_aqknow_11 m_aqknow_12 m_aqknow_13 m_aqknow_14 m_aqknow_15 m_aqknow_16 m_aqknow_17 m_aqknow_18 m_aqknow_19 m_aqknow_20 m_aqknow_21 m_aqknow_22 m_aqknow_23 m_aqknow_24 m_aqknow_25 m_aqknow_26 m_aqknow_27								
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_9, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
						
						
						
				
				//Figure 10
						/*-------------------------------\
						|           fig 10			 	  |	
						\-------------------------------*/	
				
				
				use "${baseline_endline}\data\3ie_Datasets\Events register\WF events full dataset.dta", clear


				merge m:1 event_union_fkid using "${baseline_endline}\data\3ie_Datasets\Events register\Wf_events_unique_union_updated.dta", keep (master match) keepusing(union) nogen  


				drop if union == .




				replace Year = 2022 in 825
				replace Year = 2022 in 826
				replace Year = 2021 in 827
				replace Year = 2022 in 828
				replace Year = 2022 in 829
				replace Year = 2022 in 830
				replace Year = 2022 in 831
				replace Year = 2021 in 832
				replace Year = 2022 in 897
				replace Year = 2022 in 899
				replace Year = 2022 in 898
				replace Year = 2022 in 900
				replace Year = 2022 in 901



				gen mainfocusid=event_mainfocus_fkid
				label define intervention 1 "Aquaculture technology" 2 "Gender" 3 "Nutrition" 4 "Business management" 5 "Credit" 6 "Fish processing" 7 "ICT" 8 "Other" 

				replace mainfocusid=mainfocusid-1 if event_mainfocus_fkid>6
				label values mainfocusid intervention



				forvalues i = 1/8 {
				gen intensity`i' = (mainfocusid==`i')
				}



						label var intensity1 "Aquaculture"
						label var intensity2 "Gender"
						label var intensity3 "Nutrition"
						label var intensity4 "Business management" 
						label var intensity5 "Credit" 
						label var intensity6 "Fish processing" 
						label var intensity7 "ICT" 
						label var intensity8 "Other" 
						

				generate year_month = ym(year(event_start_date), month(event_start_date))
				format year_month %tm		
						
				save "${baseline_endline}\data\3ie_Datasets\Events register\WF events full dataset_matched.dta", replace
					

					

					
					
					use "${data}\baseline_endline\baseline_endline_temp_nowinsor_Output", clear
					
					drop union
					gen union = unionid
					duplicates drop upazilaid unionid, force
					keep union unionid upazilaid treatment treat
					
					save "${baseline_endline}\data\3ie_Datasets\Events register\temp1.dta", replace
					

					
					
				use "${baseline_endline}\data\3ie_Datasets\Events register\WF events full dataset_matched.dta", clear
					

					
				merge m:1 union using "${baseline_endline}\data\3ie_Datasets\Events register\temp1.dta", keep (master match) keepusing(treatment treat unionid upazilaid) nogen	


				save "${baseline_endline}\data\3ie_Datasets\Events register\WF events full dataset_matched.dta", replace










				//CHART 1. Events across timeline



				//generating no of events in a given month for each union
				forvalues i = 1/8 {
				egen i`i' = sum(intensity`i'), by(treatment year_month)
				}





						label var i1 "Aquaculture"
						label var i2 "Gender"
						label var i3 "Nutrition"
						label var i4 "Business management" 
						label var i5 "Credit" 
						label var i6 "Fish processing" 
						label var i7 "ICT" 
						label var i8 "Other" 
						
						
						

				keep treatment year_month i* 
				duplicates drop treatment year_month, force


						rename i1 Aquaculture
						rename i2 Gender
						rename i3 Nutrition

						
					sort year_month treatment 	
						
						twoway ///
					(line Aquaculture year_month, lcolor(blue) lwidth(medium)) ///
					(line Gender year_month, lcolor(red) lwidth(medium)) ///
					(line Nutrition year_month, lcolor(green) lwidth(medium)), ///
					by(treatment, title("Timeline of events")) ///
					xlabel(, angle(35)) ///
					ylabel(, nogrid) ///
					xtitle("Time (Year-Month)") ///
					ytitle("No. of events") ///
					legend(order(1 "Aquaculture" 2 "Gender" 3 "Nutrition"))
					
				graph save "Graph" "${figures}\Figure 10_WF events_timeline of implementation.gph", replace	
					



		
				
				
				
						

			
			
			
			//Figure 11
			
			use "${data}\endline\el_vill_temp", clear
						/*-------------------------------\
						|           fig 11			 	  |	
						\-------------------------------*/	
						
				
				local vars aqua_sup_1 aqua_sup_2 aqua_sup_3 aqua_sup_4 aqua_sup_5 aqua_sup_6
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(10,12,.) 
				matrix colnames desc = total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc =  aqua_sup_1 aqua_sup_2 aqua_sup_3 aqua_sup_4 aqua_sup_5 aqua_sup_6								
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treatment==1 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treatment==2
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treatment==3
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

				cd "${figures}" //Change directory
				putexcel set figure_11, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
			
			
			
		
			
			
			//Figure 12
			use "${data}\baseline_endline\bl_el_village_temp", clear
						/*-------------------------------\
						|           fig 12			 	  |	
						\-------------------------------*/	
						
				
				local vars bl_aqua_prov_1 bl_aqua_prov_2 bl_aqua_prov_3 bl_aqua_prov_4 bl_aqua_prov_5 aqua_prov_1 aqua_prov_2 aqua_prov_3 aqua_prov_4 aqua_prov_5
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(20,12,.) 
				matrix colnames desc = total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc =  bl_aqua_prov_1 bl_aqua_prov_2 bl_aqua_prov_3 bl_aqua_prov_4 bl_aqua_prov_5 aqua_prov_1 aqua_prov_2 aqua_prov_3 aqua_prov_4 aqua_prov_5								
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x' if _merge == 3
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treatment==1 & _merge == 3
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treatment==2 & _merge == 3
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treatment==3 & _merge == 3
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_12, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
				
				
				
				
						/*-------------------------------\
						|           fig 14			 	  |	
						\-------------------------------*/	
			
			use "${folder}/baseline_endline/data/Baseline_Endline merged data/BL_El_merged_final", clear
			
			
		
				
				
				graph dot ///
					lib_bl_s7_1_8_q1 ///
					lib_s7_1_8_q1 ///
					lib_bl_s7_2_8_q1 ///
					lib_s7_2_8_q1, ///
					over(treat, label(labsize(small))) ///
					ytitle(, size(small)) ///
					asyvars ///
					horizontal ///
					///
					marker(1, msymbol(O) mcolor(maroon)) ///
					marker(2, msymbol(O) mcolor(orange)) ///
					marker(3, msymbol(O) mcolor(navy)) ///
					marker(4, msymbol(O) mcolor(forest_green)) ///
					///
					legend(order(1 "BL male" ///
								 2 "EL male" ///
								 3 "BL female" ///
								 4 "EL female") ///
						   rows(2) size(small)) ///
					///
					title("St 1: Being involved in aquaculture fulltime is not appropriate for women", ///
						  size(small))
						  
						  
						  
						   graph save "Graph" "${figures}\Figure 14.gph", replace




				
				
				
						/*-------------------------------\
						|           fig 15			 	  |	
						\-------------------------------*/	
									
						
					graph dot ///
					lib_bl_s7_1_8_q2 ///
					lib_s7_1_8_q2 ///
					lib_bl_s7_2_8_q2 ///
					lib_s7_2_8_q2, ///
					over(treat, label(labsize(small))) ///
					ytitle(, size(small)) ///
					asyvars ///
					horizontal ///
					///
					marker(1, msymbol(O) mcolor(maroon)) ///
					marker(2, msymbol(O) mcolor(orange)) ///
					marker(3, msymbol(O) mcolor(navy)) ///
					marker(4, msymbol(O) mcolor(forest_green)) ///
					///
					legend(order(1 "BL male" ///
								 2 "EL male" ///
								 3 "BL female" ///
								 4 "EL female") ///
						   rows(2) size(small)) ///
					///
					title("St 2: Women should not be owners or joint owners of homestead ponds", ///
						  size(small))
						  
						  
						  
						  graph save "Graph" "${figures}\Figure 15.gph", replace

						
						
						
						
						
						/*-------------------------------\
						|           fig 16			 	  |	
						\-------------------------------*/	

				tabstat lib_bl_s7_1_8_q5 lib_s7_1_8_q5 lib_bl_s7_2_8_q5 lib_s7_2_8_q5, by(treatment)
				
					graph dot ///
					lib_bl_s7_1_8_q5 ///
					lib_s7_1_8_q5 ///
					lib_bl_s7_2_8_q5 ///
					lib_s7_2_8_q5, ///
					over(treat, label(labsize(small))) ///
					ytitle(, size(small)) ///
					asyvars ///
					horizontal ///
					///
					marker(1, msymbol(O) mcolor(maroon)) ///
					marker(2, msymbol(O) mcolor(orange)) ///
					marker(3, msymbol(O) mcolor(navy)) ///
					marker(4, msymbol(O) mcolor(forest_green)) ///
					///
					legend(order(1 "BL male" ///
								 2 "EL male" ///
								 3 "BL female" ///
								 4 "EL female") ///
						   rows(2) size(small)) ///
					///
					title("St 5: Men should mainly be responsible for selling fish in market", ///
						  size(small))
						  
						  
						   graph save "Graph" "${figures}\Figure 16.gph", replace

			
			
			
			
			
			//Figure 26
			use "${folder}/baseline_endline/data/Baseline_Endline merged data/BL_El_merged_final", clear
						/*-------------------------------\
						|           fig 26			 	  |	
						\-------------------------------*/				
				local vars bl_pondcult pondcult
							
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(5,12,.) 
				matrix colnames desc = total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc =  bl_pondcult pondcult								
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_26, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names
						
			
			
			
	
			
			
			//Figure 27
						/*-------------------------------\
						|           fig 27			 	  |	
						\-------------------------------*/				
				local vars tot_capex_equip bl_tot_capex_equip bl_tot_regex_equip tot_regex_equip
							
							
							

			//Defining a Matrix of size and defining rows and columns//
			//(13,18,1) = (row,column,values)
				matrix define desc=J(7,12,.) 
				matrix colnames desc = total_sample sample_mean sample_sd control_sample control_mean control_sd LSP_sample LSP_mean LSP_sd NGO_sample NGO_mean NGO_sd  
				matrix rownames desc =  tot_capex_equip bl_tot_capex_equip bl_tot_regex_equip tot_regex_equip								
				
				//Assigning values to Matrix//

				local i=0   
						foreach x in `vars'   {
						local i=`i'+1
						sum `x'
						matrix desc[`i',1] =r(N)
						matrix desc[`i',2] =r(mean)
						matrix desc[`i',3] =r(sd)
						sum `x' if treat==0 
						matrix desc[`i',4] =r(N)
						matrix desc[`i',5] =r(mean)
						matrix desc[`i',6] =r(sd)
						sum `x' if treat==1
						matrix desc[`i',7] =r(N)
						matrix desc[`i',8] =r(mean)
						matrix desc[`i',9] =r(sd)
						sum `x' if treat==2
						matrix desc[`i',10] =r(N)
						matrix desc[`i',11] =r(mean)
						matrix desc[`i',12] =r(sd)
						}
					 
				matrix list desc

										cd "${figures}" //Change directory
				putexcel set figure_27, modify //Define xml sheet
				putexcel A1 = matrix ( desc), names //Names: includes both row and column names

	
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		
			
		
			
			

			
			
			
			
			
			

			
			
			
			
			
						
						
						
						
						
						
						
						
									
									
									
									