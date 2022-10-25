*Version 1.0
*Author -- Jade Peng & Ricardo Miranda
*Date -- Oct 22, 2022
*This dofile cleans viviendas, a dataset with variables related to living place characteristics in ENIGH 2020

********************************************************************************
*Read living place characteristics data
********************************************************************************
*Data was downloaded from https://www.inegi.org.mx/programas/enigh/nc/2020/#Microdatos on 10/22/2022 at 4:03 pm 
import delimited using "Raw\viviendas.csv", clear varnames(1)		

describe mat_pisos bano_excus tot_resid focos_inca
codebook mat_pisos bano_excus tot_resid focos_inca

********************************************************************************
*Find problems with the data
********************************************************************************
*Identify the unit of observation
*From the documentation we know that ïfolioviv identifies living places and foliohog identifies households(families) within living places. An observation 
bysort ïfolioviv: gen Aux=_N
sum Aux
tab Aux
drop Aux

*Duplicates
duplicates report

*Missing values (codebook or missing will  not detect them because of wrong variable types)
tab mat_pisos, m
replace mat_pisos="" if mat_pisos=="&"
destring mat_pisos, replace

tab bano_excus,m 
destring bano_excus, replace

tab tot_resid
destring tot_resid, replace

tab focos_inca
destring focos_inca, replace

********************************************************************************
*Rename variables and label them
********************************************************************************
keep ïfolioviv mat_pisos bano_excus tot_resid focos_inca

rename ïfolioviv LivingPlace
rename mat_pisos FloorMaterial
rename bano_excus NumberOfToilets
rename tot_resid NumberOfResidents
rename focos_inca NumberOfLightBulbs

label variable LivingPlace "Living place ID"
label variable FloorMaterial "Main material of which the floor of the living place is made"
label variable NumberOfToilets "Number of toilets in the living place"
label variable NumberOfResidents "Number of people habitating the living place"
label variable NumberOfLightBulbs "Number of lightbuls in the living place"

label define FloorMaterial 1 "Dirt floor" 2 "Cement floor" 3 "Wood, marble or other material"
label values FloorMaterial FloorMaterial

*Create indiciators of missing values
qui ds *
quietly ds*
ret list
local Varlist "`r(varlist)'"

gen NoMissingValues=1
foreach var in `Varlist'{
    gen M_`var'=missing(`var')
	replace NoMissingValues=0 if M_`var'==1
}

********************************************************************************
*Save data
********************************************************************************
save "$Working\LivingPlaceCharacteristics.dta", replace

 