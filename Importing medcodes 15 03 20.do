
****************************************
**#Importing text files for medcodes****
****************************************

**#Depression
import delimited "/Users/carvalenc/Documents/NHLI/txt_files/Anxiety_Depression.txt", clear

generate depression=1

save depression_medcodes.dta, replace

**#Allergy

import delimited "/Users/carvalenc/Documents/NHLI/txt_files/Atopy_aurum.txt", clear

generate foodallergy=0

replace foodallergy=1 if term== "Allergy to banana" | term== "Allergy to hazelnut" ///
| term== "Allergy to kiwi fruit" | term== "Allergy to kiwi fruit" ///
| term== "Allergy to mushrooms" | term== "Allergy to pineapple" ///
| term== "Allergy to pollen" | term== "Allergy to pork" ///
| term== "Allergy to rice" | term== "Allergy to soya" | term== "Allergy to strawberries" ///
| term== "Allergy to strawberries" | term== "Allergy to tomato" ///
| term== "Allergy to tomato" ///
| term== "Allergy to tree pollen" | term== "Cow's milk allergy" ///
| term== "Dietary advice for food allergy" | term== "Dietary education for food allergy" ///
| term== "Egg allergy" | term=="Egg free diet - allergy" | term=="Egg protein allergy" ///
| term== "Fish allergy" | term=="Food allergy" | term=="H/O: food allergy" ///
| term=="Milk free diet - allergy" | term=="Mushroom allergy" ///
| term=="Peanut allergy" | term=="Seafood allergy" | term=="Shellfish allergy" ///
| term=="Strawberry allergy" | term=="Wheat allergy"

generate atopy=0
replace atopy=1 if foodallergy==0

save allergy_medcodes.dta, replace

import delimited "/Users/carvalenc/Documents/NHLI/txt_files/CVA_aurum.txt", clear

gen CVA = 1

save CVA_medcodes.dta, replace 

**#Heart failure 

import delimited "/Users/carvalenc/Documents/NHLI/txt_files/Heart failure.txt", clear

gen heartfailure=1

save heart_failure_medcodes.dta, replace 

***All CVD except heart failure 

use Heart_except_heartfailure.dta, clear

gen medcodeid2=medcode 

destring medcodeid, replace 

replace ihd=0 if ihd==.

replace rhythm=0 if rhythm==.

replace hypertension=0 if hypertension==.

replace other_cardiac=0 if other_cardiac==.

save Heart_No_hf_medcodes.dta, replace 

import delimited "/Users/carvalenc/Documents/NHLI/txt_files/Hypertension_aurum.txt", clear

gen hypertensionmd=1

save Hypertension_aurum_medcodes.dta, replace  




