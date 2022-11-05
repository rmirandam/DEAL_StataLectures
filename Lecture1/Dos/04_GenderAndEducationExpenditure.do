*Version 1.0
*Author -- Jade Peng & Ricardo Miranda
*Date -- Nov 4, 2022

*This dofile explores the relation between household head gender and exoenditures in education

use "$Working\FinalDataset.dta", clear

*Standard ttest
ttest EducExpenditureShare, by(FemaleHH)

*Regression analysis
*Baseline analysis
reg EducExpenditureShare FemaleHH

reg EducExpenditureShare FemaleHH, robust

*Household characteristics
reg logEducExpenditure FemaleHH logIncome HHeadAge c.HHeadAge#c.HHeadAge HouseholdSize , robust

*Living place characteristics
reg logEducExpenditure FemaleHH logIncome HHeadAge c.HHeadAge#c.HHeadAge HouseholdSize , robust

*Fixed effects 
reg logEducExpenditure FemaleHH logIncome HHeadAge c.HHeadAge#c.HHeadAge HouseholdSize i.State, robust

*reg EducExpenditureShare FemaleHH EducExpenditure c.HHeadAge#c.HHeadAge HouseholdSize i.State#i.Municipality, robust
areg logEducExpenditure FemaleHH logIncome HHeadAge c.HHeadAge#c.HHeadAge HouseholdSize, robust absorb(MunicipalityID)

*An alternative identification strategy: Within living place variation
areg EducExpenditureShare FemaleHH logIncome HHeadAge c.HHeadAge#c.HHeadAge HouseholdSize if HouseholdsInLivingPlace>1 , robust absorb(LivingPlace)
