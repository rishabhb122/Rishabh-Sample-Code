





				
				//Fixed Globals
				global user "C:\Users\RishabhBhattacharya\"  //PLEASE CHANGE THE USERNAME HERE TO REPLICATE ON YOUR SYSTEM	

				global folder "${user}\OneDrive - International Initiative for Impact Evaluation"
				global normdata "${folder}\03-analysis\Aquaculture\5. Gender norms\6. Datasets\Final_After Error Reconciliation"
				
				
				
				//Working Globals
				global working "${folder}\03-analysis\Aquaculture\5. Gender norms\11.Working\Rishabh"
				global dofile "${working}\Do files"
				global data "${working}\Data"
				global logs "${working}\Log"
				global output "${working}\Output"



				
				
				
				
				
	////*********   Figure 1 - bars with ci    ********************			
				
				

	use "${data}\Male_Female_merged-Final_updated_new.dta", clear

	


	keep uid treatment ///
    m_own_lib_1 m_own_lib_2 m_own_lib_3 m_own_lib_4 m_own_lib_5 ///
    m_own_lib_6 m_own_lib_7 m_own_lib_8 m_own_lib_9 m_own_lib_10 ///
    m_own_lib_11 m_own_lib_12 m_own_lib_13 ///
    f_own_lib_1 f_own_lib_2 f_own_lib_3 f_own_lib_4 f_own_lib_5 ///
    f_own_lib_6 f_own_lib_7 f_own_lib_8 f_own_lib_9 f_own_lib_10 ///
    f_own_lib_11 f_own_lib_12 f_own_lib_13 ///
    couple_gap_1 couple_gap_2 couple_gap_3 couple_gap_4 couple_gap_5 ///
    couple_gap_6 couple_gap_7 couple_gap_8 couple_gap_9 couple_gap_10 ///
    couple_gap_11 couple_gap_12 couple_gap_13


reshape long m_own_lib_ f_own_lib_ couple_gap_, i(uid) j(norms)


label define norms_lb ///
    1  "Type of fish species to cultivate" ///
    2  "Type of fish feed to use" ///
    3  "Aquaculture inputs to purchase" ///
    4  "Owner/ co-owner of aquaculture ponds" ///
    5  "Whether HH should start new business" ///
    6  "Fish vendor in local market" ///
    7  "Take paid work from home" ///
    8  "Start business outside home" ///
    9  "Start business from home" ///
    10 "Work outside home" ///
    11 "Go to local market alone" ///
    12 "Seek healthcare for self or children" ///
    13 "Visit female friends in village"

label values norms norms_lb


rename m_own_lib_ male
rename f_own_lib_ female
rename couple_gap_ couple_gap


replace male       = male * 100
replace female     = female * 100
replace couple_gap = couple_gap * 100


collapse ///
    (mean) male female couple_gap ///
    (semean) se_male=male se_female=female se_couple_gap=couple_gap, ///
    by(norms)


* Construct gender gap as Female - Male
gen gender_gap = female - male

drop couple_gap
rename gender_gap gap


* 95% confidence intervals for male and female means
gen male_l   = male - 1.96 * se_male
gen male_u   = male + 1.96 * se_male

gen female_l = female - 1.96 * se_female
gen female_u = female + 1.96 * se_female


* Optional: if you want CI for original couple-level gap, keep se_couple_gap.
* But since plotted gap is female - male, I am not using se_couple_gap here.


* --- Prepare positions for male/female bars and gender gap line ---
gen x = .

replace x = 1  if norms == 1
replace x = 2  if norms == 2
replace x = 3  if norms == 3
replace x = 4  if norms == 5
replace x = 5  if norms == 4
replace x = 6  if norms == 7
replace x = 7  if norms == 9
replace x = 8  if norms == 10
replace x = 9  if norms == 8
replace x = 10 if norms == 6
replace x = 11 if norms == 11
replace x = 12 if norms == 12
replace x = 13 if norms == 13

gen xm = x + 0.18
gen xf = x - 0.18
gen xg = x


* --- Rounded labels for values ---
gen male_lab   = string(male, "%4.1f")
gen female_lab = string(female, "%4.1f")
gen gap_lab    = round(gap, 0.1)

* Label positions above upper confidence intervals
gen male_lab_y   = male_u 
gen female_lab_y = female_u
gen gap_lab_y    = gap


twoway ///
    (bar male xm, ///
        barw(0.30) fcolor(gs14) lcolor(none)) ///
    (bar female xf, ///
        barw(0.30) fcolor(gs10) lcolor(none)) ///
    ///
    /* 95% CI for male mean */ ///
    (rcap male_l male_u xm, ///
        lcolor(black) lwidth(thin)) ///
    ///
    /* 95% CI for female mean */ ///
    (rcap female_l female_u xf, ///
        lcolor(black) lwidth(thin)) ///
    ///
    /* Gender gap as black dotted line */ ///
    (connected gap xg, ///
        sort ///
        lcolor(black) lpattern(dot) lwidth(medthin) ///
        mcolor(black) msymbol(circle) msize(vsmall)) ///
    ///
    /* Value labels for male bars */ ///
    (scatter male_lab_y xm, ///
        msymbol(none) mlabel(male_lab) ///
        mlabcolor(black) mlabpos(12) mlabsize(vsmall)) ///
    ///
    /* Value labels for female bars */ ///
    (scatter female_lab_y xf, ///
        msymbol(none) mlabel(female_lab) ///
        mlabcolor(black) mlabpos(12) mlabsize(vsmall)) ///
    ///
    /* Value labels for gender gap line */ ///
    (scatter gap_lab_y xg, ///
        msymbol(none) mlabel(gap_lab) ///
        mlabcolor(black) mlabpos(12) mlabsize(vsmall)), ///
    ///
xlabel( ///
    1  `""HHD:" "Type of" "fish species" "to cultivate""' ///
    2  `""HHD:" "Type of" "fish feed" "to use""'  ///
    3  `""HHD:" "Aquaculture" "inputs" "to purchase""' ///
    4  `""HHD:" "Whether" "HH should" "start new" "business""' ///
    5  `""AO:" "Owner/co-" "owner of" "aquaculture" "ponds""' ///
    6  `""WFH:" "Take paid" "work" "from home""' ///
    7  `""WFH:" "Start" "business" "from home""' ///
    8  `""WOH:" "Start" "business" "outside home""' ///
    9  `""WOH:" "Any work" "outside" "home""' ///
    10 `""WOH:" "Fish vendor" "in local" "market""' ///
    11 `""FOM:" "Go to" "local market" "alone""' ///
    12 `""FOM:" "Seek" "healthcare" "alone""' ///
    13 `""FOM:" "Visit female" "friends" "alone""', ///
    angle(0) labsize(vsmall) notick) ///
    ylabel(none, nogrid) ///
	yscale(noline) ///
    ytitle("% Participants", size(vsmall)) ///
    legend(order(2 "Female" 1 "Male" 5 "Gender Gap (F-M)") cols(3) size(vsmall)) ///
    graphregion(color(white))   xsize(1.8) ysize(1)
 
 

graph export "${output}\graphs\graph1.png", replace








//*********   Figure 2a -Female - values above/below ci     ********************



	use "${data}\Male_Female_merged-Final_updated_new.dta", clear
	

	
	forval i = 1/13 {
	gen f_other_f_`i' = f_otherw_lib_`i' - f_own_lib_`i'
	gen m_other_f_`i' = m_otherw_lib_`i' - f_own_lib_`i'
	gen m_other_m_`i' = m_otherm_lib_`i' - m_own_lib_`i'
	gen f_other_m_`i' = f_otherm_lib_`i' - m_own_lib_`i'
	}
	


keep uid treatment f_other_f_* m_other_f_* m_other_m_* f_other_m_*

reshape long f_other_f_ m_other_f_ m_other_m_ f_other_m_, i(uid) j(norms)

label define norms_lb ///
    1  "Type of fish species to cultivate" ///
    2  "Type of fish feed to use" ///
    3  "Aquaculture inputs to purchase" ///
    4  "Owner/ co-owner of aquaculture ponds" ///
    5  "Whether HH should start new business" ///
    6  "Fish vendor in local market" ///
    7  "Take paid work from home" ///
    8  "Start business outside home" ///
    9  "Start business from home" ///
    10 "Work outside home" ///
    11 "Go to local market alone" ///
    12 "Seek healthcare for self or children" ///
    13 "Visit female friends in village", replace

label values norms norms_lb

rename f_other_f_ f_other_f
rename m_other_f_ m_other_f
rename m_other_m_ m_other_m
rename f_other_m_ f_other_m

* Convert to percentages if variables are 0/1
replace f_other_f = f_other_f * 100
replace m_other_f = m_other_f * 100

collapse ///
    (mean) f_other_f m_other_f ///
    (semean) se_f_other_f=f_other_f se_m_other_f=m_other_f, ///
    by(norms)

* 95% confidence intervals for means
gen f_other_f_l = f_other_f - 1.96 * se_f_other_f
gen f_other_f_u = f_other_f + 1.96 * se_f_other_f

gen m_other_f_l = m_other_f - 1.96 * se_m_other_f
gen m_other_f_u = m_other_f + 1.96 * se_m_other_f

* Keep the same graph order as your reference code
gen x = .

replace x = 1  if norms == 1
replace x = 2  if norms == 2
replace x = 3  if norms == 3
replace x = 4  if norms == 5
replace x = 5  if norms == 4
replace x = 6  if norms == 7
replace x = 7  if norms == 9
replace x = 8  if norms == 10
replace x = 9  if norms == 8
replace x = 10 if norms == 6
replace x = 11 if norms == 11
replace x = 12 if norms == 12
replace x = 13 if norms == 13

* Bar positions
gen xf = x - 0.18
gen xm = x + 0.18

* Value labels
gen f_other_f_lab = string(f_other_f, "%4.1f")
gen m_other_f_lab = string(m_other_f, "%4.1f")

* Label y-positions
gen f_other_f_lab_y = .
gen m_other_f_lab_y = .

* Put selected labels above the upper CI
replace f_other_f_lab_y = f_other_f_u + 0.7 if inlist(x,6,8,9,11,12,13)
replace m_other_f_lab_y = m_other_f_u + 0.7 if inlist(x,6,8,9,11,12,13)

* Put the remaining labels below the lower CI
replace f_other_f_lab_y = f_other_f_l - 0.7 if inlist(x,1,2,3,4,5,7,10)
replace m_other_f_lab_y = m_other_f_l - 0.7 if inlist(x,1,2,3,4,5,7,10)

* Plot graph
twoway ///
    (bar f_other_f xf, ///
        barw(0.30) fcolor(gs10) lcolor(none)) ///
    (bar m_other_f xm, ///
        barw(0.30) fcolor(gs14) lcolor(none)) ///
    ///
    /* 95% CI for f_other_f mean */ ///
    (rcap f_other_f_l f_other_f_u xf, ///
        lcolor(black) lwidth(thin)) ///
    ///
    /* 95% CI for m_other_f mean */ ///
    (rcap m_other_f_l m_other_f_u xm, ///
        lcolor(black) lwidth(thin)) ///
    ///
    /* Value labels for f_other_f bars */ ///
    (scatter f_other_f_lab_y xf, ///
        msymbol(none) mlabel(f_other_f_lab) ///
        mlabcolor(black) mlabpos(0) mlabsize(vsmall)) ///
    ///
    /* Value labels for m_other_f bars */ ///
    (scatter m_other_f_lab_y xm, ///
        msymbol(none) mlabel(m_other_f_lab) ///
        mlabcolor(black) mlabpos(0) mlabsize(vsmall)), ///
    ///
    xlabel( ///
    1  `""HHD:" "Type of" "fish species" "to cultivate""' ///
    2  `""HHD:" "Type of" "fish feed" "to use""'  ///
    3  `""HHD:" "Aquaculture" "inputs" "to purchase""' ///
    4  `""HHD:" "Whether" "HH should" "start new" "business""' ///
    5  `""AO:" "Owner/co-" "owner of" "aquaculture" "ponds""' ///
    6  `""WFH:" "Take paid" "work" "from home""' ///
    7  `""WFH:" "Start" "business" "from home""' ///
    8  `""WOH:" "Start" "business" "outside home""' ///
    9  `""WOH:" "Any work" "outside" "home""' ///
    10 `""WOH:" "Fish vendor" "in local" "market""' ///
    11 `""FOM:" "Go to" "local market" "alone""' ///
    12 `""FOM:" "Seek" "healthcare" "alone""' ///
    13 `""FOM:" "Visit female" "friends" "alone""', ///
    angle(0) labsize(vsmall) notick) ///
    ylabel(none) ///
    yscale(noline) ///
    ytitle("Norm misperception:" "predicted - (minus) actual liberal support", size(vsmall)) ///
    legend(order(1 "F other F" ///
                 2 "M other F") ///
           cols(2) size(vsmall)) ///
    graphregion(color(white))  xsize(1.8) ysize(1)
	
	
	
graph export "${output}\graphs\graph2.png", replace
	
	
	
	
	
	//*********   Figure 2b - values above/below ci     ********************



	use "${data}\Male_Female_merged-Final_updated_new.dta", clear
	

	
	forval i = 1/13 {
	gen f_other_f_`i' = f_otherw_lib_`i' - f_own_lib_`i'
	gen m_other_f_`i' = m_otherw_lib_`i' - f_own_lib_`i'
	gen m_other_m_`i' = m_otherm_lib_`i' - m_own_lib_`i'
	gen f_other_m_`i' = f_otherm_lib_`i' - m_own_lib_`i'
	}
	


keep uid treatment f_other_f_* m_other_f_* m_other_m_* f_other_m_*

reshape long f_other_f_ m_other_f_ m_other_m_ f_other_m_, i(uid) j(norms)

label define norms_lb ///
    1  "Type of fish species to cultivate" ///
    2  "Type of fish feed to use" ///
    3  "Aquaculture inputs to purchase" ///
    4  "Owner/ co-owner of aquaculture ponds" ///
    5  "Whether HH should start new business" ///
    6  "Fish vendor in local market" ///
    7  "Take paid work from home" ///
    8  "Start business outside home" ///
    9  "Start business from home" ///
    10 "Work outside home" ///
    11 "Go to local market alone" ///
    12 "Seek healthcare for self or children" ///
    13 "Visit female friends in village", replace

label values norms norms_lb

rename f_other_f_ f_other_f
rename m_other_f_ m_other_f
rename m_other_m_ m_other_m
rename f_other_m_ f_other_m

* Convert to percentages if variables are 0/1
replace f_other_m = f_other_m * 100
replace m_other_m = m_other_m * 100

collapse ///
    (mean) f_other_m m_other_m ///
    (semean) se_f_other_m=f_other_m se_m_other_m=m_other_m, ///
    by(norms)

* 95% confidence intervals for means
gen f_other_m_l = f_other_m - 1.96 * se_f_other_m
gen f_other_m_u = f_other_m + 1.96 * se_f_other_m

gen m_other_m_l = m_other_m - 1.96 * se_m_other_m
gen m_other_m_u = m_other_m + 1.96 * se_m_other_m

* Keep the same graph order as your reference code
gen x = .

replace x = 1  if norms == 1
replace x = 2  if norms == 2
replace x = 3  if norms == 3
replace x = 4  if norms == 5
replace x = 5  if norms == 4
replace x = 6  if norms == 7
replace x = 7  if norms == 9
replace x = 8  if norms == 10
replace x = 9  if norms == 8
replace x = 10 if norms == 6
replace x = 11 if norms == 11
replace x = 12 if norms == 12
replace x = 13 if norms == 13

* Bar positions
gen xf = x - 0.18
gen xm = x + 0.18

* Value labels
gen f_other_m_lab = string(f_other_m, "%4.1f")
gen m_other_m_lab = string(m_other_m, "%4.1f")

* Label y-positions
gen f_other_m_lab_y = .
gen m_other_m_lab_y = .

* Put selected labels above the upper CI
replace f_other_m_lab_y = f_other_m_u + 0.7 if inlist(x,6,8,9,11,12,13)
replace m_other_m_lab_y = m_other_m_u + 0.7 if inlist(x,6,8,9,11,12,13)

* Put the remaining labels below the lower CI
replace f_other_m_lab_y = f_other_m_l - 0.7 if inlist(x,1,2,3,4,5,7,10)
replace m_other_m_lab_y = m_other_m_l - 0.7 if inlist(x,1,2,3,4,5,7,10)

* Plot graph
twoway ///
    (bar f_other_m xf, ///
        barw(0.30) fcolor(gs10) lcolor(none)) ///
    (bar m_other_m xm, ///
        barw(0.30) fcolor(gs14) lcolor(none)) ///
    ///
    /* 95% CI for f_other_m mean */ ///
    (rcap f_other_m_l f_other_m_u xf, ///
        lcolor(black) lwidth(thin)) ///
    ///
    /* 95% CI for m_other_m mean */ ///
    (rcap m_other_m_l m_other_m_u xm, ///
        lcolor(black) lwidth(thin)) ///
    ///
    /* Value labels for f_other_m bars */ ///
    (scatter f_other_m_lab_y xf, ///
        msymbol(none) mlabel(f_other_m_lab) ///
        mlabcolor(black) mlabpos(0) mlabsize(vsmall)) ///
    ///
    /* Value labels for m_other_m bars */ ///
    (scatter m_other_m_lab_y xm, ///
        msymbol(none) mlabel(m_other_m_lab) ///
        mlabcolor(black) mlabpos(0) mlabsize(vsmall)), ///
    ///
    xlabel( ///
    1  `""HHD:" "Type of" "fish species" "to cultivate""' ///
    2  `""HHD:" "Type of" "fish feed" "to use""'  ///
    3  `""HHD:" "Aquaculture" "inputs" "to purchase""' ///
    4  `""HHD:" "Whether" "HH should" "start new" "business""' ///
    5  `""AO:" "Owner/co-" "owner of" "aquaculture" "ponds""' ///
    6  `""WFH:" "Take paid" "work" "from home""' ///
    7  `""WFH:" "Start" "business" "from home""' ///
    8  `""WOH:" "Start" "business" "outside home""' ///
    9  `""WOH:" "Any work" "outside" "home""' ///
    10 `""WOH:" "Fish vendor" "in local" "market""' ///
    11 `""FOM:" "Go to" "local market" "alone""' ///
    12 `""FOM:" "Seek" "healthcare" "alone""' ///
    13 `""FOM:" "Visit female" "friends" "alone""', ///
    angle(0) labsize(vsmall) notick) ///
    ylabel(none) ///
    yscale(noline) ///
    ytitle("Norm misperception:" "predicted - (minus) actual liberal support", size(vsmall)) ///
    legend(order(1 "F other M" ///
                 2 "M other M") ///
           cols(2) size(vsmall)) ///
    graphregion(color(white))  xsize(1.8) ysize(1)
	
graph export "${output}\graphs\graph3.png", replace	
	
	
	
	
	/*

	
	*********   Figure 2 - values above/below bars     ********************



	use "${data}\Male_Female_merged-Final_updated_new.dta", clear
	

	
	forval i = 1/13 {
	gen f_other_f_`i' = f_otherw_lib_`i' - f_own_lib_`i'
	gen m_other_f_`i' = m_otherw_lib_`i' - f_own_lib_`i'
	gen m_other_m_`i' = m_otherm_lib_`i' - m_own_lib_`i'
	gen f_other_m_`i' = f_otherm_lib_`i' - m_own_lib_`i'
	}
	


			keep uid treatment f_other_f_* m_other_f_* m_other_m_* f_other_m_*

			reshape long f_other_f_ m_other_f_ m_other_m_ f_other_m_, i(uid) j(norms)

			label define norms_lb ///
				1  "Type of fish species to cultivate" ///
				2  "Type of fish feed to use" ///
				3  "Aquaculture inputs to purchase" ///
				4  "Owner/ co-owner of aquaculture ponds" ///
				5  "Whether HH should start new business" ///
				6  "Fish vendor in local market" ///
				7  "Take paid work from home" ///
				8  "Start business outside home" ///
				9  "Start business from home" ///
				10 "Work outside home" ///
				11 "Go to local market alone" ///
				12 "Seek healthcare for self or children" ///
				13 "Visit female friends in village", replace

			label values norms norms_lb

			rename f_other_f_ f_other_f
			rename m_other_f_ m_other_f
			rename m_other_m_ m_other_m
			rename f_other_m_ f_other_m

			* Convert to percentages if variables are 0/1
			replace f_other_f = f_other_f * 100
			replace m_other_f = m_other_f * 100

			collapse ///
				(mean) f_other_f m_other_f ///
				(semean) se_f_other_f=f_other_f se_m_other_f=m_other_f, ///
				by(norms)

			* 95% confidence intervals for means
			gen f_other_f_l = f_other_f - 1.96 * se_f_other_f
			gen f_other_f_u = f_other_f + 1.96 * se_f_other_f

			gen m_other_f_l = m_other_f - 1.96 * se_m_other_f
			gen m_other_f_u = m_other_f + 1.96 * se_m_other_f

			* Keep the same graph order as your reference code
			gen x = .

			replace x = 1  if norms == 1
			replace x = 2  if norms == 2
			replace x = 3  if norms == 3
			replace x = 4  if norms == 4
			replace x = 5  if norms == 5
			replace x = 6  if norms == 7
			replace x = 7  if norms == 9
			replace x = 8  if norms == 10
			replace x = 9  if norms == 8
			replace x = 10 if norms == 6
			replace x = 11 if norms == 11
			replace x = 12 if norms == 12
			replace x = 13 if norms == 13

			* Bar positions
			gen xf = x - 0.18
			gen xm = x + 0.18

			* Value labels
			gen f_other_f_lab = string(f_other_f, "%4.1f")
			gen m_other_f_lab = string(m_other_f, "%4.1f")

			* Put labels just outside the bars, not outside the CI
			gen f_other_f_lab_y = .
			gen m_other_f_lab_y = .

			* Positive bars: label just above bar
			replace f_other_f_lab_y = f_other_f + 0.6 if f_other_f >= 0
			replace m_other_f_lab_y = m_other_f + 0.6 if m_other_f >= 0

			* Negative bars: label just below bar
			replace f_other_f_lab_y = f_other_f - 0.6 if f_other_f < 0
			replace m_other_f_lab_y = m_other_f - 0.6 if m_other_f < 0


			* Plot graph
			twoway ///
				(bar f_other_f xf, ///
					barw(0.30) fcolor(gs10) lcolor(none)) ///
				(bar m_other_f xm, ///
					barw(0.30) fcolor(gs14) lcolor(none)) ///
				///
				/* 95% CI for f_other_f mean */ ///
				(rcap f_other_f_l f_other_f_u xf, ///
					lcolor(black) lwidth(thin)) ///
				///
				/* 95% CI for m_other_f mean */ ///
				(rcap m_other_f_l m_other_f_u xm, ///
					lcolor(black) lwidth(thin)) ///
				///
				/* Value labels for f_other_f bars */ ///
				(scatter f_other_f_lab_y xf, ///
					msymbol(none) mlabel(f_other_f_lab) ///
					mlabcolor(black) mlabpos(0) mlabsize(tiny)) ///
				///
				/* Value labels for m_other_f bars */ ///
				(scatter m_other_f_lab_y xm, ///
					msymbol(none) mlabel(m_other_f_lab) ///
					mlabcolor(black) mlabpos(0) mlabsize(tiny)), ///
				///
				xlabel( ///
        1  "HHD: Fish species" ///
        2  "HHD: Fish feed" ///
        3  "HHD: Aqua inputs purchase" ///
        4  "AO: Owner/co-owner of ponds" ///
        5  "HHD: starting business" ///
        6  "WFH: Work from home" ///
        7  "WFH: Business from home" ///
        8  "WOH: Business outside home" ///
        9  "WOH: Work outside home" ///
        10 "WOH: Sell fish in market" ///
        11 "FOM: Visit local market" ///
        12 "FOM: Seek healthcare" ///
        13 "FOM: Visit female friends", ///
					angle(45) labsize(vsmall)) ///
				ylabel(0(5)20, labsize(vsmall)) ///
				yscale(range(-2 22)) ///
				ytitle("% Respondents", size(vsmall)) ///
				legend(order(1 "F other F" ///
							 2 "M other F") ///
					   cols(1) size(vsmall)) ///
				graphregion(color(white))

			//graph save "${output}\graph_other_f.gph", replace


     
*/

	
		
	************** Figure 4 - F o F *********************


		* STEP->1 ** reshape data and plot vars from regression **
		
				use "${data}\Male_Female_merged-Final_updated_new.dta", clear

				keep uid treatment ///
					m_own_lib_* m_otherm_lib_* ///
					m_wife_lib_* m_mot_lib_* m_otherw_lib_* ///
					f_own_lib_* f_husb_lib_* f_mil_lib_* f_otherw_lib_* f_otherm_lib_*

				reshape long f_own_lib_ f_otherw_lib_, i(uid) j(norms)

				rename f_own_lib_    f_own_lib
				rename f_otherw_lib_ f_otherw_lib

				label define norms_lb ///
					1  "Type of fish species to cultivate" ///
					2  "Type of fish feed to use" ///
					3  "Aquaculture inputs to purchase" ///
					4  "Owner/co-owner of aquaculture ponds" ///
					5  "Whether HH should start new business" ///
					6  "Fish vendor in local market" ///
					7  "Take paid work from home" ///
					8  "Start business outside home" ///
					9  "Start business from home" ///
					10 "Work outside home" ///
					11 "Go to local market alone" ///
					12 "Seek healthcare for self or children" ///
					13 "Visit female friends in village", replace

				label values norms norms_lb

				tempfile results
				tempname memhold

				postfile `memhold' ///
					norms con lib normmean ///
					using `results', replace

				forval j = 1/13 {

					quietly regress f_otherw_lib f_own_lib if norms == `j'

					local con  = _b[_cons]
					local lib  = _b[_cons] + _b[f_own_lib]

					quietly summarize f_own_lib if norms == `j'
					local normmean = r(mean)

					post `memhold' (`j') (`con') (`lib') (`normmean')
				}

				postclose `memhold'

				use `results', clear

				label values norms norms_lb
				
				
		* STEP->2 ** reorder questions and set positions**
		
		
		
				* Graph order
					gen x = .

replace x = 1  if norms == 1
replace x = 2  if norms == 2
replace x = 3  if norms == 3
replace x = 4  if norms == 5
replace x = 5  if norms == 4
replace x = 6  if norms == 7
replace x = 7  if norms == 9
replace x = 8  if norms == 10
replace x = 9  if norms == 8
replace x = 10 if norms == 6
replace x = 11 if norms == 11
replace x = 12 if norms == 12
replace x = 13 if norms == 13

					sort x


					* Value labels in 0.00 format
					gen con_lab  = string(con, "%4.2f")
					gen norm_lab = string(normmean, "%4.2f")
					gen lib_lab  = string(lib, "%4.2f")
					
					
* Plot positions for markers and labels
*-----------------------------------------
gen con_plot  = con
gen norm_plot = normmean
gen lib_plot  = lib

* Manually add vertical gap between Norm and Lib
* for selected x positions only
/*
* x = 1: move lib box downward
replace lib_plot = lib - 0.020 if x == 1

* x = 2, 3, 4, 5: move Lib box downward
replace lib_plot = lib - 0.025 if inlist(x, 2, 3, 4, 5)

*/

* x = 1,4,: move norm box upward
replace norm_plot = normmean + 0.015 if inlist(x, 1,4)

* x = 2,3,8,9: move norm box upward
replace norm_plot = normmean + 0.025 if inlist(x, 2, 3)
replace lib_plot = lib - 0.010 if inlist(x,2, 3)
replace norm_plot = normmean + 0.037 if inlist(x,9)
replace norm_plot = normmean + 0.015 if inlist(x,8)
replace con_plot = con - 0.010 if inlist(x,8)

* x = 6: move lib box upward norm down
replace norm_plot = normmean - 0.015 if inlist(x, 6)
replace lib_plot = lib + 0.025 if inlist(x, 6)

* x = 5: move norm box downward
replace norm_plot = normmean - 0.005	 if inlist(x, 5)
replace lib_plot = lib - 0.02	 if inlist(x, 5)

* x = 7: move norm box downward
replace norm_plot = normmean - 0.020 if inlist(x, 7)
replace lib_plot = lib + 0.025 if inlist(x, 7)

* x = 5, 10: move lib box downward and upward
replace lib_plot = lib - 0.027 if inlist(x, 5)


					
					
			* STEP->3 ** Plot Graph**	
					
					twoway ///
					///
					/* Vertical line from intercept to lib */ ///
					(rspike con_plot lib_plot x, ///
						lcolor(gs8) lwidth(thin)) ///
					///
					/* Con intercept: hollow square */ ///
(scatter con_plot x, ///
    msymbol(square) msize(huge) ///
    mcolor(white)  mlwidth(vthin)  mlcolor(gs8) ///
    mlabel(con_lab) mlabpos(0) mlabsize(vsmall) mlabcolor(black)) ///
					///
					/* Norm mean: black square */ ///
(scatter norm_plot x, ///
    msymbol(square) msize(huge) ///
    mcolor(black) mlwidth(vthin) mlcolor(black) ///
    mlabel(norm_lab) mlabpos(0) mlabsize(vsmall) mlabcolor(white)) ///
					///
					/* Lib coeff + intercept: gray square */ ///
(scatter lib_plot x, ///
    msymbol(square) msize(huge) ///
    mcolor(gs12) mlwidth(vthin) mlcolor(gs12) ///
    mlabel(lib_lab) mlabpos(0) mlabsize(vsmall) mlabcolor(black)), ///
					///
					xlabel( ///
    1  `""HHD:" "Type of" "fish species" "to cultivate""' ///
    2  `""HHD:" "Type of" "fish feed" "to use""'  ///
    3  `""HHD:" "Aquaculture" "inputs" "to purchase""' ///
    4  `""HHD:" "Whether" "HH should" "start new" "business""' ///
    5  `""AO:" "Owner/co-" "owner of" "aquaculture" "ponds""' ///
    6  `""WFH:" "Take paid" "work" "from home""' ///
    7  `""WFH:" "Start" "business" "from home""' ///
    8  `""WOH:" "Start" "business" "outside home""' ///
    9  `""WOH:" "Any work" "outside" "home""' ///
    10 `""WOH:" "Fish vendor" "in local" "market""' ///
    11 `""FOM:" "Go to" "local market" "alone""' ///
    12 `""FOM:" "Seek" "healthcare" "alone""' ///
    13 `""FOM:" "Visit female" "friends" "alone""', ///
						    angle(0) labsize(vsmall) notick) ///
    ylabel(none) ///
    yscale(range (-0.001 1)noline) ///
					ytitle("Norm misperception: coefficient estimates", margin(medium) size(vsmall)) ///
					xtitle("") ///
					legend(order(2 "Con (intercept)" ///
								 3 "Norm" ///
								 4 "Lib (coeff + intercept)") ///
						   rows(1) size(vsmall) position(6)) ///
					graphregion(color(white)) ///
					plotregion(color(white))  xsize(1.8) ysize(1)

					graph export "${output}\graphs\graph4.png", replace
					
	
	
	
	
	
	
	
	***********************************************
	
	
	************** Figure 5 - M o M *********************


		* STEP->1 ** reshape data and plot vars from regression **
		
				use "${data}\Male_Female_merged-Final_updated_new.dta", clear

				keep uid treatment ///
					m_own_lib_* m_otherm_lib_* ///
					m_wife_lib_* m_mot_lib_* m_otherw_lib_* ///
					f_own_lib_* f_husb_lib_* f_mil_lib_* f_otherw_lib_* f_otherm_lib_*

				reshape long m_own_lib_ m_otherm_lib_, i(uid) j(norms)

				rename m_own_lib_    m_own_lib
				rename m_otherm_lib_ m_otherm_lib

				label define norms_lb ///
					1  "Type of fish species to cultivate" ///
					2  "Type of fish feed to use" ///
					3  "Aquaculture inputs to purchase" ///
					4  "Owner/co-owner of aquaculture ponds" ///
					5  "Whether HH should start new business" ///
					6  "Fish vendor in local market" ///
					7  "Take paid work from home" ///
					8  "Start business outside home" ///
					9  "Start business from home" ///
					10 "Work outside home" ///
					11 "Go to local market alone" ///
					12 "Seek healthcare for self or children" ///
					13 "Visit female friends in village", replace

				label values norms norms_lb

				tempfile results
				tempname memhold

				postfile `memhold' ///
					norms con lib normmean ///
					using `results', replace

				forval j = 1/13 {

					quietly regress m_otherm_lib m_own_lib if norms == `j'

					local con  = _b[_cons]
					local lib  = _b[_cons] + _b[m_own_lib]

					quietly summarize m_own_lib if norms == `j'
					local normmean = r(mean)

					post `memhold' (`j') (`con') (`lib') (`normmean')
				}

				postclose `memhold'

				use `results', clear

				label values norms norms_lb
				
				
		* STEP->2 ** reorder questions and set positions**
		
		
		
				* Graph order
					gen x = .

replace x = 1  if norms == 1
replace x = 2  if norms == 2
replace x = 3  if norms == 3
replace x = 4  if norms == 5
replace x = 5  if norms == 4
replace x = 6  if norms == 7
replace x = 7  if norms == 9
replace x = 8  if norms == 10
replace x = 9  if norms == 8
replace x = 10 if norms == 6
replace x = 11 if norms == 11
replace x = 12 if norms == 12
replace x = 13 if norms == 13

					sort x


					* Value labels in 0.00 format
					gen con_lab  = string(con, "%4.2f")
					gen norm_lab = string(normmean, "%4.2f")
					gen lib_lab  = string(lib, "%4.2f")
					
					
* Plot positions for markers and labels
*-----------------------------------------
gen con_plot  = con
gen norm_plot = normmean
gen lib_plot  = lib

* Manually add vertical gap between Norm and Lib
* for selected x positions only

* x = 1: move lib box downward
replace lib_plot = lib - 0.025 if x == 1

* x = 2, 3, 4, 5: move Lib box downward
replace lib_plot = lib - 0.035 if inlist(x, 2, 3, 4)
replace lib_plot = lib - 0.050 if inlist(x, 6, 9, 10, 13,11)
replace lib_plot = lib - 0.045 if inlist(x, 5)


* x = 6: move lib box upward
replace lib_plot = lib + 0.020 if x == 6
replace norm_plot = normmean - 0.015  if x == 6

* x = 7: move lib box upward
replace lib_plot = lib + 0.015 if x == 7
replace norm_plot = normmean - 0.035  if x == 7


* x = 4, 5: move norm box downward and upward
replace norm_plot = normmean - 0.003 if x == 4
replace norm_plot = normmean - 0.010 if inlist(x,5,6)
replace norm_plot = normmean - 0.035  if x == 12
					
					
			* STEP->3 ** Plot Graph**	
					
					twoway ///
					///
					/* Vertical line from intercept to lib */ ///
					(rspike con_plot lib_plot x, ///
						lcolor(gs8) lwidth(thin)) ///
					///
					/* Con intercept: hollow square */ ///
(scatter con_plot x, ///
    msymbol(square) msize(huge) ///
    mcolor(white)  mlwidth(vthin)  mlcolor(gs8) ///
    mlabel(con_lab) mlabpos(0) mlabsize(vsmall) mlabcolor(black)) ///
					///
					/* Norm mean: black square */ ///
(scatter norm_plot x, ///
    msymbol(square) msize(huge) ///
    mcolor(black) mlwidth(vthin) mlcolor(black) ///
    mlabel(norm_lab) mlabpos(0) mlabsize(vsmall) mlabcolor(white)) ///
					///
					/* Lib coeff + intercept: gray square */ ///
(scatter lib_plot x, ///
    msymbol(square) msize(huge) ///
    mcolor(gs12) mlwidth(vthin) mlcolor(gs12) ///
    mlabel(lib_lab) mlabpos(0) mlabsize(vsmall) mlabcolor(black)), ///
					///
					xlabel( ///
    1  `""HHD:" "Type of" "fish species" "to cultivate""' ///
    2  `""HHD:" "Type of" "fish feed" "to use""'  ///
    3  `""HHD:" "Aquaculture" "inputs" "to purchase""' ///
    4  `""HHD:" "Whether" "HH should" "start new" "business""' ///
    5  `""AO:" "Owner/co-" "owner of" "aquaculture" "ponds""' ///
    6  `""WFH:" "Take paid" "work" "from home""' ///
    7  `""WFH:" "Start" "business" "from home""' ///
    8  `""WOH:" "Start" "business" "outside home""' ///
    9  `""WOH:" "Any work" "outside" "home""' ///
    10 `""WOH:" "Fish vendor" "in local" "market""' ///
    11 `""FOM:" "Go to" "local market" "alone""' ///
    12 `""FOM:" "Seek" "healthcare" "alone""' ///
    13 `""FOM:" "Visit female" "friends" "alone""', ///
						    angle(0) labsize(vsmall) notick) ///
    ylabel(none) ///
    yscale(range (-0.001 1)noline) ///
					ytitle("Norm misperception: coefficient estimates", margin(medium) size(vsmall)) ///
					xtitle("") ///
					legend(order(2 "Con (intercept)" ///
								 3 "Norm" ///
								 4 "Lib (coeff + intercept)") ///
						   rows(1) size(vsmall) position(6)) ///
					graphregion(color(white)) ///
					plotregion(color(white))  xsize(1.8) ysize(1)

					graph export "${output}\graphs\graph5.png", replace
					
					











	
/*	
	
	
	***********************************************
	
	
	************** Figure 3_1 - M o M *********************


		* STEP->1 ** reshape data and plot vars from regression **
		
				use "${data}\Male_Female_merged-Final_updated_new.dta", clear

				keep uid treatment ///
					m_own_lib_* m_otherm_lib_* ///
					m_wife_lib_* m_mot_lib_* m_otherw_lib_* ///
					f_own_lib_* f_husb_lib_* f_mil_lib_* f_otherw_lib_* f_otherm_lib_*

				reshape long m_own_lib_ m_otherm_lib_, i(uid) j(norms)

				rename m_own_lib_    m_own_lib
				rename m_otherm_lib_ m_otherm_lib

				label define norms_lb ///
					1  "Type of fish species to cultivate" ///
					2  "Type of fish feed to use" ///
					3  "Aquaculture inputs to purchase" ///
					4  "Owner/co-owner of aquaculture ponds" ///
					5  "Whether HH should start new business" ///
					6  "Fish vendor in local market" ///
					7  "Take paid work from home" ///
					8  "Start business outside home" ///
					9  "Start business from home" ///
					10 "Work outside home" ///
					11 "Go to local market alone" ///
					12 "Seek healthcare for self or children" ///
					13 "Visit female friends in village", replace

				label values norms norms_lb

				tempfile results
				tempname memhold

postfile `memhold' ///
    norms con con_lci con_uci lib lib_lci lib_uci normmean ///
    using `results', replace

				forval j = 1/13 {

    quietly regress m_otherm_lib m_own_lib if norms == `j'

    local crit = invttail(e(df_r), 0.025)

    * Conservative / intercept estimate and CI
    local con     = _b[_cons]
    local con_se  = _se[_cons]
    local con_lci = `con' - `crit' * `con_se'
    local con_uci = `con' + `crit' * `con_se'

    * Liberal = intercept + coefficient
    quietly lincom _cons + m_own_lib

    local lib     = r(estimate)
    local lib_se  = r(se)
    local lib_lci = `lib' - `crit' * `lib_se'
    local lib_uci = `lib' + `crit' * `lib_se'

    quietly summarize m_own_lib if norms == `j'
    local normmean = r(mean)

    post `memhold' ///
        (`j') ///
        (`con') (`con_lci') (`con_uci') ///
        (`lib') (`lib_lci') (`lib_uci') ///
        (`normmean')
}

				postclose `memhold'

				use `results', clear

				label values norms norms_lb
				
				
		* STEP->2 ** reorder questions and set positions**
		
		
		
				* Graph order
					gen x = .

					replace x = 1  if norms == 1
					replace x = 2  if norms == 2
					replace x = 3  if norms == 3
					replace x = 4  if norms == 4
					replace x = 5  if norms == 5
					replace x = 6  if norms == 7
					replace x = 7  if norms == 9
					replace x = 8  if norms == 10
					replace x = 9  if norms == 8
					replace x = 10 if norms == 6
					replace x = 11 if norms == 11
					replace x = 12 if norms == 12
					replace x = 13 if norms == 13

					sort x


					* Value labels in 0.00 format
					gen con_lab  = string(con, "%4.2f")
					gen norm_lab = string(normmean, "%4.2f")
					gen lib_lab  = string(lib, "%4.2f")
					
					
* Plot positions for markers, labels, and confidence intervals
*-----------------------------------------
gen con_plot  = con
gen norm_plot = normmean
gen lib_plot  = lib

gen con_lci_plot = con_lci
gen con_uci_plot = con_uci

gen lib_lci_plot = lib_lci
gen lib_uci_plot = lib_uci

* Manually add vertical gap between Norm and Lib
* for selected x positions only

* x = 1: move lib box downward
replace lib_plot     = lib - 0.020 if x == 1
replace lib_lci_plot = lib_lci - 0.020 if x == 1
replace lib_uci_plot = lib_uci - 0.020 if x == 1

* x = 2, 3, 4: move Lib box downward
replace lib_plot     = lib - 0.025 if inlist(x, 2, 3, 4)
replace lib_lci_plot = lib_lci - 0.025 if inlist(x, 2, 3, 4)
replace lib_uci_plot = lib_uci - 0.025 if inlist(x, 2, 3, 4)

* x = 7: move lib box upward
replace lib_plot     = lib + 0.040 if x == 7
replace lib_lci_plot = lib_lci + 0.040 if x == 7
replace lib_uci_plot = lib_uci + 0.040 if x == 7
					
			* STEP->3 ** Plot Graph**	
					
					twoway ///
///
///* Conservative confidence interval */ ///
(rcap con_lci_plot con_uci_plot x, ///
    lcolor(gs8) lwidth(vthin)) ///
///
///* Liberal confidence interval */ ///
(rcap lib_lci_plot lib_uci_plot x, ///
    lcolor(gs12) lwidth(vthin)) ///
///
///* Con intercept: hollow square */ ///
(scatter con_plot x, ///
    msymbol(square) msize(vlarge) ///
    mcolor(white)  mlwidth(vthin)  mlcolor(gs8) ///
    mlabel(con_lab) mlabpos(0) mlabsize(tiny) mlabcolor(black)) ///
					///
					/* Norm mean: black square */ ///
(scatter norm_plot x, ///
    msymbol(square) msize(vlarge) ///
    mcolor(black) mlwidth(vthin) mlcolor(black) ///
    mlabel(norm_lab) mlabpos(0) mlabsize(tiny) mlabcolor(white)) ///
					///
					/* Lib coeff + intercept: gray square */ ///
(scatter lib_plot x, ///
    msymbol(square) msize(vlarge) ///
    mcolor(gs12) mlwidth(vthin) mlcolor(gs12) ///
    mlabel(lib_lab) mlabpos(0) mlabsize(tiny) mlabcolor(black)), ///
					///
					xlabel( ///
        1  "HHD: Fish species" ///
        2  "HHD: Fish feed" ///
        3  "HHD: Aqua inputs purchase" ///
        4  "AO: Owner/co-owner of ponds" ///
        5  "HHD: starting business" ///
        6  "WFH: Work from home" ///
        7  "WFH: Business from home" ///
        8  "WOH: Business outside home" ///
        9  "WOH: Work outside home" ///
        10 "WOH: Sell fish in market" ///
        11 "FOM: Visit local market" ///
        12 "FOM: Seek healthcare" ///
        13 "FOM: Visit female friends", ///
						angle(45) labsize(vsmall)) ///
					ylabel(0(.2)1, labsize(vsmall)) ///
					ytitle("Coefficients", size(vsmall)) ///
					xtitle("") ///
					legend(order(3 "Con (intercept)" ///
					 4 "Norm" ///
					 5 "Lib (coeff + intercept)") ///
			   rows(1) size(vsmall) position(6))
						   rows(1) size(vsmall) position(6)) ///
					graphregion(color(white)) ///
					plotregion(color(white))




	
	*/
	








	


