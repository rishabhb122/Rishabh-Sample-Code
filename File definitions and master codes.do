					/*------------------------------------------------------------------------------*
					| Title: 			Header .do file - Master code								|
					| Project: 			IDEA Bangladesh					   							|
					| Authors:			Rishabh Bhattacharya										|
					| 					  									                        |
					|																				|
					| Description:		This .do defines the directory and relevant folder paths,	|
					|					and runs the codes to prepare the data, and run the RDD 	|
					|										analysis								|
					|                                                                               |
					| Date created: May 24, 2024	 					                      	    |										          
					|																			    |
					| Version: Stata 16.1 	                    							 	    |
					*-------------------------------------------------------------------------------*/
	
					clear all
					set maxvar 32000, permanent
					macro drop _all
					ssc install estout
					set more off
					

					/*----------------------------------
					
							AQUACULTURE SET
					
					------------------------------------*/

					global user "C:\Users\RishabhBhattacharya\"  //PLEASE CHANGE THE USERNAME HERE TO REPLICATE ON YOUR SYSTEM
					
					
					global folder "${user}\OneDrive - International Initiative for Impact Evaluation\03-analysis\Aquaculture"
					
					
					global baseline "${folder}/1. Baseline/"
					global endline "${folder}/2. Endline/"
					global baseline_endline "${folder}/baseline_endline" 
					
					capture mkdir "${baseline_endline}/working/Temp"
					capture mkdir "${baseline_endline}/working/Temp/data"
					capture mkdir "${baseline_endline}/working/Temp/data/baseline"
					capture mkdir "${baseline_endline}/working/Temp/data/endline"
					capture mkdir "${baseline_endline}/working/Temp/data/baseline_endline"
					capture mkdir "${baseline_endline}/working/Temp/log"
					capture mkdir "${baseline_endline}/working/Temp/output"
					capture mkdir "${baseline_endline}/working/Temp/do file"
					capture mkdir "${baseline_endline}/working/Temp/output/Tables"
					capture mkdir "${baseline_endline}/working/Temp/output/Figures"
					
					capture mkdir "${baseline_endline}/Output/Tables"   
					capture mkdir "${baseline_endline}/Output/Figures"  
			
 
					
					global data "${baseline_endline}/working/Temp/data"
					global log "${baseline_endline}/working/Temp/log"  
					global tables "${baseline_endline}/Output/Tables"   
					global figures "${baseline_endline}/Output/Figures" 
					
					global dofile "${baseline_endline}/dofiles"
					
					
					
					
					//Data preparation
					
					do "${dofile}/Infile.do"
					
					
					//Data Analysis and Export
					
					do "${dofile}/Output_new.do"
					
					
					
					
					/*----------------------------------
					
							Nutrition SET
					
					------------------------------------*/
										
					/*-------------------------------------------
									GLOBAL PATHS
					---------------------------------------------*/
					
					
					
								//Define Global Paths

									
if c(username)=="RishabhBhattacharya" {
			global user "C:\Users\RishabhBhattacharya\"
			global folder "${user}\OneDrive - International Initiative for Impact Evaluation\03-analysis\Aquaculture"
		}
		
else if c(username)=="RohanShah" {
			global user "C:/Users/RohanShah"
			global folder "${user}/International Initiative for Impact Evaluation/EO-P00201-Aquaculture - 03-analysis - 03-analysis/Aquaculture"
		}
						
						
						global baseline "${folder}/1. Baseline/"
						global endline "${folder}/2. Endline/"
						global baseline_endline "${folder}/baseline_endline" 
			 
						global data "${baseline_endline}/working/Amanda/Data"
						
						global dofile "${baseline_endline}/working/Amanda/Do Files"
						
						global tables "${baseline_endline}/Output/Tables"   
						global figures "${baseline_endline}/Output/Figures"  

					
					
					
					** ENDLINE FEMALE
					
						do "${dofile}/3IE_Endline_analysis_female.do"
						
						
					** Endline Male
					
						do "${dofile}/3IE_Endline_analysis_male.do"
						
						
						
						
					** Baseline ENDLINE FEMALE
					
						do "${dofile}/3IE_Endline_Baseline_analysis_female.do"
						
						
						
					** baseline ENDLINE MALE
					
						do "${dofile}/3IE_Endline_Baseline_analysis_male.do"
						
						
					** 3IE Nutrition Rounds
					
						do "${dofile}/3IE Nutrition Rounds Analysis.do"
						
					** Panel Analysis
					
						do "${dofile}/Panel analysis.do"
					
					
				









				

					

