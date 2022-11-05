*Version 1.0
*Author -- Jade Peng & Ricardo Miranda
*Date -- Oct 22, 2022
*This dofile cleans concentradohogares, a dataset that summarizes the main variables collected by ENIGH 2020

********************************************************************************
*Read households summary data
********************************************************************************
*Data was downloaded from https://www.inegi.org.mx/programas/enigh/nc/2020/#Microdatos on 10/22/2022 at 4:03 pm 
insheet using "Raw\concentradohogar.csv", clear		

import delimited using "Raw\concentradohogar.csv", clear varnames(1)		

describe
describe edad_jefe ing_cor educacion sexo_jefe
codebook  edad_jefe ing_cor educacion sexo_jefe

********************************************************************************
*Find problems with the data
********************************************************************************
*Identify the unit of observation
*From the documentation we know that ïfolioviv identifies living places and foliohog identifies households(families) within living places. An observation 
bysort ïfolioviv: gen Aux=_N
sum Aux
tab Aux
drop Aux

bysort foliohog: gen Aux=_N
sum Aux
tab Aux
drop Aux

bysort ïfolioviv foliohog: gen Aux=_N
sum Aux
tab Aux
tab foliohog
drop Aux

*Duplicates
duplicates report

*Missing values
quietly ds*
ret list
local Varlist "`r(varlist)'"

foreach var in `Varlist'{
    gen Aux=missing(`var')
	sum Aux
	sort Aux
	pause
	drop Aux
}

*Outliers in household head's age, income and education expenditure
sum edad_jefe, d
hist edad_jefe
sort edad_jefe

sum ing_cor,d
hist ing_cor
hist ing_cor if ing_cor<200000

sum educacion,d
hist educacion
hist educacion if educacion<20000
hist educacion if educacion<10000
hist educacion if educacion<5000
hist educacion if educacion<500

********************************************************************************
*Rename variables and label them
********************************************************************************
keep ïfolioviv foliohog edad_jefe ing_cor educacion sexo_jefe tot_integ

*Note: The id variables are renamed but never modified
rename ïfolioviv LivingPlace
rename foliohog HouseholdID
rename edad_jefe HHeadAge
rename ing_cor FlowIncome
rename educacion EducExpenditure
rename sexo_jefe HHeadSex
rename tot_integ HouseholdSize

label variable LivingPlace "Living place ID"
label variable HouseholdID "Household ID within living place ID"
label variable HHeadAge "Age of the household head"
label variable FlowIncome "Household's monthly flow income"
label variable EducExpenditure "Household's monthly expenditure in education"
label variable HHeadSex "Sex of household head"
label variable HouseholdSize "Household size"

label define HHeadSex 1 "Male" 2 "Female"
label values HHeadSex HHeadSex

*Create unique identifiers for each family
egen FamilyID=group(LivingPlace HouseholdID)

*Alternative approaches to variable names
*Camel notation
gen expInEducation=EducExpenditure
*Low bars
gen expenditure_in_edu=EducExpenditure

drop expInEducation expenditure_in_edu
********************************************************************************
*Save data
********************************************************************************
export delimited "$Working\concentradohogar_clean.csv", replace
save "$Working\EducationAndIncommeSummary.dta", replace




 