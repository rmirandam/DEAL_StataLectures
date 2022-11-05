*Version 2.0
*Author -- Jade Peng & Ricardo Miranda
*Date -- Nov 4, 2022

*This dofile has two parts, the first one studies within-living place differences in households income to illustrate common challenges when merging datasets and constructing variables.

*The second part creates a dataset to analyze the relation between household head gender and education in expenditures

********************************************************************************
*Analysis of within-living place differences in income (with a parentesis about merge and joinby)
********************************************************************************
use "$Working\EducationAndIncommeSummary.dta", clear

*sort households by income
sort FlowIncome

*Create separate datasets for below/above-median income households

*preserve (a command that allows you to store dataset only on the temporary memory)
preserve
keep if _n<_N/2
save "$Working\EducationAndIncommeSummary_LowIncome.dta", replace
restore

preserve
keep if _n>=_N/2
save "$Working\EducationAndIncommeSummary_HighIncome.dta", replace
restore


*Merge low income households with household characteristics
use "$Working\EducationAndIncommeSummary_LowIncome.dta", clear
merge m:1 LivingPlace using "$Working\LivingPlaceCharacteristics.dta"
tab _merge 

*Same merge, but starting from living place characteristics data
use "$Working\LivingPlaceCharacteristics.dta", clear
merge 1:m LivingPlace using "$Working\EducationAndIncommeSummary_LowIncome.dta"

*Create all possible within-living place combinations 
use "$Working\EducationAndIncommeSummary_LowIncome.dta", clear

keep FlowIncome HouseholdID LivingPlace
rename FlowIncome FlowIncome_1
rename HouseholdID HouseholdID_1

*This is the wrong way:
*merge m:1  LivingPlace using "$Working\EducationAndIncommeSummary_LowIncome.dta"

*This is also the wrong way
*merge m:m LivingPlace using "$Working\EducationAndIncommeSummary_LowIncome.dta", keepus(FlowIncome)
*rename FlowIncome FlowIncome_2

*This is the right way
joinby LivingPlace using "$Working\EducationAndIncommeSummary_LowIncome.dta", _merge(Merge)  unmatched(both)
di _N
rename FlowIncome FlowIncome_2
rename HouseholdID HouseholdID_2

*Question: What identifies an observation in this dataset?
egen HouseholdsPairID=group(HouseholdID_1 HouseholdID_2) 

*Now we can create all the within-living place differerences in income
bysort LivingPlace: gen Aux=_N
tab Aux
drop if Aux==1
drop if HouseholdID_1==HouseholdID_2

forvalues i=1/2{
	gen logFlowIncome_`i'=log(FlowIncome_`i')
} 

*Create (and don't forget to label')
gen DifflogFlowIncome=logFlowIncome_2-logFlowIncome_1
label variable DifflogFlowIncome "Within living place differences in income"
hist DifflogFlowIncome

*What if we care about the maximum within-living place difference only?
bysort LivingPlace: egen MaxDifflogFlowIncome=max(DifflogFlowIncome)

*Dificult task: Create an indicator for the within-group maximum
bysort LivingPlace: gen MaxDifflogFlowIncome_Ind=MaxDifflogFlowIncome==DifflogFlowIncome

sort LivingPlace
br LivingPlace *DifflogFlowIncome*

*The maximum is a variable that varies at the Living place level, therefore I collapse the data
preserve
bysort LivingPlace: keep if _n==1
keep LivingPlace MaxDifflogFlowIncome
di _N
pause
restore

replace DifflogFlowIncome=abs(DifflogFlowIncome)
collapse (max) MaxDifflogFlowIncome=DifflogFlowIncome (mean) MeanDifflogFlowIncome=DifflogFlowIncome (min) MinDifflogFlowIncome=DifflogFlowIncome, by(LivingPlace)
di _N
pause

twoway (kdensity MaxDifflogFlowIncome)  (kdensity MinDifflogFlowIncome)

********************************************************************************
*Differences in education expenditure by gender of the household head
********************************************************************************
use "$Working\EducationAndIncommeSummary_LowIncome.dta", clear
append using "$Working\EducationAndIncommeSummary_HighIncome.dta"

merge m:1 LivingPlace using "$Working\LivingPlaceCharacteristics.dta"


*The goal is to construct a dataset in which we can analyze if the fraction of expenditure spent on education differs by household head 

*Create relevant variables
gen logIncome=log(FlowIncome)
gen logEducExpenditure=log(EducExpenditure)
gen EducExpenditureShare=EducExpenditure/FlowIncome

tab HHeadSex, nolab
tab HHeadSex
gen FemaleHH=HHeadSex==2

*State and municipality indicators (see ENIGH documentation)
tostring(LivingPlace), generate(LivingPlaceString)

gen Aux=substr(LivingPlaceString,1,2)
drop Aux

gen StateString=substr(LivingPlaceString,1,2) if LivingPlace>=1000000000
replace StateString=substr(LivingPlaceString,1,1) if LivingPlace<1000000000

gen MunicipalityString=substr(LivingPlaceString,3,3) if LivingPlace>=1000000000
replace MunicipalityString=substr(LivingPlaceString,2,3) if LivingPlace<1000000000

encode MunicipalityString, gen(Municipality)
encode StateString, gen(State)
egen MunicipalityID=group(State Municipality)

drop *String

*Observations per living place
bysort LivingPlace: gen HouseholdsInLivingPlace=_N

save "$Working\FinalDataset.dta", replace

