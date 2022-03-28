***************************************************************
**#********MATCHING AND ARRANGING BASELINE COHORT**************
***************************************************************
***************************************************************
**version 4** Latest modification: March 10-2022***************
**

***Adding the medcodes from Diabetes***
***Deleted the check of the matching done in mid-February
***************************************************************
***************************************************************

***Deleting macros, etc
clear matrix
clear mata
macro drop _all

**Working directory

cd /home/cvalenci/Documents/DS169/share/CARLOS/

**Other files present at
global unex /data/master/DS169/share/CARLOS/CorrectUnexp/

*Before processing end and start dates, it appears that exposed patients have 
*a proportion of COPD 6% higher than unexposed patients

************************************************
**#******#Using Chloe's matched AURUM file******
************************************************

use ${unex}getmatchedcohort_matched_cohort_AURUM_final.dta, clear

de

***The dataset has 2,466,074 observations**

tab exposed 

***There are 2,466,074 observations 
***1,233,037 in each group

***Search for duplicates

duplicates report patid setid

***Tag the duplicates 

duplicates tag patid, generate(dup)

bysort patid : gen dep = cond(N==1,0,_n)

tab dep

*******************************
***There are 168,735 duplicates in each group  
*******************************

duplicates drop patid setid, force

******************************************
***There is a total of 2,128,604 patients
******************************************

***Merging with the COPD patients** 


******************************************************************
**#Checking that the patients are nested within practice 
** ***************************************************************
*********************

assertnested pracid patid 

sort pracid exposed

by pracid, sort: su patid


sort setid
by setid: gen litaN = _N
codebook patid if exposed == 1

***Checking how many individuals are matched

by exposed, sort: su setid 


***Risk factors

*****
*****
***************************************
***Merging all the COPD datasets

use copd_aurum1nd, clear

merge 1:1 patid using copd_aurum2nd

drop _merge 

merge 1:1 patid using copd_aurum3nd

tab copd 

save copd_merged.dta, replace

****************************************
*****

by COPD, sort: su age_start

**The dates for start and finish are 

display %dM_d_CY 16071
*January 1 2004

display %dM_d_CY 21533
*December 15 2018

display %dM_d_CY -36524

display %dM_d_CY 2936549

gen COPDvalid=0

replace COPDvalid=1 if obsdate>index_match & obsdate<.

replace COPDvalid=0 if obsdate> 22109

gen COPDvalid2=0

replace COPDvalid2=1 if obsdate<index_match & obsdate<.

replace COPDvalid2=0 if obsdate> 22109

display date("13/07/2020","DMY")

tab COPDvalid 

***There are 2,152,926
**74,660

tab COPDvalid exposed, col chi 

tab COPDvalid2 exposed, col chi 



************************************
************************************
**#CHECKING THE DATA ON THE EXPOSED
************************************
************************************


**#COPD in exposed 

***
***Merging With Medcodes 

***Using the medcode from COPD 
use medcdcopd2.dta, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

***Merging with the COPD-AURUM files (number 1)
save copd_aurum1.dta, replace

bysort patid :gen dep = cond(N==1,0,_n)

tab dep

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

drop _merge 

save copd_aurum1nd.dta, replace

***Merging with the COPD-AURUM files (number 2)
use medcdcopd2.dta, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge

save copd_aurum2, replace 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save copd_aurum2nd, replace 

***Merging With Medcodes 
use medcdcopd2.dta, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

**Merging with the COPD-AURUM files (number 3)
save copd_aurum3.dta, replace

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

tab copd 

save copd_aurum3nd.dta, replace


**#BMI in exposed 

use Exposed_Aurum_BMI.dta, clear

duplicates report patid

duplicates tag patid, generate(dup)

tab dup 

duplicates drop patid, force

su patid

***1,200,000 observations of BMI in unexposed patients 

save Exposed_BMI070322.dta, replace

use Exposed_BMI070322, clear 

gen trueheight=value if height==1

gen trueweight=value if weight==1

gen truebmi= trueweight/((trueheight)^2)

replace truebmi=value if truebmi==.

save Exposed_BMI__values_070322.dta, replace 

*****
**# Smoking in exposed and unexposed  
**

use All_SMOKING.dta, clear

duplicates report patid obsdate

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

su patid

bysort patid : gen dep = cond(_N==1,0,_n)

duplicates tag patid, generate(dup)

duplicates report patid 

******
**#Aurum therapy on the exposed is MISSING 
******

******************************
**2,868,954 unique observations
******************************

duplicates drop patid, force

save smoking_exposed_unexposed_070322.dta, replace 

************************************
**#Chronic kidney failure 
************************************

use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/KidneyFailure_aurum.dta", clear

gen medcodeid2 = medcodeid

destring medcodeid, replace 
format medcodeid %14.0g 

save crfmedcodes, replace

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save crfexpMedcodes1nd.dta, replace

****

use crfmedcodes, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save crfexpAurumMedcodes2nd.dta, replace 

*****

use crfmedcodes, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save crfexpAurumMedcodes3nd.dta, replace

***Final file 

use crfexpMedcodes1nd, clear

merge 1:1 patid using crfexpAurumMedcodes2nd

drop _merge

merge 1:1 patid using crfexpAurumMedcodes3nd

drop _merge 

save chronickidneyexposedaurum.dta, replace 

************************************
**#Hyperlipidaemia in exposed 
************************************

use "/home/cvalenci/Documents/DS169/share/Codelists/Hyplipid_medcodes_210322.dta", clear

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save hyplipAurumMedcodes1nd.dta, replace

****

use "/home/cvalenci/Documents/DS169/share/Codelists/Hyplipid_medcodes_210322.dta", clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save hyplipAurumMedcodes2nd.dta, replace 

*****

use "/home/cvalenci/Documents/DS169/share/Codelists/Hyplipid_medcodes_210322.dta", clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save hyplipAurumMedcodes3nd.dta, replace

*****

use hyplipAurumMedcodes1nd, clear

merge 1:1 patid using hyplipAurumMedcodes2nd

drop _merge

merge 1:1 patid using hyplipAurumMedcodes3nd

save hyplipexpAurum.dta, replace 

************************************

************************
**#Heart failure in exposed 
************************
use "/home/cvalenci/Documents/DS169/share/Codelists/HeartFailure.dta", clear

gen medcodeid2 = medcodeid

destring medcodeid, replace 
format medcodeid %14.0g 

sort medcodeid

save hfmedcode.dta, replace

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save hfexAurumMedcodes1nd.dta, replace

****

use "/home/cvalenci/Documents/DS169/share/Codelists/hfmedcode.dta", clear

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save hfexAurumMedcodes2nd.dta, replace

**
use "/home/cvalenci/Documents/DS169/share/Codelists/hfmedcode.dta", clear

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save hfexAurumMedcodes3nd.dta, replace

***************

use hfexAurumMedcodes1nd, clear

merge 1:1 patid using hfexAurumMedcodes2nd

drop _merge 

merge 1:1 patid using hfexAurumMedcodes3nd

save hfexpAurum.dta, replace

************************************
**#Chronic liver disease in exposed 
************************************
use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/Liver_aurum.dta", clear

gen medcodeid2 = medcodeid

destring medcodeid, replace 
format medcodeid %14.0g 

sort medcodeid 

save cldmedcodes, replace

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save cldexpAurumMedcodes1nd.dta, replace

****

use cldmedcodes, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save cldexpAurumMedcodes2nd.dta, replace 

*****

use cldmedcodes, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save cldexpAurumMedcodes3nd.dta, replace

***
use cldexpAurumMedcodes1nd, clear

merge 1:1 patid using cldexpAurumMedcodes2nd

drop _merge 

merge 1:1 patid using cldexpAurumMedcodes3nd

drop _merge 

save chrlivexpaurum.dta, replace 

************************************
**#Diabetes in exposed 
************************************
use "/home/cvalenci/Documents/DS169/share/Codelists/diabetes_aurumCAV090322.dta", clear

gen diabetes=1

gen medcodeid=substr(Diabetes_Medcodes, 2,20)

destring medcodeid, replace

sort medcodeid 

save dmmedcodes.dta, replace

***
use dmmedcodes, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save dmexpAurumMedcodes1nd.dta, replace

****

use cldmedcodes, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save dmexpAurumMedcodes2nd.dta, replace 

*****

use cldmedcodes, clear

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save dmexpAurumMedcodes3nd.dta, replace

***
*Merging all the exposed 
***


use dmexpAurumMedcodes1nd, clear

merge 1:m patid using dmexpAurumMedcodes2nd.dta

drop _merge 

merge 1:m patid using dmexpAurumMedcodes3nd.dta

save dmexpaurum.dta, replace 

*************************
**#Depression in exposed 
*************************
 
use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/depression_medcodes.dta", clear

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save depexpAurumMedcodes1nd.dta, replace

****

use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/depression_medcodes.dta", clear

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save depexpAurumMedcodes2nd.dta, replace 

***

use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/depression_medcodes.dta", clear

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save depexpAurumMedcodes3nd.dta, replace

***
*Merging all depression cases
***

use depexpAurumMedcodes1nd, clear

merge 1:1 patid using depexpAurumMedcodes2nd

drop _merge 

merge 1:1 patid using depexpAurumMedcodes3nd

save depexpAurum.dta, replace 


**********************
**#Heart disease in exposed 
**********************

use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/Heart_No_hf_medcodes.dta", clear

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save chd_nhf_expAurumMedcodes1.dta, replace 

***
use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/Heart_No_hf_medcodes.dta", clear

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save chd_nhf_expAurumMedcodes2.dta, replace 

***

use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/Heart_No_hf_medcodes.dta", clear

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save chd_nhf_expAurumMedcodes3.dta, replace

**
*Merging CHD
**

use chd_nhf_expAurumMedcodes1, clear

merge 1:1 patid using chd_nhf_expAurumMedcodes2

drop _merge 

merge 1:1 patid using chd_nhf_expAurumMedcodes3

drop _merge 

save chd_nhf_expaurum.dta, replace 


***
**# Allergy in exposed (food allergy and atopy)
**

use "/home/cvalenci/Documents/DS169/share/Codelists/allergy_medcodes.dta", clear

keep if foodallergy==1

save foodallergymedcodes.dta, replace 

use "/home/cvalenci/Documents/DS169/share/Codelists/allergy_medcodes.dta", clear

keep if atopy==1

save atopyalonemedcodes.dta, replace 

***
**#Food allergy_medcodes in exposed 

use foodallergymedcodes.dta, clear 

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save foodallexpAurumMedcodes1.dta, replace 

***

use foodallergymedcodes.dta, clear 

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save foodallexpAurumMedcodes2.dta, replace 

***

use foodallergymedcodes.dta, clear 

sort medcodeid 

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save foodallexpAurumMedcodes3.dta, replace 

***
use foodallexpAurumMedcodes1.dta, clear

merge 1:1 patid using foodallexpAurumMedcodes2

drop _merge

merge 1:1 patid using foodallexpAurumMedcodes3

drop _merge 

save foodallexp.dta, replace

***
**#Atopy in exposed 
**

use atopyalonemedcodes.dta, clear 

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save atopyallexpAurumMedcodes1.dta, replace 

**

use atopyalonemedcodes.dta, clear 

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save atopyallexpAurumMedcodes2.dta, replace 

**

use atopyalonemedcodes.dta, clear 

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save atopyallexpAurumMedcodes3.dta, replace 

***

use atopyallexpAurumMedcodes1, clear

merge 1:1 patid using atopyallexpAurumMedcodes2

drop _merge

merge 1:1 patid using atopyallexpAurumMedcodes3

drop _merge 

save atopexp.dta, replace


******************************************
**#Stroke/Cardiovascular events in exposed    
******************************************

use "/home/cvalenci/Documents/DS169/share/Codelists/CVA_medcodes.dta", clear

drop release snomedctdescriptionid snomedctconceptid cleansedreadcode originalreadcode

save CVA_medcodes_clean.dta, replace  

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save CVAallexpAurumMedcodes1.dta, replace 

***

use CVA_medcodes_clean.dta, clear

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save CVAallexpAurumMedcodes2.dta, replace 

***

use CVA_medcodes_clean.dta, clear

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save CVAallexpAurumMedcodes3.dta, replace 

****

use CVAallexpAurumMedcodes1, clear

merge 1:1 patid using CVAallexpAurumMedcodes2

drop _merge 

merge 1:1 patid using CVAallexpAurumMedcodes3

drop _merge

save CVAallexp, replace

************************************
**#Pneumonia in exposed 
************************************

use "/home/cvalenci/Documents/DS169/share/Codelists/Pneumonia_aurum.dta", clear

destring medcodeid, replace

format medcodeid %20.0g

save pnmedcodes.dta, replace

sort medcodeid 

use pnmedcodes.dta, clear

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes1sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save pnallexpAurumMedcodes1.dta, replace 

***

use pnmedcodes.dta, clear

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes2sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save pnallexpAurumMedcodes2.dta, replace 

***

use pnmedcodes.dta, clear

sort medcodeid

merge 1:m medcodeid using Exposed_Aurum_Medcodes3sorted.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save pnallexpAurumMedcodes3.dta, replace 

****

use pnallexpAurumMedcodes1, clear

merge 1:1 patid using pnallexpAurumMedcodes2

drop _merge

merge 1:1 patid using pnallexpAurumMedcodes3

drop _merge 

save pnallexp.dta, replace 


************************************
**#Eosinophil count in exposed and unexposed 
************************************

use All_EOS.dta, clear

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates tag patid, generate(dep)

tab dep

duplicates drop patid, force


gen eosvalue109cellperl = value if numunit==6 | numunit== 69 | numunit==76 |  ///
numunit==77 | numunit==79 | numunit==82 | numunit==303 | numunit == 305 ///
| numunit== 307 | numunit== 321 | numunit== 323 | numunit== 335 | numunit == 392 ///
| numunit== 431 | numunit==433 | numunit== 585 | numunit == 714 | numunit== 821 | ///
numunit== 862 | numunit==884 | numunit==933 | numunit== 1034 | numunit== 1045 | ///
numunit == 1103 | numunit== 1113 | numunit == 1133 | numunit == 1194 | numunit== 1243 ///
| numunit== 1250 | numunit== 1256 | numunit== 1271 | numunit== 1354 | numunit== 1426 /// 
| numunit==  1581 | numunit== 1640 | numunit== 1681 | numunit== 4118 | numunit== 4130 ///
| numunit== 4144 | numunit== 6173 | numunit== 6580 | numunit== 7073  | numunit== 7075 ///
| numunit== 8558 | numunit== 8605 | numunit== 8663 

su eosvalue109cellperl, detail

***99% of the values are below 1.1
***deleting values beyond that value 

drop if eosvalue109cellperl>1.5

*33,360 observations deleted

hist eosvalue109cellperl, normal 

save eosmax15.dta, replace 

******
**#****CVD cohort in the exposed 
******

***COPD 


***BMI  

use Exposed_BMI__values_070322.dta, replace

***Smoking BOTH EXPOSED AND UNEXPOSED 

merge 1:1 patid using smoking_exposed_unexposed_070322.dta

duplicates report patid 

drop _merge

***Chronic Kidney Disease

merge 1:1 patid using chronickidneyexposedaurum

duplicates report patid 

drop _merge

***Heart failure 

merge 1:1 patid using hfexpAurum

drop _merge

***Chronic Liver Disease

merge 1:1 patid using chrlivexpaurum

drop _merge

***Diabetes 

merge 1:1 patid using dmmedcodes

drop _merge 

***Depression 

merge 1:1 patid using depexpAurum

drop _merge 

***Coronary Heart Disease 
merge 1:1 patid using chd_nhf_expaurum

drop _merge 

***Food allergy 
merge 1:1 patid using foodallexp

drop _merge 

***Atopy 
merge 1:1 patid using atopexp

drop _merge 

***Cardiovascular Accidents
merge 1:1 patid using CVAallexp

drop _merge 

merge 1:1 patid using pnallexp

save cvdcohortexp240322, replace 

******
******
******

**************************************************************
**************************************************************
**#**************RISK FACTORS IN THE UNEXPOSED****************
**************************************************************
**************************************************************


***************************************
**#BMI in unexposed 
***************************************
use Unexposed_AURUM_BMI.dta, clear

duplicates tag patid, generate(dup)

tab dup 

duplicates drop patid, force

su patid

save Unexposed_BMI030322.dta, replace

use Unexposed_BMI030322, clear 

gen truebmi=value if bmi==1

***************************************
**#Smoking in unexposed 
***************************************

use Unexposed_AURUM_SMOKING.dta, clear

su patid

**10,887,188 patients

duplicates report patid obsdate

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

su patid

bysort patid : gen dep = cond(_N=1,0,_n)

duplicates tag patid, generate(dup)

duplicates report patid 
**1,171,450 unique observations

duplicates drop patid, force

***
**Dropped 93,497 observations 
***

gen smokhab=.

replace smokhab=1 if smoker==1
replace smokhab=2 if ex==1
replace smokhab=0 if never==1

***********************************************
**Save the data
***********************************************
save Unexposed_Aurum_Smoking030322.dta, replace 
***********************************************


************************
***4,088 duplicated observations 
************************

***including the values of EOS that are in units of 10^9/l 

gen eosvalue109cellperl = value if numunit==6 | numunit== 69 | numunit==76 |  ///
numunit==77 | numunit==79 | numunit==82 | numunit==303 | numunit == 305 ///
| numunit== 307 | numunit== 321 | numunit== 323 | numunit== 335 | numunit == 392 ///
| numunit== 431 | numunit==433 | numunit== 585 | numunit == 714 | numunit== 821 | ///
numunit== 862 | numunit==884 | numunit==933 | numunit== 1034 | numunit== 1045 | ///
numunit == 1103 | numunit== 1113 | numunit == 1133 | numunit == 1194 | numunit== 1243 ///
| numunit== 1250 | numunit== 1256 | numunit== 1271 | numunit== 1354 | numunit== 1426 /// 
| numunit==  1581 | numunit== 1640 | numunit== 1681 | numunit== 4118 | numunit== 4130 ///
| numunit== 4144 | numunit== 6173 | numunit== 6580 | numunit== 7073  | numunit== 7075 ///
| numunit== 8558 | numunit== 8605 | numunit== 8663 

***Converting units of 10 uL to 10^9 
 
 ***Converting units of 10^6 to 10^9 
gen eosvalue109cellperl = value*0.001 if numunit==75 | numunit== 826 
 
***Converting units of 10^12 to 10^9 (not really the units)
**gen eosvalue109cellperl = value*1000 if numunit==74 

gen eosvalue109cellperl = value*100000000000 if numunit==347 

replace eosvalue109cellperl = value*1000000000 if numunit==407

replace eosvalue109cellperl = value*1000000000000 if numunit==416 | numunit==1224


***Other units
*Numunit ==10, 139(g/l), 153(IU), 160(l) ,246(%), 254ph , 322 u/monthd 334/L 
*347 10^-2, 368 x10, 405, unknown, 923, unknown , 986, 1029, 1155, 1245, 2691,     



**#Aurum THERAPY on unexposed 

use Unexposed_AURUM_THERAPY.dta, clear

su patid

**309 million patients

duplicates drop patid, force

su patid

**1,161,427 patients 

duplicates report patid

**No more duplicates 

save Unexposed_Therapy030322.dta, replace


**************************
**#Chronic kidney failure in unexposed 
**************************

use crfmedcodes, replace

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save crfunexpAurumMedcodes.dta, replace


*****************************
**#Hyperlipidaemia in unexposed 
*****************************

use "/home/cvalenci/Documents/DS169/share/Codelists/Hyplipid_medcodes_210322.dta", clear

sort medcodeid 

gen hyplip=1

save hyplipmedc210322.dta, replace 

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save hypliunexpAurumMedcodes.dta, replace


*********************************
**#Heart failure in the unexposed
********************************* 

use hfmedcode.dta, clear

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save hfunexAurumMedcodes.dta, replace


*****************************************
**#Chronic Liver Disease in the unexposed 
*****************************************

use cldmedcodes, replace

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save cldunexpAurumMedcodes1nd.dta, replace

**#Diabetes in the unexposed

use dmmedcodes, clear

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save dmunexpAurumMedcodes.dta, replace


*******************************
**#Depression in the unexposed 
*******************************

use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/depression_medcodes.dta", clear

sort medcodeid 

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force

save depunexpAurumMedcodesnd.dta, replace


**#Heart disease in the unexposed 

use "/home/cvalenci/Documents/DS169/share/Codelists/Other codes/Heart_No_hf_medcodes.dta", clear

sort medcodeid 

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save chd_nhf_unexpAurumMedcodes.dta, replace 


****************************
**#Food allergy in unexposed 
****************************

use foodallergymedcodes.dta, clear 

sort medcodeid

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save foodaunexpAurumMedcodes.dta, replace 

***
**#Atopy in unexposed 
**

use atopyalonemedcodes.dta, clear 

sort medcodeid

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save atopyunexpAurumMedcodes.dta, replace 

********************************************
**#Stroke/Cardiovascular events in unexposed    
********************************************

use CVA_medcodes_clean.dta, replace  

sort medcodeid

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES 

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save CVAunexpAurumMedcodes.dta, replace 

*************************
**#Pneumonia in unexposed 

***Create a new medcode file for unexposed with a numeric medcodeid
***variable

use pnmedcodes.dta, clear

sort medcodeid

merge 1:m medcodeid using numUnexposed_AURUM_MEDCODES.dta

keep if _merge==3

drop _merge 

bysort patid: egen lat3 = max(obsdate)

keep if lat3==obsdate 

duplicates drop patid, force 

save pnallunexpAurumMedcodes.dta, replace 

******************************************
**#CVD cohort in unexposed ***************
******************************************

***COPD in unexposed 
***MISSING 

**BMI in unexposed 

merge 1:1 patid using Unexposed_BMI030322

drop _merge 

***Smoking in unexposed (already included with the exposed file)

***Therapy in unexposed 
merge 1:1 patid using Unexposed_Therapy030322

drop _merge 

***Chronic kidney disease in unexposed 

merge 1:1 patid using crfunexpAurumMedcodes

drop _merge 

***Hyperlipidaemia in unexposed 
merge 1:1 patid using hypliunexpAurumMedcodes

drop _merge 

***Chronic liver disease in unexposed
cldunexpAurumMedcodes1nd

drop _merge

***Depression in unexposed 

merge 1:1 using depunexpAurumMedcodesnd

drop _merge 

***Chronic heart disease 

chd_nhf_unexpAurumMedcodes

drop _merge 

***Food allergy in unexposed 

merge 1:1 patid using foodaunexpAurumMedcodes

drop _merge 

***Atopy in unexposed 

merge 1:1 patid using atopyunexpAurumMedcodes

drop _merge 

***Cardiovascular accidents in unexposed 

merge 1:1 patid using CVAunexpAurumMedcodes

drop _merge 

***Pneumonia in unexposed 
merge 1:1 patid using pnallunexpAurumMedcodes


**********************************************************************
**#***********************END OF DO FILE******************************
**********************************************************************

