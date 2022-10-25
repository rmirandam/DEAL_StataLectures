*Version 1.0
*Author -- Jade Peng & Ricardo Miranda
*Date -- Oct 22, 2022

/* 
Look at a perfectly clean dataset 
For quick demonstration at DEAL STATA workshop at Duke Economics

reference the STATA official guide linked below
chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://www.stata.com/manuals13/gsw1.pdf 
*/

*navigate to the desired working directory
cd /Users/jadepeng/GoogleDrive/22Fall/DEAL_Material

*To use a STATA pre-installed dataset
sysuse auto.dta, clear
/* 
More commonly, we can read in data by use https://xxxxx.xxx.xxx
Or use cd to adjust the filepath then use filename 
Depending on input filetype, there are various way to use use
*/

*To take a quick look at the dataset itself
browse

*Describe general information about the dataset: location, size, time last saved
*tells the structure of the data
describe 

*The phrase _dta has notes indicates there are notes attached to the dataset.
notes

*codebook should act on only one variable
*tells the general info 
*notice the difference between numerical and categorical data
codebook make
codebook foreign
label variable foreign "brand ownership"

*we can also look at certain lines selectively
list make if missing(rep78)
*list certain makes satisfying given criteria
list make if (rep78 <= 2 | missing(rep78)) & price >= 8000
*imputation 1: assume cars without repair data are never repaired
replace rep78 = 0 if missing(rep78)

/*imputation 2: assume cars without repair data are repaired the same number of times.
this strategy does not make sense in this context
but the syntax could be useful elsewhere*/
*replace rep78 = rep78[_n-1] if missing(rep78)

*compare this to the last selection after addressing missing values
list make if rep78 <= 2 & price >= 8000

*to check for duplicate, creat a new variable called dup = # of occurrences
duplicates report make
*example of help command
help duplicates

*summarize tells the feature of the data itself
*it could be done on the dataset 
summarize
*or on a specific variable
summarize price, detail

*tabulate is for categorical data only
tabulate foreign

*summarize mpg value for each foreign type separately
*by sort is called a prefix
by foreign, sort: summarize mpg
*equivalently
bysort foreign: summarize mpg

*summarize mpg value for each foreign type, another way
tabulate foreign, summarize(mpg)

*simple hypothesis test
ttest mpg, by(foreign)
*simple correlation
correlate mpg weight
*simple correlation, but within each foreign type
by foreign, sort: correlate mpg weight

*simple regression, with ereturn
regress price mpg
ereturn list
*estimation data is stored to e()
display e(r2)
*description data stored to r()
return list

*Save data in memory to mydata.dta in the current directory
*overwrite mydata.dta if it exists 
save myauto, replace

