		
			
			/*------------------------------------------------------------------------------*
			| Title: 			Data preparation											|
			| Project: 			IDEA Bangladesh					   							|
			| Authors:			Rishabh Bhattacharya										|
			| 					  									                        |
			|																				|
			| Description:		This .do imports and prepares data for analysis				|
			|                                                                               |
			| Date created: May 24, 2024	 												|	          
			|																			    |
			| Version: Stata 16.1 	                    							 	    |
			*-------------------------------------------------------------------------------*/
			
			log using "${log}/infile.log", replace

			/* Endline */
			
			use "${baseline_endline}/data/Endline data files/Aquaculture Endline 2023 HH Survey - MALE (final).dta", clear
			*destring, replace
			//HH head sex
					gen head_sex = .
					forvalues i = 1/22 {
					replace head_sex = mem_sex_`i' if memsl_`i' == hh_head_id
					}
					rename head_sex el_head_sex
					
			//HH head religion - merge from demography
					save "${data}/endline/endline_temp_male.dta", replace
					use "${baseline_endline}/data/Endline data files/Aquaculture Endline 2023 HH Survey - Demographic (final)", clear
					gen uid = hhid
					save "${data}/endline/endline_temp_demo.dta", replace
					
					use "${data}/endline/endline_temp_male.dta", replace

					merge 1:1 hhid using "${data}/endline/endline_temp_demo.dta", keep(master match) keepusing(religion_hhhead religion_oth) gen(merge1)

					drop merge1
					
					
					
			//Social category / ethnicity

					rename ethnic_group el_ethnicity
					rename religion_hhhead el_religion

			//count of hh members (sex and age)

					//b5- Count of boys in 0-5 age group in the HH
					gen b5 = 0
					forvalues i = 1/22 {
					replace b5 = b5 + 1 if mem_age_`i' <= 5 & mem_sex_`i' == 1
					}


					//b11- Count of boys in 6-11 age group in the HH
					gen b11 = 0
					forvalues i = 1/22 {
					replace b11 = b11 + 1 if mem_age_`i' > 5 & mem_age_`i' <= 11 & mem_sex_`i' == 1
					}

					//b17- Count of boys in 12-17 age group in the HH
					gen b17 = 0
					forvalues i = 1/22 {
					replace b17 = b17 + 1 if mem_age_`i' > 11 & mem_age_`i' <= 17 & mem_sex_`i' == 1
					}

					//m1	Count of men in 18-40 age group in the HH
					gen m1 = 0
					forvalues i = 1/22 {
					replace m1 = m1 + 1 if mem_age_`i' > 17 & mem_age_`i' <= 40 & mem_sex_`i' == 1
					}

					//m2	Count of men in 41-60 age group in the HH
					gen m2 = 0
					forvalues i = 1/22 {
					replace m2 = m2 + 1 if mem_age_`i' > 40 & mem_age_`i' <= 60 & mem_sex_`i' == 1
					}

					//m3	Count of men in >60 age group in the HH
					gen m3 = 0
					forvalues i = 1/22 {
					replace m3 = m3 + 1 if mem_age_`i' > 60 & mem_age_`i' < . & mem_sex_`i' == 1
					}

					//g5	Count of girls in 0-5 age group in the HH
					gen g5 = 0
					forvalues i = 1/22 {
					replace g5 = g5 + 1 if mem_age_`i' <= 5 & mem_sex_`i' == 2
					}

					//g11	Count of girls in 6-11 age group in the HH
					gen g11 = 0
					forvalues i = 1/22 {
					replace g11 = g11 + 1 if mem_age_`i' > 5 & mem_age_`i' <= 11 & mem_sex_`i' == 2
					}

					//g17	Count of girls in 12-17 age group in the HH
					gen g17 = 0
					forvalues i = 1/22 {
					replace g17 = g17 + 1 if mem_age_`i' > 11 & mem_age_`i' <= 17 & mem_sex_`i' == 2
					}

					//f1	Count of women in 18-40 age group in the HH
					gen f1 = 0
					forvalues i = 1/22 {
					replace f1 = f1 + 1 if mem_age_`i' > 17 & mem_age_`i' <= 40 & mem_sex_`i' == 2
					}

					//f2	Count of women in 41-60 age group in the HH
					gen f2 = 0
					forvalues i = 1/22 {
					replace f2 = f2 + 1 if mem_age_`i' > 40 & mem_age_`i' <= 60 & mem_sex_`i' == 2
					}

					//f3	Count of women in >60 age group in the HH
					gen f3 = 0
					forvalues i = 1/22 {
					replace f3 = f3 + 1 if mem_age_`i' > 60 & mem_age_`i' < . & mem_sex_`i' == 2
					}

					foreach x in b5 b11 b17 m1 m2 m3 g5 g11 g17 f1 f2 f3 { 
					    rename `x' el_`x'
					}
					

			//hhsize countcount of all people residing in the household
					egen el_hhsize = rowtotal ( mem_status_? mem_status_?? ), missing
					

			//ahhsize weighted family size


					forvalues i = 1/22 {
					gen ahhsize_`i' = .
					replace ahhsize_`i' = 1 if mem_status_`i' == 1 & (mem_age_`i' > 10 | mem_age_`i' < 60) & mem_sex_`i' == 1
					replace ahhsize_`i' = 0.8 if mem_status_`i' == 1 & (mem_age_`i' > 10 | mem_age_`i' < 60) & mem_sex_`i' == 2
					replace ahhsize_`i' = 0.5 if mem_status_`i' == 1 & (mem_age_`i' >= 60 | mem_age_`i' <= 10) & mem_age_`i' != .
					}
					egen el_ahhsize = rowtotal (ahhsize_*), missing
					
			//POND INFORMATION

			//npondown	No of ponds owned by HH

						egen el_npondown = rowtotal ( pond_status_* ), missing
						

			//pondown	Total area of pond owned by HH

						egen el_pondown = rowtotal(pond_size_? pond_size_??), missing


						
			//npondleasein	Number of ponds leased in by the HH

						gen npondleasein = 0
						forvalues i = 1/15 {
						replace npondleasein = npondleasein + 1 if pond_status_`i' == 1 & pond_ownership_`i' == 2
						}
						
						rename npondleasein el_npondleasein

			//pondleasein	Area of ponds leased in
						gen pondleasein = 0
						forvalues i = 1/15 {
						replace pondleasein = pondleasein + pond_size_`i' if pond_status_`i' == 1 & pond_ownership_`i' == 2
						}
						
						rename pondleasein el_pondleasein


			//npondleaseout	Number of ponds leased out by the HH

						gen npondleaseout = 0
						forvalues i = 1/15 {
						replace npondleaseout = npondleaseout + 1 if pond_status_`i' == 1 & pond_ownership_`i' == 3
						}
						
						rename npondleaseout el_npondleaseout

			//pondleaseout	Area of ponds leased out

						gen pondleaseout = 0
						forvalues i = 1/15 {
						replace pondleaseout = pondleaseout + pond_size_`i' if pond_status_`i' == 1 & pond_ownership_`i' == 3
						}
						
						rename pondleaseout el_pondleaseout


			//pondcult	Area of ponds where fish was cultivated in Apr 22 - Mar 2023
						gen pondcult = 0
						forvalues i = 1/15 {
						replace pondcult = pondcult + pond_size_`i' if pond_status_`i' == 1 & pond_used_`i' == 1
						}		
						
						rename pondcult el_pondcult


			//pondcult_sis	Area of ponds where SIS varied was cultivated in Apr 22 - Mar 2023
						gen pondcult_sis = 0
						forvalues i = 1/15 {
						replace pondcult_sis = pondcult_sis + pond_size_`i' if pond_used_`i' == 1 & pond_sis_`i' == 1
						}
						
						rename pondcult_sis el_pondcult_sis

			save "${data}/endline/endline_temp_male.dta", replace		
			use "${data}/endline/endline_temp_demo.dta", replace		
						
			//m_pondcult	Number of male members involved in pond cultivation
			forvalues i = 1/15 {
			forvalues j = 1/22 {
			gen m_pondcult_`j'_`i' =  pond_involve_`j'_`i' if pond_involve_`j'_`i' == 1
			replace m_pondcult_`j'_`i' =  0 if m_sex1_`j' == 2 & m_pondcult_`j'_`i' != .
			}
			}

			forvalues i = 1/22 {
			egen m_pondcult_`i' = rowmax (m_pondcult_`i'_*)
			}

			egen el_m_pondcult = rowtotal (m_pondcult_? m_pondcult_?? ), missing

			//f_pondcult	Number of female members involved in pond cultivation
			forvalues i = 1/15 {
			forvalues j = 1/22 {
			gen f_pondcult_`j'_`i' =  pond_involve_`j'_`i' if pond_involve_`j'_`i' == 1
			replace f_pondcult_`j'_`i' =  0 if m_sex1_`j' == 1 & f_pondcult_`j'_`i' != .
			}
			}


			forvalues i = 1/22 {
			egen f_pondcult_`i' = rowmax (f_pondcult_`i'_*)
			}			

			egen el_f_pondcult = rowtotal (f_pondcult_? f_pondcult_?? ), missing

			save "${data}/endline/endline_temp_demo.dta",replace
			
			use "${data}/endline/endline_temp_male.dta", replace	
			merge 1:1 hhid using "${data}/endline/endline_temp_demo.dta", keep(master match) keepusing(el_m_pondcult el_f_pondcult) gen(merge2)

			
			drop merge2



			//Group membership

						//dgrp	=1 if any member is part of any group
								gen dgrp=1 if s1b_q1==1
								replace dgrp=0 if s1b_q1==0
								rename dgrp el_dgrp
									
						//ngrp	Number of distinct groups any member is part of		

								egen ngrp = rowtotal (s1b_q3_?), missing
								rename ngrp el_ngrp
						//mem_grp	Number of members that are part of any group
								
								forvalues i = 1/4 {
								gen mem_grp_`i' = 1 if livgroup_no_`i' !=.
								}

								egen el_mem_grp = rowtotal (mem_grp_?), missing
								
								

						//dgrp_ngo	=1 if any member is part of any NGO group

						forvalues i = 1/4 {
						forvalues j = 1/6 {
						gen dgrp_ngo_`i'_`j' = 1 if s1b_q5_`i'_`j' == 2 | s1b_q5_`i'_`j' == 3 | s1b_q5_`i'_`j' == 4
						}
						}
						forvalues i = 1/4 {
						egen dgrp_ngo_`i' = rowtotal (dgrp_ngo_`i'_*), missing
						}


						egen dgrp_ngo_n = rowtotal (dgrp_ngo_?), missing
						replace dgrp_ngo_n = 1 if dgrp_ngo_n != .
						replace dgrp_ngo_n = 0 if s1b_q1 == 1 & dgrp_ngo_n == .

						gen dgrp_ngo = dgrp_ngo_n
						replace dgrp_ngo = 1 if dgrp_ngo_n != . & dgrp_ngo_n != 0
						replace dgrp_ngo = 0 if s1b_q1 == 1 & dgrp_ngo == . 
						
						rename dgrp_ngo el_dgrp_ngo

						//ngrp_ngo	No of household members that are part of NGO groups
						forvalues i = 1/4 {
							gen ngrp_ngo_`i' = dgrp_ngo_`i'
							replace ngrp_ngo_`i' = 1 if dgrp_ngo_`i' != 0 & dgrp_ngo_`i' != .
						}

						egen ngrp_ngo = rowtotal (ngrp_ngo_*), missing 
						replace ngrp_ngo = 0 if s1b_q1 == 1 & ngrp_ngo == . 
						
						rename ngrp_ngo el_ngrp_ngo


			//dgrp_bractmss	=1 if an y member is part of any BRAC TMSS group
						forvalues i = 1/4 {
						forvalues j = 1/6 {
						gen dgrp_bractmss_`i'_`j' = 1 if s1b_q5_`i'_`j' == 2 | s1b_q5_`i'_`j' == 3
						}
						}
						forvalues i = 1/4 {
						egen dgrp_bractmss_`i' = rowtotal (dgrp_bractmss_`i'_*), missing
						}


						egen dgrp_bractmss_n = rowtotal (dgrp_bractmss_?), missing
						replace dgrp_bractmss_n = 1 if dgrp_bractmss_n != .
						replace dgrp_bractmss_n = 0 if s1b_q1 == 1 & dgrp_bractmss_n == .

						gen dgrp_bractmss = dgrp_bractmss_n
						replace dgrp_bractmss = 1 if dgrp_bractmss_n != . & dgrp_bractmss_n != 0
						replace dgrp_bractmss = 0 if s1b_q1 == 1 & dgrp_bractmss == .  
						
						rename dgrp_bractmss el_dgrp_bractmss

			//ngrp_bractmss	No of household members that are part of BRAC and TMSS groups
						forvalues i = 1/4 {
							gen ngrp_bractmss_`i' = dgrp_ngo_`i'
							replace ngrp_bractmss_`i' = 1 if dgrp_ngo_`i' != 0 & dgrp_ngo_`i' != .
						}

						egen ngrp_bractmss = rowtotal (ngrp_bractmss_*), missing 
						replace ngrp_bractmss = 0 if s1b_q1 == 1 & ngrp_bractmss == .
						rename ngrp_bractmss el_ngrp_bractmss

			//dgrp_aqua	=1 if any member is part of any aquaculture group

						forvalues i = 1/4 {
						forvalues j = 1/6 {
						gen dgrp_aqua_`i'_`j' = 1 if s1b_q4_`i'_`j' == 1 
						}
						}
						forvalues i = 1/4 {
						egen dgrp_aqua_`i' = rowtotal (dgrp_aqua_`i'_*), missing
						}


						egen dgrp_aqua_n = rowtotal (dgrp_aqua_?), missing
						replace dgrp_aqua_n = 1 if dgrp_aqua_n != .
						replace dgrp_aqua_n = 0 if s1b_q1 == 1 & dgrp_aqua_n == .

						gen dgrp_aqua = dgrp_aqua_n
						replace dgrp_aqua = 1 if dgrp_aqua_n != . & dgrp_aqua_n != 0
						replace dgrp_aqua = 0 if s1b_q1 == 1 & dgrp_aqua == . 
						
						rename dgrp_aqua el_dgrp_aqua




			//ngrp_aqua	No of household members part of Aquaculture group

						forvalues i = 1/4 {
							gen ngrp_aqua_`i' = dgrp_aqua_`i'
							replace ngrp_aqua_`i' = 1 if dgrp_aqua_`i' != 0 & dgrp_aqua_`i' != .
						}

						egen ngrp_aqua = rowtotal (ngrp_aqua_*), missing 
						replace ngrp_aqua = 0 if s1b_q1 == 1 & ngrp_aqua == . 
						rename ngrp_aqua el_ngrp_aqua



			//dgrp_fb	=1 if any member is part of any facebook group

								gen dgrp_fb=1 if s1b_q6==1
								replace dgrp_fb=0 if s1b_q6==0
								rename dgrp_fb el_dgrp_fb


			//dgrp_rf	=1 if any member is part of RightFish group

								gen dgrp_rf= s1b_q7_1
								replace dgrp_rf=0 if s1b_q6==0					
								rename dgrp_rf el_dgrp_rf

			//d_knowrh	=1 if heard of Right Haat
					
					gen d_knowrh =  s1b_q9
					rename d_knowrh el_d_knowrh
					
					
					

			//Occupation 

			//lagri_occ	=1 if any hh member involved in labour, agri

					egen lagri_occ = rowtotal ( s1c_occu_1_* ), missing
					replace lagri_occ = 1 if lagri_occ != 0 & lagri_occ != .

			//lcons_occ	=1 if any hh member involved in labour, construction
					egen lcons_occ = rowtotal ( s1c_occu_2_* ), missing
			replace lcons_occ = 1 if lcons_occ != 0 & lcons_occ != .

			//loth_occ	=1 if any hh member involved in labour, other
					egen loth_occ = rowtotal ( s1c_occu_3_* ), missing
			replace loth_occ= 1 if loth_occ != 0 & loth_occ != .
			//agri_occ	=1 if any hh member involved in agriculture

					egen agri_occ = rowtotal ( s1c_occu_4_* ), missing
			replace agri_occ = 1 if agri_occ != 0 & agri_occ != .
			//aqua_occ	=1 if any hh member involved in aquaculture

					egen aqua_occ = rowtotal ( s1c_occu_5_* ), missing
			replace aqua_occ = 1 if aqua_occ != 0 & aqua_occ != .
			//ls_occ	=1 if any hh member involved in livestock rearing

					egen ls_occ = rowtotal ( s1c_occu_6_* ), missing
			replace ls_occ = 1 if ls_occ != 0 & ls_occ != .
			//sg_occ	=1 if any hh member involved in salaried govt job

					egen sg_occ = rowtotal ( s1c_occu_7_* ), missing
			replace sg_occ = 1 if sg_occ != 0 & sg_occ != .		

			//spvt_occ	=1 if any hh member involved in salaried pvt job

					egen spvt_occ = rowtotal ( s1c_occu_8_* ), missing
			replace spvt_occ = 1 if spvt_occ != 0 & spvt_occ != .
			//bprod_occ	=1 if any hh member involved in product related business

					egen bprod_occ = rowtotal ( s1c_occu_9_* ), missing
			replace bprod_occ = 1 if bprod_occ != 0 & bprod_occ != .
			//bserv_occ	=1 if any hh member involved in service-related business

					egen bserv_occ = rowtotal ( s1c_occu_10_* ), missing
			replace bserv_occ = 1 if bserv_occ != 0 & bserv_occ != .
			//bps_occ	=1 if any hh member involved in both product and service related business

					egen bps_occ = rowtotal ( s1c_occu_11_* ), missing
			replace bps_occ = 1 if bps_occ != 0 & bps_occ != .		
			//both_occ =1 if any hh member involved in other business

					egen both_occ = rowtotal ( s1c_occu_12_* ), missing
			replace both_occ = 1 if both_occ != 0 & both_occ != .

			//nocc	total types of occupation hh members are involved in
					egen nocc = rowtotal (lagri_occ lcons_occ loth_occ agri_occ aqua_occ ls_occ sg_occ spvt_occ bprod_occ bserv_occ bps_occ both_occ), missing
					
					foreach x in lagri_occ lcons_occ loth_occ agri_occ aqua_occ ls_occ sg_occ spvt_occ bprod_occ bserv_occ bps_occ both_occ nocc {
					rename `x' el_`x'
					}
					
					
			//Education

			//ncenroll	Sum of all members for whom are currently enrolled in school==1 (Currently Enrolled==1)
				  forvalues i = 1/22 {
				  gen ncenroll_`i' = 1 if s1d_q4_`i' == 1 | s1d_q5_`i' == 1
				  replace ncenroll_`i' = 0 if (s1d_q3_`i' == 0 & s1d_q5_`i' == 0)  | (s1d_q3_`i' == . & s1d_q5_`i' == 0) | (s1d_q3_`i' == 0 & s1d_q5_`i' == .)
				  }
				  
				  egen el_ncenroll = rowtotal (ncenroll_*), missing
				  
			//maxed_male	Highest years of schooling from amongst male member of the household who are over 30 years of age


							//Madrasa education
							forvalues i = 1/22 {
							gen maxed_male_md_`i' = .
							replace maxed_male_md_`i' = s1d_q4_`i' if s1d_q7_`i' == . & mem_sex_`i' == 1 & mem_age_`i' > 30 & mem_age_`i' != .
							replace maxed_male_md_`i' = s1d_q7_`i' if s1d_q4_`i' == . & mem_sex_`i' == 1 & mem_age_`i' > 30 & mem_age_`i' != .
							}


							 //Non-Madrasa Education
							forvalues i = 1/22 {
							gen maxed_male_nmd_`i' = .
							replace maxed_male_nmd_`i' = s1d_q6_`i' if s1d_q8_`i' == . & mem_sex_`i' == 1 & mem_age_`i' > 30 & mem_age_`i' != .
							replace maxed_male_nmd_`i' = s1d_q8_`i' if s1d_q6_`i' == . & mem_sex_`i' == 1 & mem_age_`i' > 30 & mem_age_`i' != .
							}
							
							


				//maxed_fem	Highest years of schooling from amongst female members of the hhold who are over 30 years of age

					  
							//Madrasa education
							forvalues i = 1/22 {
							gen maxed_fem_md_`i' = .
							replace maxed_fem_md_`i' = s1d_q4_`i' if s1d_q7_`i' == . & mem_sex_`i' == 2 & mem_age_`i' > 30 & mem_age_`i' != .
							replace maxed_fem_md_`i' = s1d_q7_`i' if s1d_q4_`i' == . & mem_sex_`i' == 2 & mem_age_`i' > 30 & mem_age_`i' != .
							}


							 //Non-Madrasa Education
							forvalues i = 1/22 {
							gen maxed_fem_nmd_`i' = .
							replace maxed_fem_nmd_`i' = s1d_q6_`i' if s1d_q8_`i' == . & mem_sex_`i' == 2 & mem_age_`i' > 30 & mem_age_`i' != .
							replace maxed_fem_nmd_`i' = s1d_q8_`i' if s1d_q6_`i' == . & mem_sex_`i' == 2 & mem_age_`i' > 30 & mem_age_`i' != .
							}
							
			foreach x in maxed_male_md_1 maxed_male_md_2 maxed_male_md_3 maxed_male_md_4 maxed_male_md_5 maxed_male_md_6 maxed_male_md_7 maxed_male_md_8 maxed_male_md_9 maxed_male_md_10 maxed_male_md_11 maxed_male_md_12 maxed_male_md_13 maxed_male_md_14 maxed_male_md_15 maxed_male_md_16 maxed_male_md_17 maxed_male_md_18 maxed_male_md_19 maxed_male_md_20 maxed_male_md_21 maxed_male_md_22 maxed_male_nmd_1 maxed_male_nmd_2 maxed_male_nmd_3 maxed_male_nmd_4 maxed_male_nmd_5 maxed_male_nmd_6 maxed_male_nmd_7 maxed_male_nmd_8 maxed_male_nmd_9 maxed_male_nmd_10 maxed_male_nmd_11 maxed_male_nmd_12 maxed_male_nmd_13 maxed_male_nmd_14 maxed_male_nmd_15 maxed_male_nmd_16 maxed_male_nmd_17 maxed_male_nmd_18 maxed_male_nmd_19 maxed_male_nmd_20 maxed_male_nmd_21 maxed_male_nmd_22 maxed_fem_md_1 maxed_fem_md_2 maxed_fem_md_3 maxed_fem_md_4 maxed_fem_md_5 maxed_fem_md_6 maxed_fem_md_7 maxed_fem_md_8 maxed_fem_md_9 maxed_fem_md_10 maxed_fem_md_11 maxed_fem_md_12 maxed_fem_md_13 maxed_fem_md_14 maxed_fem_md_15 maxed_fem_md_16 maxed_fem_md_17 maxed_fem_md_18 maxed_fem_md_19 maxed_fem_md_20 maxed_fem_md_21 maxed_fem_md_22 maxed_fem_nmd_1 maxed_fem_nmd_2 maxed_fem_nmd_3 maxed_fem_nmd_4 maxed_fem_nmd_5 maxed_fem_nmd_6 maxed_fem_nmd_7 maxed_fem_nmd_8 maxed_fem_nmd_9 maxed_fem_nmd_10 maxed_fem_nmd_11 maxed_fem_nmd_12 maxed_fem_nmd_13 maxed_fem_nmd_14 maxed_fem_nmd_15 maxed_fem_nmd_16 maxed_fem_nmd_17 maxed_fem_nmd_18 maxed_fem_nmd_19 maxed_fem_nmd_20 maxed_fem_nmd_21 maxed_fem_nmd_22 {
			replace `x' = 0 if `x' == 68 | `x' == -555 | `x' == 66 | `x' == 18 
			}
							
							
							egen el_maxed_male = rowmax ( maxed_male_md_* maxed_male_nmd_* )
							
							egen el_maxed_fem = rowmax ( maxed_fem_md_* maxed_fem_nmd_* )


			// Migration
			 
			gen el_hhmignum =s1e_q_no                                                      //number of current HH who have migrated


			
			
			***************************************************
			***************** I N P U T S *********************
			***************** I N P U T S *********************
			***************** I N P U T S *********************
			***************************************************
			
			
			//Source and purchase of fingerlings

			split s3_2_q1

			destring s3_2_q11 s3_2_q12 s3_2_q13 s3_2_q14 s3_2_q15 s3_2_q16, replace

			gen el_dfling_hat=1 if s3_2_q11==1| s3_2_q12==1| s3_2_q13==1| s3_2_q14==1| s3_2_q15==1| s3_2_q16==1
			replace el_dfling_hat=0 if el_dfling_hat!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. | s3_2_q16!=.)

			gen el_dfling_nurs=1 if s3_2_q11==2| s3_2_q12==2| s3_2_q13==2| s3_2_q14==2| s3_2_q15==2| s3_2_q16==2
			replace el_dfling_nurs=0 if el_dfling_nurs!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. | s3_2_q16!=.)

			gen el_dfling_trader=1 if s3_2_q11==3| s3_2_q12==3| s3_2_q13==3| s3_2_q14==3| s3_2_q15==3| s3_2_q16==3
			replace el_dfling_trader=0 if el_dfling_trader!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. | s3_2_q16!=.)

			* if purchased from non comm sources ( open, neighbour, relatives, own, gift) 
			gen el_dfling_ncomm=1 if s3_2_q11==4| s3_2_q12==4| s3_2_q13==4| s3_2_q14==4| s3_2_q15==4| s3_2_q16==4|s3_2_q11==5| s3_2_q12==5| s3_2_q13==5| s3_2_q14==5| s3_2_q15==5| s3_2_q16==5|s3_2_q11==6| s3_2_q12==6| s3_2_q13==6| s3_2_q14==6| s3_2_q15==6| s3_2_q16==6| s3_2_q11==7| s3_2_q12==7| s3_2_q13==7| s3_2_q14==7| s3_2_q15==7| s3_2_q16==7
			replace el_dfling_ncomm=0 if el_dfling_ncomm!=1 & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. | s3_2_q16!=.)


			* Purchased from Seed commission agent
			gen el_dfling_scg=1 if s3_2_q11==8| s3_2_q12==8| s3_2_q13==8| s3_2_q14==8| s3_2_q15==8| s3_2_q16==8
			replace el_dfling_scg=0 if el_dfling_scg!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. | s3_2_q16!=.)


			*Purchased from hatchery, trader, nursery, Seed commission agent
			gen el_dfling_comm =1 if el_dfling_hat==1|el_dfling_nurs==1|el_dfling_trader==1|el_dfling_scg==1
			replace el_dfling_comm =0 if el_dfling_comm!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. | s3_2_q16!=.)

			*Purchased from hatchery, trader, nursery, Seed commission agent, others after 2021
			gen el_dfling_comm21=1 if s3_2_years_1>=2021 & s3_2_years_1!=.|s3_2_years_2>=2021 & s3_2_years_2!=.|s3_2_years_3>=2021 & s3_2_years_3!=.
			replace el_dfling_comm21=0 if el_dfling_comm!=1  & (s3_2_years_1!=.| s3_2_years_2!=.| s3_2_years_3!=.)


			***************************************************
			***************** Equipments *********************
			***************************************************

			//Eqipment exp - replace . with 0
			forval i = 1/16 {
			replace s3_3_q2_`i' = 0 if s3_3_q1_`i' == 0
			}

			*total exp on all equipments

			
			gen		el_own_use_stw	=	s3_3_q1_1
			gen		el_own_use_dtw	=	s3_3_q1_2
			gen		el_own_use_pump	=	s3_3_q1_3
			gen		el_own_use_dikefence	=	s3_3_q1_4
			gen		el_own_use_netfish	=	s3_3_q1_5
			gen		el_own_use_nethapas	=	s3_3_q1_6
			gen		el_own_use_boat	=	s3_3_q1_7
			gen		el_own_use_packaging	=	s3_3_q1_8
			gen		el_own_use_aerator	=	s3_3_q1_9
			gen		el_own_use_feedingtray	=	s3_3_q1_10
			gen		el_own_use_harvesttrap	=	s3_3_q1_11
			gen		el_own_use_guardshade	=	s3_3_q1_12
			gen		el_own_use_bamboowood	=	s3_3_q1_13
			gen		el_own_use_elecequip	=	s3_3_q1_14
			gen		el_own_use_angequip	=	s3_3_q1_15
			gen		el_own_use_oth	=	s3_3_q1_16

			//Inflation Adjustment
			forval x = 1/16 {
replace s3_3_q2_`x' = s3_3_q2_`x'/1.31
}	
			
			
			
			gen		el_exp_stw	=	s3_3_q2_1
			gen		el_exp_dtw	=	s3_3_q2_2
			gen		el_exp_pump	=	s3_3_q2_3
			gen		el_exp_dikefence	=	s3_3_q2_4
			gen		el_exp_netfish	=	s3_3_q2_5
			gen		el_exp_nethapas	=	s3_3_q2_6
			gen		el_exp_boat	=	s3_3_q2_7
			gen		el_exp_packaging	=	s3_3_q2_8
			gen		el_exp_aerator	=	s3_3_q2_9
			gen		el_exp_feedingtray	=	s3_3_q2_10
			gen		el_exp_harvesttrap	=	s3_3_q2_11
			gen		el_exp_guardshade	=	s3_3_q2_12
			gen		el_exp_bamboowood	=	s3_3_q2_13
			gen		el_exp_elecequip	=	s3_3_q2_14
			gen		el_exp_angequip	=	s3_3_q2_15
			gen		el_exp_equip_oth	=	s3_3_q2_16


			

			
			
			egen el_tot_exp_equip = rowtotal(s3_3_q2_*), missing 


			*cap exp including Shallow tube well (STW), Deep tube well (DTW), Pump, Boat, aretor, Guard shade
			egen el_tot_capex_equip  = rowtotal(s3_3_q2_9 s3_3_q2_1 s3_3_q2_2 s3_3_q2_3 s3_3_q2_7 s3_3_q2_4 s3_3_q2_12), missing 

			*reamining exp on equipments
			egen el_tot_regex_equip = rowtotal(s3_3_q2_5 s3_3_q2_6 s3_3_q2_8 s3_3_q2_10 s3_3_q2_11 s3_3_q2_12 s3_3_q2_13 s3_3_q2_14 s3_3_q2_15), missing 

			
			
			
			
			***************************************************
			***************** S E R V I C E S *****************
			***************************************************
			
			//Service exp - replace . with 0
			forval i = 1/5 {
			replace s3_4_q3_`i' = 0 if s3_4_q1_`i' == 0
			}
			
			
			
			//Inflation Adjustment
			foreach x in s3_4_q3_1 s3_4_q3_2 s3_4_q3_3 s3_4_q3_4 s3_4_q3_5 {
replace `x' = `x'/1.31
}	
	
			
			*checked water quality
			gen chkwtrqual=s3_4_q1_1 

			//p_chkwtrqual	=1 if paid for water quality check
			gen p_chkwtrqual= 1 if s3_4_q2_4_1==1|s3_4_q2_5_1 == 1|s3_4_q2_6_1 == 1
			replace p_chkwtrqual= 0 if s3_4_q1_1!= . &  p_chkwtrqual!= 1


			// netserv	=1 if used netting services 
			gen netserv=s3_4_q1_4


			//p_netserv	=1 if paid for netting services
			gen p_netserv= 1 if s3_4_q2_4_4 == 1|s3_4_q2_5_4==1|s3_4_q2_6_4==1
			replace p_netserv= 0 if s3_4_q1_4 != . & p_netserv!= 1

			//serv_govt	=1 if availed any service from govt
			gen serv_govt=1 if s3_4_q2_1_1==1|s3_4_q2_1_2==1|s3_4_q2_1_3==1|s3_4_q2_1_4==1|s3_4_q2_1_5==1 | s3_4_q2_4_1==1|s3_4_q2_4_2==1|s3_4_q2_4_3==1|s3_4_q2_4_4==1|s3_4_q2_4_5==1
			replace serv_govt= 0 if s3_4_q1_4 != . & serv_govt!= 1 

			//serv_ngo	=1 if availed any service from ngo
			gen serv_ngo=1 if s3_4_q2_2_1==1|s3_4_q2_2_2==1|s3_4_q2_2_3==1|s3_4_q2_2_4==1|s3_4_q2_2_5==1 | s3_4_q2_5_1==1|s3_4_q2_5_2==1|s3_4_q2_5_3==1|s3_4_q2_5_4==1|s3_4_q2_5_5==1
			replace serv_ngo= 0 if 	s3_4_q1_4 != . & serv_ngo!= 1 

			//serv_pvt	=1 if availed any service from pvt
			gen serv_pvt=1 if s3_4_q2_3_1==1|s3_4_q2_3_2==1|s3_4_q2_3_3==1|s3_4_q2_3_4==1|s3_4_q2_3_5==1 | s3_4_q2_6_1==1|s3_4_q2_6_2==1|s3_4_q2_6_3==1|s3_4_q2_6_4==1|s3_4_q2_6_5==1
			replace serv_pvt= 0 if 	s3_4_q1_4 != . & serv_pvt!= 1 

			//texp_serv	Total expenditure on services
			
			gen	el_use_serv_chkpond	=	s3_4_q1_1
			gen	el_use_serv_trainingfp	=	s3_4_q1_2
			gen	el_use_serv_trainingfh	=	s3_4_q1_3
			gen	el_use_serv_netting	=	s3_4_q1_4
			gen	el_use_serv_oth	=	s3_4_q1_5


		
			
			egen tot_exp_service=rowtotal(s3_4_q3_1 s3_4_q3_2 s3_4_q3_3 s3_4_q3_4 s3_4_q3_5), missing
			
			
			foreach x in chkwtrqual p_chkwtrqual netserv p_netserv serv_govt serv_ngo serv_pvt tot_exp_service {
			rename `x' el_`x'
			}
			

			
			
			
			***************************************************
			***************** I N P U T S *********************
			***************************************************
			//Input exp - replace . with 0
			forval i = 1/11 {
			replace s3_5_q2_`i' = 0 if s3_5_q1_`i' == 0
			}
			
						
			//Cost of inputs: Lime, feed, fertilizers, medicines and fuel
			
			gen dlime = s3_5_q1_1
			gen exp_lime = s3_5_q2_1

			gen dfert_home = s3_5_q1_2 
			gen exp_ferthome = s3_5_q2_2

			gen dfert_comm = s3_5_q1_3 
			gen exp_fertcomm = s3_5_q2_3 

			gen dff_home = s3_5_q1_4 
			gen exp_ffhome = s3_5_q2_4 

			gen dff_comm = s3_5_q1_5
			gen exp_ffcomm = s3_5_q2_5

			gen dgastab = s3_5_q1_6
			gen exp_gastab = s3_5_q2_6

			gen dmed = s3_5_q1_7
			gen exp_med = s3_5_q2_7

			gen dhorm = s3_5_q1_8
			gen exp_horm = s3_5_q2_8

			gen delec = s3_5_q1_9
			gen exp_elec =  s3_5_q2_9

			gen ddiesel = s3_5_q1_10
			gen exp_diesel = s3_5_q2_10

			
			gen	el_use_inp_lime	=	s3_5_q1_1
			gen	el_use_inp_hmfert	=	s3_5_q1_2
			gen	el_use_inp_comfert	=	s3_5_q1_3
			gen	el_use_inp_hmfeed	=	s3_5_q1_4
			gen	el_use_inp_comfeed	=	s3_5_q1_5
			gen	el_use_inp_gastab	=	s3_5_q1_6
			gen	el_use_inp_chempest	=	s3_5_q1_7
			gen	el_use_inp_enzhorm	=	s3_5_q1_8
			gen	el_use_inp_elec	=	s3_5_q1_9
			gen	el_use_inp_dsl	=	s3_5_q1_10
			gen	el_use_inp_oth	=	s3_5_q1_11
			
			
				//Inflation Adjustment
				foreach x in exp_lime exp_ferthome exp_fertcomm exp_ffhome exp_ffcomm exp_gastab exp_med exp_horm exp_elec exp_diesel  s3_5_q2_11 {
replace `x' = `x'/1.31
}	


				egen tot_exp_inputs =rowtotal(exp_lime exp_ferthome exp_fertcomm exp_ffhome exp_ffcomm exp_gastab exp_med exp_horm exp_elec exp_diesel s3_5_q2_11), missing

			
			
				foreach x in dlime exp_lime dfert_home exp_ferthome dfert_comm exp_fertcomm dff_home exp_ffhome dff_comm exp_ffcomm dgastab exp_gastab dmed exp_med dhorm exp_horm delec exp_elec ddiesel exp_diesel tot_exp_inputs {
				rename `x' el_`x'
				}
				
				
				
				



	
				
			
			
			
			
			***************************************************
			***************** L A B O R *********************
			***************************************************	
			
			gen el_exp_mlab= s3_6_q1_1+ s3_6_q2_1
			gen el_exp_flab= s3_6_q1_2+ s3_6_q2_2
			gen el_exp_clab= s3_6_q1_3+ s3_6_q2_3
			gen el_exp_olab= s3_6_q1_4+ s3_6_q2_4
			
				//Inflation Adjustment
				
				foreach x in el_exp_mlab el_exp_flab el_exp_clab el_exp_olab {
replace `x' = `x'/1.31
}	
			
			
			egen el_tot_exp_labor = rowtotal (el_exp_mlab el_exp_flab el_exp_clab el_exp_olab), missing
					
					
					
			***************** TOTAL AQUACULTURE EXPENDITURE *********************	
			egen el_tot_exp_aqua = rowtotal (el_tot_exp_equip el_tot_exp_service el_tot_exp_inputs el_tot_exp_labor), missing
								
					
		
		
		
		
		
		
		
		
		
		
			***********************************************
			***************** L A N D *********************
			***************** L A N D *********************
			***************** L A N D *********************
			***********************************************
	

			// Household land 


			gen own_agland = agriplot_q2_2               //plot type 2 - Agri land, homestead garden and orchards- check with Rohan

			gen leasein_agland = agriplot_q3_2 

			gen leaseout_agland  = agriplot_q4_2

			* Total land owned- all 5 types of plots
			egen tot_land_own =rowtotal( agriplot_q2_1 agriplot_q2_2  agriplot_q2_3  agriplot_q2_4  agriplot_q2_5 ), missing
			egen tot_land_leasedin =rowtotal( agriplot_q3_1 agriplot_q3_2  agriplot_q3_3  agriplot_q3_4  agriplot_q3_5 ), missing
			egen tot_land_leaseout =rowtotal( agriplot_q4_1 agriplot_q4_2  agriplot_q4_3  agriplot_q4_4  agriplot_q4_5 ), missing
			
			foreach x in own_agland leasein_agland leaseout_agland tot_land_own tot_land_leasedin tot_land_leaseout	 agriplot_q4_2 {
				rename `x' el_`x'
			}


			//Fish Variety

			forvalues x=1/119{
			forvalues y=1/15{
			destring s3_1_q1_`x'_`y', replace
			}
			}

			drop s3_1_q1_1 s3_1_q1_2 s3_1_q1_3 s3_1_q1_4 s3_1_q1_5 s3_1_q1_6 s3_1_q1_7 s3_1_q1_8 s3_1_q1_9 s3_1_q1_10 s3_1_q1_11 s3_1_q1_12 s3_1_q1_13 s3_1_q1_14 s3_1_q1_15 s3_1_q1__222* s3_1_q1_other*

			forvalues x=1/119{
					egen el_fishvar`x'=rowtotal(s3_1_q1_`x'_1 s3_1_q1_`x'_2 s3_1_q1_`x'_3 s3_1_q1_`x'_4 s3_1_q1_`x'_5 s3_1_q1_`x'_6 s3_1_q1_`x'_7 s3_1_q1_`x'_8 s3_1_q1_`x'_9 s3_1_q1_`x'_10 s3_1_q1_`x'_11 s3_1_q1_`x'_12 s3_1_q1_`x'_13 s3_1_q1_`x'_14 s3_1_q1_`x'_15), missing
			}

			forvalues x=1/119{
				replace el_fishvar`x'=1 if el_fishvar`x'>0 & el_fishvar`x'!=.
			}

			egen el_allvar=rowtotal(el_fishvar1-el_fishvar119), missing
			egen el_sisvar=rowtotal(el_fishvar97-el_fishvar105), missing


			
			***************Pond Productivity**********************
			***************Pond Productivity**********************
			***************Pond Productivity**********************
			***************Pond Productivity**********************
			
			
			//Harvest , Sale and consumed Quantity and Pond Productivity
			foreach x in s3_1a_q1 s3_1a_q2 s3_1a_q3 s3_1b_q1 s3_1b_q2 s3_1b_q3 {
			gen n_`x' = `x'
			replace n_`x' = . if   `x' == 999 | `x' == 9999 |  `x' == 99999 |  `x' == 999999 |  `x' == 9999999 |  `x' == 99999999
			}
			replace n_s3_1b_q2 = . if n_s3_1b_q1 == .

			
			
			
			gen el_sis_harv = n_s3_1a_q1

			gen el_sis_sold = n_s3_1a_q2

			gen el_sis_cons = n_s3_1a_q3 

			gen el_nonsis_harv = n_s3_1b_q1

			gen el_nonsis_sold = n_s3_1b_q2

			gen el_nonsis_cons = n_s3_1b_q3
			
					//Productivity
					gen el_sis_prod=el_sis_harv/el_pondcult
					gen el_nsis_prod=el_nonsis_harv/el_pondcult
					
				
					
					gen el_harv=el_sis_harv+el_nonsis_harv
					

					gen el_cons=el_sis_cons+el_nonsis_cons
					

					gen el_sold=el_sis_sold+el_nonsis_sold
					

					gen el_prod=el_harv/el_pondcult
					
			
			
			
			*************** Per Decimal **********************
			*************** Per Decimal **********************
			*************** Per Decimal **********************			
			
			
					local pdec_var el_exp_stw el_exp_dtw el_exp_pump el_exp_dikefence el_exp_netfish el_exp_nethapas el_exp_boat el_exp_packaging el_exp_aerator el_exp_feedingtray el_exp_harvesttrap el_exp_guardshade el_exp_bamboowood el_exp_elecequip el_exp_angequip el_exp_equip_oth el_tot_regex_equip el_tot_capex_equip el_tot_exp_equip el_tot_exp_service el_exp_lime el_exp_ferthome el_exp_fertcomm el_exp_ffhome el_exp_ffcomm el_exp_gastab el_exp_med el_exp_horm el_exp_elec el_exp_diesel el_tot_exp_inputs el_exp_mlab el_exp_flab el_exp_clab el_exp_olab el_tot_exp_labor el_tot_exp_aqua


		foreach var in `pdec_var'{
			gen `var'_pdec=`var'/el_pondcult
			}
			
			
			
				
	
	
	
	
	
			*************** Income **********************
			***************I N C O M E**********************
			***************I N C O M E**********************
			***************I N C O M E**********************
	
			foreach x in  s4_1_q1 s4_1_q10 s4_1_q11 s4_1_q12 s4_1_q13 s4_1_q2 s4_1_q3 s4_1_q4 s4_1_q5 s4_1_q6 s4_1_q7 s4_1_q8 s4_1_q9 s4_3_q1 s4_3_q10 s4_3_q11 s4_3_q12 s4_3_q13 s4_3_q2 s4_3_q3 s4_3_q4 s4_3_q5 s4_3_q6 s4_3_q7 s4_3_q8 s4_3_q9 {
				gen n_`x' = `x'
				replace n_`x' = . if `x' == -555 | `x' == 555
		}



		
		
					**no of income sources 
				gen el_nincsources = 0

				forvalues i = 1/13 {
					replace el_nincsources = el_nincsources +  1 if n_s4_1_q`i' != . & n_s4_1_q`i' > 0 
				}
				**Income comparison 
				gen el_inc_comp=s4_2

		
			rename	n_s4_1_q1 el_inc_ag	
			rename	n_s4_1_q10 el_inc_ag_ws	
			rename	n_s4_1_q11 el_inc_ag_wu	
			rename	n_s4_1_q12 el_inc_nag_ws	
			rename	n_s4_1_q13 el_inc_nag_wu	
			rename	n_s4_1_q2 el_inc_ls	
			rename	n_s4_1_q3 el_inc_aqc	
			rename	n_s4_1_q4 el_inc_aqb	
			rename	n_s4_1_q5 el_inc_ent	
			rename	n_s4_1_q6 el_inc_ws	
			rename	n_s4_1_q7 el_inc_rem	
			rename	n_s4_1_q8 el_inc_tp	
			rename	n_s4_1_q9 el_inc_oth	
			rename	n_s4_3_q1 el_exp_ag	
			rename	n_s4_3_q10 el_exp_ag_ws	
			rename	n_s4_3_q11 el_exp_ag_wu	
			rename	n_s4_3_q12 el_exp_nag_ws	
			rename	n_s4_3_q13 el_exp_nag_wu	
			rename	n_s4_3_q2 el_exp_ls	
			rename	n_s4_3_q3 el_exp_aqc	
			rename	n_s4_3_q4 el_exp_aqb	
			rename	n_s4_3_q5 el_exp_ent	
			rename	n_s4_3_q6 el_exp_ws	
			rename	n_s4_3_q7 el_exp_rem	
			rename	n_s4_3_q8 el_exp_tp	
			rename	n_s4_3_q9 el_exp_oth
			

			foreach x in el_inc_ag el_inc_ag_ws el_inc_ag_wu el_inc_nag_ws el_inc_nag_wu el_inc_ls el_inc_aqc el_inc_aqb el_inc_ent el_inc_ws el_inc_rem el_inc_tp el_inc_oth  {
			replace `x' = `x'/1.31
			}
			
			foreach x in el_exp_ag el_exp_ag_ws el_exp_ag_wu el_exp_nag_ws el_exp_nag_wu el_exp_ls el_exp_aqc el_exp_aqb el_exp_ent el_exp_ws el_exp_rem el_exp_tp el_exp_oth {
				replace `x' = `x'/1.31
			}
			
			
			
			
			egen el_aq_inc=	rowtotal (el_inc_aqc el_inc_aqb),missing
		egen el_hh_inc=rowtotal (el_inc_ag el_inc_ag_ws el_inc_ag_wu el_inc_nag_ws el_inc_nag_wu el_inc_ls el_inc_aqc el_inc_aqb el_inc_ent el_inc_ws el_inc_rem el_inc_tp el_inc_oth), missing
		gen el_prop_aq_inc=el_aq_inc/el_hh_inc
			
			
			
			
			
			
			

				
				/* male time use */
				foreach x in s7_1_3_q3 s7_1_3_q3_s s7_1_3_q4 s7_1_3_q4_s s7_1_3_q5 s7_1_3_q5_s s7_1_3_q6 s7_1_3_q6_s s7_1_3_q7 s7_1_3_q7_s s7_1_3_q8 s7_1_3_q8_s s7_1_3_q9 s7_1_3_q9_s s7_1_3_q10 s7_1_3_q10_s s7_1_3_q11 s7_1_3_q11_s s7_1_3_q12 s7_1_3_q12_s s7_1_3_q13 s7_1_3_q13_s s7_1_3_q14 s7_1_3_q14_s {
				gen n_`x' = `x'
				replace n_`x' = . if `x' == -999
				replace n_`x' = . if `x'< 1 & `x'> .9
				}

				gen el_m_ta_pondprep = n_s7_1_3_q3
				gen el_m_ta_purff = n_s7_1_3_q4 
				gen el_m_ta_purflings = n_s7_1_3_q5
				gen el_m_ta_prepff = n_s7_1_3_q6
				gen el_m_ta_ff = n_s7_1_3_q7 
				gen el_m_ta_pmain = n_s7_1_3_q8 
				gen el_m_ta_harvsis= n_s7_1_3_q9 
				gen el_m_ta_harvmainfish = n_s7_1_3_q10 
				gen el_m_ta_fsale_nb = n_s7_1_3_q11 
				gen el_m_ta_fsale_lm = n_s7_1_3_q12 
				gen el_m_ta_pmonitor = n_s7_1_3_q13 
				gen el_m_ta_oth = n_s7_1_3_q14
				
				egen el_m_ta_total = rowtotal (el_m_ta_pondprep el_m_ta_purff el_m_ta_purflings el_m_ta_prepff el_m_ta_ff el_m_ta_pmain el_m_ta_harvsis el_m_ta_harvmainfish el_m_ta_fsale_nb el_m_ta_fsale_lm el_m_ta_pmonitor el_m_ta_oth), missing
				
				
				
				
				
				//Aquaculture Knowledge and practices
				
							forvalues i = 1/27 {
					gen el_m_aqknow_`i' = s7_1_6_q1_`i'
					replace el_m_aqknow_`i' = 1 if s7_1_6_q1_`i' == 1 | s7_1_6_q1_`i' == 2
					replace el_m_aqknow_`i' = 0 if s7_1_6_q1_`i' == 3	
				}

				egen el_m_aqprac7 = rowtotal (el_m_aqknow_1 el_m_aqknow_2 el_m_aqknow_3 el_m_aqknow_4 el_m_aqknow_5 el_m_aqknow_6 el_m_aqknow_7), missing

				egen el_m_aqprac27 = rowtotal (el_m_aqknow_1 el_m_aqknow_2 el_m_aqknow_3 el_m_aqknow_4 el_m_aqknow_5 el_m_aqknow_6 el_m_aqknow_7 el_m_aqknow_8 el_m_aqknow_9 el_m_aqknow_10 el_m_aqknow_11 el_m_aqknow_12 el_m_aqknow_13 el_m_aqknow_14 el_m_aqknow_15 el_m_aqknow_16 el_m_aqknow_17 el_m_aqknow_18 el_m_aqknow_19 el_m_aqknow_20 el_m_aqknow_21 el_m_aqknow_22 el_m_aqknow_23 el_m_aqknow_24 el_m_aqknow_25 el_m_aqknow_26 el_m_aqknow_27), missing
				
				egen el_m_aqpracdo7 = rowtotal (s7_1_6_q2_1 s7_1_6_q2_2 s7_1_6_q2_3 s7_1_6_q2_4 s7_1_6_q2_5 s7_1_6_q2_6 s7_1_6_q2_7), missing
				
				egen el_m_aqpracdo27 = rowtotal (s7_1_6_q2_1 s7_1_6_q2_2 s7_1_6_q2_3 s7_1_6_q2_4 s7_1_6_q2_5 s7_1_6_q2_6 s7_1_6_q2_7 s7_1_6_q2_8 s7_1_6_q2_9 s7_1_6_q2_10 s7_1_6_q2_11 s7_1_6_q2_12 s7_1_6_q2_13 s7_1_6_q2_14 s7_1_6_q2_15 s7_1_6_q2_16 s7_1_6_q2_17 s7_1_6_q2_18 s7_1_6_q2_19 s7_1_6_q2_20 s7_1_6_q2_21 s7_1_6_q2_22 s7_1_6_q2_23 s7_1_6_q2_24 s7_1_6_q2_25 s7_1_6_q2_26 s7_1_6_q2_27), missing
				
				
				
				*save "${data}/endline/endline_temp_male.dta", replace	
				
				
				
				
				
				
				
				
				////////////********** female time use ***************//////////////////
				////////////********** female time use ***************//////////////////
				////////////********** female time use ***************//////////////////
				////////////********** female time use ***************//////////////////
				
				
				
				merge 1:1 hhid using "${baseline_endline}/data/Endline data files/Aquaculture Endline 2023 HH Survey - FEMALE (final).dta", keep(master match) keepusing(s7_2_3_q3 s7_2_3_q3_s s7_2_3_q4 s7_2_3_q4_s s7_2_3_q5 s7_2_3_q5_s s7_2_3_q6 s7_2_3_q6_s s7_2_3_q7 s7_2_3_q7_s s7_2_3_q8 s7_2_3_q8_s s7_2_3_q9 s7_2_3_q9_s s7_2_3_q10 s7_2_3_q10_s s7_2_3_q11 s7_2_3_q11_s s7_2_3_q12 s7_2_3_q12_s s7_2_3_q13 s7_2_3_q13_s s7_2_3_q14 s7_2_3_q14_s s7_2_6_q1_*) gen(merge2)
				
				*keep if merge2==3
				drop merge2

				foreach x in s7_2_3_q3 s7_2_3_q3_s s7_2_3_q4 s7_2_3_q4_s s7_2_3_q5 s7_2_3_q5_s s7_2_3_q6 s7_2_3_q6_s s7_2_3_q7 s7_2_3_q7_s s7_2_3_q8 s7_2_3_q8_s s7_2_3_q9 s7_2_3_q9_s s7_2_3_q10 s7_2_3_q10_s s7_2_3_q11 s7_2_3_q11_s s7_2_3_q12 s7_2_3_q12_s s7_2_3_q13 s7_2_3_q13_s s7_2_3_q14 s7_2_3_q14_s {
				gen n_`x' = `x'
				replace n_`x' = . if `x' == -999
				replace n_`x' = . if `x'< 1 & `x'> .9
				}
				
				gen el_f_ta_pondprep = n_s7_2_3_q3
				gen el_f_ta_purff = n_s7_2_3_q4 
				gen el_f_ta_purflings = n_s7_2_3_q5
				gen el_f_ta_prepff = n_s7_2_3_q6
				gen el_f_ta_ff = n_s7_2_3_q7 
				gen el_f_ta_pmain = n_s7_2_3_q8 
				gen el_f_ta_harvsis= n_s7_2_3_q9 
				gen el_f_ta_harvmainfish = n_s7_2_3_q10 
				gen el_f_ta_fsale_nb = n_s7_2_3_q11 
				gen el_f_ta_fsale_lm = n_s7_2_3_q12 
				gen el_f_ta_pmonitor = n_s7_2_3_q13 
				gen el_f_ta_oth = n_s7_2_3_q14		
				
				egen el_f_ta_total = rowtotal (el_f_ta_pondprep el_f_ta_purff el_f_ta_purflings el_f_ta_prepff el_f_ta_ff el_f_ta_pmain el_f_ta_harvsis el_f_ta_harvmainfish el_f_ta_fsale_nb el_f_ta_fsale_lm el_f_ta_pmonitor el_f_ta_oth), missing
				
				
				
				
				//Aquaculture Knowledge and practices
				
				forvalues i = 1/7 {
				gen el_f_aqknow_`i' = s7_2_6_q1_`i'
				replace el_f_aqknow_`i' = 1 if s7_2_6_q1_`i' == 1 | s7_2_6_q1_`i' == 2
				replace el_f_aqknow_`i' = 0 if s7_2_6_q1_`i' == 3	
			}

			egen el_f_aqprac7 = rowtotal (el_f_aqknow_1 el_f_aqknow_2 el_f_aqknow_3 el_f_aqknow_4 el_f_aqknow_5 el_f_aqknow_6 el_f_aqknow_7), missing
			
			
			save "${data}/endline/endline_temp_male.dta", replace	
			
			
			
			
			
			
	
		
		
		
		
		
		
		
		********************************************************************************************************************************		
		/* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline */
		/* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline *//* Baseline */
			
		********************************************************************************************************************************
			
			use "${baseline_endline}/data/Baseline data files/Aquaculture Baseline HH Survey-2020_MALE_PII_DROP_labelled.dta", clear

			*destring, replace
			//HH head sex
							

					
			//HH head religion/Sex - merge from demography
					save "${data}/baseline/baseline_temp_male.dta", replace	
					merge 1:1 hhid using "${baseline_endline}/data/Baseline data files\Aquaculture_baseline_listing_PII_Removed__svyd HHs.dta", assert(master match) keep(master match) keepusing(mid1_* s1a_q3_* s1a_q4_* s1a_q4_other_* s1a_q5_* s1a_q6_* s1a_q7_* s1a_q12_* pond_sl_* pond_name_* ponddesc_* ponddesc_oth_* plot_type_* pond_size_* pond_dist_* pondused_* pond_nursery_* pond_sis_*  hhi_a12 hhi_a12_other) nogenerate
					
					destring mid1_*, replace
					rename hhi_a12  bl_religion
					gen bl_head_sex = s1a_q3_1

					
			//Social category / ethnicity

					rename ethnic_group  bl_ethnicity
		*save "${data}/baseline/infile.dta", replace

		*use "${baseline}\3. Section-wise data\Raw data from IPA\Aquaculture_baseline_listing_PII_Removed__svyd HHs.dta", clear
			//count of hh members (sex and age)

					//b5- Count of boys in 0-5 age group in the HH
					gen b5 = 0
					forvalues i = 1/19 {
					replace b5 = b5 + 1 if s1a_q5_`i' <= 5 & s1a_q3_`i' == 1
					}


					//b11- Count of boys in 6-11 age group in the HH
					gen b11 = 0
					forvalues i = 1/19 {
					replace b11 = b11 + 1 if s1a_q5_`i' > 5 & s1a_q5_`i' <= 11 & s1a_q3_`i' == 1
					}

					//b17- Count of boys in 12-17 age group in the HH
					gen b17 = 0
					forvalues i = 1/19 {
					replace b17 = b17 + 1 if s1a_q5_`i' > 11 & s1a_q5_`i' <= 17 & s1a_q3_`i' == 1
					}

					//m1	Count of men in 18-40 age group in the HH
					gen m1 = 0
					forvalues i = 1/19 {
					replace m1 = m1 + 1 if s1a_q5_`i' > 17 & s1a_q5_`i' <= 40 & s1a_q3_`i' == 1
					}

					//m2	Count of men in 41-60 age group in the HH
					gen m2 = 0
					forvalues i = 1/19 {
					replace m2 = m2 + 1 if s1a_q5_`i' > 40 & s1a_q5_`i' <= 60 & s1a_q3_`i' == 1
					}

					//m3	Count of men in >60 age group in the HH
					gen m3 = 0
					forvalues i = 1/19 {
					replace m3 = m3 + 1 if s1a_q5_`i' > 60 & s1a_q5_`i' < . & s1a_q3_`i' == 1
					}

					//g5	Count of girls in 0-5 age group in the HH
					gen g5 = 0
					forvalues i = 1/19 {
					replace g5 = g5 + 1 if s1a_q5_`i' <= 5 & s1a_q3_`i' == 2
					}

					//g11	Count of girls in 6-11 age group in the HH
					gen g11 = 0
					forvalues i = 1/19 {
					replace g11 = g11 + 1 if s1a_q5_`i' > 5 & s1a_q5_`i' <= 11 & s1a_q3_`i' == 2
					}

					//g17	Count of girls in 12-17 age group in the HH
					gen g17 = 0
					forvalues i = 1/19 {
					replace g17 = g17 + 1 if s1a_q5_`i' > 11 & s1a_q5_`i' <= 17 & s1a_q3_`i' == 2
					}

					//f1	Count of women in 18-40 age group in the HH
					gen f1 = 0
					forvalues i = 1/19 {
					replace f1 = f1 + 1 if s1a_q5_`i' > 17 & s1a_q5_`i' <= 40 & s1a_q3_`i' == 2
					}

					//f2	Count of women in 41-60 age group in the HH
					gen f2 = 0
					forvalues i = 1/19 {
					replace f2 = f2 + 1 if s1a_q5_`i' > 40 & s1a_q5_`i' <= 60 & s1a_q3_`i' == 2
					}

					//f3	Count of women in >60 age group in the HH
					gen f3 = 0
					forvalues i = 1/19 {
					replace f3 = f3 + 1 if s1a_q5_`i' > 60 & s1a_q5_`i' < . & s1a_q3_`i' == 2
					}
					
					
					foreach x in b5 b11 b17 m1 m2 m3 g5 g11 g17 f1 f2 f3 { 
					    rename `x' bl_`x'
					}


			//hhsize countcount of all people residing in the household
					forvalues i = 1/19 {
						gen hhsize_`i' = 1 if mid1_`i' != .
					}
					egen bl_hhsize = rowtotal ( hhsize_* ), missing
					

			//ahhsize weighted family size


					forvalues i = 1/19 {
					gen ahhsize_`i' = .
					replace ahhsize_`i' = 1 if hhsize_`i' == 1 & (s1a_q5_`i' > 10 | s1a_q5_`i' < 60) & s1a_q3_`i' == 1
					replace ahhsize_`i' = 0.8 if hhsize_`i' == 1 & (s1a_q5_`i' > 10 | s1a_q5_`i' < 60) & s1a_q3_`i' == 2
					replace ahhsize_`i' = 0.5 if hhsize_`i' == 1 & (s1a_q5_`i' >= 60 | s1a_q5_`i' <= 10) & s1a_q5_`i' != .
					}
					egen bl_ahhsize = rowtotal (ahhsize_*), missing
					
			//POND INFORMATION

			//npondown	No of ponds owned by HH
							
						forvalues i = 1/13 {
						gen npondown_`i' = 1 if pond_sl_`i' != .
						}
						egen bl_npondown = rowtotal (npondown_*), missing
						

			//pondown	Total area of pond owned by HH

						egen bl_pondown = rowtotal(pond_size_? pond_size_??), missing


						
			//npondleasein	Number of ponds leased in by the HH

						gen npondleasein = 0
						forvalues i = 1/13 {
						replace npondleasein = npondleasein + 1 if plot_type_`i' == 2
						}
						
						rename npondleasein bl_npondleasein

			//pondleasein	Area of ponds leased in
						gen pondleasein = 0
						forvalues i = 1/13 {
						replace pondleasein = pondleasein + pond_size_`i' if plot_type_`i' == 2
						}
						
						rename pondleasein bl_pondleasein

			//npondleaseout	Number of ponds leased out by the HH

						gen npondleaseout = 0
						forvalues i = 1/13 {
						replace npondleaseout = npondleaseout + 1 if plot_type_`i' == 3
						}
						
						
						rename npondleaseout bl_npondleaseout
						
						
						

			//pondleaseout	Area of ponds leased out

						gen pondleaseout = 0
						forvalues i = 1/13 {
						replace pondleaseout = pondleaseout + pond_size_`i' if plot_type_`i' == 3
						}
						
						rename pondleaseout bl_pondleaseout


			//pondcult	Area of ponds where fish was cultivated in Apr 22 - Mar 2023
						gen pondcult = 0
						forvalues i = 1/13 {
						replace pondcult = pondcult + pond_size_`i' if pondused_`i' == 1
						}	
						
						rename pondcult bl_pondcult


			//pondcult_sis	Area of ponds where SIS varied was cultivated in Apr 22 - Mar 2023
						gen pondcult_sis = 0
						forvalues i = 1/13 {
						replace pondcult_sis = pondcult_sis + pond_size_`i' if pond_sis_`i' == 1
						}
						
						rename pondcult_sis bl_pondcult_sis

						

			save "${data}/baseline/baseline_temp_male.dta", replace			
			use "${baseline_endline}/data/Baseline data files\Aquaculture_baseline_listing_PII_Removed__svyd HHs.dta",  clear		
			
			save "${data}/baseline/baseline_temp_demo.dta", replace
			
						
			//m_pondcult	Number of male members involved in pond cultivation
		forvalues i = 1/13 {
		forvalues j = 1/19 {
		gen m_pondcult_`j'_`i' =  pond_hh_member_`j'_`i' if pond_hh_member_`j'_`i' == 1
		replace m_pondcult_`j'_`i' =  0 if s1a_q3_`j' == 2 & pond_hh_member_`j'_`i' != .
		}
		}

		forvalues i = 1/19 {
		egen m_pondcult_`i' = rowmax (m_pondcult_`i'_*)
		}

		egen bl_m_pondcult = rowtotal (m_pondcult_? m_pondcult_?? ), missing

		//f_pondcult	Number of female members involved in pond cultivation
		forvalues i = 1/13 {
		forvalues j = 1/19 {
		gen f_pondcult_`j'_`i' =  pond_hh_member_`j'_`i' if pond_hh_member_`j'_`i' == 1
		replace f_pondcult_`j'_`i' =  0 if s1a_q3_`j' == 1 & f_pondcult_`j'_`i' != .
		}
		}


		forvalues i = 1/19 {
		egen f_pondcult_`i' = rowmax (f_pondcult_`i'_*)
		}			

		egen bl_f_pondcult = rowtotal (f_pondcult_? f_pondcult_?? ), missing


			save "${data}/baseline/baseline_temp_demo.dta", replace
			use "${data}/baseline/baseline_temp_male.dta", replace	
			merge 1:1 hhid using "${data}/baseline/baseline_temp_demo.dta", keep(master match) keepusing(bl_m_pondcult bl_f_pondcult) gen(merge2)

			keep if merge2==3
			drop merge2



			//Group membership

					//dgrp	=1 if any member is part of any group
								gen dgrp=1 if s1b_q1==1
								replace dgrp=0 if s1b_q1==0
								
								rename dgrp bl_dgrp
								
						//ngrp	Number of distinct groups any member is part of		

								egen ngrp = rowtotal (s1b_q3_?), missing
								
								rename ngrp bl_ngrp
								
						//mem_grp	Number of members that are part of any group
								
								gen bl_mem_grp = livgroup_count
								
											
								

						//dgrp_ngo	=1 if any member is part of any NGO group

						forvalues i = 1/4 {
						forvalues j = 1/5 {
						gen dgrp_ngo_`i'_`j' = 1 if s1b_q5_`i'_`j' == 2 | s1b_q5_`i'_`j' == 3 | s1b_q5_`i'_`j' == 4
						}
						}
						forvalues i = 1/4 {
						egen dgrp_ngo_`i' = rowtotal (dgrp_ngo_`i'_*), missing
						}


						egen dgrp_ngo_n = rowtotal (dgrp_ngo_?), missing
						replace dgrp_ngo_n = 1 if dgrp_ngo_n != .
						replace dgrp_ngo_n = 0 if s1b_q1 == 1 & dgrp_ngo_n == .

						gen dgrp_ngo = dgrp_ngo_n
						replace dgrp_ngo = 1 if dgrp_ngo_n != . & dgrp_ngo_n != 0
						replace dgrp_ngo = 0 if s1b_q1 == 1 & dgrp_ngo == .  
						
						rename dgrp_ngo bl_dgrp_ngo

						//ngrp_ngo	No of household members that are part of NGO groups
						forvalues i = 1/4 {
							gen ngrp_ngo_`i' = dgrp_ngo_`i'
							replace ngrp_ngo_`i' = 1 if dgrp_ngo_`i' != 0 & dgrp_ngo_`i' != .
						}

						egen ngrp_ngo = rowtotal (ngrp_ngo_*), missing 
						replace ngrp_ngo = 0 if s1b_q1 == 1 & ngrp_ngo == . 
						rename ngrp_ngo bl_ngrp_ngo


			//dgrp_bractmss	=1 if an y member is part of any BRAC TMSS group
						forvalues i = 1/4 {
						forvalues j = 1/5 {
						gen dgrp_bractmss_`i'_`j' = 1 if s1b_q5_`i'_`j' == 2 | s1b_q5_`i'_`j' == 3
						}
						}
						forvalues i = 1/4 {
						egen dgrp_bractmss_`i' = rowtotal (dgrp_bractmss_`i'_*), missing
						}


						egen dgrp_bractmss_n = rowtotal (dgrp_bractmss_?), missing
						replace dgrp_bractmss_n = 1 if dgrp_bractmss_n != .
						replace dgrp_bractmss_n = 0 if s1b_q1 == 1 & dgrp_bractmss_n == .

						gen dgrp_bractmss = dgrp_bractmss_n
						replace dgrp_bractmss = 1 if dgrp_bractmss_n != . & dgrp_bractmss_n != 0
						replace dgrp_bractmss = 0 if s1b_q1 == 1 & dgrp_bractmss == .  
						
						rename dgrp_bractmss bl_dgrp_bractmss

			//ngrp_bractmss	No of household members that are part of BRAC and TMSS groups
						forvalues i = 1/4 {
							gen ngrp_bractmss_`i' = dgrp_ngo_`i'
							replace ngrp_bractmss_`i' = 1 if dgrp_ngo_`i' != 0 & dgrp_ngo_`i' != .
						}

						egen ngrp_bractmss = rowtotal (ngrp_bractmss_*), missing 
						replace ngrp_bractmss = 0 if s1b_q1 == 1 & ngrp_bractmss == .
						
						rename ngrp_bractmss bl_ngrp_bractmss

			//dgrp_aqua	=1 if any member is part of any aquaculture group

						forvalues i = 1/4 {
						forvalues j = 1/5 {
						gen dgrp_aqua_`i'_`j' = 1 if s1b_q4_`i'_`j' == 1 
						}
						}
						forvalues i = 1/4 {
						egen dgrp_aqua_`i' = rowtotal (dgrp_aqua_`i'_*), missing
						}


						egen dgrp_aqua_n = rowtotal (dgrp_aqua_?), missing
						replace dgrp_aqua_n = 1 if dgrp_aqua_n != .
						replace dgrp_aqua_n = 0 if s1b_q1 == 1 & dgrp_aqua_n == .

						gen dgrp_aqua = dgrp_aqua_n
						replace dgrp_aqua = 1 if dgrp_aqua_n != . & dgrp_aqua_n != 0
						replace dgrp_aqua = 0 if s1b_q1 == 1 & dgrp_aqua == . 
						
						rename dgrp_aqua bl_dgrp_aqua




			//ngrp_aqua	No of household members part of Aquaculture group

						forvalues i = 1/4 {
							gen ngrp_aqua_`i' = dgrp_aqua_`i'
							replace ngrp_aqua_`i' = 1 if dgrp_aqua_`i' != 0 & dgrp_aqua_`i' != .
						}

						egen ngrp_aqua = rowtotal (ngrp_aqua_*), missing 
						replace ngrp_aqua = 0 if s1b_q1 == 1 & ngrp_aqua == . 
						
						rename ngrp_aqua bl_ngrp_aqua



		//dgrp_fb	=1 if any member is part of any facebook group

							//gen dgrp_fb=1 if s1b_q6==1
							//replace dgrp_fb=0 if s1b_q6==0


		//dgrp_rf	=1 if any member is part of RightFish group

							//gen dgrp_rf= s1b_q7_1
							//replace dgrp_rf=0 if s1b_q6==0					


		//d_knowrh	=1 if heard of Right Haat
				
				//gen d_knowrh =  s1b_q9
				

		//Occupation 

		//lagri_occ	=1 if any hh member involved in labour, agri

				egen lagri_occ = rowtotal ( s1c_occu_1_* ), missing
				replace lagri_occ = 1 if lagri_occ != 0 & lagri_occ != .

		//lcons_occ	=1 if any hh member involved in labour, construction
				egen lcons_occ = rowtotal ( s1c_occu_2_* ), missing
		replace lcons_occ = 1 if lcons_occ != 0 & lcons_occ != .

		//loth_occ	=1 if any hh member involved in labour, other
				egen loth_occ = rowtotal ( s1c_occu_3_* ), missing
		replace loth_occ= 1 if loth_occ != 0 & loth_occ != .
		//agri_occ	=1 if any hh member involved in agriculture

				egen agri_occ = rowtotal ( s1c_occu_4_* ), missing
		replace agri_occ = 1 if agri_occ != 0 & agri_occ != .
		//aqua_occ	=1 if any hh member involved in aquaculture

				egen aqua_occ = rowtotal ( s1c_occu_5_* ), missing
		replace aqua_occ = 1 if aqua_occ != 0 & aqua_occ != .
		//ls_occ	=1 if any hh member involved in livestock rearing

				egen ls_occ = rowtotal ( s1c_occu_6_* ), missing
		replace ls_occ = 1 if ls_occ != 0 & ls_occ != .
		//sg_occ	=1 if any hh member involved in salaried govt job

				egen sg_occ = rowtotal ( s1c_occu_7_* ), missing
		replace sg_occ = 1 if sg_occ != 0 & sg_occ != .		

		//spvt_occ	=1 if any hh member involved in salaried pvt job

				egen spvt_occ = rowtotal ( s1c_occu_8_* ), missing
		replace spvt_occ = 1 if spvt_occ != 0 & spvt_occ != .
		//bprod_occ	=1 if any hh member involved in product related business

				egen bprod_occ = rowtotal ( s1c_occu_9_* ), missing
		replace bprod_occ = 1 if bprod_occ != 0 & bprod_occ != .
		//bserv_occ	=1 if any hh member involved in service-related business

				egen bserv_occ = rowtotal ( s1c_occu_10_* ), missing
		replace bserv_occ = 1 if bserv_occ != 0 & bserv_occ != .
		//bps_occ	=1 if any hh member involved in both product and service related business

				egen bps_occ = rowtotal ( s1c_occu_11_* ), missing
		replace bps_occ = 1 if bps_occ != 0 & bps_occ != .		
		//both_occ =1 if any hh member involved in other business

				egen both_occ = rowtotal ( s1c_occu_12_* ), missing
		replace both_occ = 1 if both_occ != 0 & both_occ != .

		//nocc	total types of occupation hh members are involved in
				egen nocc = rowtotal (lagri_occ lcons_occ loth_occ agri_occ aqua_occ ls_occ sg_occ spvt_occ bprod_occ bserv_occ bps_occ both_occ), missing
				
					foreach x in lagri_occ lcons_occ loth_occ agri_occ aqua_occ ls_occ sg_occ spvt_occ bprod_occ bserv_occ bps_occ both_occ nocc {
					rename `x' bl_`x'
					}
				
				
				
				
		//Education
		
		
		
			//Male & Female respondent education
			
			destring male_resp_pos, gen (male_pos)
			gen female_pos = female_name_listing
			
			
					//Max_edu for alkl respondents


							//Madrasa education
							forvalues i = 1/19 {
							gen bl_maxed_resp_md_`i' = .
							replace bl_maxed_resp_md_`i' = s1d_q4_`i' if s1d_q7_`i' == .
							replace bl_maxed_resp_md_`i' = s1d_q7_`i' if s1d_q4_`i' == .
							}


							 //Non-Madrasa Education
							forvalues i = 1/19 {
							gen bl_maxed_resp_nmd_`i' = .
							replace bl_maxed_resp_nmd_`i' = s1d_q6_`i' if s1d_q8_`i' == .
							replace bl_maxed_resp_nmd_`i' = s1d_q8_`i' if s1d_q6_`i' == .
							}
							
			
			
			
			
			
			forval i = 1/19 {
							egen bl_maxed_resp_edu_`i' = rowmax ( bl_maxed_resp_md_`i' bl_maxed_resp_nmd_`i' )
							
			}
			
				forval i = 1/19 {
				gen bl_male_resp_edu_`i' = bl_maxed_resp_edu_`i' if male_pos == `i'
				gen bl_fem_resp_edu_`i' = bl_maxed_resp_edu_`i' if female_pos == `i'
				}
			
			
			egen bl_male_resp_edu = rowmax (bl_male_resp_edu_*)
			egen bl_fem_resp_edu = rowmax (bl_fem_resp_edu_*)
			
			
			forval i = 1/19 {
			drop bl_maxed_resp_md_`i'
			drop bl_maxed_resp_nmd_`i'
			drop bl_maxed_resp_edu_`i'
			drop bl_male_resp_edu_`i'
			drop bl_fem_resp_edu_`i'
			}
			
		
		
		
		

		//ncenroll	Sum of all members for whom are currently enrolled in school==1 (Currently Enrolled==1)
			  forvalues i = 1/19 {
			  gen ncenroll_`i' = 1 if s1d_q4_`i' == 1 | s1d_q5_`i' == 1
			  replace ncenroll_`i' = 0 if (s1d_q3_`i' == 0 & s1d_q5_`i' == 0)  | (s1d_q3_`i' == . & s1d_q5_`i' == 0) | (s1d_q3_`i' == 0 & s1d_q5_`i' == .)
			  }
			  
			  egen bl_ncenroll = rowtotal (ncenroll_*), missing
			  
		//maxed_male	Highest years of schooling from amongst male member of the household who are over 30 years of age


						//Madrasa education
						forvalues i = 1/19 {
						gen maxed_male_md_`i' = .
						replace maxed_male_md_`i' = s1d_q4_`i' if s1d_q7_`i' == . & s1a_q3_`i' == 1 & s1a_q5_`i' > 30 & s1a_q5_`i' != .
						replace maxed_male_md_`i' = s1d_q7_`i' if s1d_q4_`i' == . & s1a_q3_`i' == 1 & s1a_q5_`i' > 30 & s1a_q5_`i' != .
						}


						 //Non-Madrasa Education
						forvalues i = 1/19 {
						gen maxed_male_nmd_`i' = .
						replace maxed_male_nmd_`i' = s1d_q6_`i' if s1d_q8_`i' == . & s1a_q3_`i' == 1 & s1a_q5_`i' > 30 & s1a_q5_`i' != .
						replace maxed_male_nmd_`i' = s1d_q8_`i' if s1d_q6_`i' == . & s1a_q3_`i' == 1 & s1a_q5_`i' > 30 & s1a_q5_`i' != .
						}
						
						


			//maxed_fem	Highest years of schooling from amongst female members of the hhold who are over 30 years of age

				  
						//Madrasa education
						forvalues i = 1/19 {
						gen maxed_fem_md_`i' = .
						replace maxed_fem_md_`i' = s1d_q4_`i' if s1d_q7_`i' == . & s1a_q3_`i' == 2 & s1a_q5_`i' > 30 & s1a_q5_`i' != .
						replace maxed_fem_md_`i' = s1d_q7_`i' if s1d_q4_`i' == . & s1a_q3_`i' == 2 & s1a_q5_`i' > 30 & s1a_q5_`i' != .
						}


						 //Non-Madrasa Education
						forvalues i = 1/19 {
						gen maxed_fem_nmd_`i' = .
						replace maxed_fem_nmd_`i' = s1d_q6_`i' if s1d_q8_`i' == . & s1a_q3_`i' == 2 & s1a_q5_`i' > 30 & s1a_q5_`i' != .
						replace maxed_fem_nmd_`i' = s1d_q8_`i' if s1d_q6_`i' == . & s1a_q3_`i' == 2 & s1a_q5_`i' > 30 & s1a_q5_`i' != .
						}
						
		foreach x in maxed_male_md_1 maxed_male_md_2 maxed_male_md_3 maxed_male_md_4 maxed_male_md_5 maxed_male_md_6 maxed_male_md_7 maxed_male_md_8 maxed_male_md_9 maxed_male_md_10 maxed_male_md_11 maxed_male_md_12 maxed_male_md_13 maxed_male_md_14 maxed_male_md_15 maxed_male_md_16 maxed_male_md_17 maxed_male_md_18 maxed_male_md_19 maxed_male_nmd_1 maxed_male_nmd_2 maxed_male_nmd_3 maxed_male_nmd_4 maxed_male_nmd_5 maxed_male_nmd_6 maxed_male_nmd_7 maxed_male_nmd_8 maxed_male_nmd_9 maxed_male_nmd_10 maxed_male_nmd_11 maxed_male_nmd_12 maxed_male_nmd_13 maxed_male_nmd_14 maxed_male_nmd_15 maxed_male_nmd_16 maxed_male_nmd_17 maxed_male_nmd_18 maxed_male_nmd_19  maxed_fem_md_1 maxed_fem_md_2 maxed_fem_md_3 maxed_fem_md_4 maxed_fem_md_5 maxed_fem_md_6 maxed_fem_md_7 maxed_fem_md_8 maxed_fem_md_9 maxed_fem_md_10 maxed_fem_md_11 maxed_fem_md_12 maxed_fem_md_13 maxed_fem_md_14 maxed_fem_md_15 maxed_fem_md_16 maxed_fem_md_17 maxed_fem_md_18 maxed_fem_md_19  maxed_fem_nmd_1 maxed_fem_nmd_2 maxed_fem_nmd_3 maxed_fem_nmd_4 maxed_fem_nmd_5 maxed_fem_nmd_6 maxed_fem_nmd_7 maxed_fem_nmd_8 maxed_fem_nmd_9 maxed_fem_nmd_10 maxed_fem_nmd_11 maxed_fem_nmd_12 maxed_fem_nmd_13 maxed_fem_nmd_14 maxed_fem_nmd_15 maxed_fem_nmd_16 maxed_fem_nmd_17 maxed_fem_nmd_18 maxed_fem_nmd_19  {
		replace `x' = 0 if `x' == 68 | `x' == -555 | `x' == 66 | `x' == 18 
		}
						
						
						egen bl_maxed_male = rowmax ( maxed_male_md_* maxed_male_nmd_* )
						
						egen bl_maxed_fem = rowmax ( maxed_fem_md_* maxed_fem_nmd_* )


			// Migration
			 
			gen bl_hhmignum =s1e_q_no                                                      //number of current HH who have migrated

			***************************************************
			***************** I N P U T S *********************
			***************** I N P U T S *********************
			***************** I N P U T S *********************
           ***************************************************			
			
			
			
			
			

			//Source and purchase of fingerlings

			split s3_2_q1

			destring s3_2_q11 s3_2_q12 s3_2_q13 s3_2_q14 s3_2_q15, replace

			gen bl_dfling_hat=1 if s3_2_q11==1| s3_2_q12==1| s3_2_q13==1| s3_2_q14==1| s3_2_q15==1
			replace bl_dfling_hat=0 if bl_dfling_hat!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. )

			gen bl_dfling_nurs=1 if s3_2_q11==2| s3_2_q12==2| s3_2_q13==2| s3_2_q14==2| s3_2_q15==2
			replace bl_dfling_nurs=0 if bl_dfling_nurs!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. )

			gen bl_dfling_trader=1 if s3_2_q11==3| s3_2_q12==3| s3_2_q13==3| s3_2_q14==3| s3_2_q15==3
			replace bl_dfling_trader=0 if bl_dfling_trader!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. )

			* if purchased from non comm sources ( open, neighbour, relatives, own, gift) 
			gen bl_dfling_ncomm=1 if s3_2_q11==4| s3_2_q12==4| s3_2_q13==4| s3_2_q14==4| s3_2_q15==4| s3_2_q11==5| s3_2_q12==5| s3_2_q13==5| s3_2_q14==5| s3_2_q15==5| s3_2_q11==6| s3_2_q12==6| s3_2_q13==6| s3_2_q14==6| s3_2_q15==6| s3_2_q11==7| s3_2_q12==7| s3_2_q13==7| s3_2_q14==7| s3_2_q15==7
			replace bl_dfling_ncomm=0 if bl_dfling_ncomm!=1 & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. )


			* Purchased from Seed commission agent
			gen bl_dfling_scg=1 if s3_2_q11==8| s3_2_q12==8| s3_2_q13==8| s3_2_q14==8| s3_2_q15==8
			replace bl_dfling_scg=0 if bl_dfling_scg!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. )


			*Purchased from hatchery, trader, nursery, Seed commission agent
			gen bl_dfling_comm =1 if bl_dfling_hat==1|bl_dfling_nurs==1|bl_dfling_trader==1|bl_dfling_scg==1
			replace bl_dfling_comm =0 if bl_dfling_comm!=1  & (s3_2_q11!=. | s3_2_q12!=. | s3_2_q13!=. | s3_2_q14!=. | s3_2_q15!=. )

			*Purchased from hatchery, trader, nursery, Seed commission agent, others after 2021
			gen bl_dfling_comm21=1 if s3_2_years_1>=2021 & s3_2_years_1!=.|s3_2_years_2>=2021 & s3_2_years_2!=.|s3_2_years_3>=2021 & s3_2_years_3!=.
			replace bl_dfling_comm21=0 if bl_dfling_comm!=1  & (s3_2_years_1!=.| s3_2_years_2!=.| s3_2_years_3!=.)



								***************************************************
		***************** Equipments *********************
		***************************************************
			
			//Eqipment exp - replace . with 0
			forval i = 1/16 {
			replace s3_3_q2_`i' = 0 if s3_3_q1_`i' == 0
			}
			
			*total exp on all equipments

			
			gen		bl_own_use_stw	=	s3_3_q1_1
			gen		bl_own_use_dtw	=	s3_3_q1_2
			gen		bl_own_use_pump	=	s3_3_q1_3
			gen		bl_own_use_dikefence	=	s3_3_q1_4
			gen		bl_own_use_netfish	=	s3_3_q1_5
			gen		bl_own_use_nethapas	=	s3_3_q1_6
			gen		bl_own_use_boat	=	s3_3_q1_7
			gen		bl_own_use_packaging	=	s3_3_q1_8
			gen		bl_own_use_aerator	=	s3_3_q1_9
			gen		bl_own_use_feedingtray	=	s3_3_q1_10
			gen		bl_own_use_harvesttrap	=	s3_3_q1_11
			gen		bl_own_use_guardshade	=	s3_3_q1_12
			gen		bl_own_use_bamboowood	=	s3_3_q1_13
			gen		bl_own_use_elecequip	=	s3_3_q1_14
			gen		bl_own_use_angequip	=	s3_3_q1_15
			gen		bl_own_use_oth	=	s3_3_q1_16
			gen		bl_exp_stw	=	s3_3_q2_1
			gen		bl_exp_dtw	=	s3_3_q2_2
			gen		bl_exp_pump	=	s3_3_q2_3
			gen		bl_exp_dikefence	=	s3_3_q2_4
			gen		bl_exp_netfish	=	s3_3_q2_5
			gen		bl_exp_nethapas	=	s3_3_q2_6
			gen		bl_exp_boat	=	s3_3_q2_7
			gen		bl_exp_packaging	=	s3_3_q2_8
			gen		bl_exp_aerator	=	s3_3_q2_9
			gen		bl_exp_feedingtray	=	s3_3_q2_10
			gen		bl_exp_harvesttrap	=	s3_3_q2_11
			gen		bl_exp_guardshade	=	s3_3_q2_12
			gen		bl_exp_bamboowood	=	s3_3_q2_13
			gen		bl_exp_elecequip	=	s3_3_q2_14
			gen		bl_exp_angequip	=	s3_3_q2_15
			gen		bl_exp_equip_oth	=	s3_3_q2_16


			
			
			
			egen bl_tot_exp_equip = rowtotal(s3_3_q2_*), missing 
			
			
			*cap exp including Shallow tube well (STW), Deep tube well (DTW), Pump, Boat, aretor, Guard shade
			egen bl_tot_capex_equip  = rowtotal(s3_3_q2_9 s3_3_q2_1 s3_3_q2_2 s3_3_q2_3 s3_3_q2_7 s3_3_q2_4 s3_3_q2_12), missing 

			*reamining exp on equipments
			egen bl_tot_regex_equip = rowtotal(s3_3_q2_5 s3_3_q2_6 s3_3_q2_8 s3_3_q2_10 s3_3_q2_11 s3_3_q2_12 s3_3_q2_13 s3_3_q2_14 s3_3_q2_15), missing 
			
			
			
	
	
	
	
		
		
				***************************************************
				***************** S E R V I C E S *****************
				***************************************************	
		
		
				
				
				//Input services
				
				//Service exp - replace . with 0
				forval i = 1/5 {
				replace s3_4_q3_`i' = 0 if s3_4_q1_`i' == 0
				}
				
				

				*checked water quality chkwtrqual	=1 if checked water quality
				gen chkwtrqual=s3_4_q1_1 

				//p_chkwtrqual	=1 if paid for water quality check
				gen p_chkwtrqual= 1 if s3_4_q2_4_1==1|s3_4_q2_5_1 == 1|s3_4_q2_6_1 == 1
				replace p_chkwtrqual= 0 if s3_4_q1_1!= . &  p_chkwtrqual!= 1


				// netserv	=1 if used netting services 
				gen netserv=s3_4_q1_4


				//p_netserv	=1 if paid for netting services
				gen p_netserv= 1 if s3_4_q2_4_4 == 1|s3_4_q2_5_4==1|s3_4_q2_6_4==1
				replace p_netserv= 0 if s3_4_q1_4 != . & p_netserv!= 1

				//serv_govt	=1 if availed any service from govt
				gen serv_govt=1 if s3_4_q2_1_1==1|s3_4_q2_1_2==1|s3_4_q2_1_3==1|s3_4_q2_1_4==1|s3_4_q2_1_5==1 | s3_4_q2_4_1==1|s3_4_q2_4_2==1|s3_4_q2_4_3==1|s3_4_q2_4_4==1|s3_4_q2_4_5==1
				replace serv_govt= 0 if s3_4_q1_4 != . & serv_govt!= 1 

				//serv_ngo	=1 if availed any service from ngo
			gen serv_ngo=1 if s3_4_q2_2_1==1|s3_4_q2_2_2==1|s3_4_q2_2_3==1|s3_4_q2_2_4==1|s3_4_q2_2_5==1 | s3_4_q2_5_1==1|s3_4_q2_5_2==1|s3_4_q2_5_3==1|s3_4_q2_5_4==1|s3_4_q2_5_5==1
			replace serv_ngo= 0 if 	s3_4_q1_4 != . & serv_ngo!= 1 

			//serv_pvt	=1 if availed any service from pvt
			gen serv_pvt=1 if s3_4_q2_3_1==1|s3_4_q2_3_2==1|s3_4_q2_3_3==1|s3_4_q2_3_4==1|s3_4_q2_3_5==1 | s3_4_q2_6_1==1|s3_4_q2_6_2==1|s3_4_q2_6_3==1|s3_4_q2_6_4==1|s3_4_q2_6_5==1
			replace serv_pvt= 0 if 	s3_4_q1_4 != . & serv_pvt!= 1 

			//texp_serv	Total expenditure on services
			
			gen	el_use_serv_chkpond	=	s3_4_q1_1
			gen	el_use_serv_trainingfp	=	s3_4_q1_2
			gen	el_use_serv_trainingfh	=	s3_4_q1_3
			gen	el_use_serv_netting	=	s3_4_q1_4
			gen	el_use_serv_oth	=	s3_4_q1_5
			
			egen tot_exp_service=rowtotal(s3_4_q3_1 s3_4_q3_2 s3_4_q3_3 s3_4_q3_4 s3_4_q3_5), missing

			foreach x in chkwtrqual p_chkwtrqual netserv p_netserv serv_govt serv_ngo serv_pvt tot_exp_service {
			rename `x' bl_`x'
			}

			
			***************************************************
			***************** I N P U T S *********************
			***************************************************			
			
			//Input exp - replace . with 0
			forval i = 1/11 {
			replace s3_5_q2_`i' = 0 if s3_5_q1_`i' == 0
			}
			
			
			

			//. Cost of inputs: Lime, feed, fertilizers, medicines and fuel

			gen dlime = s3_5_q1_1
			gen exp_lime = s3_5_q2_1

			gen dfert_home = s3_5_q1_2 
			gen exp_ferthome = s3_5_q2_2

			gen dfert_comm = s3_5_q1_3 
			gen exp_fertcomm = s3_5_q2_3 

			gen dff_home = s3_5_q1_4 
			gen exp_ffhome = s3_5_q2_4 

			gen dff_comm = s3_5_q1_5
			gen exp_ffcomm = s3_5_q2_5

			gen dgastab = s3_5_q1_6
			gen exp_gastab = s3_5_q2_6

			gen dmed = s3_5_q1_7
			gen exp_med = s3_5_q2_7

			gen dhorm = s3_5_q1_8
			gen exp_horm = s3_5_q2_8

			gen delec = s3_5_q1_9
			gen exp_elec =  s3_5_q2_9

			gen ddiesel = s3_5_q1_10
			gen exp_diesel = s3_5_q2_10

			
			gen	bl_use_inp_lime	=	s3_5_q1_1
			gen	bl_use_inp_hmfert	=	s3_5_q1_2
			gen	bl_use_inp_comfert	=	s3_5_q1_3
			gen	bl_use_inp_hmfeed	=	s3_5_q1_4
			gen	bl_use_inp_comfeed	=	s3_5_q1_5
			gen	bl_use_inp_gastab	=	s3_5_q1_6
			gen	bl_use_inp_chempest	=	s3_5_q1_7
			gen	bl_use_inp_enzhorm	=	s3_5_q1_8
			gen	bl_use_inp_elec	=	s3_5_q1_9
			gen	bl_use_inp_dsl	=	s3_5_q1_10
			gen	bl_use_inp_oth	=	s3_5_q1_11


			*total expenditure
			egen tot_exp_inputs =rowtotal(exp_lime exp_ferthome exp_fertcomm exp_ffhome exp_ffcomm exp_gastab exp_med exp_horm exp_elec exp_diesel s3_5_q2_11), missing
			
				foreach x in dlime exp_lime dfert_home exp_ferthome dfert_comm exp_fertcomm dff_home exp_ffhome dff_comm exp_ffcomm dgastab exp_gastab dmed exp_med dhorm exp_horm delec exp_elec ddiesel exp_diesel tot_exp_inputs {
				rename `x' bl_`x'
				}

				
			***************************************************
			***************** L A B O R *********************
			***************************************************	
			
			gen bl_exp_mlab= s3_6_q1_1+ s3_6_q2_1
			gen bl_exp_flab= s3_6_q1_2+ s3_6_q2_2
			gen bl_exp_clab= s3_6_q1_3+ s3_6_q2_3	
			
			egen bl_tot_exp_labor = rowtotal (bl_exp_mlab bl_exp_flab bl_exp_clab), missing
			
			
			***************** TOTAL AQUACULTURE EXPENDITURE *********************	
			egen bl_tot_exp_aqua = rowtotal (bl_tot_exp_equip bl_tot_exp_service bl_tot_exp_inputs bl_tot_exp_labor), missing
				
				
				

				
				
				
							***********************************************
			***************** L A N D *********************
			***************** L A N D *********************
			***************** L A N D *********************
			***********************************************
				
				
			gen own_agland = agriplot_q2_2               //plot type 2 - Agri land, homestead garden and orchards- check with Rohan

			gen leasein_agland = agriplot_q3_2 

			gen leaseout_agland  = agriplot_q4_2

			* Total land owned- all 5 types of plots
			egen tot_land_own =rowtotal( agriplot_q2_1 agriplot_q2_2  agriplot_q2_3  agriplot_q2_4  agriplot_q2_5 ), missing
			egen tot_land_leasedin =rowtotal( agriplot_q3_1 agriplot_q3_2  agriplot_q3_3  agriplot_q3_4  agriplot_q3_5 ), missing
			egen tot_land_leaseout =rowtotal( agriplot_q4_1 agriplot_q4_2  agriplot_q4_3  agriplot_q4_4  agriplot_q4_5 ), missing
			
			foreach x in own_agland leasein_agland leaseout_agland tot_land_own tot_land_leasedin tot_land_leaseout	 agriplot_q4_2 {
				rename `x' bl_`x'
			}


			//Fish Variety
			rename s3_1_q1_* bl_fishvar*
egen bl_allvar= rowtotal(bl_fishvar1-bl_fishvar119), missing
egen bl_sisvar= rowtotal(bl_fishvar97-bl_fishvar105), missing
gen hh_blsis=(bl_sisvar>0 & bl_sisvar!=.)



***************Pond Productivity**********************
			***************Pond Productivity**********************
			***************Pond Productivity**********************
			***************Pond Productivity**********************
			
			
			//Harvest , Sale and consumed Quantity and Pond Productivity
			foreach x in s3_1a_q1 s3_1a_q2 s3_1a_q3 s3_1b_q1 s3_1b_q2 s3_1b_q3 {
			gen n_`x' = `x'
			replace n_`x' = . if   `x' == 999 | `x' == 9999 |  `x' == 99999 |  `x' == 999999 |  `x' == 9999999 |  `x' == 99999999
			}
			replace n_s3_1b_q2 = . if n_s3_1b_q1 == .

			
			
			
			gen bl_sis_harv = n_s3_1a_q1

			gen bl_sis_sold = n_s3_1a_q2

			gen bl_sis_cons = n_s3_1a_q3 

			gen bl_nonsis_harv = n_s3_1b_q1

			gen bl_nonsis_sold = n_s3_1b_q2

			gen bl_nonsis_cons = n_s3_1b_q3


			
					//Productivity
					gen bl_sis_prod=bl_sis_harv/bl_pondcult
					gen bl_nsis_prod=bl_nonsis_harv/bl_pondcult
					
				
					
					gen bl_harv=bl_sis_harv+bl_nonsis_harv
					

					gen bl_cons=bl_sis_cons+bl_nonsis_cons
					

					gen bl_sold=bl_sis_sold+bl_nonsis_sold
					

					gen bl_prod=bl_harv/bl_pondcult


			*************** Per Decimal **********************
			*************** Per Decimal **********************
			*************** Per Decimal **********************			
			
			
					local pdec_var bl_exp_stw bl_exp_dtw bl_exp_pump bl_exp_dikefence bl_exp_netfish bl_exp_nethapas bl_exp_boat bl_exp_packaging bl_exp_aerator bl_exp_feedingtray bl_exp_harvesttrap bl_exp_guardshade bl_exp_bamboowood bl_exp_elecequip bl_exp_angequip bl_exp_equip_oth bl_tot_regex_equip bl_tot_capex_equip bl_tot_exp_equip bl_tot_exp_service bl_exp_lime bl_exp_ferthome bl_exp_fertcomm bl_exp_ffhome bl_exp_ffcomm bl_exp_gastab bl_exp_med bl_exp_horm bl_exp_elec bl_exp_diesel bl_tot_exp_inputs bl_exp_mlab bl_exp_flab bl_exp_clab bl_tot_exp_labor bl_tot_exp_aqua 



		foreach var in `pdec_var'{
			gen `var'_pdec=`var'/bl_pondcult
			}
			
								
					
					
					
					

			////////////********** Income ***************//////////////////
			////////////********** Income ***************//////////////////
			////////////********** Income ***************//////////////////
			////////////********** Income ***************//////////////////
			////////////********** Income ***************//////////////////
			
			

				
			
			
			
			foreach x in  s4_1_q1 s4_1_q2 s4_1_q3 s4_1_q4 s4_1_q5 s4_1_q6 s4_1_q7 s4_1_q8 s4_1_q9  {
				gen n_`x' = `x'
				replace n_`x' = . if `x' == -555 | `x' == 555
		}

		**no of income sources 
				gen bl_nincsources = 0

				forvalues i = 1/9 {
					replace bl_nincsources = bl_nincsources +  1 if n_s4_1_q`i' != . & n_s4_1_q`i' > 0 
				}
				
				
		**Income comparison 
		gen bl_inc_comp=s4_2
		
		
		
		

			rename	n_s4_1_q1 bl_inc_ag		
			rename	n_s4_1_q2 bl_inc_ls	
			rename	n_s4_1_q3 bl_inc_aqc	
			rename	n_s4_1_q4 bl_inc_aqb	
			rename	n_s4_1_q5 bl_inc_ent	
			rename	n_s4_1_q6 bl_inc_ws	
			rename	n_s4_1_q7 bl_inc_rem	
			rename	n_s4_1_q8 bl_inc_tp	
			rename	n_s4_1_q9 bl_inc_oth
		
		
		
			
		egen bl_aq_inc=	rowtotal (bl_inc_aqc  bl_inc_aqb), missing
		egen bl_hh_inc=rowtotal (bl_inc_ag bl_inc_ls bl_inc_aqc bl_inc_aqb bl_inc_ent bl_inc_ws bl_inc_rem bl_inc_tp bl_inc_oth), missing
		gen bl_prop_aq_inc=bl_aq_inc/bl_hh_inc


			
			
			
		
		/* male time use */
					
			foreach x in q3_male_mandays q4_male_mandays q5_male_mandays q6_male_mandays q7_male_mandays q8_male_mandays q9_male_mandays q10_male_mandays q11_male_mandays q12_male_mandays q13_male_mandays q14_male_mandays {
gen n_`x' = `x'
replace n_`x' = . if `x' == -999
replace n_`x' = . if `x'< 1 & `x'> .9
}	
				
				
			gen bl_m_ta_pondprep = n_q3_male_mandays
			gen bl_m_ta_purff = n_q4_male_mandays
			gen bl_m_ta_purflings = n_q5_male_mandays
			gen bl_m_ta_prepff = n_q6_male_mandays
			gen bl_m_ta_ff = n_q7_male_mandays
			gen bl_m_ta_pmain = n_q8_male_mandays
			gen bl_m_ta_harvsis= n_q9_male_mandays
			gen bl_m_ta_harvmainfish = n_q10_male_mandays
			gen bl_m_ta_fsale_nb = n_q11_male_mandays
			gen bl_m_ta_fsale_lm = n_q12_male_mandays 
			gen bl_m_ta_pmonitor = n_q13_male_mandays
			gen bl_m_ta_oth = n_q14_male_mandays
			
			
			egen bl_m_ta_total = rowtotal (bl_m_ta_pondprep bl_m_ta_purff bl_m_ta_purflings bl_m_ta_prepff bl_m_ta_ff bl_m_ta_pmain bl_m_ta_harvsis bl_m_ta_harvmainfish bl_m_ta_fsale_nb bl_m_ta_fsale_lm bl_m_ta_pmonitor bl_m_ta_oth), missing
			
			
			
			
			//Aquaculture knowledge and practices
			
			forvalues i = 1/7 {
				gen bl_m_aqknow_`i' = s7_1_6_q1_`i'
				replace bl_m_aqknow_`i' = 1 if s7_1_6_q1_`i' == 1 | s7_1_6_q1_`i' == 2
				replace bl_m_aqknow_`i' = 0 if s7_1_6_q1_`i' == 3	
			}

			egen bl_m_aqprac7 = rowtotal (bl_m_aqknow_1 bl_m_aqknow_2 bl_m_aqknow_3 bl_m_aqknow_4 bl_m_aqknow_5 bl_m_aqknow_6 bl_m_aqknow_7), missing

			
			*save "${data}/baseline/infile.dta", replace
			
			
			
			
			
			
			
				////////////********** female time use ***************//////////////////
				////////////********** female time use ***************//////////////////
				////////////********** female time use ***************//////////////////
				////////////********** female time use ***************//////////////////
			
				merge 1:1 hhid using "${baseline_endline}/data/Baseline data files/Aquaculture Baseline HH Survey-2020_FEMALE_PII_DROP_labelled.dta", keep(master match) keepusing(*mandays s7_2_6_q1_*) gen(merge2)
				
				*keep if merge2==3
				drop merge2

							foreach x in q3_female_mandays q4_female_mandays q5_female_mandays q6_female_mandays q7_female_mandays q8_female_mandays q9_female_mandays q10_female_mandays q11_female_mandays q12_female_mandays q13_female_mandays q14_female_mandays {
	gen n_`x' = `x'
	replace n_`x' = . if `x' == -999
	replace n_`x' = . if `x'< 1 & `x'> .9
	}
				
					
				gen bl_f_ta_pondprep = n_q3_female_mandays
				gen bl_f_ta_purff = n_q4_female_mandays
				gen bl_f_ta_purflings = n_q5_female_mandays
				gen bl_f_ta_prepff = n_q6_female_mandays
				gen bl_f_ta_ff = n_q7_female_mandays
				gen bl_f_ta_pmain = n_q8_female_mandays
				gen bl_f_ta_harvsis= n_q9_female_mandays
				gen bl_f_ta_harvmainfish = n_q10_female_mandays
				gen bl_f_ta_fsale_nb = n_q11_female_mandays
				gen bl_f_ta_fsale_lm = n_q12_female_mandays
				gen bl_f_ta_pmonitor = n_q13_female_mandays
				gen bl_f_ta_oth = n_q14_female_mandays
				
				
				egen bl_f_ta_total = rowtotal (bl_f_ta_pondprep bl_f_ta_purff bl_f_ta_purflings bl_f_ta_prepff bl_f_ta_ff bl_f_ta_pmain bl_f_ta_harvsis bl_f_ta_harvmainfish bl_f_ta_fsale_nb bl_f_ta_fsale_lm bl_f_ta_pmonitor bl_f_ta_oth), missing
			
			
			
			
			//Aquaculture knowledge and practices
				
				
				
				
			forvalues i = 1/7 {
				gen bl_f_aqknow_`i' = s7_2_6_q1_`i'
				replace bl_f_aqknow_`i' = 1 if s7_2_6_q1_`i' == 1 | s7_2_6_q1_`i' == 2
				replace bl_f_aqknow_`i' = 0 if s7_2_6_q1_`i' == 3	
			}

			egen bl_f_aqprac7 = rowtotal (bl_f_aqknow_1 bl_f_aqknow_2 bl_f_aqknow_3 bl_f_aqknow_4 bl_f_aqknow_5 bl_f_aqknow_6 bl_f_aqknow_7), missing

			
			save "${data}/baseline/baseline_temp_male.dta", replace	
			
	
	
	
	
	
		****************************************************************************************************
		*** MERGE BASELINE ENDLINE****************************
		*********************************************************************************************	
	
	
						merge 1:1 hhid using "${baseline_endline}/data/Baseline data files\Aquaculture_baseline_listing_PII_Removed__svyd HHs.dta", keepusing(treatment upazila division union category) update replace	
						
						
			generate treat=treatment-1
			label define treat_labels 0 "Control" 1 "LSP" 2 "NGO"
			label values treat treat_labels
			
					rename union unionid
					rename upazila upazilaid
					drop _merge
					
					merge 1:1 hhid using "${data}/endline/endline_temp_male.dta", keepusing(el_*)
					
					save "${data}/baseline_endline/baseline_endline_temp.dta", replace		
					
					
					
					

			
		
		****************************************************************************************************
		*** MERGE WF events intensity****************************
		*********************************************************************************************
	
		use "${folder}\WorldFish MIS\3ie_Datasets\Events register\WF events dataset_unionid_match.dta", replace	
	
		gen mainfocusid=event_mainfocus_fkid
		label define intervention 1 "Aquaculture technology" 2 "Gender" 3 "Nutrition" 4 "Business management" 5 "Credit" 6 "Fish processing" 7 "ICT" 8 "Other" 
		label values mainfocusid intervention
		replace mainfocusid=mainfocusid-1 if event_mainfocus_fkid>6
		
		
		bys unionid Year mainfocusid: gen n=_N
		rename n intensity
		
		collapse (max) intensity, by(unionid Year  mainfocusid treat)
		
		reshape wide intensity, i(unionid Year  treat) j(mainfocusid)
		
		collapse (sum) intensity*, by(unionid)
		
			
		label var intensity1 "Aquaculture"
		label var intensity2 "Gender"
		label var intensity3 "Nutrition"
		label var intensity4 "Business management" 
		label var intensity5 "Credit" 
		label var intensity6 "Fish processing" 
		label var intensity7 "ICT" 
		label var intensity8 "Other" 
			
		save "${folder}\WorldFish MIS\3ie_Datasets\Events register\WF events intensity_union.dta", replace
		
		
		use "${data}/baseline_endline/baseline_endline_temp.dta", replace
		
		merge m:1 unionid using "${folder}\WorldFish MIS\3ie_Datasets\Events register\WF events intensity_union.dta", gen(merge_intensity)
	
	
		foreach var of varlist intensity1 intensity2 intensity3 intensity4 intensity5 intensity6 intensity7 intensity8{
			replace `var'=0 if `var'==.
		}
		
		
		label var intensity1 "Aquaculture"
		label var intensity2 "Gender"
		label var intensity3 "Nutrition"
		label var intensity4 "Business management" 
		label var intensity5 "Credit" 
		label var intensity6 "Fish processing" 
		label var intensity7 "ICT" 
		label var intensity8 "Other" 
		
		save "${data}/baseline_endline/baseline_endline_temp.dta", replace
		
		
		
		
		****************************************************************************************************
		*** MERGE Village data****************************
		*********************************************************************************************
		
		use "${data}/baseline_endline/baseline_endline_temp.dta", clear
		
		gen union = unionid
		
		rename village village_name
		merge m:1 union village_name using "${folder}\baseline_endline\data\Endline data files\Aquaculture Endline 2023 HH Survey - Village (with treatment)_updated.dta", generate(_merge_village) keep (master match)
		
		save "${data}/baseline_endline/baseline_endline_temp.dta", replace
		
			

		

			

			
		//29.10.2024	
			
			
			
			
			
						
			
		****************************************************************************************************
		//Income Per Decimal
		*********************************************************************************************				
			
use "${data}/baseline_endline/baseline_endline_temp.dta", replace			

		
		foreach x in aq_inc hh_inc {
			gen bl_`x'_pdec = bl_`x'/bl_pondcult
			gen el_`x'_pdec = el_`x'/el_pondcult
		}
			
		
			****************************************************************************************************
			*** BUYER ANALYSIS****************************
			*********************************************************************************************	
			

			
						****************************************************************************************************
			*** BUYER ANALYSIS****************************
			*********************************************************************************************	
			
			
			foreach x in s3_7_a s3_7_b s3_7_c s3_7_d {
	rename `x' bl_`x'
	}
	foreach x in s3_7_name_1 s3_7_name_2 s3_7_name_3 {
	rename `x' bl_`x'
	}
	foreach x in s3_7_q5_1 s3_7_q5_1_1 s3_7_q5_2_1 s3_7_q5_3_1 s3_7_q5_4_1 s3_7_q5_5_1 s3_7_q5_6_1 s3_7_q5_7_1 s3_7_q5_8_1 s3_7_q5_9_1 s3_7_q5_10_1 s3_7_q5__222_1 s3_7_q5_other_1 s3_7_q6_1 s3_7_q5_2 s3_7_q5_1_2 s3_7_q5_2_2 s3_7_q5_3_2 s3_7_q5_4_2 s3_7_q5_5_2 s3_7_q5_6_2 s3_7_q5_7_2 s3_7_q5_8_2 s3_7_q5_9_2 s3_7_q5_10_2 s3_7_q5__222_2 s3_7_q5_other_2 s3_7_q6_2 s3_7_q5_3 s3_7_q5_1_3 s3_7_q5_2_3 s3_7_q5_3_3 s3_7_q5_4_3 s3_7_q5_5_3 s3_7_q5_6_3 s3_7_q5_7_3 s3_7_q5_8_3 s3_7_q5_9_3 s3_7_q5_10_3 s3_7_q5__222_3 s3_7_q5_other_3 s3_7_q6_3 {
	rename `x' bl_`x'
	}


	foreach x in s3_7_years_1 s3_7_years_2 s3_7_years_3 {
		rename `x' bl_`x'
	}


			merge 1:1 hhid using "${data}/endline/endline_temp_male.dta", gen(_merge_buy) keep (master match) keepusing (s3_7_a s3_7_b s3_7_c s3_7_d s3_7_name_1 s3_7_name_2 s3_7_name_3 s3_7_q5_1 s3_7_q5_1_1 s3_7_q5_2_1 s3_7_q5_3_1 s3_7_q5_4_1 s3_7_q5_5_1 s3_7_q5_6_1 s3_7_q5_7_1 s3_7_q5_8_1 s3_7_q5_9_1 s3_7_q5_10_1 s3_7_q5__222_1 s3_7_q5_other_1 s3_7_q6_1 s3_7_q5_2 s3_7_q5_1_2 s3_7_q5_2_2 s3_7_q5_3_2 s3_7_q5_4_2 s3_7_q5_5_2 s3_7_q5_6_2 s3_7_q5_7_2 s3_7_q5_8_2 s3_7_q5_9_2 s3_7_q5_10_2 s3_7_q5__222_2 s3_7_q5_other_2 s3_7_q6_2 s3_7_q5_3 s3_7_q5_1_3 s3_7_q5_2_3 s3_7_q5_3_3 s3_7_q5_4_3 s3_7_q5_5_3 s3_7_q5_6_3 s3_7_q5_7_3 s3_7_q5_8_3 s3_7_q5_9_3 s3_7_q5_10_3 s3_7_q5__222_3 s3_7_q5_other_3 s3_7_q6_3)
			
			merge 1:1 hhid using "${data}/endline/endline_temp_male.dta", gen(_merge_buy1) keep (master match) keepusing (s3_7_years_1 s3_7_years_2 s3_7_years_3)
			


			
			foreach x in s3_7_a s3_7_b s3_7_c s3_7_d s3_7_name_1 s3_7_name_2 s3_7_name_3 s3_7_q5_1 s3_7_q5_1_1 s3_7_q5_2_1 s3_7_q5_3_1 s3_7_q5_4_1 s3_7_q5_5_1 s3_7_q5_6_1 s3_7_q5_7_1 s3_7_q5_8_1 s3_7_q5_9_1 s3_7_q5_10_1 s3_7_q5__222_1 s3_7_q5_other_1 s3_7_q6_1 s3_7_q5_2 s3_7_q5_1_2 s3_7_q5_2_2 s3_7_q5_3_2 s3_7_q5_4_2 s3_7_q5_5_2 s3_7_q5_6_2 s3_7_q5_7_2 s3_7_q5_8_2 s3_7_q5_9_2 s3_7_q5_10_2 s3_7_q5__222_2 s3_7_q5_other_2 s3_7_q6_2 s3_7_q5_3 s3_7_q5_1_3 s3_7_q5_2_3 s3_7_q5_3_3 s3_7_q5_4_3 s3_7_q5_5_3 s3_7_q5_6_3 s3_7_q5_7_3 s3_7_q5_8_3 s3_7_q5_9_3 s3_7_q5_10_3 s3_7_q5__222_3 s3_7_q5_other_3 s3_7_q6_3 {
	rename `x' el_`x'			
			}
			
			
			foreach x in s3_7_years_1 s3_7_years_2 s3_7_years_3 {
				rename `x' el_`x'
			}
			
			
		
		
		
		
		
		forvalues x = 1/14 {
	gen bl_buyer_`x' = 1 if bl_s3_7_name_1 == `x' | bl_s3_7_name_2 == `x' | bl_s3_7_name_3 == `x'
	}

	forvalues x = 1/14 {
	gen el_buyer_`x' = 1 if el_s3_7_name_1 == `x' | el_s3_7_name_2 == `x' | el_s3_7_name_3 == `x'
	}
	forvalues x = 1/14 {
	replace bl_buyer_`x' = 0 if bl_buyer_`x' == .
	}
	forvalues x = 1/14 {
	replace el_buyer_`x' = 0 if el_buyer_`x' == . & _merge_buy1 != 1
	}
		
		
		
		
			forvalues x = 1/14 {
				forvalues i=1/10 {
					gen bl_buyer_reason_`x'_`i' = 1 if (bl_s3_7_q5_`i'_1 == 1 | bl_s3_7_q5_`i'_2 == 1 | bl_s3_7_q5_`i'_3 == 1) & bl_buyer_`x' == 1
					replace bl_buyer_reason_`x'_`i' = 0 if bl_buyer_`x' == 0
				}
			}
			forvalues x = 1/14 {
				forvalues i=1/10 {	
		replace bl_buyer_reason_`x'_`i' = 0 if bl_buyer_`x' != . & bl_buyer_reason_`x'_`i' == .
		replace bl_buyer_reason_`x'_`i' = . if bl_buyer_`x' == 0
				}
			}
		
			
			
					


			forvalues x = 1/14 {
				forvalues i=1/10 {
					gen el_buyer_reason_`x'_`i' = 1 if (el_s3_7_q5_`i'_1 == 1 | el_s3_7_q5_`i'_2 == 1 | el_s3_7_q5_`i'_3 == 1) & el_buyer_`x' == 1
					replace el_buyer_reason_`x'_`i' = 0 if el_buyer_`x' == 0
					
				}
			}
			forvalues x = 1/14 {
				forvalues i=1/10 {	
		replace el_buyer_reason_`x'_`i' = 0 if el_buyer_`x' != . & el_buyer_reason_`x'_`i' == .
		replace el_buyer_reason_`x'_`i' = . if el_buyer_`x' == 0
				}
			}
	
			
		
		
		//Rename Endline Vars	
		*********************************************************************************************
		
		rename el_* *
		
		*********************************************************************************************
		//Rename Endline Vars
				
		
		
		
		
		
		
		****************************************************************************************************
		//Total intensity and category generation
		*********************************************************************************************
			
			
			
			egen intensity_tot = rowtotal ( intensity1 intensity2 intensity3 intensity4 intensity5 intensity6 intensity7 intensity8 ), missing
			
			forvalues i = 1/3 {
gen category`i' = 1 if category == `i'
replace category`i' = 0 if category`i' == .
}

			
			//LOg transform
 

foreach x in sis_prod nsis_prod prod tot_regex_equip_pdec tot_capex_equip_pdec tot_exp_equip_pdec tot_exp_inputs_pdec tot_exp_service_pdec tot_exp_labor_pdec tot_exp_aqua_pdec aq_inc_pdec prop_aq_inc hh_inc nincsources {
	gen ln_`x' = log(`x')
	gen ln_bl_`x' = log(bl_`x')
	
}



foreach x in sold {
	gen ln_`x' = log(`x')
	gen ln_bl_`x' = log(bl_`x')
	
}
	
	
	
	
	
	
	//-------------------------------------------------//
	*****************************************************
						//04.09.2024
	*****************************************************
	//-------------------------------------------------//
	
	
		//Sale/pdec
		foreach var in sold {
			gen `var'_pdec=`var'/pondcult
			}
			
			
		foreach var in bl_sold{
			gen `var'_pdec=`var'/bl_pondcult
			}
			
			
			
			
				//24.09.24
			
			//Assets
			
			//male baseline
			
			foreach x in sg3_a1_q2_1 sg3_a1_q2_2 sg3_a1_q2_3 sg3_a1_q2_4 sg3_a1_q2_5 sg3_a1_q2_6 sg3_a1_q2_7 sg3_a1_q2_8 sg3_a1_q2_9 sg3_a1_q2_10 sg3_a1_q2_11 sg3_a1_q2_12 sg3_a1_q2_13 sg3_a1_q2_14 sg3_a1_q2_15 sg3_a1_q2_16 sg3_a1_q2_17 sg3_a1_q2_18 sg3_a1_q2_19 sg3_a1_q2_20 sg3_a1_q2_21 sg3_a1_q2_22 sg3_a2_q2_1 sg3_a2_q2_2 sg3_a2_q2_3 sg3_a2_q2_4 sg3_a2_q2_5 sg3_a2_q2_6 sg3_a2_q2_7 sg3_a2_q2_8 sg3_a2_q2_9 sg3_a2_q2_10 sg3_a2_q2_11 sg3_a2_q2_12 sg3_a2_q2_13 sg3_a2_q2_14 sg3_a2_q2_15 sg3_a2_q2_16 sg3_a2_q2_17 sg3_a2_q2_18 sg3_a2_q2_19 sg3_a2_q2_20 sg3_a2_q2_21 sg3_a2_q2_22 sg3_a2_q2_23 sg3_a2_q2_24 sg3_a2_q2_25 sg3_a3_q2_1 sg3_a3_q2_2 sg3_a3_q2_3 sg3_a3_q2_4 sg3_a3_q2_5 sg3_a3_q2_6{
rename `x' bl_`x'
}
			foreach x in sg3_a1_q1_1 sg3_a1_q1_2 sg3_a1_q1_3 sg3_a1_q1_4 sg3_a1_q1_5 sg3_a1_q1_6 sg3_a1_q1_7 sg3_a1_q1_8 sg3_a1_q1_9 sg3_a1_q1_10 sg3_a1_q1_11 sg3_a1_q1_12 sg3_a1_q1_13 sg3_a1_q1_14 sg3_a1_q1_15 sg3_a1_q1_16 sg3_a1_q1_17 sg3_a1_q1_18 sg3_a1_q1_19 sg3_a1_q1_20 sg3_a1_q1_21 sg3_a1_q1_22 sg3_a2_q1_1 sg3_a2_q1_2 sg3_a2_q1_3 sg3_a2_q1_4 sg3_a2_q1_5 sg3_a2_q1_6 sg3_a2_q1_7 sg3_a2_q1_8 sg3_a2_q1_9 sg3_a2_q1_10 sg3_a2_q1_11 sg3_a2_q1_12 sg3_a2_q1_13 sg3_a2_q1_14 sg3_a2_q1_15 sg3_a2_q1_16 sg3_a2_q1_17 sg3_a2_q1_18 sg3_a2_q1_19 sg3_a2_q1_20 sg3_a2_q1_21 sg3_a2_q1_22 sg3_a2_q1_23 sg3_a2_q1_24 sg3_a2_q1_25 sg3_a3_q1_1 sg3_a3_q1_2 sg3_a3_q1_3 sg3_a3_q1_4 sg3_a3_q1_5 sg3_a3_q1_6{
rename `x' bl_`x'
}

foreach x in s7_1_8_q1 s7_1_8_q2 s7_1_8_q3 s7_1_8_q4 s7_1_8_q5 s7_1_8_q6 s7_1_8_q7{
rename `x' bl_`x'
}
			
			
			
			
			//male endline
			
			merge 1:1 hhid using "${data}/endline/endline_temp_male.dta", keepusing(sg3_a1_q1_1 sg3_a1_q1_2 sg3_a1_q1_3 sg3_a1_q1_4 sg3_a1_q1_5 sg3_a1_q1_6 sg3_a1_q1_7 sg3_a1_q1_8 sg3_a1_q1_9 sg3_a1_q1_10 sg3_a1_q1_11 sg3_a1_q1_12 sg3_a1_q1_13 sg3_a1_q1_14 sg3_a1_q1_15 sg3_a1_q1_16 sg3_a1_q1_17 sg3_a1_q1_18 sg3_a1_q1_19 sg3_a1_q1_20 sg3_a1_q1_21 sg3_a1_q1_22 sg3_a2_q1_1 sg3_a2_q1_2 sg3_a2_q1_3 sg3_a2_q1_4 sg3_a2_q1_5 sg3_a2_q1_6 sg3_a2_q1_7 sg3_a2_q1_8 sg3_a2_q1_9 sg3_a2_q1_10 sg3_a2_q1_11 sg3_a2_q1_12 sg3_a2_q1_13 sg3_a2_q1_14 sg3_a2_q1_15 sg3_a2_q1_16 sg3_a2_q1_17 sg3_a2_q1_18 sg3_a2_q1_19 sg3_a2_q1_20 sg3_a2_q1_21 sg3_a2_q1_22 sg3_a2_q1_23 sg3_a2_q1_24 sg3_a2_q1_25 sg3_a3_q1_1 sg3_a3_q1_2 sg3_a3_q1_3 sg3_a3_q1_4 sg3_a3_q1_5 sg3_a3_q1_6 sg3_a1_q2_1 sg3_a1_q2_2 sg3_a1_q2_3 sg3_a1_q2_4 sg3_a1_q2_5 sg3_a1_q2_6 sg3_a1_q2_7 sg3_a1_q2_8 sg3_a1_q2_9 sg3_a1_q2_10 sg3_a1_q2_11 sg3_a1_q2_12 sg3_a1_q2_13 sg3_a1_q2_14 sg3_a1_q2_15 sg3_a1_q2_16 sg3_a1_q2_17 sg3_a1_q2_18 sg3_a1_q2_19 sg3_a1_q2_20 sg3_a1_q2_21 sg3_a1_q2_22 sg3_a2_q2_1 sg3_a2_q2_2 sg3_a2_q2_3 sg3_a2_q2_4 sg3_a2_q2_5 sg3_a2_q2_6 sg3_a2_q2_7 sg3_a2_q2_8 sg3_a2_q2_9 sg3_a2_q2_10 sg3_a2_q2_11 sg3_a2_q2_12 sg3_a2_q2_13 sg3_a2_q2_14 sg3_a2_q2_15 sg3_a2_q2_16 sg3_a2_q2_17 sg3_a2_q2_18 sg3_a2_q2_19 sg3_a2_q2_20 sg3_a2_q2_21 sg3_a2_q2_22 sg3_a2_q2_23 sg3_a2_q2_24 sg3_a2_q2_25 sg3_a3_q2_1 sg3_a3_q2_2 sg3_a3_q2_3 sg3_a3_q2_4 sg3_a3_q2_5 sg3_a3_q2_6) keep (master match) nogen
			
			merge 1:1 hhid using "${data}/endline/endline_temp_male.dta", keepusing(s7_1_8_q1 s7_1_8_q2 s7_1_8_q3 s7_1_8_q4 s7_1_8_q5 s7_1_8_q6 s7_1_8_q7) keep (master match) nogen
			
			
			
			
			
			//fem baseline
			
			
			merge 1:1 hhid using "${baseline_endline}/data/Baseline data files/Aquaculture Baseline HH Survey-2020_FEMALE_PII_DROP_labelled.dta",keepusing (s2_q1 s2_q2 s2_q3 s2_q4 s2_q5 s2_q6 s2_q7 s7_2_8_q1 s7_2_8_q2 s7_2_8_q3 s7_2_8_q4 s7_2_8_q5 s7_2_8_q6 s7_2_8_q7) keep (master match) nogen
			
			foreach x in s2_q1 s2_q2 s2_q3 s2_q4 s2_q5 s2_q6 s2_q7 s7_2_8_q1 s7_2_8_q2 s7_2_8_q3 s7_2_8_q4 s7_2_8_q5 s7_2_8_q6 s7_2_8_q7{
				rename `x' bl_`x'
			}
			

	
			
			//fem endline
			
			
			merge 1:1 hhid using "${baseline_endline}/data/Endline data files/Aquaculture Endline 2023 HH Survey - FEMALE (final).dta", keepusing(s2_q1_1 s2_q1_2 s2_q1_3 s2_q1_4 s2_q1_5 s2_q1_6 s2_q1_7 s2_q1_8 s2_q2 s2_q3 s2_q4 s2_q5 s2_q6 s2_q7 s2_q8 s2_q9 s2_q10 s7_2_8_q1 s7_2_8_q2 s7_2_8_q3 s7_2_8_q4 s7_2_8_q5 s7_2_8_q6 s7_2_8_q7) keep (master match) nogen
			

			
			
			//cleaning
			forval i = 1/17 {
			replace sg3_a1_q1_`i' = 0 if (sg3_a1_q2_`i' > 100 | sg3_a1_q2_`i' == -888) & sg3_a1_q2_`i'!= .
			replace sg3_a1_q2_`i' = . if (sg3_a1_q2_`i' > 100 | sg3_a1_q2_`i' == -888) & sg3_a1_q2_`i'!= .
			}
			
			
			forval i = 1/25 {
			replace sg3_a2_q1_`i' = 0 if (sg3_a2_q2_`i' > 100 | sg3_a2_q2_`i' == -888 | sg3_a2_q2_`i' == .888) & sg3_a2_q2_`i'!= .
			replace sg3_a2_q2_`i' = . if (sg3_a2_q2_`i' > 100 | sg3_a2_q2_`i' == -888 | sg3_a2_q2_`i' == .888) & sg3_a2_q2_`i'!= .
			}
			
			
			
			egen s2_q1 = rowtotal ( s2_q1_1 s2_q1_2 s2_q1_3 s2_q1_4 s2_q1_5 s2_q1_6 s2_q1_7 s2_q1_8 ), missing
			rename s2_q5 s2_q5a
			rename s2_q6 s2_q5
			rename s2_q7 s2_q6
			rename s2_q8 s2_q7
			
			
			
						
	//Label vars
	
	
label variable	b5	"Count of boys in 0-5 age group in the HH "
label variable	b11	"Count of boys in 6-11 age group in the HH "
label variable	b17	"Count of boys in 12-17 age group in the HH "
label variable	m1	"Count of men in 18-40 age group in the HH "
label variable	m2	"Count of men in 41-60 age group in the HH "
label variable	m3	"Count of men in >60 age group in the HH "
label variable	g5	"Count of girls in 0-5 age group in the HH "
label variable	g11	"Count of girls in 6-11 age group in the HH "
label variable	g17	"Count of girls in 12-17 age group in the HH "
label variable	f1	"Count of women in 18-40 age group in the HH "
label variable	f2	"Count of women in 41-60 age group in the HH "
label variable	f3	"Count of women in >60 age group in the HH "
label variable	hhsize	"count of all people residing in the household "
label variable	ahhsize	"weighted family size "
label variable	npondown	"No of ponds owned by HH "
label variable	pondown	"Total area of pond owned by HH "
label variable	npondleasein	"Number of ponds leased in by the HH "
label variable	pondleasein	"Area of ponds leased in "
label variable	npondleaseout	"Number of ponds leased out by the HH "
label variable	pondleaseout	"Area of ponds leased out "
label variable	pondcult	"Area of ponds where fish was cultivated in Apr 22 - Mar 2023 "
label variable	pondcult_sis	"Area of ponds where SIS was cultivated in Apr 22 - Mar 2023 "
label variable	m_pondcult	"Number of male members involved in pond cultivation "
label variable	f_pondcult	"Number of female members involved in pond cultivation "
label variable	dgrp	"=1 if any member is part of any group "
label variable	ngrp	"Number of distinct groups any member is part of "
label variable	mem_grp	"Number of members that are part of any group "
label variable	dgrp_ngo	"=1 if any member is part of any NGO group "
label variable	ngrp_ngo	"No of household members that are part of NGO groups "
label variable	dgrp_bractmss	"=1 if any member is part of any BRAC TMSS group "
label variable	ngrp_bractmss	"No of household members that are part of BRAC and TMSS groups "
label variable	dgrp_aqua	"=1 if any member is part of any aquaculture group "
label variable	ngrp_aqua	"No of household members part of Aquaculture group "
label variable	dgrp_fb	"=1 if any member is part of any facebook group "
label variable	dgrp_rf	"=1 if any member is part of RightFish group "
label variable	d_knowrh	"=1 if heard of Right Haat "
label variable	lagri_occ	"=1 if any hh member involved in labour, agri "
label variable	lcons_occ	"=1 if any hh member involved in labour, construction "
label variable	loth_occ	"=1 if any hh member involved in labour, other "
label variable	agri_occ	"=1 if any hh member involved in agriculture "
label variable	aqua_occ	"=1 if any hh member involved in aquaculture "
label variable	ls_occ	"=1 if any hh member involved in livestock rearing "
label variable	sg_occ	"=1 if any hh member involved in salaried govt job "
label variable	spvt_occ	"=1 if any hh member involved in salaried pvt job "
label variable	bprod_occ	"=1 if any hh member involved in product related business "
label variable	bserv_occ	"=1 if any hh member involved in service-related business "
label variable	bps_occ	"=1 if any hh member involved in both product and service related business "
label variable	both_occ	"=1 if any hh member involved in any other business "
label variable	nocc	"total types of occupation hh members are involved in "
label variable	ncenroll	"Sum of all members for whom are currently enrolled in school==1 (Currently Enrolled==1) "
label variable	maxed_male	"Highest years of schooling from amongst male member of the household who are over 30 years of age "
label variable	maxed_fem	"Highest years of schooling from amongst female members of the hhold who are over 30 years of age "
label variable	hhmignum	"Total number of migrants "
label variable	dfling_hat	"1 if fingeling purchased from Hatchery "
label variable	dfling_nurs	"1 if fingeling purchased from Nursery "
label variable	dfling_trader	"1 if fingeling purchased from Trader "
label variable	dfling_ncomm	"1 if fingeling purchased from non comm sources ( open, neighbour, relatives etc) "
label variable	dfling_scg	"1 if fingeling received or purchased from Seed commission agent "
label variable	dfling_comm	"1 if fingeling hatchery, nursery, Seed commission agent, trader "
label variable	dfling_comm21	"1 if fingeling source on or after 2021 "
label variable	tot_exp_equip "Total expenditure on equipments "
label variable	tot_regex_equip	"Regular exp on equipments (fishing rod etc) "
label variable	tot_capex_equip	"Capex on equipments (borewell etc) "
label variable	chkwtrqual	"1 if checked water quality "
label variable	p_chkwtrqual	"1 if paid for water quality check "
label variable	netserv	"1 if used netting services "
label variable	p_netserv	"1 if paid for netting services "
label variable	serv_govt	"1 if availed any service from govt "
label variable	serv_ngo	"1 if availed any service from ngo "
label variable	serv_pvt	"1 if availed any service from pvt "
label variable	tot_exp_service	"Total expenditure on services "
label variable	use_inp_lime	"Use of Input: Lime"
label variable	use_inp_hmfert	"Use of Input: Home fertilizer"
label variable	use_inp_comfert	"Use of Input: Commercial Fertilizer"
label variable	use_inp_hmfeed	"Use of Input: Home-made fish feed"
label variable	use_inp_comfeed	"Use of Input: Purchased/commercial fish feed"
label variable	use_inp_gastab	"Use of Input: Gas tablets (AluminiumPhosphite)"
label variable	use_inp_chempest	"Use of Input: Other medicines/chemical pesticides"
label variable	use_inp_enzhorm	"Use of Input: Enzymes/hormones"
label variable	use_inp_elec	"Use of Input: Electricity "
label variable	use_inp_dsl	"Use of Input: Diesel"
label variable	use_inp_oth	"Use of Input: Others"
label variable	exp_lime	"Input Expenditure: Lime"
label variable	exp_ferthome	"Input Expenditure: Home fertilizer"
label variable	exp_fertcomm	"Input Expenditure: Commercial Fertilizer"
label variable	exp_ffhome	"Input Expenditure: Home-made fish feed"
label variable	exp_ffcomm	"Input Expenditure: Purchased/commercial fish feed"
label variable	exp_gastab	"Input Expenditure: Gas tablets (AluminiumPhosphite)"
label variable	exp_med	"Input Expenditure: Other medicines/chemical pesticides"
label variable	exp_horm	"Input Expenditure: Enzymes/hormones"
label variable	exp_elec	"Input Expenditure: Electricity "
label variable	exp_diesel	"Input Expenditure: Diesel"
label variable	tot_exp_inputs	"Total Input Expenditure"
label variable	tot_exp_labor	"Total Labor expenditure"
label variable	tot_exp_aqua	"Total Aquaculture expenditure"
label variable	allvar	"Total fish varieties cultivated"
label variable	sisvar	"Total SIS fish varieties cultivated"
label variable	own_agland	"Total Agri land owned"
label variable	leasein_agland	"Total Agri land leaselin"
label variable	leaseout_agland	"Total Agri land leaseout"
label variable	tot_land_own	"Total  land owned"
label variable	tot_land_leasedin	"Total land leased in"
label variable	tot_land_leaseout	"Total land leased out"
label variable	sis_harv	"SIS quantity harvest "
label variable	sis_sold	"SIS quantity sold "
label variable	sis_cons	"SIS quantity consumed "
label variable	nonsis_harv	"Non-SIS quantity harvest "
label variable	nonsis_sold	"Non-SIS quantity sold "
label variable	nonsis_cons	"Non-SIS quantity consumed "
label variable	harv	"Total fish harvested"
label variable	cons	"Total fish consumed"
label variable	sold	"Total fish sold"
label variable sold_pdec "Quantity sold (kg/decimal)"
label variable	sis_prod "SIS Productivity"
label variable	nsis_prod "NSIS Productivity"


label variable	prod	"Total Productivity"
label variable	inc_ag	"Income: Agriculture "
label variable	inc_ag_ws	"Income: Agriculture wage labour-skilled"
label variable	inc_ag_wu	"Income: Agriculture wage labour-"
label variable	inc_nag_ws	"Income: Non-agricultural wage labour-skilled"
label variable	inc_nag_wu	"Income: Non-agricultural wage labour-unskilled"
label variable	inc_ls	"Income: Livestock"
label variable	inc_aqc	"Income: Aquaculture: pond cultivation"
label variable	inc_aqb	"Income: Aquaculture: enterprises (like hatchery, nursery, fish feed/seed business, etc)"
label variable	inc_ent	"Income: Other non-aquaculture enterprises"
label variable	inc_ws	"Income: Wages and Salaries"
label variable	inc_rem	"Income: Remittances from family"
label variable	inc_tp	"Income: Transfers"
label variable	inc_oth	"Income: Others (specify)"
label variable	exp_ag	"Expenditure: Agriculture "
label variable	exp_ag_ws	"Expenditure: Agriculture wage labour-skilled"
label variable	exp_ag_wu	"Expenditure: Agriculture wage labour-"
label variable	exp_nag_ws	"Expenditure: Non-agricultural wage labour-skilled"
label variable	exp_nag_wu	"Expenditure: Non-agricultural wage labour-unskilled"
label variable	exp_ls	"Expenditure: Livestock"
label variable	exp_aqc	"Expenditure: Aquaculture: pond cultivation"
label variable	exp_aqb	"Expenditure: Aquaculture: enterprises (like hatchery, nursery, fish feed/seed business, etc)"
label variable	exp_ent	"Expenditure: Other non-aquaculture enterprises"
label variable	exp_ws	"Expenditure: Wages and Salaries"
label variable	exp_rem	"Expenditure: Remittances from family"
label variable	exp_tp	"Expenditure: Transfers"
label variable	exp_oth	"Expenditure: Others (specify)"
label variable	aq_inc	"Total Aquaculture Income"
label variable	hh_inc	"Total HH Income"
label variable	prop_aq_inc	"Proportion of HH inc to Aqua inc"
label variable	m_ta_pondprep	"Time use: Pond preparation (person days of work)"
label variable	m_ta_purff	"Time use: Purchase & collection of fish feed (person days of work) "
label variable	m_ta_purflings	"Time use: Purchase & collection of fingerlings (person days of work"
label variable	m_ta_prepff	"Time use: Preparation of fish feed"
label variable	m_ta_ff	"Time use: Feeding of fish (person days of work)"
label variable	m_ta_pmain	"Time use: Maintenance of pond (weed removal, application of lime, etc) (person days of work)"
label variable	m_ta_harvsis	"Time use: Harvesting of Mola or other SIS ( Person Days of work)"
label variable	m_ta_harvmainfish	"Time use: Harvesting of main fish species (Person Days of work)"
label variable	m_ta_fsale_nb	"Time use: Sales of fish to neighbors and near house ( Person Days of work)"
label variable	m_ta_fsale_lm	"Time use: Sales of fish in local or regional markets ( PersonDays of work)"
label variable	m_ta_pmonitor	"Time use: Pond monitoring ( Person Days of work)"
label variable	m_ta_oth	"Time use: Other time use ( PersonDays of work)"
label variable	f_ta_pondprep	"Time use: Pond preparation (person days of work)"
label variable	f_ta_purff	"Time use: Purchase & collection of fish feed (person days of work) "
label variable	f_ta_purflings	"Time use: Purchase & collection of fingerlings (person days of work"
label variable	f_ta_prepff	"Time use: Preparation of fish feed"
label variable	f_ta_ff	"Time use: Feeding of fish (person days of work)"
label variable	f_ta_pmain	"Time use: Maintenance of pond (weed removal, application of lime, etc) (person days of work)"
label variable	f_ta_harvsis	"Time use: Harvesting of Mola or other SIS ( Person Days of work)"
label variable	f_ta_harvmainfish	"Time use: Harvesting of main fish species (Person Days of work)"
label variable	f_ta_fsale_nb	"Time use: Sales of fish to neighbors and near house ( Person Days of work)"
label variable	f_ta_fsale_lm	"Time use: Sales of fish in local or regional markets ( PersonDays of work)"
label variable	f_ta_pmonitor	"Time use: Pond monitoring ( Person Days of work)"
label variable	f_ta_oth	"Time use: Other time use ( PersonDays of work)"
label variable	m_ta_total	"Time use: Male Total Time use"
label variable	f_ta_total	"Time use: Female Total Time use"
label variable	m_aqprac7	"Sum: Male knowledge about 7 practices"
label variable	m_aqprac27	"Sum: Male knowledge about 27 practices"
label variable	m_aqpracdo7	"Sum: Male practicing 7 practices"
label variable	f_aqprac7	"Sum: Female knowledge about 7 practices"

label variable	intensity1	"No of WF events conducted in Union: Aquaculture"
label variable	intensity2	"No of WF events conducted in Union: Gender"
label variable	intensity3	"No of WF events conducted in Union: Nutrition"
label variable	intensity4	"No of WF events conducted in Union: Business management"
label variable	intensity5	"No of WF events conducted in Union: Credit"
label variable	intensity6	"No of WF events conducted in Union: Fish processing"
label variable	intensity7	"No of WF events conducted in Union: ICT"
label variable	intensity8	"No of WF events conducted in Union: Other"
label variable	tot_regex_equip_pdec	"Total exp: Regular Equipment (per decimal)"
label variable	tot_capex_equip_pdec	"Total exp: Capital Equipment (per decimal)"
label variable	tot_exp_equip_pdec	"Total exp: Total Eqipment [regex+capex] (per decimal)"
label variable	tot_exp_service_pdec	"Total exp: Service (per decimal)"
label variable	tot_exp_inputs_pdec	"Total exp: Inputs (per decimal)"
label variable	tot_exp_labor_pdec	"Total exp: Labor (per decimal)"
label variable	tot_exp_aqua_pdec	"Total exp: Aquaculture (per decimal)"
label variable	aq_inc_pdec	"Aqua income(per decimal)"
label variable	ln_tot_regex_equip_pdec	"Total exp: Regular Equipment (log per decimal)"
label variable	ln_bl_tot_regex_equip_pdec	"Total exp: Regular Equipment (log per decimal)"
label variable	ln_tot_capex_equip_pdec	"Total exp: Capital Equipment(log per decimal)"
label variable	ln_bl_tot_capex_equip_pdec	"Total exp: Capital Equipment(log per decimal)"
label variable	ln_tot_exp_equip_pdec	"Total exp: Total Eqipment [regex+capex](log per decimal)"
label variable	ln_bl_tot_exp_equip_pdec	"Total exp: Total Eqipment [regex+capex](log per decimal)"
label variable	ln_tot_exp_inputs_pdec	"Total exp: Inputs(log per decimal)"
label variable	ln_bl_tot_exp_inputs_pdec	"Total exp: Inputs(log per decimal)"
label variable	ln_tot_exp_service_pdec	"Total exp: Service(log per decimal)"
label variable	ln_bl_tot_exp_service_pdec	"Total exp: Service(log per decimal)"
label variable	ln_tot_exp_labor_pdec	"Total exp: Labor(log per decimal)"
label variable	ln_bl_tot_exp_labor_pdec	"Total exp: Labor(log per decimal)"
label variable	ln_tot_exp_aqua_pdec	"Total exp: Aquaculture(log per decimal)"
label variable	ln_bl_tot_exp_aqua_pdec	"Total exp: Aquaculture(log per decimal)"
label variable	ln_aq_inc_pdec	"Aqua income (log per decimal)"
label variable	ln_bl_aq_inc_pdec	"Aqua income (log per decimal)"




			
			
label variable 	bl_b5	"Count of boys in 0-5 age group in the HH "
label variable 	bl_b11	"Count of boys in 6-11 age group in the HH "
label variable 	bl_b17	"Count of boys in 12-17 age group in the HH "
label variable 	bl_m1	"Count of men in 18-40 age group in the HH "
label variable 	bl_m2	"Count of men in 41-60 age group in the HH "
label variable 	bl_m3	"Count of men in >60 age group in the HH "
label variable 	bl_g5	"Count of girls in 0-5 age group in the HH "
label variable 	bl_g11	"Count of girls in 6-11 age group in the HH "
label variable 	bl_g17	"Count of girls in 12-17 age group in the HH "
label variable 	bl_f1	"Count of women in 18-40 age group in the HH "
label variable 	bl_f2	"Count of women in 41-60 age group in the HH "

label variable 	bl_f3	"Count of women in >60 age group in the HH "
label variable 	bl_hhsize	"count of all people residing in the household "
label variable 	bl_ahhsize	"weighted family size "
label variable 	bl_npondown	"No of ponds owned by HH "
label variable 	bl_pondown	"Total area of pond owned by HH "
label variable 	bl_npondleasein	"Number of ponds leased in by the HH "
label variable 	bl_pondleasein	"Area of ponds leased in "
label variable 	bl_npondleaseout	"Number of ponds leased out by the HH "
label variable bl_pondleaseout "Area of ponds leased out "

label variable 	bl_pondcult	"Area of ponds where fish was cultivated in Apr 22 - Mar 2023 "
label variable 	bl_pondcult_sis	"Area of ponds where SIS was cultivated in Apr 22 - Mar 2023 "
label variable 	bl_m_pondcult	"Number of male members involved in pond cultivation "
label variable 	bl_f_pondcult	"Number of female members involved in pond cultivation "
label variable 	bl_dgrp	"=1 if any member is part of any group "
label variable 	bl_ngrp	"Number of distinct groups any member is part of "
label variable 	bl_mem_grp	"Number of members that are part of any group "
label variable 	bl_dgrp_ngo	"=1 if any member is part of any NGO group "
label variable 	bl_ngrp_ngo	"No of household members that are part of NGO groups "
label variable 	bl_dgrp_bractmss	"=1 if any member is part of any BRAC TMSS group "
label variable 	bl_ngrp_bractmss	"No of household members that are part of BRAC and TMSS groups "
label variable 	bl_dgrp_aqua	"=1 if any member is part of any aquaculture group "
label variable 	bl_ngrp_aqua	"No of household members part of Aquaculture group "



label variable 	bl_ncenroll	"Sum of all members for whom are currently enrolled in school==1 (Currently Enrolled==1) "
label variable 	bl_maxed_male	"Highest years of schooling from amongst male member of the household who are over 30 years of age "
label variable 	bl_maxed_fem	"Highest years of schooling from amongst female members of the hhold who are over 30 years of age "
label variable 	bl_hhmignum	"Total number of migrants "
label variable 	bl_dfling_hat	"1 if fingeling purchased from Hatchery "
label variable 	bl_dfling_nurs	"1 if fingeling purchased from Nursery "
label variable 	bl_dfling_trader	"1 if fingeling purchased from Trader "
label variable 	bl_dfling_ncomm	"1 if fingeling purchased from non comm sources ( open, neighbour, relatives etc) "
label variable 	bl_dfling_scg	"1 if fingeling received or purchased from Seed commission agent "
label variable 	bl_dfling_comm	"1 if fingeling hatchery, nursery, Seed commission agent, trader "
label variable 	bl_dfling_comm21	"1 if fingeling source on or after 2021 "
label variable 	bl_tot_exp_equip	"Total expenditure on equipments "
label variable 	bl_tot_regex_equip	"Regular exp on equipments (fishing rod etc) "
label variable 	bl_tot_capex_equip	"Capex on equipments (borewell etc) "
label variable 	bl_chkwtrqual	"1 if checked water quality "
label variable 	bl_p_chkwtrqual	"1 if paid for water quality check "
label variable 	bl_netserv	"1 if used netting services "
label variable 	bl_p_netserv	"1 if paid for netting services "
label variable 	bl_serv_govt	"1 if availed any service from govt "
label variable 	bl_serv_ngo	"1 if availed any service from ngo "
label variable 	bl_serv_pvt	"1 if availed any service from pvt "
label variable 	bl_tot_exp_service	"Total expenditure on services "
label variable 	bl_use_inp_lime	"Use of Input: Lime"
label variable 	bl_use_inp_hmfert	"Use of Input: Home fertilizer"
label variable 	bl_use_inp_comfert	"Use of Input: Commercial Fertilizer"
label variable 	bl_use_inp_hmfeed	"Use of Input: Home-made fish feed"
label variable 	bl_use_inp_comfeed	"Use of Input: Purchased/commercial fish feed"
label variable 	bl_use_inp_gastab	"Use of Input: Gas tablets (AluminiumPhosphite)"
label variable 	bl_use_inp_chempest	"Use of Input: Other medicines/chemical pesticides"
label variable 	bl_use_inp_enzhorm	"Use of Input: Enzymes/hormones"
label variable 	bl_use_inp_elec	"Use of Input: Electricity "
label variable 	bl_use_inp_dsl	"Use of Input: Diesel"
label variable 	bl_use_inp_oth	"Use of Input: Others"
label variable 	bl_exp_lime	"Input Expenditure: Lime"
label variable 	bl_exp_ferthome	"Input Expenditure: Home fertilizer"
label variable 	bl_exp_fertcomm	"Input Expenditure: Commercial Fertilizer"
label variable 	bl_exp_ffhome	"Input Expenditure: Home-made fish feed"
label variable 	bl_exp_ffcomm	"Input Expenditure: Purchased/commercial fish feed"
label variable 	bl_exp_gastab	"Input Expenditure: Gas tablets (AluminiumPhosphite)"
label variable 	bl_exp_med	"Input Expenditure: Other medicines/chemical pesticides"
label variable 	bl_exp_horm	"Input Expenditure: Enzymes/hormones"
label variable 	bl_exp_elec	"Input Expenditure: Electricity "
label variable 	bl_exp_diesel	"Input Expenditure: Diesel"
label variable 	bl_tot_exp_inputs	"Total Input Expenditure"
label variable 	bl_tot_exp_labor	"Total Labor expenditure"
label variable 	bl_tot_exp_aqua	"Total Aquaculture expenditure"
label variable 	bl_allvar	"Total fish varieties cultivated"
label variable 	bl_sisvar	"Total SIS fish varieties cultivated"
label variable 	bl_own_agland	"Total Agri land owned"
label variable 	bl_leasein_agland	"Total Agri land leaselin"
label variable 	bl_leaseout_agland	"Total Agri land leaseout"
label variable 	bl_tot_land_own	"Total  land owned"
label variable 	bl_tot_land_leasedin	"Total land leased in"
label variable 	bl_tot_land_leaseout	"Total land leased out"
label variable 	bl_sis_harv	"SIS quantity harvest "
label variable 	bl_sis_sold	"SIS quantity sold "
label variable 	bl_sis_cons	"SIS quantity consumed "
label variable 	bl_nonsis_harv	"Non-SIS quantity harvest "
label variable 	bl_nonsis_sold	"Non-SIS quantity sold "
label variable 	bl_nonsis_cons	"Non-SIS quantity consumed "
label variable 	bl_harv	"Total fish harvested"
label variable 	bl_cons	"Total fish consumed"
label variable 	bl_sold	"Total fish sold"
label variable bl_sold_pdec "Quantity sold (kg/decimal)"
label variable 	bl_prod	"Total Productivity"
label variable	bl_sis_prod "SIS Productivity"
label variable	bl_nsis_prod "NSIS Productivity"


label variable 	bl_inc_ag	"Income: Agriculture "
label variable 	bl_inc_ls	"Income: Livestock"
label variable 	bl_inc_aqc	"Income: Aquaculture: pond cultivation"
label variable 	bl_inc_aqb	"Income: Aquaculture: enterprises (like hatchery, nursery, fish feed/seed business, etc)"
label variable 	bl_inc_ent	"Income: Other non-aquaculture enterprises"
label variable 	bl_inc_ws	"Income: Wages and Salaries"
label variable 	bl_inc_rem	"Income: Remittances from family"
label variable 	bl_inc_tp	"Income: Transfers"
label variable 	bl_inc_oth	"Income: Others (specify)"
label variable 	bl_aq_inc	"Total Aquaculture Income"
label variable 	bl_hh_inc	"Total HH Income"
label variable 	bl_prop_aq_inc	"Proportion of HH inc to Aqua inc"
label variable 	bl_m_ta_pondprep	"Time use: Pond preparation (person days of work)"
label variable 	bl_m_ta_purff	"Time use: Purchase & collection of fish feed (person days of work) "
label variable 	bl_m_ta_purflings	"Time use: Purchase & collection of fingerlings (person days of work"
label variable 	bl_m_ta_prepff	"Time use: Preparation of fish feed"
label variable 	bl_m_ta_ff	"Time use: Feeding of fish (person days of work)"
label variable 	bl_m_ta_pmain	"Time use: Maintenance of pond (weed removal, application of lime, etc) (person days of work)"
label variable 	bl_m_ta_harvsis	"Time use: Harvesting of Mola or other SIS ( Person Days of work)"
label variable 	bl_m_ta_harvmainfish	"Time use: Harvesting of main fish species (Person Days of work)"
label variable 	bl_m_ta_fsale_nb	"Time use: Sales of fish to neighbors and near house ( Person Days of work)"
label variable 	bl_m_ta_fsale_lm	"Time use: Sales of fish in local or regional markets ( PersonDays of work)"
label variable 	bl_m_ta_pmonitor	"Time use: Pond monitoring ( Person Days of work)"
label variable 	bl_m_ta_oth	"Time use: Other time use ( PersonDays of work)"
label variable 	bl_f_ta_pondprep	"Time use: Pond preparation (person days of work)"
label variable 	bl_f_ta_purff	"Time use: Purchase & collection of fish feed (person days of work) "
label variable 	bl_f_ta_purflings	"Time use: Purchase & collection of fingerlings (person days of work"
label variable 	bl_f_ta_prepff	"Time use: Preparation of fish feed"
label variable 	bl_f_ta_ff	"Time use: Feeding of fish (person days of work)"
label variable 	bl_f_ta_pmain	"Time use: Maintenance of pond (weed removal, application of lime, etc) (person days of work)"
label variable 	bl_f_ta_harvsis	"Time use: Harvesting of Mola or other SIS ( Person Days of work)"
label variable 	bl_f_ta_harvmainfish	"Time use: Harvesting of main fish species (Person Days of work)"
label variable 	bl_f_ta_fsale_nb	"Time use: Sales of fish to neighbors and near house ( Person Days of work)"
label variable 	bl_f_ta_fsale_lm	"Time use: Sales of fish in local or regional markets ( PersonDays of work)"
label variable 	bl_f_ta_pmonitor	"Time use: Pond monitoring ( Person Days of work)"
label variable 	bl_f_ta_oth	"Time use: Other time use ( PersonDays of work)"
label variable 	bl_m_ta_total	"Time use: Male Total Time use"
label variable 	bl_f_ta_total	"Time use: Female Total Time use"
label variable 	bl_m_aqprac7	"Sum: Male knowledge about 7 practices"

label variable 	bl_f_aqprac7	"Sum: Female knowledge about 7 practices"


label variable 	bl_tot_regex_equip_pdec	"Total exp: Regular Equipment (per decimal)"
label variable 	bl_tot_capex_equip_pdec	"Total exp: Capital Equipment (per decimal)"
label variable 	bl_tot_exp_equip_pdec	"Total exp: Total Eqipment [regex+capex] (per decimal)"
label variable 	bl_tot_exp_service_pdec	"Total exp: Service (per decimal)"
label variable 	bl_tot_exp_inputs_pdec	"Total exp: Inputs (per decimal)"
label variable 	bl_tot_exp_labor_pdec	"Total exp: Labor (per decimal)"
label variable 	bl_tot_exp_aqua_pdec	"Total exp: Aquaculture (per decimal)"
label variable 	bl_aq_inc_pdec	"Aqua income(per decimal)"

			

			
			
			
			
			//30/09/24
			
			
egen sg3_a1_q1 = rowtotal ( sg3_a1_q1_1 sg3_a1_q1_2 sg3_a1_q1_3 sg3_a1_q1_4 sg3_a1_q1_5 sg3_a1_q1_6 sg3_a1_q1_7 sg3_a1_q1_8 sg3_a1_q1_9 sg3_a1_q1_10 sg3_a1_q1_11 sg3_a1_q1_12 sg3_a1_q1_13 sg3_a1_q1_14 sg3_a1_q1_15 sg3_a1_q1_16 sg3_a1_q1_17 ), missing

egen bl_sg3_a1_q1 = rowtotal ( bl_sg3_a1_q1_1 bl_sg3_a1_q1_2 bl_sg3_a1_q1_3 bl_sg3_a1_q1_4 bl_sg3_a1_q1_5 bl_sg3_a1_q1_6 bl_sg3_a1_q1_7 bl_sg3_a1_q1_8 bl_sg3_a1_q1_9 bl_sg3_a1_q1_10 bl_sg3_a1_q1_11 bl_sg3_a1_q1_12 bl_sg3_a1_q1_13 bl_sg3_a1_q1_14 bl_sg3_a1_q1_15 bl_sg3_a1_q1_16 bl_sg3_a1_q1_17 ), missing

egen sg3_a2_q1 = rowtotal ( sg3_a2_q1_1 sg3_a2_q1_2 sg3_a2_q1_3 sg3_a2_q1_4 sg3_a2_q1_5 sg3_a2_q1_6 sg3_a2_q1_7 sg3_a2_q1_8 sg3_a2_q1_9 sg3_a2_q1_10 sg3_a2_q1_11 sg3_a2_q1_12 sg3_a2_q1_13 sg3_a2_q1_14 sg3_a2_q1_15 sg3_a2_q1_16 sg3_a2_q1_17 sg3_a2_q1_18 sg3_a2_q1_19 sg3_a2_q1_20 sg3_a2_q1_21 sg3_a2_q1_22 sg3_a2_q1_23 sg3_a2_q1_24 ), missing

egen bl_sg3_a2_q1 = rowtotal ( bl_sg3_a2_q1_1 bl_sg3_a2_q1_2 bl_sg3_a2_q1_3 bl_sg3_a2_q1_4 bl_sg3_a2_q1_5 bl_sg3_a2_q1_6 bl_sg3_a2_q1_7 bl_sg3_a2_q1_8 bl_sg3_a2_q1_9 bl_sg3_a2_q1_10 bl_sg3_a2_q1_11 bl_sg3_a2_q1_12 bl_sg3_a2_q1_13 bl_sg3_a2_q1_14 bl_sg3_a2_q1_15 bl_sg3_a2_q1_16 bl_sg3_a2_q1_17 bl_sg3_a2_q1_18 bl_sg3_a2_q1_19 bl_sg3_a2_q1_20 bl_sg3_a2_q1_21 bl_sg3_a2_q1_22 bl_sg3_a2_q1_23 bl_sg3_a2_q1_24 ), missing

egen sg3_a3_q1_largelivestock = rowtotal ( sg3_a3_q1_1 sg3_a3_q1_2 sg3_a3_q1_3 sg3_a3_q1_4 sg3_a3_q1_5 ), missing

egen bl_sg3_a3_q1_largelivestock = rowtotal ( bl_sg3_a3_q1_1 bl_sg3_a3_q1_2 bl_sg3_a3_q1_3 bl_sg3_a3_q1_4 bl_sg3_a3_q1_5 ), missing



egen sg3_a3_q2_livestock_n = rowtotal ( sg3_a3_q2_1 sg3_a3_q2_2 sg3_a3_q2_3 sg3_a3_q2_4 sg3_a3_q2_5 ), missing
egen bl_sg3_a3_q2_livestock_n = rowtotal ( bl_sg3_a3_q2_1 bl_sg3_a3_q2_2 bl_sg3_a3_q2_3 bl_sg3_a3_q2_4 bl_sg3_a3_q2_5 ), missing



egen hh_nonfood_exp = rowtotal (s2_q2 s2_q3 s2_q4 s2_q7), missing
egen bl_hh_nonfood_exp = rowtotal (bl_s2_q2 bl_s2_q3 bl_s2_q4 bl_s2_q7), missing



			
			
label variable s2_q1 "HH Expenditure: Food Items (endline)"
label variable sg3_a1_q1 "Productive asset ownership 1/17"
label variable bl_sg3_a1_q1 "Productive asset ownership 1/17"
label variable sg3_a2_q1 "HH asset ownership 1/24"
label variable bl_sg3_a2_q1 "HH asset ownership 1/24"
label variable sg3_a3_q1_largelivestock "Livestock ownership 1/5"
label variable bl_sg3_a3_q1_largelivestock "Livestock ownership 1/5"

label variable sg3_a3_q2_livestock_n "Total no. of Livestock 1/5"
label variable bl_sg3_a3_q2_livestock_n "Total no. of Livestock 1/5"

label variable hh_nonfood_exp "Non-food exp - 2,3,4,7"
label variable bl_hh_nonfood_exp "Non-food exp - 2,3,4,7"



//Asset ownership proportion

foreach x in sg3_a1_q1 bl_sg3_a1_q1 {
replace `x' = `x'/17
}
foreach x in sg3_a2_q1 bl_sg3_a2_q1 {
replace `x' = `x'/24
}
foreach x in sg3_a3_q1_largelivestock bl_sg3_a3_q1_largelivestock {
replace `x' = `x'/5
}



//HH items exp

egen hh_items_exp = rowtotal (s2_q5a s2_q9 s2_q10), missing
label variable hh_items_exp " hh items & clothing exp. "




//Female exp Nomalisation (Inflation adjustment)

foreach x in hh_items_exp s2_q1 hh_nonfood_exp s2_q5 s2_q6 {
	replace `x' = `x'/1.31
}





//SAVE OUTPUT FILE
save"${data}/baseline_endline/baseline_endline_temp_nowinsor_Output.dta", replace



//31/3/25
		
		
		//decision making
		
			//Female baseline
			use "${data}/baseline_endline/baseline_endline_temp_nowinsor_Output.dta", clear



			merge 1:1 hhid using "${baseline_endline}/data/Baseline data files/Aquaculture Baseline HH Survey-2020_FEMALE_PII_DROP_labelled.dta", gen(merge_fem_decm) keep (master match) keepusing(s7_2_4_q1_* s7_2_4_q2_* s7_2_5_q_* s7_2_5_q1_* s7_2_5_q3_* sg2_2_q1_* sg2_2_q3_* s7_2_7_q*)

			rename s7_2_4_q1_* bl_s7_2_4_q1_* 
			rename s7_2_4_q2_* bl_s7_2_4_q2_* 
			rename s7_2_5_q_* bl_s7_2_5_q_* 
			rename s7_2_5_q1_* bl_s7_2_5_q1_*
			rename s7_2_5_q3_* bl_s7_2_5_q3_*
			rename sg2_2_q1_* bl_sg2_2_q1_* 
			rename sg2_2_q3_* bl_sg2_2_q3_* 
			rename s7_2_7_q* bl_s7_2_7_q*
			
			
			//Female endline
			
			merge 1:1 hhid using "${baseline_endline}/data/Endline data files/Aquaculture Endline 2023 HH Survey - FEMALE (final).dta", gen(merge_fem_decm_el) keep (master match) keepusing(s7_2_4_q1_* s7_2_4_q2_* s7_2_5_q_* s7_2_5_q1_* s7_2_5_q3_* sg2_2_q1_* sg2_2_q3_* s7_2_7_q*)
			
			
			
			//Variable index for women decision making and participation
			
					//7.2.4. Role in household decision-making about participation in aquaculture production
						//Endline
						egen f_dec_aqua_part = rowtotal(s7_2_4_q2_*), missing
						replace f_dec_aqua_part = 0 if f_dec_aqua_part ==. &  merge_fem_decm_el == 3
						
						//Baseline
						egen bl_f_dec_aqua_part = rowtotal(bl_s7_2_4_q2_*), missing
						replace bl_f_dec_aqua_part = 0 if bl_f_dec_aqua_part ==. &  merge_fem_decm == 3
						
					
					//7.2.5. Role in household decision-making about aquaculture production decisions
						//Endline
						
							//participation
							egen f_dec_aqua_prod = rowtotal(s7_2_5_q1_1 s7_2_5_q1_2 s7_2_5_q1_3), missing
							egen f_dec_aqua_sale = rowtotal(s7_2_5_q1_4 s7_2_5_q1_5 s7_2_5_q1_6  s7_2_5_q1_7), missing
							
							replace f_dec_aqua_prod = 0 if f_dec_aqua_prod ==. &  merge_fem_decm_el == 3
							replace f_dec_aqua_sale = 0 if f_dec_aqua_sale ==. &  merge_fem_decm_el == 3
					
					
							//Input
							egen f_decinp_aqua_prod = rowtotal(s7_2_5_q3_1 s7_2_5_q3_2 s7_2_5_q3_3), missing
							egen f_decinp_aqua_sale = rowtotal(s7_2_5_q3_4 s7_2_5_q3_5 s7_2_5_q3_6 s7_2_5_q3_7), missing
																			
						
					
					
					//Baseline
					
							//Participation
							egen bl_f_dec_aqua_prod = rowtotal(bl_s7_2_5_q1_1 bl_s7_2_5_q1_2 bl_s7_2_5_q1_3), missing
							egen bl_f_dec_aqua_sale = rowtotal(bl_s7_2_5_q1_4 bl_s7_2_5_q1_5 bl_s7_2_5_q1_6 bl_s7_2_5_q1_7), missing
							
							replace bl_f_dec_aqua_prod = 0 if bl_f_dec_aqua_prod ==. &  merge_fem_decm == 3
							replace bl_f_dec_aqua_sale = 0 if bl_f_dec_aqua_sale ==. &  merge_fem_decm == 3
							
							
							//Input
							
							egen bl_f_decinp_aqua_prod = rowtotal(bl_s7_2_5_q3_1 bl_s7_2_5_q1_2 bl_s7_2_5_q3_3), missing
							egen bl_f_decinp_aqua_sale = rowtotal(bl_s7_2_5_q3_4 bl_s7_2_5_q1_5 bl_s7_2_5_q1_6 bl_s7_2_5_q3_7), missing
				
				
				//MODULE G2: ROLE IN HOUSEHOLD DECISION-MAKING AROUND PRODUCTION AND INCOME
					//Endline
					
								//Participation
								forval i = 1/11{
									replace sg2_2_q1_`i' = 0 if sg2_2_q1_`i' == 1 | sg2_2_q1_`i' == 4
									replace sg2_2_q1_`i' = 1 if sg2_2_q1_`i' == 2 | sg2_2_q1_`i' == 3
									replace sg2_2_q1_`i' = 0 if sg2_2_q1_`i' == . &  merge_fem_decm_el == 3
								}					
								
								egen f_dec_hh_incprod = rowtotal(sg2_2_q1_*), missing
								
								//Input
								forval i = 1/11{
									replace sg2_2_q3_`i' = 0 if sg2_2_q3_`i' == 1 | sg2_2_q3_`i' == 4
									replace sg2_2_q3_`i' = 1 if sg2_2_q3_`i' == 2 | sg2_2_q3_`i' == 3
								}
								
								egen f_decinp_hh_incprod = rowtotal(sg2_2_q3_*), missing
					
					//Baseline
					
								//Participation
								forval i = 1/11{
									replace bl_sg2_2_q1_`i' = 0 if bl_sg2_2_q1_`i' == 1 | bl_sg2_2_q1_`i' == 4
									replace bl_sg2_2_q1_`i' = 1 if bl_sg2_2_q1_`i' == 2 | bl_sg2_2_q1_`i' == 3
									replace bl_sg2_2_q1_`i' = 0 if bl_sg2_2_q1_`i' == . &  merge_fem_decm == 3
								}
								
								egen bl_f_dec_hh_incprod = rowtotal(bl_sg2_2_q1_*), missing								

								//Input
								
								forval i = 1/11{
									replace bl_sg2_2_q3_`i' = 0 if bl_sg2_2_q3_`i' == 1 | bl_sg2_2_q3_`i' == 4
									replace bl_sg2_2_q3_`i' = 1 if bl_sg2_2_q3_`i' == 2 | bl_sg2_2_q3_`i' == 3
								}
								
								egen bl_f_decinp_hh_incprod = rowtotal(bl_sg2_2_q3_*), missing
							
				
				//7.2.7. Social capital and market links 
				//Endline
					foreach i in 1 2 3 5 6 7 8 9 10{
						replace s7_2_7_q`i' = 0 if s7_2_7_q`i' == 3 
						replace s7_2_7_q`i' = 1 if s7_2_7_q`i' == 1 | s7_2_7_q`i' == 2 
						replace s7_2_7_q`i' = 1 if s7_2_7_q`i' == . & merge_fem_decm_el == 3
					}
					
					
					egen f_market_link = rowtotal (s7_2_7_q*),m
							
				
				//Baseline
					foreach i in 1 2 3 5 6 7 8 9 10{
						replace bl_s7_2_7_q`i' = 0 if bl_s7_2_7_q`i' == 3 
						replace bl_s7_2_7_q`i' = 1 if bl_s7_2_7_q`i' == 1 | bl_s7_2_7_q`i' == 2 
						replace bl_s7_2_7_q`i' = 1 if bl_s7_2_7_q`i' == . & merge_fem_decm == 3
					}
					
					
					
					egen bl_f_market_link = rowtotal (bl_s7_2_7_q*),m
					
					
					
					
			//Replace missing with zero in dec making modules
			
			
			
			//Endline
			forval i = 1/6 {
				replace s7_2_4_q2_`i' = 0 if  s7_2_4_q2_`i' == . & merge_fem_decm_el == 3
			} 
			
			
			forval i = 1/7 {
				replace s7_2_5_q1_`i' = 0 if  s7_2_5_q1_`i' == . & merge_fem_decm_el == 3
			} 
			
			forval i = 1/11 {
				replace sg2_2_q1_`i' = 0 if  sg2_2_q1_`i' == . & merge_fem_decm_el == 3
			} 
			
			
			foreach i in 1 2 3 5 6 7 8 9 10{
				replace s7_2_7_q`i' = 0 if  s7_2_7_q`i' == . & merge_fem_decm_el == 3
			} 
			
			
			
			//Baseline
			forval i = 1/6 {
				replace bl_s7_2_4_q2_`i' = 0 if  bl_s7_2_4_q2_`i' == . & merge_fem_decm == 3
			} 
			
			
			forval i = 1/7 {
				replace bl_s7_2_5_q1_`i' = 0 if  bl_s7_2_5_q1_`i' == . & merge_fem_decm == 3
			} 
			
			forval i = 1/11 {
				replace bl_sg2_2_q1_`i' = 0 if  bl_sg2_2_q1_`i' == . & merge_fem_decm == 3
			} 
			
			
			foreach i in 1 2 3 5 6 7 8 9 10 {
				replace bl_s7_2_7_q`i' = 0 if  bl_s7_2_7_q`i' == . & merge_fem_decm == 3
			} 
			
			
			
			
			save "${data}/baseline_endline/baseline_endline_temp_nowinsor_Output.dta", replace
			
			use "${data}/baseline_endline/baseline_endline_temp_nowinsor_Output.dta", clear
			
			
			save "${folder}/baseline_endline/data/Baseline_Endline merged data/BL_El_merged_final", replace
			
			
			
						//Output File
			
			use "${folder}/baseline_endline/data/Baseline_Endline merged data/BL_El_merged_final", clear
			
			
			gen nsisvar = allvar -  sisvar
			gen bl_nsisvar = bl_allvar -  bl_sisvar
			
			
			gen bl_muslim = (bl_religion == 1)
			gen bl_bangali = (bl_ethnicity == 1)
			
			foreach x in bl_male_resp_edu bl_fem_resp_edu {
				replace `x' = . if `x' < 0
			}
			
			
			
			
			//liberal recoding
			//male
			foreach x in bl_s7_1_8_q1 bl_s7_1_8_q2 bl_s7_1_8_q3 bl_s7_1_8_q4 bl_s7_1_8_q5 bl_s7_1_8_q6 bl_s7_1_8_q7 s7_1_8_q1 s7_1_8_q2 s7_1_8_q3 s7_1_8_q4 s7_1_8_q5 s7_1_8_q6 s7_1_8_q7 {
			gen lib_`x' = `x'
			}
			foreach x in bl_s7_1_8_q1 bl_s7_1_8_q2 bl_s7_1_8_q4 bl_s7_1_8_q5 bl_s7_1_8_q6 bl_s7_1_8_q7 s7_1_8_q1 s7_1_8_q2 s7_1_8_q4 s7_1_8_q5 s7_1_8_q6 s7_1_8_q7 {
			replace lib_`x' = 0 if `x' == 1 | `x' == 2 | `x' == 3
			replace lib_`x' = 1 if `x' == 4 | `x' == 5
			}
			foreach x in bl_s7_1_8_q3 s7_1_8_q3 {
			replace lib_`x' = 0 if `x' == 4 | `x' == 5 | `x' == 3
			replace lib_`x' = 1 if `x' == 2 | `x' == 1
			}


			//female
			foreach x in bl_s7_2_8_q1 bl_s7_2_8_q2 bl_s7_2_8_q3 bl_s7_2_8_q4 bl_s7_2_8_q5 bl_s7_2_8_q6 bl_s7_2_8_q7 s7_2_8_q1 s7_2_8_q2 s7_2_8_q3 s7_2_8_q4 s7_2_8_q5 s7_2_8_q6 s7_2_8_q7 {
			gen lib_`x' = `x'
			}
			foreach x in bl_s7_2_8_q1 bl_s7_2_8_q2 bl_s7_2_8_q4 bl_s7_2_8_q5 bl_s7_2_8_q6 bl_s7_2_8_q7 s7_2_8_q1 s7_2_8_q2 s7_2_8_q4 s7_2_8_q5 s7_2_8_q6 s7_2_8_q7 {
			replace lib_`x' = 0 if `x' == 1 | `x' == 2 | `x' == 3
			replace lib_`x' = 1 if `x' == 4 | `x' == 5
			}
			foreach x in bl_s7_2_8_q3 s7_2_8_q3 {
			replace lib_`x' = 0 if `x' == 4 | `x' == 5 | `x' == 3`	'
			replace lib_`x' = 1 if `x' == 2 | `x' == 1
			}
			
			save "${folder}/baseline_endline/data/Baseline_Endline merged data/BL_El_merged_final", replace
			
			
			
			
			
			
			
			
			
			
			
							//Figure 11	& Fig 12 (Village dataset)	
						
								
			use  "${folder}/baseline_endline/data\Endline data files\Aquaculture Endline 2023 HH Survey - Village (with treatment)_updated.dta", clear
			
			forval i = 1/6 {
			    egen aqua_sup_`i' = rowmax(sec_14_4_`i'_*)
				replace aqua_sup_`i' = . if aqua_prog_vill == .
			}
			
			
			
			forval i = 1/5 {
			    egen aqua_prov_`i' = rowmax(sec_14_2_`i'_*)
				replace aqua_prov_`i' = . if aqua_prog_vill == .
			}
			
			
			
			keep treatment union union_name village village_name aqua_sup_* aqua_prov_*
			
		
			
			
			
			
			
		save "${data}\endline\el_vill_temp", replace
			
			
			
			
			
			use "${folder}\baseline_endline\data\Baseline data files\Aquaculture Baseline HH Survey-2020_VILLAGE_clean.dta", clear
			
			
						forval i = 1/6 {
			    egen aqua_sup_`i' = rowmax(sec_14_4_`i'_*)
				replace aqua_sup_`i' = . if aqua_prog_vill == .
			}
			
			
			
			forval i = 1/5 {
			    egen aqua_prov_`i' = rowmax(sec_14_2_`i'_*)
				replace aqua_prov_`i' = . if aqua_prog_vill == .
			}
			
			keep union village village_name aqua_sup_* aqua_prov_*
			
			rename aqua_sup_* bl_aqua_sup_* 
			rename aqua_prov_* bl_aqua_prov_*
			
				save "${data}\baseline\bl_vill_temp", replace
			
			
			merge 1:1 union village using "${data}\endline\el_vill_temp"
			
			
			
		foreach x in bl_aqua_sup_1 bl_aqua_sup_2 bl_aqua_sup_3 bl_aqua_sup_4 bl_aqua_sup_5 bl_aqua_sup_6 bl_aqua_prov_1 bl_aqua_prov_2 bl_aqua_prov_3 bl_aqua_prov_4 bl_aqua_prov_5 {
		replace `x' = 0 if `x' == .
		}
					
			
			save "${data}\baseline_endline\bl_el_village_temp", replace
			
			
			log close
			
	
	


