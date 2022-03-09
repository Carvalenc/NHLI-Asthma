*** March 2022 *****
**** chloe ****

***** based on covid-asthma AJRCCM paper categorisation ******
****** does not take into ics does but that is also recorded *****


* keep only prescriptions during baseline year
keep if issue<studystart & issue>=(studystart-365.25)

merge m:1 prodcode using ${drugs}AsthmaMEDS_final_AURUM, keep(match master) nogen

* asthma meds 
gen saba=1 if group==1
gen add_on=1 if group==10 | group==14 | group==19 | group==8
gen ics=1 if group==9 | group==7 | group==19

bysort patid: egen saba_tot=total(saba)
bysort patid: egen ics_tot=total(ics)
bysort patid: egen add_tot=total(add)

drop saba add_on

* categorise if ICS only or add-on drug too (LABA, LTRA or theophylline)
gen ics_any=1 if ics_tot>0  &  add_t==0
gen saba_only=1 if saba_t>0 & add_t==0 & ics_t==0
gen add_any=1 if ics_tot>0 & add_t>0

* ICS
bysort patid: egen ics_t=total(ics)
* create variable for 1-3 ICS or >3 ICS
recode ics_t 1/3=0 3/max=1
by patid: egen ics_total=max(ics_t)
label define ics_tota 0 "1-3/intermittent" 1 ">3/regular" 
label value ics_total ics_total
drop ics_t ics
* create variable for ICS dose prescribed using the maximum dose the inhaler prescribed in the exposure period
bysort patid: egen max=max(dose_cat) if issue>start 
by patid: egen max_dose=max(max)
drop max
replace max=0 if max==.
label define max_dose 0 "none" 1 "low" 2 "medium" 3 "high"
label value max_dose max_dose

tab max

* create summary asthma medication variable
gen meds=1 if saba_only==1
replace meds=2 if ics_any==1 & ics_t==0
replace meds=3 if ics_any==1 & ics_t==1
replace meds=4 if add_any==1 & ics_t==0
replace meds=4 if add_any==1 & ics_t==1
replace meds=0 if meds==.

label define meds 0 "none" 1 "SABA only" 2 "ICS only intermittent" 3 "ICS only regular" 4 "ICS + add-on intermittent" 5 "ICS + add-on regular"
label value meds meds

tab meds

