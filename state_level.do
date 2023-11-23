capture log close
log using "/Users/shuhuisun/Desktop/Y1S1/econometrics-M.R./state_level"
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

// Import Data
use $output/plan_attributes_readible.dta

// create state level variables
gen state_ppo=0
gen state_hmo=0
gen state_pos=0
gen state_epo=0
gen state_platinum=0
gen state_gold=0
gen state_silver=0
gen state_bronze=0
gen state_catastrophic=0
gen state_pregnancy_notice=0
gen state_prior_auth_spec=0
gen state_wellness=0
gen state_asthma=0
gen state_heartdisease=0
gen state_depression=0
gen state_diabetes=0
gen state_hbd_hc=0
gen state_lowerbackpain=0
gen state_painmanagement=0
gen state_pregnency=0
gen state_weightlossprograms=0
gen state_outofcountry=0
gen state_outofservice=0
gen state_nationalnetwork=0
gen state_av=0
gen state_mult_net_tiers=0
gen state_firsttierutil=0
gen state_secondtierutil=0
local cons = "baby diabetes frac"
local ins = "deduct copay coin lim"
foreach con in `cons' {
	foreach i in `ins' {
		gen state_`con'`i' = 0
	}
}
gen state_specdrugmaxcoin=0
gen state_begprimcostshare=0
gen state_begprimdeduct=0


local vars = "m d t"
foreach var in `vars' {
	gen st`var'inntier1individualmoop=0
	gen st`var'inntier1familyperpersonmoop=0
	gen st`var'inntier1familypergroupmoop=0
	gen st`var'inntier2individualmoop=0
	gen st`var'inntier2familyperpersonmoop=0
	gen st`var'inntier2familypergroupmoop=0
	gen st`var'outofnetindividualmoop=0
	gen st`var'outofnetfamilyperpersonmoop=0
	gen st`var'outofnetfamilypergroupmoop=0
	gen st`var'combinnoonindividualmoop=0
	gen st`var'combinnoonfamilyperpersonmoo=0
	gen st`var'combinnoonfamilypergroupmoop=0
	gen st`var'dedinntier1individual=0
	gen st`var'dedinntier1familyperperson=0
	gen st`var'dedinntier1familypergroup=0
	gen st`var'dedinntier1coinsurance=0
	gen st`var'dedinntier2individual=0
	gen st`var'dedinntier2familyperperson=0
	gen st`var'dedinntier2familypergroup=0
	gen st`var'dedinntier2coinsurance=0
	gen st`var'dedoutofnetindividual=0
	gen st`var'dedoutofnetfamilyperperson=0
	gen st`var'dedoutofnetfamilypergroup=0
	gen st`var'dedcombinnoonindividual=0
	gen st`var'dedcombinnoonfamilyperperson=0
	gen st`var'dedcombinnoonfamilypergroup=0
}
gen state_hsa=0

// Create state code local variables
egen stategroup = group(statecode)
qui sum stategroup
local statemax = r(max)
bys statecode: gen st_policycount = _N

// Create state means
forval s = 1/`statemax' {
	qui su ppo if stategroup == `s'
	replace state_ppo = r(mean) if stategroup == `s'
	qui su hmo if stategroup == `s'
	replace state_hmo = r(mean) if stategroup == `s'
	qui su pos if stategroup == `s'
	replace state_pos = r(mean) if stategroup == `s'
	qui su epo if stategroup == `s'
	replace state_epo = r(mean) if stategroup == `s'
	qui su platinum if stategroup == `s'
	replace state_platinum = r(mean) if stategroup == `s'
	qui su gold if stategroup == `s'
	replace state_gold = r(mean) if stategroup == `s'
	qui su silver if stategroup == `s'
	replace state_silver = r(mean) if stategroup == `s'
	qui su bronze if stategroup == `s'
	replace state_bronze = r(mean) if stategroup == `s'
	qui su catastrophic if stategroup == `s'
	replace state_catastrophic = r(mean) if stategroup == `s'
	qui su isnoticerequiredforpregnancy if stategroup == `s'
	replace state_pregnancy_notice = r(mean) if stategroup == `s'
	qui su isreferralrequiredforspecialist if stategroup == `s'
	replace state_prior_auth_spec = r(mean) if stategroup == `s'
	qui su wellnessprogramoffered if stategroup == `s'
	replace state_wellness = r(mean) if stategroup == `s'
	qui su asthma if stategroup == `s'
	replace state_asthma = r(mean) if stategroup == `s'
	qui su heartdisease if stategroup == `s'
	replace state_heartdisease = r(mean) if stategroup == `s'
	qui su depression if stategroup == `s'
	replace state_depression = r(mean) if stategroup == `s'
	qui su diabetes if stategroup == `s'
	replace state_diabetes = r(mean) if stategroup == `s'
	qui su hbd_hc if stategroup == `s'
	replace state_hbd_hc = r(mean) if stategroup == `s'
	qui su lowerbackpain if stategroup == `s'
	replace state_lowerbackpain = r(mean) if stategroup == `s'
	qui su painmanagement if stategroup == `s'
	replace state_painmanagement = r(mean) if stategroup == `s'
	qui su pregnancy if stategroup == `s'
	replace state_pregnancy = r(mean) if stategroup == `s'
	qui su weightlossprograms if stategroup == `s'
	replace state_weightlossprograms = r(mean) if stategroup == `s'
	qui su outofcountrycoverage if stategroup == `s'
	replace state_outofcountry = r(mean) if stategroup == `s'
	qui su outofserviceareacoverage if stategroup == `s'
	replace state_outofservice = r(mean) if stategroup == `s'
	qui su nationalnetwork if stategroup == `s'
	replace state_nationalnetwork = r(mean) if stategroup == `s'
	qui su avcalculatoroutputnumber if stategroup == `s'
	replace state_av = r(mean) if stategroup == `s'
	qui su multipleinnetworktiers if stategroup == `s'
	replace state_mult_net_tiers = r(mean) if stategroup == `s'
	qui su firsttierutilization if stategroup == `s'
	replace state_firsttierutil = r(mean) if stategroup == `s'
	qui su secondtierutilization if stategroup == `s'
	replace state_secondtierutil = r(mean) if stategroup == `s'
	foreach con in `cons' {
		foreach i in `ins' {
			qui su sbchaving`con'`i' if stategroup== `s'
			replace state_`con'`i' = r(mean) if stategroup== `s'
		}
}
	qui su specialtydrugmaximumcoinsurance if stategroup == `s'
	replace state_specdrugmaxcoin = r(mean) if stategroup == `s'
	qui su beginprimarycarecostsharingafter if stategroup == `s'
	replace state_begprimcostshare = r(mean) if stategroup == `s'
	qui su beginprimarycaredeductiblecoinsu if stategroup == `s'
	replace state_begprimdeduct = r(mean) if stategroup == `s'
	local vars = "m d t"
	foreach var in `vars' {
		qui su `var'ehbinntier1individualmoop if stategroup == `s'
		replace st`var'inntier1individualmoop=r(mean) if stategroup == `s'
		qui su `var'ehbinntier1familyperpersonmoop if stategroup == `s'
		replace st`var'inntier1familyperpersonmoop=r(mean) if stategroup == `s'
		qui su `var'ehbinntier1familypergroupmoop if stategroup == `s'
		replace st`var'inntier1familypergroupmoop=r(mean) if stategroup == `s'
		qui su `var'ehbinntier2individualmoop if stategroup == `s'
		replace st`var'inntier2individualmoop=r(mean) if stategroup == `s'
		qui su `var'ehbinntier2familyperpersonmoop if stategroup == `s'
		replace st`var'inntier2familyperpersonmoop=r(mean) if stategroup == `s'
		qui su `var'ehbinntier2familypergroupmoop if stategroup == `s'
		replace st`var'inntier2familypergroupmoop=r(mean) if stategroup == `s'
		qui su `var'ehboutofnetindividualmoop if stategroup == `s'
		replace st`var'outofnetindividualmoop=r(mean) if stategroup == `s'
		qui su `var'ehboutofnetfamilyperpersonmoop if stategroup == `s'
		replace st`var'outofnetfamilyperpersonmoop=r(mean) if stategroup == `s'
		qui su `var'ehboutofnetfamilypergroupmoop if stategroup == `s'
		replace st`var'outofnetfamilypergroupmoop=r(mean) if stategroup == `s'
		qui su `var'ehbcombinnoonindividualmoop if stategroup == `s'
		replace st`var'combinnoonindividualmoop=r(mean) if stategroup == `s'
		qui su `var'ehbcombinnoonfamilyperpersonmoo if stategroup == `s'
		replace st`var'combinnoonfamilyperpersonmoo=r(mean) if stategroup == `s'
		qui su `var'ehbcombinnoonfamilypergroupmoop if stategroup == `s'
		replace st`var'combinnoonfamilypergroupmoop=r(mean) if stategroup == `s'
		qui su `var'ehbdedinntier1individual if stategroup == `s'
		replace st`var'dedinntier1individual=r(mean) if stategroup == `s'
		qui su `var'ehbdedinntier1familyperperson if stategroup == `s'
		replace st`var'dedinntier1familyperperson=r(mean) if stategroup == `s'
		qui su `var'ehbdedinntier1familypergroup if stategroup == `s'
		replace st`var'dedinntier1familypergroup=r(mean) if stategroup == `s'
		qui su `var'ehbdedinntier1coinsurance if stategroup == `s'
		replace st`var'dedinntier1coinsurance=r(mean) if stategroup == `s'
		qui su `var'ehbdedinntier2individual if stategroup == `s'
		replace st`var'dedinntier2individual=r(mean) if stategroup == `s'
		qui su `var'ehbdedinntier2familyperperson if stategroup == `s'
		replace st`var'dedinntier2familyperperson=r(mean) if stategroup == `s'
		qui su `var'ehbdedinntier2familypergroup if stategroup == `s'
		replace st`var'dedinntier2familypergroup=r(mean) if stategroup == `s'
		qui su `var'ehbdedinntier2coinsurance if stategroup == `s'
		replace st`var'dedinntier2coinsurance=r(mean) if stategroup == `s'
		qui su `var'ehbdedoutofnetindividual if stategroup == `s'
		replace st`var'dedoutofnetindividual=r(mean) if stategroup == `s'
		qui su `var'ehbdedoutofnetfamilyperperson if stategroup == `s'
		replace st`var'dedoutofnetfamilyperperson=r(mean) if stategroup == `s'
		qui su `var'ehbdedoutofnetfamilypergroup if stategroup == `s'
		replace st`var'dedoutofnetfamilypergroup=r(mean) if stategroup == `s'
		qui su `var'ehbdedcombinnoonindividual if stategroup == `s'
		replace st`var'dedcombinnoonindividual=r(mean) if stategroup == `s'
		qui su `var'ehbdedcombinnoonfamilyperperson if stategroup == `s'
		replace st`var'dedcombinnoonfamilyperperson=r(mean) if stategroup == `s'
		qui su `var'ehbdedcombinnoonfamilypergroup if stategroup == `s'
		replace st`var'dedcombinnoonfamilypergroup=r(mean) if stategroup == `s'
	}
	qui su ishsaeligible if stategroup == `s'
	replace state_hsa = r(max) if stategroup == `s'
}

keep state* st*
drop standard*
bys statecode: keep if _n==1

save $output/state_level.dta, replace
log close
