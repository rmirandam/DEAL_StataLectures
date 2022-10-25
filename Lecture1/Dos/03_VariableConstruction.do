*Version 1.0
*Author -- Jade Peng & Ricardo Miranda
*Date -- Oct 22, 2022
*This dofile merges living place characteristics data with expenditures in education and identifies observations with missing values

*Identify problematic observations 
use "$Working\EducationAndIncommeSummary.dta", clear

merge m:1 LivingPlace using "$Working\LivingPlaceCharacteristics.dta"

*Test if observations with missing values are systematically different 
foreach var in HHeadSex HHeadAge FlowIncome EducExpenditure{
	reg `var' NoMissingValues, robust
}

drop if NoMissingValues

save "$Working\FinalDataset.dta", replace