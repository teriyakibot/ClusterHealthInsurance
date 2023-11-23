capture log close
log using "/Users/shuhuisun/Desktop/Y1S1/econometrics-M.R./cleaner"
set more off
clear all
set matsize 800
set seed 0
global bootstraps 1000


// Set environmet variables
global projects: env projects
global storage: env storage

// General locations
global dataraw =  "$storage/econometrics/big/insurance_project"
global output = "$projects/econometrics/big/insurance_project"

// Load CSV Data
import delimited $dataraw/Plan_Attributes_PUF.csv

// Drop Dental Plans
drop if dentalonlyplan=="Yes"

// Create plan type indicators
gen epo = 0 if plantype !=""
replace epo = 1 if plantype == "EPO"
gen hmo = 0 if plantype !=""
replace hmo = 1 if plantype == "HMO"
gen pos = 0 if plantype !=""
replace pos = 1 if plantype == "POS"
gen ppo = 0 if plantype !=""
replace ppo = 1 if plantype == "PPO"

// Create metal level indicators
gen bronze = 0 if metallevel !=""
replace bronze = 1 if metallevel == "Bronze"
gen catastrophic = 0 if metallevel !=""
replace catastrophic = 1 if metallevel == "Catastrophic"
gen gold = 0 if metallevel !=""
replace gold = 1 if metallevel == "Gold"
gen platinum = 0 if metallevel !=""
replace platinum = 1 if metallevel == "Platinum"
gen silver = 0 if metallevel !=""
replace silver = 1 if metallevel == "Silver"
gen expandedbronze = 0 if metallevel !=""
replace expandedbronze = 1 if metallevel == "Expanded Bronze"

// Pregnancy Notice Requirement
replace isnoticerequiredforpregnancy = "0" if isnoticerequiredforpregnancy == "No"
replace isnoticerequiredforpregnancy = "1" if isnoticerequiredforpregnancy == "Yes"
destring isnoticerequiredforpregnancy, replace

// Referral Required for Specialist
replace isreferralrequiredforspecialist = "0" if isreferralrequiredforspecialist == "No"
replace isreferralrequiredforspecialist = "1" if isreferralrequiredforspecialist == "Yes"
destring isreferralrequiredforspecialist, replace

// Wellness Program Offered
replace wellnessprogramoffered = "0" if wellnessprogramoffered == "No"
replace wellnessprogramoffered = "1" if wellnessprogramoffered == "Yes"
destring wellnessprogramoffered, replace

// Make disease prevention program variable readible
gen asthma =0 if diseasemanagementprogramsoffered != ""
replace asthma = 1 if strpos(diseasemanagementprogramsoffered, "Asthma")

gen heartdisease =0 if diseasemanagementprogramsoffered != ""
replace heartdisease = 1 if strpos(diseasemanagementprogramsoffered, "Heart Disease")

gen depression =0 if diseasemanagementprogramsoffered != ""
replace depression = 1 if strpos(diseasemanagementprogramsoffered, "Depression")

gen diabetes =0 if diseasemanagementprogramsoffered != ""
replace diabetes = 1 if strpos(diseasemanagementprogramsoffered, "Diabetes")

gen hbd_hc =0 if diseasemanagementprogramsoffered != ""
replace hbd_hc = 1 if strpos(diseasemanagementprogramsoffered, "High Blood Pressure")

gen lowerbackpain =0 if diseasemanagementprogramsoffered != ""
replace lowerbackpain = 1 if strpos(diseasemanagementprogramsoffered, "Low Back Pain")

gen painmanagement =0 if diseasemanagementprogramsoffered != ""
replace painmanagement = 1 if strpos(diseasemanagementprogramsoffered, "Pain Management")

gen pregnancy =0 if diseasemanagementprogramsoffered != ""
replace pregnancy = 1 if strpos(diseasemanagementprogramsoffered, "Pregnancy")

gen weightlossprograms =0 if diseasemanagementprogramsoffered != "Weight Loss Programs"
replace weightlossprogram = 1 if strpos(diseasemanagementprogramsoffered, "")



// Out of Country Coverage
replace outofcountrycoverage = "0" if outofcountrycoverage == "No"
replace outofcountrycoverage = "1" if outofcountrycoverage == "Yes"
destring outofcountrycoverage, replace

// Out of Service Coverage
replace outofserviceareacoverage = "0" if outofserviceareacoverage == "No"
replace outofserviceareacoverage = "1" if outofserviceareacoverage == "Yes"
destring outofserviceareacoverage, replace

// National Network
replace nationalnetwork = "0" if nationalnetwork == "No"
replace nationalnetwork = "1" if nationalnetwork == "Yes"
destring nationalnetwork, replace

// Multiple In Network Tiers
replace multipleinnetworktiers = "0" if multipleinnetworktiers == "No"
replace multipleinnetworktiers = "1" if multipleinnetworktiers == "Yes"
destring multipleinnetworktiers, replace

// First/Second Tier Utilization
replace firsttierutilization = subinstr(firsttierutilization,"%","",.)
destring firsttierutilization, replace
replace secondtierutilization = subinstr(secondtierutilization,"%","",.)
destring secondtierutilization, replace

// Info from Summary of Benefits Covered
// because of varlenght simple fracture has to be outside of loop
local ins = "deductible copayment coinsurance limit"
local ins2 = "deductibl copayment coinsuran limit"
local conditions "ababy diabetes"
foreach con in `conditions' {
	foreach i in `ins' {
		replace sbchaving`con'`i' = subinstr(sbchaving`con'`i',"$","",.)
		replace sbchaving`con'`i' = subinstr(sbchaving`con'`i',",","",.)
	destring sbchaving`con'`i', replace
	}
}
foreach i in `ins2' {
	replace sbchavingsimplefracture`i' = subinstr(sbchavingsimplefracture`i',"$","",.)
	replace sbchavingsimplefracture`i' = subinstr(sbchavingsimplefracture`i',",","",.)
	destring sbchavingsimplefracture`i', replace
}

rename sbchavingababydeductible sbchavingbabydeduct
rename sbchavingababycopayment sbchavingbabycopay
rename sbchavingababycoinsurance sbchavingbabycoin
rename sbchavingababylimit sbchavingbabylim

rename sbchavingdiabetesdeductible sbchavingdiabetesdeduct
rename sbchavingdiabetescopayment sbchavingdiabetescopay
rename sbchavingdiabetescoinsurance sbchavingdiabetescoin
rename sbchavingdiabeteslimit sbchavingdiabeteslim

rename sbchavingsimplefracturedeductibl sbchavingfracdeduct
rename sbchavingsimplefracturecopayment sbchavingfraccopay
rename sbchavingsimplefracturecoinsuran sbchavingfraccoin
rename sbchavingsimplefracturelimit sbchavingfraclim

// Specialty Drug Maximum Coinsurance
replace specialtydrugmaximumcoinsurance = subinstr(specialtydrugmaximumcoinsurance,"$","",.)
replace specialtydrugmaximumcoinsurance = subinstr(specialtydrugmaximumcoinsurance,",","",.)
destring specialtydrugmaximumcoinsurance, replace

// Meat of the cleaning
tostring dehbinntier2individualmoop, replace
tostring dehbinntier2familyperpersonmoop, replace
tostring dehbinntier2familypergroupmoop, replace
local vars = "m d t"
foreach var in `vars' {
	replace `var'ehbinntier1individualmoop = "" if strpos(`var'ehbinntier1individualmoop, "Not Applicable")
	replace `var'ehbinntier1individualmoop = "" if strpos(`var'ehbinntier1individualmoop, "not applicable")
	replace `var'ehbinntier1individualmoop = subinstr(`var'ehbinntier1individualmoop," ","",.)
	replace `var'ehbinntier1individualmoop = subinstr(`var'ehbinntier1individualmoop,"$","",.)
	replace `var'ehbinntier1individualmoop = subinstr(`var'ehbinntier1individualmoop,",","",.)
	replace `var'ehbinntier1individualmoop = subinstr(`var'ehbinntier1individualmoop,"perperson","",.)
	replace `var'ehbinntier1individualmoop = subinstr(`var'ehbinntier1individualmoop,"pergroup","",.)
	destring `var'ehbinntier1individualmoop, replace
	replace `var'ehbinntier1familyperpersonmoop = "" if strpos(`var'ehbinntier1familyperpersonmoop, "Not Applicable")
	replace `var'ehbinntier1familyperpersonmoop = "" if strpos(`var'ehbinntier1familyperpersonmoop, "not applicable")
	replace `var'ehbinntier1familyperpersonmoop = subinstr(`var'ehbinntier1familyperpersonmoop," ","",.)
	replace `var'ehbinntier1familyperpersonmoop = subinstr(`var'ehbinntier1familyperpersonmoop,"$","",.)
	replace `var'ehbinntier1familyperpersonmoop = subinstr(`var'ehbinntier1familyperpersonmoop,",","",.)
	replace `var'ehbinntier1familyperpersonmoop = subinstr(`var'ehbinntier1familyperpersonmoop,"perperson","",.)
	replace `var'ehbinntier1familyperpersonmoop = subinstr(`var'ehbinntier1familyperpersonmoop,"pergroup","",.)
	destring `var'ehbinntier1familyperpersonmoop, replace
	replace `var'ehbinntier1familypergroupmoop = "" if strpos(`var'ehbinntier1familypergroupmoop, "Not Applicable")
	replace `var'ehbinntier1familypergroupmoop = "" if strpos(`var'ehbinntier1familypergroupmoop, "not applicable")
	replace `var'ehbinntier1familypergroupmoop = subinstr(`var'ehbinntier1familypergroupmoop," ","",.)
	replace `var'ehbinntier1familypergroupmoop = subinstr(`var'ehbinntier1familypergroupmoop,"$","",.)
	replace `var'ehbinntier1familypergroupmoop = subinstr(`var'ehbinntier1familypergroupmoop,",","",.)
	replace `var'ehbinntier1familypergroupmoop = subinstr(`var'ehbinntier1familypergroupmoop,"perperson","",.)
	replace `var'ehbinntier1familypergroupmoop = subinstr(`var'ehbinntier1familypergroupmoop,"pergroup","",.)
	destring `var'ehbinntier1familypergroupmoop, replace
	replace `var'ehbinntier2individualmoop = "" if strpos(`var'ehbinntier2individualmoop, "Not Applicable")
	replace `var'ehbinntier2individualmoop = "" if strpos(`var'ehbinntier2individualmoop, "not applicable")
	replace `var'ehbinntier2individualmoop = subinstr(`var'ehbinntier2individualmoop," ","",.)
	replace `var'ehbinntier2individualmoop = subinstr(`var'ehbinntier2individualmoop,"$","",.)
	replace `var'ehbinntier2individualmoop = subinstr(`var'ehbinntier2individualmoop,",","",.)
	replace `var'ehbinntier2individualmoop = subinstr(`var'ehbinntier2individualmoop,"perperson","",.)
	replace `var'ehbinntier2individualmoop = subinstr(`var'ehbinntier2individualmoop,"pergroup","",.)
	destring `var'ehbinntier2individualmoop, replace
	replace `var'ehbinntier2familyperpersonmoop = "" if strpos(`var'ehbinntier2familyperpersonmoop, "Not Applicable")
	replace `var'ehbinntier2familyperpersonmoop = "" if strpos(`var'ehbinntier2familyperpersonmoop, "not applicable")
	replace `var'ehbinntier2familyperpersonmoop = subinstr(`var'ehbinntier2familyperpersonmoop," ","",.)
	replace `var'ehbinntier2familyperpersonmoop = subinstr(`var'ehbinntier2familyperpersonmoop,"$","",.)
	replace `var'ehbinntier2familyperpersonmoop = subinstr(`var'ehbinntier2familyperpersonmoop,",","",.)
	replace `var'ehbinntier2familyperpersonmoop = subinstr(`var'ehbinntier2familyperpersonmoop,"perperson","",.)
	replace `var'ehbinntier2familyperpersonmoop = subinstr(`var'ehbinntier2familyperpersonmoop,"pergroup","",.)
	destring `var'ehbinntier2familyperpersonmoop, replace
	replace `var'ehbinntier2familypergroupmoop = "" if strpos(`var'ehbinntier2familypergroupmoop, "Not Applicable")
	replace `var'ehbinntier2familypergroupmoop = "" if strpos(`var'ehbinntier2familypergroupmoop, "not applicable")
	replace `var'ehbinntier2familypergroupmoop = subinstr(`var'ehbinntier2familypergroupmoop," ","",.)
	replace `var'ehbinntier2familypergroupmoop = subinstr(`var'ehbinntier2familypergroupmoop,"$","",.)
	replace `var'ehbinntier2familypergroupmoop = subinstr(`var'ehbinntier2familypergroupmoop,",","",.)
	replace `var'ehbinntier2familypergroupmoop = subinstr(`var'ehbinntier2familypergroupmoop,"perperson","",.)
	replace `var'ehbinntier2familypergroupmoop = subinstr(`var'ehbinntier2familypergroupmoop,"pergroup","",.)
	destring `var'ehbinntier2familypergroupmoop, replace
	replace `var'ehboutofnetindividualmoop = "" if strpos(`var'ehboutofnetindividualmoop, "Not Applicable")
	replace `var'ehboutofnetindividualmoop = "" if strpos(`var'ehboutofnetindividualmoop, "not applicable")
	replace `var'ehboutofnetindividualmoop = subinstr(`var'ehboutofnetindividualmoop," ","",.)
	replace `var'ehboutofnetindividualmoop = subinstr(`var'ehboutofnetindividualmoop,"$","",.)
	replace `var'ehboutofnetindividualmoop = subinstr(`var'ehboutofnetindividualmoop,",","",.)
	replace `var'ehboutofnetindividualmoop = subinstr(`var'ehboutofnetindividualmoop,"perperson","",.)
	replace `var'ehboutofnetindividualmoop = subinstr(`var'ehboutofnetindividualmoop,"pergroup","",.)
	destring `var'ehboutofnetindividualmoop, replace
	replace `var'ehboutofnetfamilyperpersonmoop = "" if strpos(`var'ehboutofnetfamilyperpersonmoop, "Not Applicable")
	replace `var'ehboutofnetfamilyperpersonmoop = "" if strpos(`var'ehboutofnetfamilyperpersonmoop, "not applicable")
	replace `var'ehboutofnetfamilyperpersonmoop = subinstr(`var'ehboutofnetfamilyperpersonmoop," ","",.)
	replace `var'ehboutofnetfamilyperpersonmoop = subinstr(`var'ehboutofnetfamilyperpersonmoop,"$","",.)
	replace `var'ehboutofnetfamilyperpersonmoop = subinstr(`var'ehboutofnetfamilyperpersonmoop,",","",.)
	replace `var'ehboutofnetfamilyperpersonmoop = subinstr(`var'ehboutofnetfamilyperpersonmoop,"perperson","",.)
	replace `var'ehboutofnetfamilyperpersonmoop = subinstr(`var'ehboutofnetfamilyperpersonmoop,"pergroup","",.)
	destring `var'ehboutofnetfamilyperpersonmoop, replace
	replace `var'ehboutofnetfamilypergroupmoop = "" if strpos(`var'ehboutofnetfamilypergroupmoop, "Not Applicable")
	replace `var'ehboutofnetfamilypergroupmoop = "" if strpos(`var'ehboutofnetfamilypergroupmoop, "not applicable")
	replace `var'ehboutofnetfamilypergroupmoop = subinstr(`var'ehboutofnetfamilypergroupmoop," ","",.)
	replace `var'ehboutofnetfamilypergroupmoop = subinstr(`var'ehboutofnetfamilypergroupmoop,"$","",.)
	replace `var'ehboutofnetfamilypergroupmoop = subinstr(`var'ehboutofnetfamilypergroupmoop,",","",.)
	replace `var'ehboutofnetfamilypergroupmoop = subinstr(`var'ehboutofnetfamilypergroupmoop,"perperson","",.)
	replace `var'ehboutofnetfamilypergroupmoop = subinstr(`var'ehboutofnetfamilypergroupmoop,"pergroup","",.)
	destring `var'ehboutofnetfamilypergroupmoop, replace
	replace `var'ehbcombinnoonindividualmoop = "" if strpos(`var'ehbcombinnoonindividualmoop, "Not Applicable")
	replace `var'ehbcombinnoonindividualmoop = "" if strpos(`var'ehbcombinnoonindividualmoop, "not applicable")
	replace `var'ehbcombinnoonindividualmoop = subinstr(`var'ehbcombinnoonindividualmoop," ","",.)
	replace `var'ehbcombinnoonindividualmoop = subinstr(`var'ehbcombinnoonindividualmoop,"$","",.)
	replace `var'ehbcombinnoonindividualmoop = subinstr(`var'ehbcombinnoonindividualmoop,",","",.)
	replace `var'ehbcombinnoonindividualmoop = subinstr(`var'ehbcombinnoonindividualmoop,"perperson","",.)
	replace `var'ehbcombinnoonindividualmoop = subinstr(`var'ehbcombinnoonindividualmoop,"pergroup","",.)
	destring `var'ehbcombinnoonindividualmoop, replace
	replace `var'ehbcombinnoonfamilyperpersonmoo = "" if strpos(`var'ehbcombinnoonfamilyperpersonmoo, "Not Applicable")
	replace `var'ehbcombinnoonfamilyperpersonmoo = "" if strpos(`var'ehbcombinnoonfamilyperpersonmoo, "not applicable")
	replace `var'ehbcombinnoonfamilyperpersonmoo = subinstr(`var'ehbcombinnoonfamilyperpersonmoo," ","",.)
	replace `var'ehbcombinnoonfamilyperpersonmoo = subinstr(`var'ehbcombinnoonfamilyperpersonmoo,"$","",.)
	replace `var'ehbcombinnoonfamilyperpersonmoo = subinstr(`var'ehbcombinnoonfamilyperpersonmoo,",","",.)
	replace `var'ehbcombinnoonfamilyperpersonmoo = subinstr(`var'ehbcombinnoonfamilyperpersonmoo,"perperson","",.)
	replace `var'ehbcombinnoonfamilyperpersonmoo = subinstr(`var'ehbcombinnoonfamilyperpersonmoo,"pergroup","",.)
	destring `var'ehbcombinnoonfamilyperpersonmoo, replace
	replace `var'ehbcombinnoonfamilypergroupmoop = "" if strpos(`var'ehbcombinnoonfamilypergroupmoop, "Not Applicable")
	replace `var'ehbcombinnoonfamilypergroupmoop = "" if strpos(`var'ehbcombinnoonfamilypergroupmoop, "not applicable")
	replace `var'ehbcombinnoonfamilypergroupmoop = subinstr(`var'ehbcombinnoonfamilypergroupmoop," ","",.)
	replace `var'ehbcombinnoonfamilypergroupmoop = subinstr(`var'ehbcombinnoonfamilypergroupmoop,"$","",.)
	replace `var'ehbcombinnoonfamilypergroupmoop = subinstr(`var'ehbcombinnoonfamilypergroupmoop,",","",.)
	replace `var'ehbcombinnoonfamilypergroupmoop = subinstr(`var'ehbcombinnoonfamilypergroupmoop,"perperson","",.)
	replace `var'ehbcombinnoonfamilypergroupmoop = subinstr(`var'ehbcombinnoonfamilypergroupmoop,"pergroup","",.)
	destring `var'ehbcombinnoonfamilypergroupmoop, replace
	replace `var'ehbdedinntier1individual = "" if strpos(`var'ehbdedinntier1individual, "Not Applicable")
	replace `var'ehbdedinntier1individual = "" if strpos(`var'ehbdedinntier1individual, "not applicable")
	replace `var'ehbdedinntier1individual = subinstr(`var'ehbdedinntier1individual," ","",.)
	replace `var'ehbdedinntier1individual = subinstr(`var'ehbdedinntier1individual,"$","",.)
	replace `var'ehbdedinntier1individual = subinstr(`var'ehbdedinntier1individual,",","",.)
	replace `var'ehbdedinntier1individual = subinstr(`var'ehbdedinntier1individual,"perperson","",.)
	replace `var'ehbdedinntier1individual = subinstr(`var'ehbdedinntier1individual,"pergroup","",.)
	destring `var'ehbdedinntier1individual, replace
	replace `var'ehbdedinntier1familyperperson = "" if strpos(`var'ehbdedinntier1familyperperson, "Not Applicable")
	replace `var'ehbdedinntier1familyperperson = "" if strpos(`var'ehbdedinntier1familyperperson, "not applicable")
	replace `var'ehbdedinntier1familyperperson = subinstr(`var'ehbdedinntier1familyperperson," ","",.)
	replace `var'ehbdedinntier1familyperperson = subinstr(`var'ehbdedinntier1familyperperson,"$","",.)
	replace `var'ehbdedinntier1familyperperson = subinstr(`var'ehbdedinntier1familyperperson,",","",.)
	replace `var'ehbdedinntier1familyperperson = subinstr(`var'ehbdedinntier1familyperperson,"perperson","",.)
	replace `var'ehbdedinntier1familyperperson = subinstr(`var'ehbdedinntier1familyperperson,"pergroup","",.)
	destring `var'ehbdedinntier1familyperperson, replace
	replace `var'ehbdedinntier1familypergroup = "" if strpos(`var'ehbdedinntier1familypergroup, "Not Applicable")
	replace `var'ehbdedinntier1familypergroup = "" if strpos(`var'ehbdedinntier1familypergroup, "not applicable")
	replace `var'ehbdedinntier1familypergroup = subinstr(`var'ehbdedinntier1familypergroup," ","",.)
	replace `var'ehbdedinntier1familypergroup = subinstr(`var'ehbdedinntier1familypergroup,"$","",.)
	replace `var'ehbdedinntier1familypergroup = subinstr(`var'ehbdedinntier1familypergroup,",","",.)
	replace `var'ehbdedinntier1familypergroup = subinstr(`var'ehbdedinntier1familypergroup,"perperson","",.)
	replace `var'ehbdedinntier1familypergroup = subinstr(`var'ehbdedinntier1familypergroup,"pergroup","",.)
	destring `var'ehbdedinntier1familypergroup, replace
	replace `var'ehbdedinntier1coinsurance = "" if strpos(`var'ehbdedinntier1coinsurance, "Not Applicable")
	replace `var'ehbdedinntier1coinsurance = "" if strpos(`var'ehbdedinntier1coinsurance, "not applicable")
	replace `var'ehbdedinntier1coinsurance = subinstr(`var'ehbdedinntier1coinsurance," ","",.)
	replace `var'ehbdedinntier1coinsurance = subinstr(`var'ehbdedinntier1coinsurance,"$","",.)
	replace `var'ehbdedinntier1coinsurance = subinstr(`var'ehbdedinntier1coinsurance,",","",.)
	replace `var'ehbdedinntier1coinsurance = subinstr(`var'ehbdedinntier1coinsurance,"perperson","",.)
	replace `var'ehbdedinntier1coinsurance = subinstr(`var'ehbdedinntier1coinsurance,"pergroup","",.)
	destring `var'ehbdedinntier1coinsurance, replace
	replace `var'ehbdedinntier2individual = "" if strpos(`var'ehbdedinntier2individual, "Not Applicable")
	replace `var'ehbdedinntier2individual = "" if strpos(`var'ehbdedinntier2individual, "not applicable")
	replace `var'ehbdedinntier2individual = subinstr(`var'ehbdedinntier2individual," ","",.)
	replace `var'ehbdedinntier2individual = subinstr(`var'ehbdedinntier2individual,"$","",.)
	replace `var'ehbdedinntier2individual = subinstr(`var'ehbdedinntier2individual,",","",.)
	replace `var'ehbdedinntier2individual = subinstr(`var'ehbdedinntier2individual,"perperson","",.)
	replace `var'ehbdedinntier2individual = subinstr(`var'ehbdedinntier2individual,"pergroup","",.)
	destring `var'ehbdedinntier2individual, replace
	replace `var'ehbdedinntier2familyperperson = "" if strpos(`var'ehbdedinntier2familyperperson, "Not Applicable")
	replace `var'ehbdedinntier2familyperperson = "" if strpos(`var'ehbdedinntier2familyperperson, "not applicable")
	replace `var'ehbdedinntier2familyperperson = subinstr(`var'ehbdedinntier2familyperperson," ","",.)
	replace `var'ehbdedinntier2familyperperson = subinstr(`var'ehbdedinntier2familyperperson,"$","",.)
	replace `var'ehbdedinntier2familyperperson = subinstr(`var'ehbdedinntier2familyperperson,",","",.)
	replace `var'ehbdedinntier2familyperperson = subinstr(`var'ehbdedinntier2familyperperson,"perperson","",.)
	replace `var'ehbdedinntier2familyperperson = subinstr(`var'ehbdedinntier2familyperperson,"pergroup","",.)
	destring `var'ehbdedinntier2familyperperson, replace
	replace `var'ehbdedinntier2familypergroup = "" if strpos(`var'ehbdedinntier2familypergroup, "Not Applicable")
	replace `var'ehbdedinntier2familypergroup = "" if strpos(`var'ehbdedinntier2familypergroup, "not applicable")
	replace `var'ehbdedinntier2familypergroup = subinstr(`var'ehbdedinntier2familypergroup," ","",.)
	replace `var'ehbdedinntier2familypergroup = subinstr(`var'ehbdedinntier2familypergroup,"$","",.)
	replace `var'ehbdedinntier2familypergroup = subinstr(`var'ehbdedinntier2familypergroup,",","",.)
	replace `var'ehbdedinntier2familypergroup = subinstr(`var'ehbdedinntier2familypergroup,"perperson","",.)
	replace `var'ehbdedinntier2familypergroup = subinstr(`var'ehbdedinntier2familypergroup,"pergroup","",.)
	destring `var'ehbdedinntier2familypergroup, replace
	replace `var'ehbdedinntier2coinsurance = "" if strpos(`var'ehbdedinntier2coinsurance, "Not Applicable")
	replace `var'ehbdedinntier2coinsurance = "" if strpos(`var'ehbdedinntier2coinsurance, "not applicable")
	replace `var'ehbdedinntier2coinsurance = subinstr(`var'ehbdedinntier2coinsurance," ","",.)
	replace `var'ehbdedinntier2coinsurance = subinstr(`var'ehbdedinntier2coinsurance,"$","",.)
	replace `var'ehbdedinntier2coinsurance = subinstr(`var'ehbdedinntier2coinsurance,",","",.)
	replace `var'ehbdedinntier2coinsurance = subinstr(`var'ehbdedinntier2coinsurance,"perperson","",.)
	replace `var'ehbdedinntier2coinsurance = subinstr(`var'ehbdedinntier2coinsurance,"pergroup","",.)
	destring `var'ehbdedinntier2coinsurance, replace
	replace `var'ehbdedoutofnetindividual = "" if strpos(`var'ehbdedoutofnetindividual, "Not Applicable")
	replace `var'ehbdedoutofnetindividual = "" if strpos(`var'ehbdedoutofnetindividual, "not applicable")
	replace `var'ehbdedoutofnetindividual = subinstr(`var'ehbdedoutofnetindividual," ","",.)
	replace `var'ehbdedoutofnetindividual = subinstr(`var'ehbdedoutofnetindividual,"$","",.)
	replace `var'ehbdedoutofnetindividual = subinstr(`var'ehbdedoutofnetindividual,",","",.)
	replace `var'ehbdedoutofnetindividual = subinstr(`var'ehbdedoutofnetindividual,"perperson","",.)
	replace `var'ehbdedoutofnetindividual = subinstr(`var'ehbdedoutofnetindividual,"pergroup","",.)
	destring `var'ehbdedoutofnetindividual, replace
	replace `var'ehbdedoutofnetfamilyperperson = "" if strpos(`var'ehbdedoutofnetfamilyperperson, "Not Applicable")
	replace `var'ehbdedoutofnetfamilyperperson = "" if strpos(`var'ehbdedoutofnetfamilyperperson, "not applicable")
	replace `var'ehbdedoutofnetfamilyperperson = subinstr(`var'ehbdedoutofnetfamilyperperson," ","",.)
	replace `var'ehbdedoutofnetfamilyperperson = subinstr(`var'ehbdedoutofnetfamilyperperson,"$","",.)
	replace `var'ehbdedoutofnetfamilyperperson = subinstr(`var'ehbdedoutofnetfamilyperperson,",","",.)
	replace `var'ehbdedoutofnetfamilyperperson = subinstr(`var'ehbdedoutofnetfamilyperperson,"perperson","",.)
	replace `var'ehbdedoutofnetfamilyperperson = subinstr(`var'ehbdedoutofnetfamilyperperson,"pergroup","",.)
	destring `var'ehbdedoutofnetfamilyperperson, replace
	replace `var'ehbdedoutofnetfamilypergroup = "" if strpos(`var'ehbdedoutofnetfamilypergroup, "Not Applicable")
	replace `var'ehbdedoutofnetfamilypergroup = "" if strpos(`var'ehbdedoutofnetfamilypergroup, "not applicable")
	replace `var'ehbdedoutofnetfamilypergroup = subinstr(`var'ehbdedoutofnetfamilypergroup," ","",.)
	replace `var'ehbdedoutofnetfamilypergroup = subinstr(`var'ehbdedoutofnetfamilypergroup,"$","",.)
	replace `var'ehbdedoutofnetfamilypergroup = subinstr(`var'ehbdedoutofnetfamilypergroup,",","",.)
	replace `var'ehbdedoutofnetfamilypergroup = subinstr(`var'ehbdedoutofnetfamilypergroup,"perperson","",.)
	replace `var'ehbdedoutofnetfamilypergroup = subinstr(`var'ehbdedoutofnetfamilypergroup,"pergroup","",.)
	destring `var'ehbdedoutofnetfamilypergroup, replace
	replace `var'ehbdedcombinnoonindividual = "" if strpos(`var'ehbdedcombinnoonindividual, "Not Applicable")
	replace `var'ehbdedcombinnoonindividual = "" if strpos(`var'ehbdedcombinnoonindividual, "not applicable")
	replace `var'ehbdedcombinnoonindividual = subinstr(`var'ehbdedcombinnoonindividual," ","",.)
	replace `var'ehbdedcombinnoonindividual = subinstr(`var'ehbdedcombinnoonindividual,"$","",.)
	replace `var'ehbdedcombinnoonindividual = subinstr(`var'ehbdedcombinnoonindividual,",","",.)
	replace `var'ehbdedcombinnoonindividual = subinstr(`var'ehbdedcombinnoonindividual,"perperson","",.)
	replace `var'ehbdedcombinnoonindividual = subinstr(`var'ehbdedcombinnoonindividual,"pergroup","",.)
	destring `var'ehbdedcombinnoonindividual, replace
	replace `var'ehbdedcombinnoonfamilyperperson = "" if strpos(`var'ehbdedcombinnoonfamilyperperson, "Not Applicable")
	replace `var'ehbdedcombinnoonfamilyperperson = "" if strpos(`var'ehbdedcombinnoonfamilyperperson, "not applicable")
	replace `var'ehbdedcombinnoonfamilyperperson = subinstr(`var'ehbdedcombinnoonfamilyperperson," ","",.)
	replace `var'ehbdedcombinnoonfamilyperperson = subinstr(`var'ehbdedcombinnoonfamilyperperson,"$","",.)
	replace `var'ehbdedcombinnoonfamilyperperson = subinstr(`var'ehbdedcombinnoonfamilyperperson,",","",.)
	replace `var'ehbdedcombinnoonfamilyperperson = subinstr(`var'ehbdedcombinnoonfamilyperperson,"perperson","",.)
	replace `var'ehbdedcombinnoonfamilyperperson = subinstr(`var'ehbdedcombinnoonfamilyperperson,"pergroup","",.)
	destring `var'ehbdedcombinnoonfamilyperperson, replace
	replace `var'ehbdedcombinnoonfamilypergroup = "" if strpos(`var'ehbdedcombinnoonfamilypergroup, "Not Applicable")
	replace `var'ehbdedcombinnoonfamilypergroup = "" if strpos(`var'ehbdedcombinnoonfamilypergroup, "not applicable")
	replace `var'ehbdedcombinnoonfamilypergroup = subinstr(`var'ehbdedcombinnoonfamilypergroup," ","",.)
	replace `var'ehbdedcombinnoonfamilypergroup = subinstr(`var'ehbdedcombinnoonfamilypergroup,"$","",.)
	replace `var'ehbdedcombinnoonfamilypergroup = subinstr(`var'ehbdedcombinnoonfamilypergroup,",","",.)
	replace `var'ehbdedcombinnoonfamilypergroup = subinstr(`var'ehbdedcombinnoonfamilypergroup,"perperson","",.)
	replace `var'ehbdedcombinnoonfamilypergroup = subinstr(`var'ehbdedcombinnoonfamilypergroup,"pergroup","",.)
	destring `var'ehbdedcombinnoonfamilypergroup, replace
}

// Is HSA Eligible
replace ishsaeligible = "0" if ishsaeligible == "No"
replace ishsaeligible = "1" if ishsaeligible == "Yes"
destring ishsaeligible, replace

save $output/plan_attributes_readible.dta, replace
log close
